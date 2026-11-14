#!/usr/bin/env python3
"""Fixture suite for post-review.py, run against fake_forge.py.

    python3 test_post_review.py

Prints one PASS or FAIL line per named assertion; mutate.py reads those lines.
"""

import concurrent.futures
import glob
import json
import os
import shlex
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
SCRIPT = os.path.join(HERE, "post-review.py")
FORGE = os.path.join(HERE, "fake_forge.py")
ADO_HOST = "dev.azure.com"
SENTINEL = "sentinel-token-not-a-secret"
TOKEN_VAR = "AZURE_DEVOPS_EXT_PAT"

EXPECTED_VOCAB = [
    "MANIFEST-INVALID", "UNSUPPORTED-FORGE", "EMPTY", "NO-FRONTMATTER", "ALREADY-POSTED",
    "POSTED-UNKNOWN", "UNFINISHED-RUN", "NO-TOKEN", "AUTH-REFUSED", "STALE-HEAD", "MISSING-COMMIT",
    "OUT-OF-DIFF", "LINE-OUT-OF-FILE", "OFF-DIFF-LINE", "STALE-SUGGESTION", "SUGGESTION-IN-GROUP",
    "PARTITION", "PENDING-EXISTS", "LANDED", "REJECTED", "UNCERTAIN", "UNVERIFIED", "MISSING",
    "CORRECTED", "MISMATCH", "MISPLACED", "NO-STATE", "SETTLING",
]

# Statuses whose fixtures belong to a later task of the build plan. Each task
# that adds a status's fixture removes it here; the set is empty once the
# script is complete, and from then on any status without a fixture fails.
OWED_BY_LATER_TASKS = {"UNCERTAIN", "UNVERIFIED", "MISSING", "CORRECTED", "NO-STATE", "SETTLING"}

HOSTILE_GIT_CONFIG = """\
[color]
\tui = always
[diff]
\tnoprefix = true
\tcontext = 8
\texternal = false
\trenames = copies
[core]
\tquotePath = true
"""

BUILD_ENV = dict(
    {k: v for k, v in os.environ.items() if k != TOKEN_VAR},
    GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_NOSYSTEM="1",
    GIT_AUTHOR_NAME="tester", GIT_AUTHOR_EMAIL="tester@example.invalid",
    GIT_COMMITTER_NAME="tester", GIT_COMMITTER_EMAIL="tester@example.invalid",
    GIT_AUTHOR_DATE="@1700000000 +0000", GIT_COMMITTER_DATE="@1700000000 +0000",
)

APP_BASE = ["line %02d" % n for n in range(1, 21)]
APP_HEAD = list(APP_BASE)
APP_HEAD[1] = "LINE 02"
APP_HEAD[14:17] = ["LINE 15", "LINE 16", "LINE 17"]
CRLF_BASE = "one\r\ntwo\r\nthree\r\n"
CRLF_HEAD = 'one\r\nsay("\U0001F600")\r\nshout("\U0001F600")\r\n'
GUIDE = "".join("guide %d\n" % n for n in range(1, 6))


def lines_text(lines):
    return "".join(line + "\n" for line in lines)


CREATED = []


# --- the repository every fixture copies -------------------------------------


class Template:
    root = None
    clone = None
    base = None
    head = None
    moved = None


def build_git(cwd, *args):
    return subprocess.run(["git", *args], cwd=cwd, env=BUILD_ENV, capture_output=True,
                          check=True).stdout.decode().strip()


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write(text)


def build_template():
    Template.root = tempfile.mkdtemp(prefix="post-review-template-")
    CREATED.append(Template.root)
    clone = os.path.join(Template.root, "clone")
    os.makedirs(clone)
    build_git(clone, "init", "-q", "-b", "main")
    write(os.path.join(clone, "src/app.py"), lines_text(APP_BASE))
    write(os.path.join(clone, "src/crlf.txt"), CRLF_BASE)
    write(os.path.join(clone, "docs/guide.md"), GUIDE)
    build_git(clone, "add", "-A")
    build_git(clone, "commit", "-qm", "base")
    Template.base = build_git(clone, "rev-parse", "HEAD")
    build_git(clone, "checkout", "-qb", "feature")
    write(os.path.join(clone, "src/app.py"), lines_text(APP_HEAD))
    write(os.path.join(clone, "src/crlf.txt"), CRLF_HEAD)
    build_git(clone, "commit", "-qam", "head")
    Template.head = build_git(clone, "rev-parse", "HEAD")
    write(os.path.join(clone, "src/app.py"), lines_text(APP_HEAD + ["line 21"]))
    build_git(clone, "commit", "-qam", "moved")
    Template.moved = build_git(clone, "rev-parse", "HEAD")
    build_git(clone, "checkout", "-q", Template.head)
    Template.clone = clone


