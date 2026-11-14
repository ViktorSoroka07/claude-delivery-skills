#!/usr/bin/env python3
"""A GitHub and Azure DevOps stand-in for post-review.py's suite.

Installed on PATH as `gh` and `curl` shims that exec this file with the tool's
name first. Every call loads the request model from $FAKE_FORGE_DIR/model.json,
answers the way the forge's references describe, saves the model, and appends
the argument list and payload file to calls.jsonl, never standard input or the
environment.
"""

import json
import os
import re
import subprocess
import sys
import urllib.parse

ADO_HOST = "dev.azure.com"
SIGN_IN_PAGE = "<html><head><title>Sign in to your account</title></head><body>Sign in</body></html>"
TAG = re.compile(r"<[A-Za-z][A-Za-z0-9]*>")
HUNK = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@")


class Answer:
    def __init__(self, status, body, content_type="application/json; charset=utf-8", headers=None):
        self.status = status
        self.body = body
        self.content_type = content_type
        self.headers = headers or {}


def json_answer(status, data, headers=None):
    return Answer(status, json.dumps(data), headers=headers)


def raw_json_string(text):
    """A JSON string literal as a careless server writes one: quotes escaped,
    backslashes and control characters left raw."""
    return '"' + text.replace('"', '\\"') + '"'


def malformed_echo(data, body):
    """Serialise `data` with its `body` string echoed raw where json.dumps would escape it."""
    return json.dumps(data).replace(json.dumps(body), raw_json_string(body), 1)


# --- the model --------------------------------------------------------------


def model_dir():
    return os.environ["FAKE_FORGE_DIR"]


def load_model():
    with open(os.path.join(model_dir(), "model.json"), encoding="utf-8") as f:
        return json.load(f)


def save_model(model):
    path = os.path.join(model_dir(), "model.json")
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(model, f, indent=1)
    os.replace(tmp, path)


def log_call(tool, argv, payload_file):
    payload = None
    if payload_file:
        try:
            with open(payload_file, encoding="utf-8") as f:
                payload = f.read()
        except OSError:
            payload = None
    entry = {"tool": tool, "argv": argv, "payload": payload}
    with open(os.path.join(model_dir(), "calls.jsonl"), "a", encoding="utf-8") as f:
        f.write(json.dumps(entry) + "\n")


def next_id(model):
    model["next_id"] += 1
    return model["next_id"]


def git(model, *args):
    env = dict(os.environ, GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_NOSYSTEM="1")
    return subprocess.run(["git", "-C", model["git_dir"], *args], capture_output=True,
                          env=env, check=True).stdout.decode("utf-8")


def diff_model(model):
    """{path: {"changed": set of right-side lines, "position": {line: position}}},
    parsed from git's unified diff between the merge base and the head."""
    merge_base = git(model, "merge-base", model["base"], model["head"]).strip()
    text = git(model, "diff", "-U3", "--no-color", "--no-ext-diff", "--src-prefix=a/",
               "--dst-prefix=b/", merge_base, model["head"])
    files = {}
    current = None
    position = None
    line = 0
    for row in text.split("\n"):
        if row.startswith("diff --git "):
            current = None
            position = None
            continue
        if position is None and row.startswith("+++ "):
            name = row[4:]
            current = files.setdefault(name[2:] if name.startswith("b/") else name,
                                       {"changed": set(), "position": {}})
            continue
        if position is None and row.startswith("--- "):
            name = row[4:]
            if name.startswith("a/"):
                files.setdefault(name[2:], {"changed": set(), "position": {}})
            continue
        hunk = HUNK.match(row)
        if hunk and current is not None:
            line = int(hunk.group(1))
            position = 0 if position is None else position + 1
            continue
        if position is None or current is None or not row:
            continue
        if row.startswith("\\"):
            continue
        position += 1
        if row[0] == "+":
            current["changed"].add(line)
            current["position"][line] = position
            line += 1
        elif row[0] == " ":
            current["position"][line] = position
            line += 1
    return files


