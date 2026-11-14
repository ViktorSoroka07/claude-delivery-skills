#!/usr/bin/env python3
"""Fixture suite for post-review.py, run against fake_forge.py.

    python3 test_post_review.py           # every test, and the vocabulary check
    python3 test_post_review.py NAME ...  # the named tests only ("vocabulary" names the check)

Prints one PASS or FAIL line per named assertion; mutate.py reads those lines.
"""

import base64
import concurrent.futures
import glob
import json
import os
import re
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
    "CORRECTED", "MISMATCH", "MISPLACED", "NO-STATE", "SETTLING", "MOVED-MID-RUN", "DRY-RUN",
]

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
    def __init__(self, forge="github", threads=None, posted="posted: null", token=SENTINEL, review=None,
                 findings_text=None):
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
        review = dict({"pr": "42", "reviewed_sha": Template.head}, **(review or {}))
        keys = "".join("%s: %s\n" % kv for kv in review.items() if kv[1] is not None)
        frontmatter = "---\nrepo: x\n%s%s\n---\n" % (keys, posted) if posted is not None else ""
        self.findings_text = findings_text or frontmatter + "# Review of request 42\n\nFindings.\n"
        write(self.findings, self.findings_text)
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

    def record_file(self):
        found = glob.glob(os.path.join(self.root, "state", "delivery-skills", "post-review", "*",
                                       "state.json"))
        return found[0] if found else None

    def record(self):
        if not self.record_file():
            return None
        with open(self.record_file(), encoding="utf-8") as f:
            return json.load(f)

    def age(self, seconds):
        """Move every time the run's record holds `seconds` into the past."""
        data = self.record()
        data["started"] -= seconds
        for event in data["events"]:
            if event[0] in ("sending", "uncertain"):
                event[2] -= seconds
        write(self.record_file(), json.dumps(data))

    def events(self):
        """The record's events with their times dropped."""
        return [e[:2] if e[0] in ("sending", "uncertain") else e for e in self.record()["events"]]

    def record_events_for(self, key):
        return [e for e in self.events() if e[1] == key]

    def result(self, run):
        with open(os.path.join(run.out.strip().split("\n")[-1], "result.json"), encoding="utf-8") as f:
            return json.load(f)

    def edits(self):
        return [c for c in self.calls() if any(m in c["argv"] for m in ("PATCH", "PUT"))]

    def findings_now(self):
        with open(self.findings, encoding="utf-8", newline="") as f:
            return f.read()

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
def malformed_verified_head_is_refused(r):
    fx = Fixture("github")
    fx.manifest["verified_head"] = Template.moved[:7]
    refused(r, fx, "MANIFEST-INVALID", "a verified_head shorter than a full SHA")


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
    lines = "---\npr: 42\nreviewed_sha: %s\nposted: null\n---\n" % Template.head
    r.check("a findings file without frontmatter: the refusal gives the lines to add",
            lines in run.out, run.out)
    write(fx.findings, lines + fx.findings_text)
    r.status("a findings file without frontmatter: with the lines given added, the post lands",
             fx.run(), "LANDED")


@test
def frontmatter_without_a_posted_line_is_refused(r):
    head = "---\nrepo: x\npr: 42\nreviewed_sha: %s\n" % Template.head
    fx = Fixture("ado", findings_text=head + "---\n# Review of request 42\n")
    what = "a findings file whose frontmatter lacks posted:"
    run = refused(r, fx, "NO-FRONTMATTER", what)
    printed = run.out.split("\nNO-FRONTMATTER ", 1)[0]
    r.eq("%s: the refusal prints only the line the block lacks" % what, printed, "posted: null")
    write(fx.findings, head + printed + "\n---\n# Review of request 42\n")
    landed(r, "%s: with the printed line added where the stop says" % what, fx.run())
    r.eq("%s: the file keeps one frontmatter block" % what,
         [row for row in fx.findings_now().split("\n") if row == "---"], ["---", "---"])


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


def reviewed_sha_line(fx):
    return next(row for row in fx.findings_now().split("\n") if row.startswith("reviewed_sha:"))