# --- fixtures ----------------------------------------------------------------


def default_model(forge, clone):
    return {
        "repo": "acme/tickets" if forge == "github" else "acme/field ops/tickets",
        "number": 42, "head": Template.head, "base": Template.base, "git_dir": clone,
        "user": {"login": "reviewer", "id": 7, "ado_id": "reviewer-id"},
        "token": SENTINEL, "reviews": [], "comments": [], "threads": [],
        "next_id": 100, "faults": {}, "page_size": 100,
    }


class Fixture:
    def __init__(self, forge="github", threads=None, posted="posted: null", token=SENTINEL):
        self.forge = forge
        self.root = tempfile.mkdtemp(prefix="post-review-test-")
        CREATED.append(self.root)
        self.clone = os.path.join(self.root, "clone")
        shutil.copytree(Template.clone, self.clone, symlinks=True)
        for d in ("bin", "forge", "state", "tmp"):
            os.makedirs(os.path.join(self.root, d))
        python = shlex.quote(sys.executable)
        for tool in ("gh", "curl"):
            write(os.path.join(self.root, "bin", tool),
                  "#!/bin/sh\nexec %s %s %s \"$@\"\n" % (python, shlex.quote(FORGE), tool))
            os.chmod(os.path.join(self.root, "bin", tool), 0o755)
        write(os.path.join(self.root, "hostile.gitconfig"), HOSTILE_GIT_CONFIG)
        self.findings = os.path.join(self.root, "reviews", "r1.md")
        frontmatter = "---\nrepo: x\npr: 42\n%s\n---\n" % posted if posted is not None else ""
        write(self.findings, frontmatter + "# Review of request 42\n\nFindings.\n")
        self.model = default_model(forge, self.clone)
        repo_key = ("github.com/acme/tickets" if forge == "github"
                    else "%s/acme/field ops/tickets" % ADO_HOST)
        self.manifest = {
            "schema": 1, "forge": forge, "repo": repo_key, "request": 42,
            "reviewed_sha": Template.head, "form": "default", "findings_file": self.findings,
            "threads": threads if threads is not None else [inline("M-1", 2)],
        }
        self.env = dict(
            {k: v for k, v in os.environ.items() if k != TOKEN_VAR},
            PATH=os.path.join(self.root, "bin") + os.pathsep + os.environ["PATH"],
            FAKE_FORGE_DIR=os.path.join(self.root, "forge"),
            XDG_STATE_HOME=os.path.join(self.root, "state"),
            TMPDIR=os.path.join(self.root, "tmp"),
            GIT_CONFIG_GLOBAL=os.path.join(self.root, "hostile.gitconfig"),
            GIT_CONFIG_NOSYSTEM="1",
        )
        if token is not None:
            self.env[TOKEN_VAR] = token

    def save_model(self):
        write(os.path.join(self.root, "forge", "model.json"), json.dumps(self.model))

    def stored(self):
        with open(os.path.join(self.root, "forge", "model.json"), encoding="utf-8") as f:
            return json.load(f)

    def run(self, *args):
        self.save_model()
        path = os.path.join(self.root, "manifest.json")
        write(path, json.dumps(self.manifest))
        proc = subprocess.run([sys.executable, SCRIPT, path, *args], cwd=self.clone, env=self.env,
                              capture_output=True, timeout=300)
        self.model = self.stored()
        return Run(proc.returncode, proc.stdout.decode("utf-8", "replace"),
                   proc.stderr.decode("utf-8", "replace"))

    def tool(self, tool, *args, stdin=""):
        self.save_model()
        proc = subprocess.run([os.path.join(self.root, "bin", tool), *args], cwd=self.root,
                              env=self.env, input=stdin.encode(), capture_output=True, timeout=60)
        self.model = self.stored()
        return Run(proc.returncode, proc.stdout.decode("utf-8", "replace"),
                   proc.stderr.decode("utf-8", "replace"))

    def calls(self):
        path = os.path.join(self.root, "forge", "calls.jsonl")
        if not os.path.exists(path):
            return []
        with open(path, encoding="utf-8") as f:
            return [json.loads(line) for line in f]

    def creates(self):
        return [c for c in self.calls() if is_create(c)]

    def record(self):
        found = glob.glob(os.path.join(self.root, "state", "delivery-skills", "post-review", "*",
                                       "state.json"))
        if not found:
            return None
        with open(found[0], encoding="utf-8") as f:
            return json.load(f)

    def file(self, name, data):
        path = os.path.join(self.root, name)
        write(path, data if isinstance(data, str) else json.dumps(data))
        return path

    def ado_url(self, tail):
        return "https://%s/acme/field%%20ops/_apis/git/repositories/tickets/pullRequests/42%s" % (
            ADO_HOST, tail)