def fault(model, name):
    return model.get("faults", {}).get(name)


def create_fault(model):
    """The scripted rejection for this create, counted across the run, or None."""
    model["creates"] = model.get("creates", 0) + 1
    reject = fault(model, "reject_create")
    if reject and reject["nth"] == model["creates"]:
        return reject["status"]
    return None


def stored_body(model, body):
    return TAG.sub("", body) if fault(model, "sanitize_tags") else body


def misreported(model, index, line):
    shift = fault(model, "misreport_line")
    if shift and shift["nth"] == index + 1 and line is not None:
        return line + 1
    return line


# --- GitHub -----------------------------------------------------------------


def github_page(items, query, page_size):
    per_page = min(int(query.get("per_page", ["30"])[0]), page_size)
    page = int(query.get("page", ["1"])[0])
    chunk = items[(page - 1) * per_page: page * per_page]
    headers = {}
    if page * per_page < len(items):
        headers["Link"] = '<https://api.github.com/next?page=%d>; rel="next"' % (page + 1)
    return json_answer(200, chunk, headers)


def github_review(model, review):
    return {"id": review["id"], "user": {"login": review["login"]}, "state": review["state"],
            "body": review["body"], "commit_id": review["commit_id"],
            "html_url": "https://github.com/%s/pull/%d#pullrequestreview-%d" % (
                model["repo"], model["number"], review["id"])}


def github_create_review(model, payload_text):
    try:
        payload = json.loads(payload_text)
    except (TypeError, ValueError):
        return json_answer(400, {"message": "Problems parsing JSON"})
    pending = "event" not in payload
    login = model["user"]["login"]
    if pending and any(r["state"] == "PENDING" and r["login"] == login for r in model["reviews"]):
        return json_answer(422, {"message": "Unprocessable Entity",
                                 "errors": ["User can only have one pending review per pull request"]})
    rejected = create_fault(model)
    if rejected:
        return json_answer(rejected, {"message": "Unprocessable Entity"})
    diff = diff_model(model)
    comments = payload.get("comments", [])
    for comment in comments:
        changed = diff.get(comment.get("path"), {}).get("changed", set())
        lines = [comment.get("line"), comment.get("start_line") or comment.get("line")]
        if comment.get("side", "RIGHT") != "RIGHT" or any(n not in changed for n in lines):
            return json_answer(422, {"message": "Unprocessable Entity",
                                     "errors": ["Line could not be resolved"]})
    review = {"id": next_id(model), "login": login, "state": "PENDING" if pending else "COMMENTED",
              "body": stored_body(model, payload.get("body", "")),
              "commit_id": payload.get("commit_id", model["head"])}
    model["reviews"].append(review)
    for comment in comments:
        position = diff[comment["path"]]["position"][comment["line"]]
        model["comments"].append({
            "id": next_id(model), "review_id": review["id"], "path": comment["path"],
            "line": comment["line"], "start_line": comment.get("start_line"),
            "side": comment.get("side", "RIGHT"), "start_side": comment.get("start_side"),
            "body": stored_body(model, comment["body"]), "commit_id": review["commit_id"],
            "position": position, "login": login, "pending": pending})
    reply = github_review(model, review)
    if fault(model, "malformed_reply"):
        return Answer(200, malformed_echo(reply, review["body"]))
    return json_answer(200, reply)


def github_resolved_comment(model, index, comment):
    return {"id": comment["id"], "pull_request_review_id": comment["review_id"],
            "path": comment["path"], "line": misreported(model, index, comment["line"]),
            "start_line": misreported(model, index, comment["start_line"]),
            "side": comment["side"], "start_side": comment["start_side"],
            "body": comment["body"], "commit_id": comment["commit_id"],
            "position": comment["position"], "user": {"login": comment["login"]}}