@test
def moved_head_posts_once_its_advice_is_followed(r):
    for forge in ("github", "ado"):
        fx = Fixture(forge, threads=[inline("M-1", 2, body=B1)])
        fx.model["head"] = Template.moved
        what = "a %s request whose author pushed after the review" % forge
        run = refused(r, fx, "STALE-HEAD", what)
        r.check("%s: the stop says to set verified_head and leave reviewed_sha" % what,
                "set its verified_head to %s" % Template.moved in run.out
                and "Leave reviewed_sha as it is" in run.out, run.out)
        fx.manifest["verified_head"] = Template.moved
        landed(r, "%s: with verified_head set as the stop says" % what, fx.run())
        r.eq("%s: the findings file's reviewed_sha is unchanged" % what, reviewed_sha_line(fx),
             "reviewed_sha: %s" % Template.head)
        stamp = ("review_id: {0}, url: https://github.com/acme/tickets/pull/42#pullrequestreview-{0}"
                 .format(fx.stored()["reviews"][0]["id"]) if forge == "github"
                 else "threads: [%d]" % fx.stored()["threads"][0]["id"])
        r.eq("%s: posted: records the head the post went out at" % what, posted_line(fx),
             "posted: { at: T, form: default, %s, head: %s }" % (stamp, Template.moved[:7]))
        if forge == "github":
            r.eq("%s: the review is created at the new head" % what, payloads(fx)[0]["commit_id"],
                 Template.moved)
    staged = Fixture("github", threads=[inline("M-1", 2, body=B1)])
    staged.model["head"] = staged.manifest["verified_head"] = Template.moved
    staged.manifest["pending"] = True
    landed(r, "a staged review re-verified at a new head", staged.run())


@test
def missing_base_commit_is_refused(r):
    fx = Fixture("ado")
    fx.model["base"] = "e" * 40
    run = refused(r, fx, "MISSING-COMMIT", "a base commit missing locally")
    r.check("a base commit missing locally: the refusal names the fetch", "git fetch" in run.out, run.out)


@test
def dry_run_reports_a_status_of_its_own(r):
    fx = Fixture("github")
    run = refused(r, fx, "DRY-RUN", "a dry run", "--dry-run")
    r.eq("a dry run: it exits 0", run.rc, 0)
    r.eq("a dry run: result.json says it was a dry run", fx.result(run)["status"], "DRY-RUN")


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



@test
def findings_file_of_another_review_is_refused(r):
    other = refused(r, Fixture("ado", review={"pr": "41"}), "MANIFEST-INVALID",
                    "a findings file of another request")
    r.check("a findings file of another request: the refusal names both requests",
            "records pr: 41" in other.out and "posts pr: 42" in other.out, other.out)
    refused(r, Fixture("ado", review={"reviewed_sha": Template.base}), "MANIFEST-INVALID",
            "a findings file of another head")
    bare = refused(r, Fixture("ado", review={"reviewed_sha": None}), "MANIFEST-INVALID",
                   "a findings file without reviewed_sha")
    r.check("a findings file without reviewed_sha: the refusal names the line it lacks",
            "has no reviewed_sha line" in bare.out, bare.out)


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
         fx.events(), [["sending", "review"], ["landed", "review", review_id]])


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
    r.eq("the ADO happy path: the record holds sending and landed in order", fx.events(),
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
         fx.events(), [["sending", "M-1"], ["landed", "M-1", ids[0]], ["sending", "M-2"],
                                 ["landed", "M-2", ids[1]], ["sending", "M-3"], ["rejected", "M-3", 400]])
    r.check("a 400 on the third ADO thread: the stop names what had landed",
            "landed before the stop: M-1 %s" % ids[0] in run.out, run.out)
    again = fx.run()
    r.status("a plain re-run after the ADO 400: the run stops UNFINISHED-RUN", again, "UNFINISHED-RUN")
    r.eq("a plain re-run after the ADO 400: no further create reached the stand-in", len(fx.creates()), 3)
    del fx.model["faults"]["reject_create"]
    landed(r, "a resume at once after the ADO 400, with no call in doubt", fx.run("--resume"))
    r.eq("a resume at once after the ADO 400: it posts only the threads not yet on the request",
         (len(fx.creates()), len(fx.stored()["threads"])), (5, 4))


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
    fx.model["faults"]["mangle"] = {"kind": "tags", "patch": True}
    run = fx.run()
    what = "a sanitizer dropping <Id> again after the PATCH"
    r.status("%s: the run stops MISMATCH" % what, run, "MISMATCH")
    r.check("%s: the stop prints the diff" % what,
            "-Problem: <Id> is dropped." in run.out and "+Problem:  is dropped." in run.out, run.out)
    r.eq("%s: it is corrected once" % what, len(fx.edits()), 1)
    r.eq("%s: posted: stays unwritten" % what, fx.findings_now(), fx.findings_text)