def is_create(call):
    argv = call["argv"]
    method = next((argv[i + 1] for i, a in enumerate(argv[:-1]) if a in ("-X", "--method")), None)
    target = argv[-1] if call["tool"] == "curl" else next(
        (a for a in argv[1:] if not a.startswith("-") and a.startswith("repos/")), "")
    return method == "POST" and (target.endswith("/reviews") or "/threads?" in target
                                 or target.endswith("/threads"))


class Run:
    def __init__(self, rc, out, err):
        self.rc = rc
        self.out = out
        self.err = err

    def status(self):
        lines = self.out.strip().split("\n")
        return lines[-2].split(" ", 1)[0] if len(lines) >= 2 else ""


def inline(key, line, path="src/app.py", body=None, **extra):
    thread = {"key": key, "path": path, "line": line,
              "body": body if body is not None else "**Medium - %s**\n\nProblem: thing.\n" % key}
    thread.update(extra)
    return thread


# --- the harness -------------------------------------------------------------


class Results:
    def __init__(self, name):
        self.name = name
        self.rows = []
        self.covered = set()

    def check(self, label, ok, detail=""):
        self.rows.append((label, bool(ok), detail))

    def eq(self, label, got, want):
        self.check(label, got == want, "wanted %r, got %r" % (want, got))

    def status(self, label, run, want):
        self.covered.add(want)
        self.check(label, run.status() == want,
                   "wanted %s, got %r | out: %s | err: %s" % (want, run.status(), run.out[-600:],
                                                              run.err[-300:]))


TESTS = []


def test(fn):
    TESTS.append(fn)
    return fn


def run_test(fn):
    results = Results(fn.__name__)
    try:
        fn(results)
    except Exception as e:  # a crashing test reports as a failure of that test, not of the run
        results.check("%s ran to the end" % fn.__name__, False, "%s: %s" % (type(e).__name__, e))
    return results


# --- stand-in self-tests -----------------------------------------------------


def review_payload(fx, comments, event="COMMENT"):
    payload = {"commit_id": Template.head, "body": "", "comments": comments}
    if event:
        payload["event"] = event
    return fx.file("payload.json", payload)


@test
def stand_in_refuses_a_github_comment_off_a_changed_line(r):
    fx = Fixture("github")
    off = fx.tool("gh", "api", "-i", "-X", "POST", "repos/acme/tickets/pulls/42/reviews", "--input",
                  review_payload(fx, [{"path": "src/app.py", "line": 10, "side": "RIGHT", "body": "x"}]))
    r.check("stand-in: a GitHub comment off a changed line gets 422",
            off.out.startswith("HTTP/2.0 422") and off.rc == 1, off.out[:200])
    on = fx.tool("gh", "api", "-i", "-X", "POST", "repos/acme/tickets/pulls/42/reviews", "--input",
                 review_payload(fx, [{"path": "src/app.py", "line": 2, "side": "RIGHT", "body": "x"}]))
    r.check("stand-in: a GitHub comment on a changed line is accepted",
            on.out.startswith("HTTP/2.0 200") and on.rc == 0, on.out[:200])


@test
def stand_in_ignores_a_patch_of_thread_context(r):
    fx = Fixture("ado")
    context = {"filePath": "/src/app.py", "rightFileStart": {"line": 2, "offset": 1},
               "rightFileEnd": {"line": 2, "offset": 2}}
    thread = {"comments": [{"parentCommentId": 0, "content": "x", "commentType": 1}], "status": 1,
              "threadContext": context}
    config = 'user = ":%s"\n' % SENTINEL
    body = os.path.join(fx.root, "reply.json")
    fx.tool("curl", "-K", "-", "-sS", "-X", "POST", "-o", body, "-w", "%{http_code}",
            "--data-binary", "@" + fx.file("thread.json", thread),
            fx.ado_url("/threads?api-version=7.1"), stdin=config)
    with open(body, encoding="utf-8") as f:
        thread_id = json.load(f)["id"]
    moved = dict(context, rightFileStart={"line": 15, "offset": 1}, rightFileEnd={"line": 15, "offset": 2})
    patched = fx.tool("curl", "-K", "-", "-sS", "-X", "PATCH", "-o", body, "-w", "%{http_code}",
                      "--data-binary", "@" + fx.file("patch.json", {"threadContext": moved, "status": 1}),
                      fx.ado_url("/threads/%d?api-version=7.1" % thread_id), stdin=config)
    r.eq("stand-in: an ADO PATCH of threadContext answers 200", patched.out, "200")
    listed = fx.tool("curl", "-K", "-", "-sS", "-w", "", fx.ado_url("/threads?api-version=7.1"),
                     stdin=config)
    r.eq("stand-in: the patched thread keeps its threadContext",
         json.loads(listed.out)["value"][0]["threadContext"], context)