def github_route(model, method, path, payload_text):
    url = urllib.parse.urlsplit(path.lstrip("/"))
    query = urllib.parse.parse_qs(url.query)
    parts = url.path.split("/")
    if not model.get("gh_authenticated", True):
        return json_answer(401, {"message": "Bad credentials"})
    if parts == ["user"] and method == "GET":
        return json_answer(200, {"login": model["user"]["login"], "id": model["user"]["id"]})
    prefix = ["repos"] + model["repo"].split("/") + ["pulls", str(model["number"])]
    if parts[:len(prefix)] != prefix:
        return json_answer(404, {"message": "Not Found"})
    rest = parts[len(prefix):]
    page_size = model.get("page_size", 100)
    if rest == [] and method == "GET":
        return json_answer(200, {"number": model["number"], "head": {"sha": model["head"]},
                                 "base": {"sha": model["base"]}})
    if rest == ["reviews"] and method == "GET":
        return github_page([github_review(model, r) for r in model["reviews"]], query, page_size)
    if rest == ["reviews"] and method == "POST":
        return github_create_review(model, payload_text)
    if len(rest) >= 2 and rest[0] == "reviews":
        review = next((r for r in model["reviews"] if str(r["id"]) == rest[1]), None)
        if review is None:
            return json_answer(404, {"message": "Not Found"})
        if rest[2:] == [] and method == "GET":
            return json_answer(200, github_review(model, review))
        if rest[2:] == ["comments"] and method == "GET":
            mine = [{"id": c["id"], "pull_request_review_id": c["review_id"], "path": c["path"],
                     "position": c["position"], "original_position": c["position"],
                     "line": None, "side": None, "commit_id": c["commit_id"], "body": c["body"],
                     "user": {"login": c["login"]}}
                    for c in model["comments"] if c["review_id"] == review["id"]]
            return github_page(mine, query, page_size)
    if rest == ["comments"] and method == "GET":
        published = [c for c in model["comments"] if not c["pending"]]
        return github_page([github_resolved_comment(model, i, c) for i, c in enumerate(published)],
                           query, page_size)
    return json_answer(404, {"message": "Not Found"})


def gh_main(model, argv):
    if not argv or argv[0] != "api":
        sys.stderr.write("unknown command %r for \"gh\"\n" % (argv[0] if argv else ""))
        return 1
    method = None
    include = False
    input_file = None
    fields = []
    path = None
    args = argv[1:]
    i = 0
    while i < len(args):
        arg = args[i]
        if arg in ("-i", "--include"):
            include = True
        elif arg in ("-X", "--method", "--input", "-f", "--raw-field", "-F", "--field", "-H", "--header"):
            if i + 1 >= len(args):
                sys.stderr.write("flag needs an argument: %s\n" % arg)
                return 1
            value = args[i + 1]
            i += 1
            if arg in ("-X", "--method"):
                method = value.upper()
            elif arg == "--input":
                input_file = value
            elif arg in ("-f", "--raw-field", "-F", "--field"):
                fields.append(value)
        elif arg.startswith("-"):
            sys.stderr.write("unknown flag: %s\n" % arg)
            return 1
        elif path is None:
            path = arg
        else:
            sys.stderr.write("accepts 1 arg(s), received %d\n" % (len(args)))
            return 1
        i += 1
    if path is None:
        sys.stderr.write("accepts 1 arg(s), received 0\n")
        return 1
    if method is None:
        method = "POST" if fields or input_file else "GET"
    payload_text = None
    if input_file is not None:
        try:
            with open(input_file, encoding="utf-8") as f:
                payload_text = f.read()
        except OSError as e:
            sys.stderr.write("open %s: %s\n" % (input_file, e.strerror))
            return 1
    answer = github_route(model, method, path, payload_text)
    out = []
    if include:
        out.append("HTTP/2.0 %d %s" % (answer.status, "OK" if answer.status < 400 else "Error"))
        headers = dict(answer.headers, **{"Content-Type": answer.content_type})
        out.extend("%s: %s" % (k, v) for k, v in sorted(headers.items()))
        out.append("")
    out.append(answer.body)
    sys.stdout.write("\n".join(out))
    if answer.status >= 400:
        message = "Error"
        try:
            message = json.loads(answer.body).get("message", message)
        except ValueError:
            pass
        sys.stderr.write("gh: %s (HTTP %d)\n" % (message, answer.status))
        return 1
    return 0