@test
def misreported_line_stops_misplaced(r):
    ado = Fixture("ado")
    ado.model["faults"]["misreport_line"] = {"nth": 1}
    r.status("an ADO read-back reporting another line: the run stops MISPLACED", ado.run(), "MISPLACED")
    gh = Fixture("github")
    gh.model["faults"]["misreport_line"] = {"nth": 1}
    r.status("a GitHub read-back reporting another line: the run stops MISPLACED", gh.run(), "MISPLACED")
    r.eq("a read-back reporting another line: nothing is moved", ado.edits() + gh.edits(), [])
    r.eq("a read-back reporting another line: posted: stays unwritten", ado.findings_now(), ado.findings_text)


# --- task 4: lost answers, resume and the settle window ------------------------


SETTLE = 600


def three_threads():
    return [inline("M-1", 2, body=B1), inline("M-2", 15), inline("M-3", 16)]


def unwritten(r, label, fx):
    r.eq("%s: posted: stays unwritten" % label, fx.findings_now(), fx.findings_text)


@test
def lost_answer_whose_create_landed_at_once(r):
    fx = Fixture("ado", threads=three_threads())
    fx.model["faults"]["lost_answer"] = {"nth": 2, "answer": 502, "lands": "now"}
    landed(r, "a 502 whose create landed at once", fx.run())
    threads = fx.stored()["threads"]
    r.eq("a 502 whose create landed at once: the stand-in holds one copy of each thread",
         [t["content"] for t in threads], [B1, three_threads()[1]["body"], three_threads()[2]["body"]])
    r.eq("a 502 whose create landed at once: the record pairs it with the forge's id",
         fx.events()[2:5], [["sending", "M-2"], ["uncertain", "M-2"], ["landed", "M-2", threads[1]["id"]]])


@test
def lost_github_answer_and_latest_reviews(r):
    for absent in (True, False):
        what = "a GitHub 502 whose review %s latestReviews" % ("is absent from" if absent else "reached")
        fx = Fixture("github", threads=standard_threads())
        fx.model["faults"]["lost_answer"] = {"nth": 1, "answer": 502, "lands": "now"}
        fx.model["faults"]["absent_from_latest"] = absent
        run = fx.run()
        landed(r, what, run)
        r.eq("%s: the stand-in holds one review" % what, len(fx.stored()["reviews"]), 1)
        r.eq("%s: the run %s" % (what, "reports it absent from latestReviews" if absent else "notes nothing"),
             "absent from latestReviews" in run.out, absent)


@test
def lost_answer_that_never_lands(r):
    fx = Fixture("ado", threads=three_threads())
    fx.model["faults"]["lost_answer"] = {"nth": 2, "answer": 502, "lands": "never"}
    run = fx.run()
    what = "a 502 that never lands"
    r.status("%s: the run stops UNCERTAIN" % what, run, "UNCERTAIN")
    r.check("%s: the stop names the absent thread and what had landed" % what,
            "does not show M-2" in run.out and "landed before the stop: M-1" in run.out, run.out)
    r.eq("%s: no thread past it is sent" % what, len(fx.creates()), 2)
    unwritten(r, what, fx)
    again = fx.run()
    r.status("a plain re-run after an UNCERTAIN stop: the run stops UNFINISHED-RUN", again, "UNFINISHED-RUN")
    r.eq("a plain re-run after an UNCERTAIN stop: no further create reached the stand-in", len(fx.creates()), 2)
    calls = len(fx.calls())
    early = fx.run("--resume")
    r.status("a resume inside the settle window: the run stops SETTLING", early, "SETTLING")
    r.eq("a resume inside the settle window: it makes no call", len(fx.calls()), calls)
    fx.age(SETTLE + 1)
    landed(r, "a resume after the window, the lost create never landed", fx.run("--resume"))
    r.eq("a resume after the window, the lost create never landed: it posts the absent threads once",
         (len(fx.creates()), len(fx.stored()["threads"])), (4, 3))