@test
def stand_in_answers_a_curl_call_without_credential_with_the_sign_in_page(r):
    fx = Fixture("ado")
    url = fx.ado_url("?api-version=7.1")
    bare = fx.tool("curl", "-sS", "-w", "\\n%{http_code} %{content_type}", url)
    r.check("stand-in: a curl call without the user line gets 203 and a sign-in page",
            bare.out.endswith("203 text/html; charset=utf-8") and "Sign in" in bare.out, bare.out[-200:])
    wrong = fx.tool("curl", "-K", "-", "-sS", "-w", "\\n%{http_code}", url, stdin='user = ":wrong"\n')
    r.check("stand-in: a curl call with a wrong token gets 203", wrong.out.endswith("203"), wrong.out[-80:])
    good = fx.tool("curl", "-K", "-", "-sS", "-w", "\\n%{http_code}", url,
                   stdin='user = ":%s"\n' % SENTINEL)
    r.check("stand-in: a curl call with the token gets 200", good.out.endswith("200"), good.out[-80:])
    fx.model["auth_failure"] = 401
    refused = fx.tool("curl", "-sS", "-w", "%{http_code}", url)
    r.eq("stand-in: in 401 mode a curl call without the user line gets 401", refused.out, "401")
    r.check("stand-in: the call log holds no token",
            SENTINEL not in json.dumps(fx.calls()), "token found in calls.jsonl")


@test
def stand_in_pages_a_github_list(r):
    fx = Fixture("github")
    fx.model["page_size"] = 2
    fx.tool("gh", "api", "-i", "-X", "POST", "repos/acme/tickets/pulls/42/reviews", "--input",
            review_payload(fx, [{"path": "src/app.py", "line": n, "side": "RIGHT", "body": "c%d" % n}
                                for n in (2, 15, 16)]))
    first = fx.tool("gh", "api", "-i", "repos/acme/tickets/pulls/42/comments?per_page=100&page=1")
    second = fx.tool("gh", "api", "-i", "repos/acme/tickets/pulls/42/comments?per_page=100&page=2")
    r.check("stand-in: a GitHub list longer than a page links to page two",
            'rel="next"' in first.out.split("\n\n", 1)[0], first.out[:300])
    r.eq("stand-in: page two holds the rest of the list",
         [c["line"] for c in json.loads(second.out.split("\n\n", 1)[1])], [16])
    r.check("stand-in: the last page links to nothing", 'rel="next"' not in second.out, second.out[:300])


@test
def stand_in_computes_pending_positions_from_its_own_diff(r):
    fx = Fixture("github")
    reply = fx.tool("gh", "api", "-X", "POST", "repos/acme/tickets/pulls/42/reviews", "--input",
                    review_payload(fx, [{"path": "src/app.py", "line": n, "side": "RIGHT", "body": "c"}
                                        for n in (2, 17)], event=None))
    review = json.loads(reply.out)
    r.eq("stand-in: a review without event is pending", review["state"], "PENDING")
    listed = fx.tool("gh", "api", "repos/acme/tickets/pulls/42/reviews/%d/comments" % review["id"])
    r.eq("stand-in: positions count from the first hunk header, each later header counting one",
         [c["position"] for c in json.loads(listed.out)], [3, 16])
    again = fx.tool("gh", "api", "-i", "-X", "POST", "repos/acme/tickets/pulls/42/reviews", "--input",
                    review_payload(fx, [], event=None))
    r.check("stand-in: a second pending review of the same user gets 422",
            again.out.startswith("HTTP/2.0 422"), again.out[:200])