# --- Azure DevOps -----------------------------------------------------------


def ado_thread(model, index, thread):
    context = thread["threadContext"]
    if context is not None:
        context = json.loads(json.dumps(context))
        for end in ("rightFileStart", "rightFileEnd"):
            if isinstance(context.get(end), dict):
                context[end]["line"] = misreported(model, index, context[end].get("line"))
    return {"id": thread["id"], "status": thread["status"], "isDeleted": False,
            "threadContext": context,
            "comments": [{"id": 1, "parentCommentId": 0, "content": thread["content"],
                          "commentType": "text", "author": {"id": thread["author"]}}]}


def ado_create_thread(model, payload_text):
    try:
        payload = json.loads(payload_text)
        content = payload["comments"][0]["content"]
    except (TypeError, ValueError, KeyError, IndexError):
        return json_answer(400, {"message": "Value cannot be null.", "typeKey": "ArgumentNullException"})
    rejected = create_fault(model)
    if rejected:
        return json_answer(rejected, {"message": "The request is invalid.",
                                      "typeKey": "InvalidArgumentValueException"})
    thread = {"id": next_id(model), "author": model["user"]["ado_id"],
              "status": "active" if payload.get("status") == 1 else payload.get("status"),
              "threadContext": payload.get("threadContext"), "content": stored_body(model, content)}
    model["threads"].append(thread)
    reply = ado_thread(model, -1, thread)
    if fault(model, "malformed_reply"):
        return Answer(200, malformed_echo(reply, thread["content"]))
    return json_answer(200, reply)


def ado_patch_thread(model, thread_id, payload_text):
    thread = next((t for t in model["threads"] if t["id"] == thread_id), None)
    if thread is None:
        return json_answer(404, {"message": "Thread not found."})
    payload = json.loads(payload_text)
    thread["status"] = payload.get("status")
    return json_answer(200, ado_thread(model, -1, thread))


def ado_route(model, method, url, payload_text):
    parts = urllib.parse.urlsplit(url)
    segments = [urllib.parse.unquote(s).lower() for s in parts.path.strip("/").split("/")]
    if parts.netloc != ADO_HOST:
        return Answer(404, "not found", "text/plain")
    org, project, repo = (s.lower() for s in model["repo"].split("/"))
    if segments == [org, "_apis", "connectiondata"]:
        return json_answer(200, {"authenticatedUser": {"id": model["user"]["ado_id"]}})
    prefix = [org, project, "_apis", "git", "repositories", repo, "pullrequests", str(model["number"])]
    if segments[:len(prefix)] != prefix:
        return json_answer(404, {"message": "The pull request could not be found."})
    rest = segments[len(prefix):]
    if rest == [] and method == "GET":
        return json_answer(200, {"pullRequestId": model["number"],
                                 "lastMergeSourceCommit": {"commitId": model["head"]},
                                 "lastMergeTargetCommit": {"commitId": model["base"]}})
    if rest == ["threads"] and method == "GET":
        threads = [ado_thread(model, i, t) for i, t in enumerate(model["threads"])]
        return json_answer(200, {"value": threads, "count": len(threads)})
    if rest == ["threads"] and method == "POST":
        return ado_create_thread(model, payload_text)
    if len(rest) == 2 and rest[0] == "threads" and method == "PATCH":
        return ado_patch_thread(model, int(rest[1]), payload_text)
    return json_answer(404, {"message": "Not found."})


CURL_VALUE_OPTIONS = {"-X": "request", "--request": "request", "-H": "header", "--header": "header",
                      "--data-binary": "data", "-o": "output", "--output": "output",
                      "-w": "write-out", "--write-out": "write-out", "-m": "max-time",
                      "--max-time": "max-time", "-K": "config", "--config": "config",
                      "-u": "user", "--user": "user"}