@test
def late_landing_after_a_hang(r):
    fx = Fixture("ado", threads=three_threads()[:2])
    fx.model["faults"]["lost_answer"] = {"nth": 2, "answer": "hang", "lands": "next_run", "seconds": 1}
    what = "a create that hangs past the timeout and lands later"
    r.status("%s: the run stops UNCERTAIN" % what, fx.run(), "UNCERTAIN")
    r.status("%s: a resume inside the window stops SETTLING" % what, fx.run("--resume"), "SETTLING")
    fx.age(SETTLE + 1)
    landed(r, "%s: a resume after the window" % what, fx.run("--resume"))
    r.eq("%s: the resume after the window posts nothing" % what,
         (len(fx.creates()), len(fx.stored()["threads"])), (2, 2))


@test
def late_landing_of_an_earlier_draft(r):
    fx = Fixture("ado", threads=[inline("M-1", 2, body="Problem: the first draft.\n")])
    fx.model["faults"]["lost_answer"] = {"nth": 1, "answer": 502, "lands": "next_run"}
    what = "a late landing of an earlier draft"
    r.status("%s: the run stops UNCERTAIN" % what, fx.run(), "UNCERTAIN")
    fx.manifest["threads"][0]["body"] = "Problem: the edited text.\n"
    fx.age(SETTLE + 1)
    run = fx.run("--resume")
    r.eq("%s: the resume pairs it by anchor rather than posting again" % what,
         (len(fx.creates()), len(fx.stored()["threads"])), (1, 1))
    r.status("%s: the resume corrects the draft in place" % what, run, "CORRECTED")


@test
def lost_answer_landing_with_a_sanitized_body(r):
    fx = Fixture("ado", threads=[inline("M-1", 2, body="Problem: <Id> is dropped.\n")])
    fx.model["faults"]["lost_answer"] = {"nth": 1, "answer": 502, "lands": "now"}
    fx.model["faults"]["mangle"] = {"kind": "tags"}
    fx.run()
    threads = fx.stored()["threads"]
    what = "a 502 whose create landed with a sanitized body"
    r.eq("%s: the stand-in holds one copy" % what, len(threads), 1)
    r.eq("%s: the record pairs it with the forge's id" % what, fx.events()[-1], ["landed", "M-1", threads[0]["id"]])


@test
def copy_landing_after_the_resume_posted(r):
    fx = Fixture("ado", threads=[inline("M-1", 2, body=B1)])
    fx.model["faults"]["lost_answer"] = {"nth": 1, "answer": 502, "lands": "after_next_create"}
    fx.run()
    fx.age(SETTLE + 1)
    run = fx.run("--resume")
    what = "the lost original landing after the resume's post"
    r.status("%s: the run stops UNCERTAIN" % what, run, "UNCERTAIN")
    r.check("%s: the stop names the copy it cannot account for" % what,
            "pair with no thread" in run.out, run.out)
    unwritten(r, what, fx)