@test
def stand_in_refuses_arguments_the_real_tools_refuse(r):
    fx = Fixture("ado")
    r.check("stand-in: gh refuses an unknown flag",
            fx.tool("gh", "api", "--paginate-all", "user").rc == 1)
    r.check("stand-in: curl refuses an unknown option",
            fx.tool("curl", "--bogus", fx.ado_url("")).rc == 2)
    r.check("stand-in: gh refuses an --input file that does not exist",
            fx.tool("gh", "api", "-X", "POST", "--input", "/nonexistent/p.json", "user").rc == 1)



# --- task 2: manifest, pre-flight and the posted-line guard -------------------


def refused(r, fx, want, label, *args):
    run = fx.run(*args)
    r.status("%s: the run stops %s" % (label, want), run, want)
    r.eq("%s: no create reached the stand-in" % label, len(fx.creates()), 0)
    return run


SUGGESTION_16_17 = {"start": 16, "end": 17, "original": ["LINE 16", "LINE 17"]}


@test
def unknown_field_is_refused(r):
    fx = Fixture("ado", threads=[inline("M-1", 17, start_lin=16)])
    run = refused(r, fx, "MANIFEST-INVALID", "a misspelled start_line")
    r.check("a misspelled start_line: the refusal names the field", "'start_lin'" in run.out, run.out)


@test
def exact_duplicate_keys_are_refused(r):
    fx = Fixture("ado", threads=[inline("M-1", 2), inline("M-1", 15)])
    refused(r, fx, "MANIFEST-INVALID", "a key given twice")


@test
def empty_thread_list_is_refused(r):
    refused(r, Fixture("github", threads=[]), "EMPTY", "an empty thread list")


@test
def gitlab_manifest_is_refused(r):
    fx = Fixture("github")
    fx.manifest.update(forge="gitlab", repo="gitlab.com/acme/tickets")
    run = refused(r, fx, "UNSUPPORTED-FORGE", "a GitLab manifest")
    r.check("a GitLab manifest: the refusal says the script does not cover that forge",
            "github and ado only" in run.out, run.out)


@test
def findings_file_without_frontmatter_is_refused(r):
    fx = Fixture("ado", posted=None)
    run = refused(r, fx, "NO-FRONTMATTER", "a findings file without frontmatter")
    r.check("a findings file without frontmatter: the refusal gives the three lines to add",
            "---\nposted: null\n---\n" in run.out, run.out)


@test
def findings_file_already_posted_is_refused(r):
    fx = Fixture("ado", posted="posted: { at: T, form: default, threads: [11, 12] }")
    refused(r, fx, "ALREADY-POSTED", "a posted: line holding a record")


@test
def findings_file_with_the_placeholder_is_refused(r):
    fx = Fixture("ado", posted='posted: "before migration - any record of it is in the body"')
    refused(r, fx, "POSTED-UNKNOWN", "a posted: line holding the placeholder")


@test
def ado_run_without_token_is_refused_before_any_call(r):
    fx = Fixture("ado", token=None)
    run = fx.run()
    r.status("an ADO run without the token variable stops NO-TOKEN", run, "NO-TOKEN")
    r.eq("an ADO run without the token variable makes no call", fx.calls(), [])


@test
def refused_credential_is_reported(r):
    for mode in (203, 401):
        fx = Fixture("ado")
        fx.model["token"] = "the-token-the-forge-knows"
        fx.model["auth_failure"] = mode
        run = refused(r, fx, "AUTH-REFUSED", "a credential refused with %d" % mode)
        r.check("a credential refused with %d: the token is in no output" % mode,
                SENTINEL not in run.out + run.err, run.out + run.err)
        r.check("a credential refused with %d: the token is in no argument list" % mode,
                SENTINEL not in json.dumps([c["argv"] for c in fx.calls()]))


@test
def moved_forge_head_is_refused(r):
    fx = Fixture("ado")
    fx.model["head"] = Template.moved
    refused(r, fx, "STALE-HEAD", "a forge head moved past the local clone")


@test
def missing_base_commit_is_refused(r):
    fx = Fixture("ado")
    fx.model["base"] = "e" * 40
    run = refused(r, fx, "MISSING-COMMIT", "a base commit missing locally")
    r.check("a base commit missing locally: the refusal names the fetch", "git fetch" in run.out, run.out)


@test
def out_of_diff_path_is_refused(r):
    fx = Fixture("ado", threads=[inline("M-1", 3, path="docs/guide.md")])
    refused(r, fx, "OUT-OF-DIFF", "an ADO thread on a file outside the diff")


@test
def line_past_end_of_file_is_refused(r):
    fx = Fixture("ado", threads=[inline("M-1", 25)])
    refused(r, fx, "LINE-OUT-OF-FILE", "an ADO thread past the end of its file")