CURL_FLAGS = {"-s": "silent", "--silent": "silent", "-S": "show-error", "--show-error": "show-error",
              "-sS": "silent", "-Ss": "silent", "-v": "verbose", "--verbose": "verbose"}


def curl_config_users(text):
    """The `user` values a curl config file sets, unquoted per curl's syntax."""
    users = []
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        match = re.match(r"^(?:--)?([A-Za-z-]+)\s*[=: ]\s*(.*)$", line)
        if not match:
            continue
        key, value = match.group(1), match.group(2)
        if value.startswith('"'):
            value = re.sub(r'\\(.)', lambda m: {"t": "\t", "n": "\n", "r": "\r"}.get(m.group(1), m.group(1)),
                           value[1:value.rindex('"')] if value.count('"') >= 2 else value[1:])
        if key in ("user", "u"):
            users.append(value)
    return users


def curl_main(model, argv, stdin_text):
    opts = {}
    headers = []
    url = None
    i = 0
    while i < len(argv):
        arg = argv[i]
        if arg in CURL_VALUE_OPTIONS:
            if i + 1 >= len(argv):
                sys.stderr.write("curl: option %s: requires parameter\n" % arg)
                return 2
            i += 1
            if CURL_VALUE_OPTIONS[arg] == "header":
                headers.append(argv[i])
            else:
                opts[CURL_VALUE_OPTIONS[arg]] = argv[i]
        elif arg in CURL_FLAGS:
            opts[CURL_FLAGS[arg]] = True
        elif arg.startswith("-"):
            sys.stderr.write("curl: option %s: is unknown\n" % arg)
            return 2
        elif url is None:
            url = arg
        else:
            sys.stderr.write("curl: one URL per call in this stand-in\n")
            return 2
        i += 1
    if url is None:
        sys.stderr.write("curl: no URL specified\n")
        return 2
    method = opts.get("request") or ("POST" if "data" in opts else "GET")
    users = []
    config = opts.get("config")
    if config == "-":
        users += curl_config_users(stdin_text)
    elif config:
        with open(config, encoding="utf-8") as f:
            users += curl_config_users(f.read())
    if "user" in opts:
        users.append(opts["user"])
    payload_text = None
    data = opts.get("data")
    if data is not None:
        if data.startswith("@"):
            try:
                with open(data[1:], encoding="utf-8") as f:
                    payload_text = f.read()
            except OSError:
                sys.stderr.write("curl: Failed to open %s\n" % data[1:])
                return 26
        else:
            payload_text = data
    token = users[-1].split(":", 1)[1] if users and ":" in users[-1] else None
    if token != model["token"]:
        if model.get("auth_failure", 203) == 401:
            answer = Answer(401, "", "text/plain")
        else:
            answer = Answer(203, SIGN_IN_PAGE, "text/html; charset=utf-8")
    else:
        answer = ado_route(model, method.upper(), url, payload_text)
    output = opts.get("output")
    if output:
        with open(output, "w", encoding="utf-8") as f:
            f.write(answer.body)
    else:
        sys.stdout.write(answer.body)
    write_out = opts.get("write-out")
    if write_out:
        sys.stdout.write(write_out.replace("\\n", "\n").replace("%{http_code}", "%03d" % answer.status)
                         .replace("%{content_type}", answer.content_type))
    return 0


def payload_argument(tool, argv):
    flag = "--input" if tool == "gh" else "--data-binary"
    for i, arg in enumerate(argv[:-1]):
        if arg == flag:
            value = argv[i + 1]
            return value[1:] if tool == "curl" and value.startswith("@") else value
    return None


def main(argv):
    tool, args = argv[1], argv[2:]
    log_call(tool, args, payload_argument(tool, args))
    stdin_text = sys.stdin.read() if tool == "curl" and not sys.stdin.isatty() else ""
    model = load_model()
    rc = gh_main(model, args) if tool == "gh" else curl_main(model, args, stdin_text)
    save_model(model)
    return rc


if __name__ == "__main__":
    sys.exit(main(sys.argv))