@test
def stray_item_of_the_users_named_on_resume(r):
    fx = Fixture("ado", threads=three_threads())
    fx.model["faults"]["lost_answer"] = {"nth": 2, "answer": 502, "lands": "never"}
    fx.run()
    fx.model["threads"].append({"id": 500, "author": "reviewer-id", "status": "active",
                                "threadContext": None, "content": "A note the user wrote by hand.\n"})
    fx.age(SETTLE + 1)
    what = "an item the user wrote during the post"
    run = fx.run("--resume")
    r.status("%s: the resume stops UNCERTAIN" % what, run, "UNCERTAIN")
    r.check("%s: the stop names the item and the flag that leaves it out" % what,
            "ids 500" in run.out and "--resume --ignore-item <id>" in run.out, run.out)
    landed(r, "%s: a resume naming it with --ignore-item" % what, fx.run("--resume", "--ignore-item", "500"))
    ids = [t["id"] for t in fx.stored()["threads"]]
    r.eq("%s: the user's item stays, and the post holds the manifest's threads once" % what,
         (500 in ids, len(ids), len(fx.creates())), (True, 4, 4))
    r.check("%s: posted: leaves the user's item out" % what, "500" not in posted_line(fx), posted_line(fx))


@test
def run_killed_between_a_create_and_its_record(r):
    fx = Fixture("ado", threads=three_threads()[:2])
    fx.model["faults"]["lost_answer"] = {"nth": 1, "answer": "kill", "lands": "now"}
    killed = fx.run()
    what = "a run killed after its create landed"
    r.check("%s: the run dies" % what, killed.rc != 0 and fx.events() == [["sending", "M-1"]],
            "rc %s, events %s" % (killed.rc, fx.record() and fx.events()))
    again = fx.run()
    r.status("%s: a plain re-run stops UNFINISHED-RUN" % what, again, "UNFINISHED-RUN")
    r.eq("%s: a plain re-run sends no further create" % what, len(fx.creates()), 1)
    r.status("%s: a resume inside the window stops SETTLING" % what, fx.run("--resume"), "SETTLING")
    fx.age(SETTLE + 1)
    landed(r, "%s: a resume after the window" % what, fx.run("--resume"))
    threads = fx.stored()["threads"]
    r.eq("%s: the resume posts only the thread never sent" % what,
         (len(fx.creates()), len(threads)), (2, 2))
    r.eq("%s: the record pairs the landed thread with the forge's id" % what,
         fx.record_events_for("M-1")[-1], ["landed", "M-1", threads[0]["id"]])


@test
def read_back_that_fails(r):
    for failures, want in ((3, "LANDED"), (4, "UNVERIFIED")):
        fx = Fixture("github", threads=standard_threads())
        fx.model["faults"]["fail_reads"] = {"after_creates": 1, "count": failures, "status": 502}
        run = fx.run()
        what = "a read-back failing %s times" % ("three" if failures == 3 else "four")
        r.status("%s: the run stops %s" % (what, want) if want != "LANDED"
                 else "%s: the retries read it back clean" % what, run, want)
        if want == "UNVERIFIED":
            review_id = fx.stored()["reviews"][0]["id"]
            r.check("%s: the stop lists the created id" % what,
                    "landed before the stop: review %s" % review_id in run.out, run.out)
            unwritten(r, what, fx)


@test
def created_thread_that_the_list_never_shows(r):
    fx = Fixture("ado", threads=three_threads()[:2])
    fx.model["faults"]["hide"] = {"nth": 2, "by_id": True}
    landed(r, "a thread missing from the list but readable by id", fx.run())
    gone = Fixture("ado", threads=three_threads()[:2])
    gone.model["faults"]["hide"] = {"nth": 2}
    run = gone.run()
    what = "a 2xx whose thread never shows, even by id"
    r.status("%s: the run stops MISSING" % what, run, "MISSING")
    r.check("%s: the stop names the thread" % what, "does not show M-2" in run.out, run.out)
    unwritten(r, what, gone)


@test
def resume_without_a_record(r):
    fx = Fixture("ado")
    r.status("a resume with no record: the run stops NO-STATE", fx.run("--resume"), "NO-STATE")
    r.eq("a resume with no record: it makes no call", fx.calls(), [])