@test
def github_line_off_changed_lines_is_refused(r):
    fx = Fixture("github", threads=[inline("M-1", 10)])
    refused(r, fx, "OFF-DIFF-LINE", "a GitHub thread on an unchanged line")


@test
def stale_suggestion_is_refused(r):
    stale = dict(SUGGESTION_16_17, original=["  LINE 16", "LINE 17"])
    fx = Fixture("ado", threads=[inline("M-1", 17, start_line=16, suggestion=stale)])
    refused(r, fx, "STALE-SUGGESTION", "a suggestion whose lines differ only in leading whitespace")


@test
def suggestion_in_a_group_is_refused(r):
    members = [{"path": "src/app.py", "line": 17}, {"path": "src/crlf.txt", "line": 2}]
    fx = Fixture("ado", threads=[inline("C-1", 17, start_line=16, suggestion=SUGGESTION_16_17,
                                        members=members)])
    fx.manifest["form"] = "compact"
    refused(r, fx, "SUGGESTION-IN-GROUP", "a multi-member compact thread with a suggestion")


@test
def partition_straddle_is_refused(r):
    members = [{"path": "docs/guide.md", "line": 3}, {"path": "src/app.py", "line": 2}]
    fx = Fixture("ado", threads=[inline("C-1", None, path=None, members=members)])
    fx.manifest["form"] = "compact"
    run = refused(r, fx, "PARTITION", "a request-level compact thread with an in-diff member")
    r.check("a request-level compact thread with an in-diff member: the refusal names it",
            "src/app.py:2" in run.out and "docs/guide.md:3" not in run.out, run.out)


@test
def existing_pending_review_is_refused(r):
    fx = Fixture("github")
    fx.manifest["pending"] = True
    fx.model["reviews"].append({"id": 5, "login": "reviewer", "state": "PENDING", "body": "",
                                "commit_id": Template.head})
    refused(r, fx, "PENDING-EXISTS", "a pending review of the user's already on the request")



# --- task 3: post, classify and read back --------------------------------------


B1 = "**Medium - first**\n\nProblem: the thing.\n"
SB = "**Minor - rename**\n\nSuggestion:\n```suggestion\nfixed 16\nfixed 17\n```\n"
RB = "**Minor - docs/guide.md:3 is stale**\n\nProblem: it says otherwise.\n"
MALFORMED = "**Medium - path**\n\nProblem: C:\\qux\\new\tpath, see `x`.\n"


def standard_threads():
    return [inline("M-1", 2, body=B1),
            inline("M-2", 17, start_line=16, suggestion=SUGGESTION_16_17, body=SB),
            {"key": "R-1", "path": None, "body": RB}]


def payloads(fx):
    return [json.loads(c["payload"]) for c in fx.creates()]


def ado_payload(body, context=None):
    payload = {"comments": [{"parentCommentId": 0, "content": body, "commentType": 1}], "status": 1}
    if context:
        payload["threadContext"] = context
    return payload


def ado_context(path, start, end, end_offset):
    return {"filePath": path, "rightFileStart": {"line": start, "offset": 1},
            "rightFileEnd": {"line": end, "offset": end_offset}}


def landed(r, label, run):
    r.status("%s: the run reads back clean" % label, run, "LANDED")
    r.eq("%s: the run exits 0" % label, run.rc, 0)


@test
def github_happy_path(r):
    fx = Fixture("github", threads=standard_threads())
    run = fx.run()
    landed(r, "the GitHub happy path", run)
    r.eq("the GitHub happy path: the stored payload matches the literal", payloads(fx), [{
        "commit_id": Template.head, "event": "COMMENT", "body": RB, "comments": [
            {"path": "src/app.py", "line": 2, "side": "RIGHT", "body": B1},
            {"path": "src/app.py", "line": 17, "start_line": 16, "side": "RIGHT",
             "start_side": "RIGHT", "body": SB}]}])
    stored = fx.stored()
    review_id = stored["reviews"][0]["id"] if stored["reviews"] else None
    r.eq("the GitHub happy path: one review with two comments",
         (len(stored["reviews"]), len(stored["comments"])), (1, 2))
    r.eq("the GitHub happy path: the record holds sending and landed in order",
         fx.record()["events"], [["sending", "review"], ["landed", "review", review_id]])