@test
def resume_after_the_head_moved_with_nothing_landed(r):
    fx = Fixture("github", threads=[inline("M-1", 2, body=B1)])
    fx.model["faults"]["lost_answer"] = {"nth": 1, "answer": 502, "lands": "never"}
    fx.run()
    fx.model["head"] = Template.moved
    fx.age(SETTLE + 1)
    what = "a resume after the author pushed, the lost review never landed"
    r.status("%s: the resume stops STALE-HEAD" % what, fx.run("--resume"), "STALE-HEAD")
    fx.manifest["verified_head"] = Template.moved
    landed(r, "%s: with verified_head set as the stop says" % what, fx.run("--resume"))
    r.eq("%s: the review is posted once, at the new head" % what,
         (len(fx.stored()["reviews"]), payloads(fx)[-1]["commit_id"]), (1, Template.moved))
    r.eq("%s: the record names the head the resume posted at" % what, fx.record()["head"], Template.moved)


@test
def resume_after_the_head_moved_with_threads_landed(r):
    fx = Fixture("ado", threads=three_threads())
    fx.model["faults"]["lost_answer"] = {"nth": 2, "answer": 502, "lands": "never"}
    fx.run()
    first = fx.stored()["threads"][0]["id"]
    fx.model["head"] = fx.manifest["verified_head"] = Template.moved
    fx.age(SETTLE + 1)
    what = "a resume after the author pushed, one thread landed"
    run = fx.run("--resume")
    r.status("%s: the resume stops MOVED-MID-RUN" % what, run, "MOVED-MID-RUN")
    r.eq("%s: it posts nothing at the new head" % what, len(fx.creates()), 2)
    r.check("%s: the stop names what landed where" % what,
            "M-1 landed at %s before the request moved to %s; M-2, M-3 did not"
            % (Template.head[:7], Template.moved[:7]) in run.out, run.out)
    fx.manifest["threads"] = fx.manifest["threads"][1:]
    landed(r, "%s: the landed thread taken out, run again without --resume" % what, fx.run())
    ids = [t["id"] for t in fx.stored()["threads"]]
    r.eq("%s: the request holds each thread once" % what, len(ids), 3)
    r.eq("%s: posted: records the second run at the new head" % what, posted_line(fx),
         "posted: { at: T, form: default, threads: [%s], head: %s }"
         % (", ".join(str(i) for i in ids if i != first), Template.moved[:7]))


# --- task 5: correction and write-back -----------------------------------------


TAGGED = "Problem: <Id> is dropped.\n"
STAMP = re.compile(r"at: \d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ, ")


def posted_line(fx):
    """The findings file's posted: line with its time replaced by T, or None if the time is malformed."""
    line = next(row for row in fx.findings_now().split("\n") if row.startswith("posted:"))
    return STAMP.sub("at: T, ", line) if STAMP.search(line) else line


def corrected(r, what, fx, run):
    r.status("%s: the run corrects it in place" % what, run, "CORRECTED")
    r.eq("%s: the run exits 0" % what, run.rc, 0)


@test
def sanitized_body_corrected_on_ado(r):
    fx = Fixture("ado", threads=[inline("M-1", 2, body=TAGGED)])
    fx.model["faults"]["mangle"] = {"kind": "tags"}
    run = fx.run()
    what = "a sanitizer dropping <Id> on ADO once"
    corrected(r, what, fx, run)
    r.eq("%s: the stored body is the one sent" % what, fx.stored()["threads"][0]["content"], TAGGED)
    r.eq("%s: the result records the correction" % what,
         [(row["status"], row["before"], row["after"]) for row in fx.result(run)["threads"]],
         [("CORRECTED", "Problem:  is dropped.\n", TAGGED)])


@test
def sanitized_bodies_corrected_on_github(r):
    fx = Fixture("github", threads=[inline("M-1", 2, body=TAGGED),
                                    {"key": "R-1", "path": None, "body": "Request: <Id> too.\n"}])
    fx.model["faults"]["mangle"] = {"kind": "tags"}
    run = fx.run()
    what = "a sanitizer dropping <Id> from a GitHub comment and the review body"
    corrected(r, what, fx, run)
    stored = fx.stored()
    r.eq("%s: both bodies are stored as sent" % what,
         (stored["comments"][0]["body"], stored["reviews"][0]["body"]), (TAGGED, "Request: <Id> too.\n"))
    r.eq("%s: one PATCH and one PUT" % what, sorted(c["argv"][3] for c in fx.edits()), ["PATCH", "PUT"])


@test
def sanitized_pending_review_is_not_edited(r):
    fx = Fixture("github", threads=[inline("M-1", 2, body=TAGGED)])
    fx.manifest["pending"] = True
    fx.model["faults"]["mangle"] = {"kind": "tags"}
    run = fx.run()
    what = "a staged review with a sanitized body"
    r.status("%s: the run stops MISMATCH" % what, run, "MISMATCH")
    r.eq("%s: no PATCH reached the stand-in" % what, fx.edits(), [])


@test
def bodies_differing_at_their_end(r):
    for kind, body, what in (("final_char", "Problem: off by one.", "a body differing only in its final character"),
                             ("final_newline", B1, "a body that lost its trailing newline")):
        fx = Fixture("ado", threads=[inline("M-1", 2, body=body)])
        fx.model["faults"]["mangle"] = {"kind": kind}
        corrected(r, what, fx, fx.run())
        r.eq("%s: the stored body is the one sent" % what, fx.stored()["threads"][0]["content"], body)


@test
def written_posted_values(r):
    gh = Fixture("github", threads=standard_threads())
    landed(r, "a GitHub post's write-back", gh.run())
    review = gh.stored()["reviews"][0]["id"]
    r.eq("a GitHub post's write-back: posted: holds the review's id and link", posted_line(gh),
         "posted: { at: T, form: default, review_id: %d, url: "
         "https://github.com/acme/tickets/pull/42#pullrequestreview-%d }" % (review, review))
    staged = Fixture("github", threads=[inline("M-1", 2, body=B1)])
    staged.manifest["pending"] = True
    landed(r, "a staged GitHub review's write-back", staged.run())
    review = staged.stored()["reviews"][0]["id"]
    r.eq("a staged GitHub review's write-back: posted: holds the review and the staged head",
         posted_line(staged), "posted: { at: T, form: pending, review_id: %d, url: "
         "https://github.com/acme/tickets/pull/42#pullrequestreview-%d, head: %s }"
         % (review, review, Template.head[:7]))
    ado = Fixture("ado", threads=standard_threads())
    ado.manifest["form"] = "compact"
    landed(r, "a compact ADO post's write-back", ado.run())
    r.eq("a compact ADO post's write-back: posted: holds every thread's id", posted_line(ado),
         "posted: { at: T, form: compact, threads: [%s] }"
         % ", ".join(str(t["id"]) for t in ado.stored()["threads"]))


FRONTMATTER_AROUND = """---
repo: %s/acme/field ops/tickets      # the folder key
pr: 42                             # null for a branch review
reviewed_sha: %s
posted: null
extra:
  - kept as it was
---
# Review of request 42\r
\r
Body lines keep their CRLF.\r
"""


@test
def write_back_changes_only_the_posted_value(r):
    text = FRONTMATTER_AROUND % (ADO_HOST, Template.head)
    fx = Fixture("ado", findings_text=text)
    what = "the write-back"
    landed(r, "a findings file whose posted: is not its last key", fx.run())
    thread = fx.stored()["threads"][0]["id"]
    r.eq("%s: every byte outside posted: is unchanged" % what, STAMP.sub("at: T, ", fx.findings_now()),
         text.replace("posted: null\n",
                      "posted: { at: T, form: default, threads: [%d] }\n" % thread))


@test
def repost_over_earlier_values(r):
    record = "posted: { at: T, form: default,\n    threads: [11, 12] }"
    fx = Fixture("ado", posted=record)
    run = fx.run("--repost")
    what = "--repost over a value running over several lines"
    landed(r, what, run)
    thread = fx.stored()["threads"][0]["id"]
    r.eq("%s: the file reads as the literal" % what, STAMP.sub("at: T, ", fx.findings_now()),
         fx.findings_text.replace(record, "posted: { at: T, form: default, threads: [%d] }" % thread))
    r.eq("%s: the result carries the value replaced" % what, fx.result(run)["replaced"], record + "\n")
    placeholder = 'posted: "before migration - any record of it is in the body"'
    old = Fixture("ado", posted=placeholder)
    run = old.run("--repost")
    landed(r, "--repost over the placeholder", run)
    r.eq("--repost over the placeholder: the result carries the placeholder",
         old.result(run)["replaced"], placeholder + "\n")