@test
def ado_happy_path(r):
    fx = Fixture("ado", threads=standard_threads())
    run = fx.run()
    landed(r, "the ADO happy path", run)
    r.eq("the ADO happy path: the stored payloads match the literals", payloads(fx), [
        ado_payload(B1, ado_context("/src/app.py", 2, 2, 2)),
        ado_payload(SB, ado_context("/src/app.py", 16, 17, 8)),
        ado_payload(RB)])
    ids = [t["id"] for t in fx.stored()["threads"]]
    r.eq("the ADO happy path: the record holds sending and landed in order", fx.record()["events"],
         [["sending", "M-1"], ["landed", "M-1", ids[0]], ["sending", "M-2"], ["landed", "M-2", ids[1]],
          ["sending", "R-1"], ["landed", "R-1", ids[2]]])


@test
def github_pending_review(r):
    fx = Fixture("github", threads=[inline("M-1", 2, body=B1), inline("M-2", 17, start_line=16, body=SB)])
    fx.manifest["pending"] = True
    run = fx.run()
    landed(r, "a staged GitHub review", run)
    r.check("a staged GitHub review: the payload carries no event",
            payloads(fx) and "event" not in payloads(fx)[0], payloads(fx))
    stored = fx.stored()
    r.eq("a staged GitHub review: the stand-in holds it pending at the literal positions",
         ([rv["state"] for rv in stored["reviews"]], [c["position"] for c in stored["comments"]]),
         (["PENDING"], [3, 16]))


@test
def github_comments_past_one_page(r):
    fx = Fixture("github", threads=[inline("M-%d" % n, n) for n in (2, 15, 16)])
    fx.model["page_size"] = 2
    landed(r, "a GitHub review whose comments run past one page", fx.run())


@test
def malformed_create_replies(r):
    gh = Fixture("github", threads=[inline("M-1", 2), {"key": "R-1", "path": None, "body": MALFORMED}])
    gh.model["faults"]["malformed_reply"] = True
    landed(r, "a malformed GitHub create reply", gh.run())
    stored = gh.stored()
    r.eq("a malformed GitHub create reply: the review is recorded once", len(stored["reviews"]), 1)
    r.eq("a malformed GitHub create reply: the record holds the id the forge gave",
         gh.record()["events"][-1], ["landed", "review", stored["reviews"][0]["id"]])
    ado = Fixture("ado", threads=[inline("M-1", 2, body=MALFORMED), inline("M-2", 15, body=MALFORMED + "2")])
    ado.model["faults"]["malformed_reply"] = True
    landed(r, "a malformed ADO create reply", ado.run())
    threads = ado.stored()["threads"]
    r.eq("a malformed ADO create reply: each thread is recorded once", len(threads), 2)
    r.eq("a malformed ADO create reply: the record holds the ids the forge gave",
         [e[2] for e in ado.record()["events"] if e[0] == "landed"], [t["id"] for t in threads])


@test
def stand_in_malformed_reply_defeats_a_strict_parse(r):
    fx = Fixture("ado")
    fx.model["faults"]["malformed_reply"] = True
    body = os.path.join(fx.root, "reply.json")
    fx.tool("curl", "-K", "-", "-sS", "-X", "POST", "-o", body, "-w", "%{http_code}", "--data-binary",
            "@" + fx.file("thread.json", ado_payload(MALFORMED)), fx.ado_url("/threads?api-version=7.1"),
            stdin='user = ":%s"\n' % SENTINEL)
    with open(body, encoding="utf-8") as f:
        text = f.read()
    try:
        json.loads(text)
        strict_fails = False
    except ValueError:
        strict_fails = True
    r.check("stand-in: a malformed create reply fails a strict JSON parse", strict_fails, text[:200])


@test
def ado_rejection_on_the_third_thread(r):
    fx = Fixture("ado", threads=[inline("M-1", 2), inline("M-2", 15), inline("M-3", 16),
                                 {"key": "R-1", "path": None, "body": RB}])
    fx.model["faults"]["reject_create"] = {"nth": 3, "status": 400}
    run = fx.run()
    r.status("a 400 on the third ADO thread: the run stops REJECTED", run, "REJECTED")
    r.eq("a 400 on the third ADO thread: threads past it are never sent", len(fx.creates()), 3)
    ids = [t["id"] for t in fx.stored()["threads"]]
    r.eq("a 400 on the third ADO thread: the record holds threads 1-2 landed and 3 rejected",
         fx.record()["events"], [["sending", "M-1"], ["landed", "M-1", ids[0]], ["sending", "M-2"],
                                 ["landed", "M-2", ids[1]], ["sending", "M-3"], ["rejected", "M-3", 400]])
    r.check("a 400 on the third ADO thread: the stop names what had landed",
            "landed before the stop: M-1 %s" % ids[0] in run.out, run.out)
    again = fx.run()
    r.status("a plain re-run after the ADO 400: the run stops UNFINISHED-RUN", again, "UNFINISHED-RUN")
    r.eq("a plain re-run after the ADO 400: no further create reached the stand-in", len(fx.creates()), 3)