# --- task 6: working files, the credential and portability ---------------------


def clone_status(fx):
    return subprocess.run(["git", "status", "--porcelain", "--ignored"], cwd=fx.clone, env=BUILD_ENV,
                          capture_output=True, check=True).stdout.decode()


def listing(root):
    return sorted(os.path.relpath(os.path.join(d, f), root) for d, _, files in os.walk(root) for f in files)


@test
def run_leaves_the_clone_and_the_review_folder_alone(r):
    for forge in ("github", "ado"):
        fx = Fixture(forge, threads=standard_threads())
        status, reviews = clone_status(fx), listing(os.path.dirname(fx.findings))
        what = "a%s run from inside a clone" % (" GitHub" if forge == "github" else "n ADO")
        landed(r, what, fx.run())
        r.eq("%s: git status is unchanged" % what, clone_status(fx), status)
        r.eq("%s: the review folder holds no new file" % what, listing(os.path.dirname(fx.findings)), reviews)


@test
def sentinel_token_appears_nowhere(r):
    fx = Fixture("ado", threads=standard_threads())
    fx.model["faults"]["mangle"] = {"kind": "tags"}
    fx.manifest["threads"][0]["body"] = TAGGED
    run = fx.run()
    corrected(r, "an ADO run with a sentinel token", fx, run)
    forms = (SENTINEL, base64.b64encode((":" + SENTINEL).encode()).decode())
    files = [os.path.join(fx.root, d, name) for d in ("tmp", "state") for name in listing(os.path.join(fx.root, d))]
    places = {
        "in no argument list": json.dumps([c["argv"] for c in fx.calls()]),
        "not in the stand-in's call log":
            open(os.path.join(fx.root, "forge", "calls.jsonl"), encoding="utf-8").read(),
        "not in the stand-in's model, the token it accepts aside":
            json.dumps({k: v for k, v in fx.stored().items() if k != "token"}),
        "not in the run's working files or record":
            "".join(open(f, encoding="utf-8", errors="replace").read() for f in files),
        "not in the script's output": run.out + run.err,
    }
    for place, text in places.items():
        r.check("the sentinel token: %s" % place, not any(form in text for form in forms), place)
    r.check("the sentinel token: the result JSON is among the files searched",
            any(f.endswith("result.json") for f in files), files)
    flags = [a for c in fx.calls() if c["tool"] == "curl" for a in c["argv"]
             if a in ("-v", "--verbose") or a.startswith("--trace")]
    r.eq("no call passes curl a verbose or trace flag", flags, [])


# --- the vocabulary ----------------------------------------------------------


def vocabulary_check(covered, every_test_ran):
    results = Results("vocabulary")
    proc = subprocess.run([sys.executable, SCRIPT, "--print-status-vocab"], capture_output=True)
    printed = proc.stdout.decode().split()
    results.eq("the status vocabulary matches the expected list", printed, EXPECTED_VOCAB)
    if not every_test_ran:
        return results
    uncovered = set(EXPECTED_VOCAB) - covered
    results.check("every status has a fixture", not uncovered, "without a fixture: %s" % sorted(uncovered))
    return results


def main(names):
    unknown = sorted(set(names) - {fn.__name__ for fn in TESTS} - {"vocabulary"})
    if unknown:
        print("unknown test: %s" % ", ".join(unknown))
        return 2
    build_template()
    passed = failed = 0
    covered = set()
    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
        outcomes = list(pool.map(run_test, [fn for fn in TESTS if not names or fn.__name__ in names]))
    if not names or "vocabulary" in names:
        outcomes.append(vocabulary_check(set().union(*(o.covered for o in outcomes)), not names))
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
    print("%d passed, %d failed" % (passed, failed))
    for root in CREATED:
        shutil.rmtree(root, ignore_errors=True)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