@test
def github_rejection_leaves_nothing_behind(r):
    fx = Fixture("github", threads=standard_threads())
    fx.model["faults"]["reject_create"] = {"nth": 1, "status": 422}
    run = fx.run()
    r.status("a GitHub 422: the run stops REJECTED", run, "REJECTED")
    r.eq("a GitHub 422: the stand-in holds no review", fx.stored()["reviews"], [])
    landed(r, "a plain re-run after a GitHub 422", fx.run())


@test
def ado_suggestion_over_an_astral_character_and_crlf(r):
    original = ['say("\U0001F600")', 'shout("\U0001F600")']
    fx = Fixture("ado", threads=[inline("M-1", 3, path="src/crlf.txt", start_line=2, body=SB,
                                        suggestion={"start": 2, "end": 3, "original": original})])
    landed(r, "an ADO suggestion over an astral character and CRLF", fx.run())
    r.eq("an ADO suggestion over an astral character and CRLF: the stored payload spans the literal "
         "UTF-16 offset", payloads(fx), [ado_payload(SB, ado_context("/src/crlf.txt", 2, 3, 12))])


@test
def keys_differing_only_in_case(r):
    fx = Fixture("ado", threads=[inline("M-1", 2, body="upper\n"), inline("m-1", 15, body="lower\n")])
    run = fx.run()
    r.check("case-distinct keys: both threads land and read back as sent",
            run.status() == "LANDED" and [t["content"] for t in fx.stored()["threads"]] == ["upper\n", "lower\n"],
            run.out[-400:])


@test
def sanitized_body_stops_mismatch(r):
    fx = Fixture("ado", threads=[inline("M-1", 2, body="Problem: <Id> is dropped.\n")])
    fx.model["faults"]["sanitize_tags"] = True
    run = fx.run()
    r.status("a sanitizer dropping <Id> on ADO: the run stops MISMATCH", run, "MISMATCH")
    r.check("a sanitizer dropping <Id> on ADO: the stop prints the diff",
            "-Problem: <Id> is dropped." in run.out and "+Problem:  is dropped." in run.out, run.out)


@test
def misreported_line_stops_misplaced(r):
    ado = Fixture("ado")
    ado.model["faults"]["misreport_line"] = {"nth": 1}
    r.status("an ADO read-back reporting another line: the run stops MISPLACED", ado.run(), "MISPLACED")
    gh = Fixture("github")
    gh.model["faults"]["misreport_line"] = {"nth": 1}
    r.status("a GitHub read-back reporting another line: the run stops MISPLACED", gh.run(), "MISPLACED")


# --- the vocabulary ----------------------------------------------------------


def vocabulary_check(covered):
    results = Results("vocabulary")
    proc = subprocess.run([sys.executable, SCRIPT, "--print-status-vocab"], capture_output=True)
    printed = proc.stdout.decode().split()
    results.eq("the status vocabulary matches the expected list", printed, EXPECTED_VOCAB)
    uncovered = set(EXPECTED_VOCAB) - covered
    results.check("every status has a fixture, apart from those later tasks owe",
                  uncovered == OWED_BY_LATER_TASKS,
                  "without a fixture and not owed: %s; owed but covered: %s" % (
                      sorted(uncovered - OWED_BY_LATER_TASKS), sorted(OWED_BY_LATER_TASKS - uncovered)))
    return results


def main():
    build_template()
    passed = failed = 0
    covered = set()
    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
        outcomes = list(pool.map(run_test, TESTS))
    outcomes.append(vocabulary_check(set().union(*(o.covered for o in outcomes))))
    for outcome in outcomes:
        print(outcome.name)
        covered |= outcome.covered
        for label, ok, detail in outcome.rows:
            if ok:
                passed += 1
                print("  PASS %s" % label)
            else:
                failed += 1
                print("  FAIL %s" % label)
                if detail:
                    print("       %s" % detail)
    if OWED_BY_LATER_TASKS:
        print("statuses later tasks owe a fixture: %s" % " ".join(sorted(OWED_BY_LATER_TASKS)))
    print("%d passed, %d failed" % (passed, failed))
    for root in CREATED:
        shutil.rmtree(root, ignore_errors=True)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
