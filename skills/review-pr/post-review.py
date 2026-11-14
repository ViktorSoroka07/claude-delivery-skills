#!/usr/bin/env python3
"""Post a review-pr manifest to GitHub or Azure DevOps, and read it back.

Run from the clone the review was made in:

    post-review.py <manifest.json> [--resume] [--repost] [--settle N] [--timeout N] [--dry-run]
    post-review.py --print-status-vocab
"""

import argparse
import functools
import json
import os
import re
import subprocess
import sys
import tempfile
import time
import urllib.parse
from dataclasses import dataclass, field
from typing import Callable, Dict, List, Optional, Set, Tuple

STATUSES = (
    "MANIFEST-INVALID", "UNSUPPORTED-FORGE", "EMPTY", "NO-FRONTMATTER", "ALREADY-POSTED",
    "POSTED-UNKNOWN", "UNFINISHED-RUN",
    "NO-TOKEN", "AUTH-REFUSED",
    "STALE-HEAD", "MISSING-COMMIT",
    "OUT-OF-DIFF", "LINE-OUT-OF-FILE", "OFF-DIFF-LINE", "STALE-SUGGESTION", "SUGGESTION-IN-GROUP",
    "PARTITION", "PENDING-EXISTS",
    "LANDED", "REJECTED", "UNCERTAIN", "UNVERIFIED", "MISSING", "CORRECTED", "MISMATCH", "MISPLACED",
    "NO-STATE", "SETTLING",
)

TOKEN_VAR = "AZURE_DEVOPS_EXT_PAT"
ADO_HOST = "dev.azure.com"
GITHUB_HOST = "github.com"
ADO_API = "api-version=7.1"
PLACEHOLDER = "before migration - any record of it is in the body"
NULL_VALUES = ("null", "~", "")
READ_RETRIES = 3
READ_RETRY_PAUSE = 2
SHA = re.compile(r"^[0-9a-f]{40}([0-9a-f]{24})?$")
TAG = re.compile(r"<[A-Za-z][A-Za-z0-9]*>")
HUNK = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@")

TOP_FIELDS = {"schema", "forge", "repo", "request", "reviewed_sha", "form", "pending",
              "findings_file", "threads"}
THREAD_FIELDS = {"key", "path", "line", "start_line", "body", "suggestion", "members"}
SUGGESTION_FIELDS = {"start", "end", "original"}
MEMBER_FIELDS = {"path", "line"}

CHILD_ENV = {k: v for k, v in os.environ.items() if k != TOKEN_VAR}


class Stop(Exception):
    def __init__(self, status, message, detail=""):
        super().__init__(message)
        self.status = status
        self.message = message
        self.detail = detail


@dataclass(frozen=True)
class Suggestion:
    start: int
    end: int
    original: Tuple[str, ...]


@dataclass(frozen=True)
class Thread:
    key: str
    path: Optional[str]
    line: Optional[int]
    start_line: Optional[int]
    body: str
    suggestion: Optional[Suggestion]
    members: Tuple[Tuple[Optional[str], Optional[int]], ...]

    @property
    def first_line(self):
        return self.start_line or self.line


@dataclass(frozen=True)
class Manifest:
    forge: str
    repo: Tuple[str, ...]
    request: int
    reviewed_sha: str
    form: str
    pending: bool
    findings_file: str
    threads: Tuple[Thread, ...]


@dataclass
class Head:
    """What pre-flight learned about the request at the forge and in the clone."""
    sha: str
    merge_base: str
    files: Set[str]
    blobs: Dict[str, List[bytes]] = field(default_factory=dict)


# --- the manifest ------------------------------------------------------------


def invalid(message):
    return Stop("MANIFEST-INVALID", message)


def is_count(value):
    return isinstance(value, int) and not isinstance(value, bool) and value >= 1


def check_fields(obj, allowed, required, where):
    if not isinstance(obj, dict):
        raise invalid("%s is not an object" % where)
    unknown = sorted(set(obj) - allowed)
    if unknown:
        raise invalid("%s has an unknown field %r" % (where, unknown[0]))
    missing = sorted(required - set(obj))
    if missing:
        raise invalid("%s lacks the field %r" % (where, missing[0]))


def parse_suggestion(raw, where, first_line, line):
    check_fields(raw, SUGGESTION_FIELDS, SUGGESTION_FIELDS, where + "'s suggestion")
    start, end, original = raw["start"], raw["end"], raw["original"]
    if not (is_count(start) and is_count(end) and start <= end):
        raise invalid("%s's suggestion needs start <= end, both line numbers" % where)
    if not (isinstance(original, list) and all(isinstance(o, str) for o in original)
            and len(original) == end - start + 1):
        raise invalid("%s's suggestion needs one original line per replaced line" % where)
    if (start, end) != (first_line, line):
        raise invalid("%s is anchored on lines %d-%d but its suggestion replaces %d-%d; the anchor "
                      "must span exactly the replaced lines" % (where, first_line, line, start, end))
    return Suggestion(start, end, tuple(original))


def parse_thread(raw, index):
    where = "thread %d" % (index + 1)
    check_fields(raw, THREAD_FIELDS, {"key", "path", "body"}, where)
    key, path, body = raw["key"], raw["path"], raw["body"]
    if not isinstance(key, str) or not key:
        raise invalid("%s needs a non-empty string key" % where)
    where = "thread %r" % key
    if not isinstance(body, str) or not body:
        raise invalid("%s needs a non-empty body" % where)
    line, start_line = raw.get("line"), raw.get("start_line")
    suggestion = None
    if path is None:
        if line is not None or start_line is not None or raw.get("suggestion") is not None:
            raise invalid("%s is request-level (path null) and so takes no line or suggestion" % where)
    else:
        if not isinstance(path, str) or not path or path.startswith("/"):
            raise invalid("%s needs a repository-relative path" % where)
        if not is_count(line):
            raise invalid("%s needs a line number" % where)
        if start_line is not None and not (is_count(start_line) and start_line < line):
            raise invalid("%s needs start_line below line, or null" % where)
        if raw.get("suggestion") is not None:
            suggestion = parse_suggestion(raw["suggestion"], where, start_line or line, line)
    members = []
    for member in raw.get("members") or []:
        check_fields(member, MEMBER_FIELDS, MEMBER_FIELDS, where + "'s member")
        members.append((member["path"], member["line"]))
    return Thread(key, path, line, start_line, body, suggestion, tuple(members))


def parse_repo(forge, repo):
    host, segments = (GITHUB_HOST, 2) if forge == "github" else (ADO_HOST, 3)
    parts = repo.split("/") if isinstance(repo, str) else []
    if len(parts) != segments + 1 or parts[0] != host or not all(parts):
        raise invalid("repo %r is not a %s repository key (%s/ and %d path segments)"
                      % (repo, forge, host, segments))
    return tuple(parts[1:])


def load_manifest(path):
    try:
        with open(path, encoding="utf-8") as f:
            raw = json.load(f)
    except (OSError, ValueError) as e:
        raise invalid("cannot read the manifest %s: %s" % (path, e)) from None
    check_fields(raw, TOP_FIELDS, TOP_FIELDS - {"pending"}, "the manifest")
    if raw["schema"] != 1:
        raise invalid("schema %r: this script reads schema 1" % (raw["schema"],))
    forge = raw["forge"]
    if forge not in ("github", "ado"):
        raise Stop("UNSUPPORTED-FORGE", "forge %r: this script posts to github and ado only; post to "
                   "any other forge by hand per references/posting-and-applying.md" % (forge,))
    repo = parse_repo(forge, raw["repo"])
    if raw["request"] is None:
        raise invalid("request is null: a branch review has no request to post to")
    if not is_count(raw["request"]):
        raise invalid("request must be the request's number")
    if not isinstance(raw["reviewed_sha"], str) or not SHA.match(raw["reviewed_sha"]):
        raise invalid("reviewed_sha must be a full commit SHA")
    if raw["form"] not in ("default", "compact"):
        raise invalid("form must be default or compact; a staged review sets pending: true")
    pending = raw.get("pending", False)
    if not isinstance(pending, bool):
        raise invalid("pending must be true or false")
    if pending and forge != "github":
        raise invalid("Azure DevOps cannot stage a review: post nothing, and leave the findings "
                      "unposted until the user says post")
    findings = raw["findings_file"]
    if not isinstance(findings, str) or not os.path.isabs(findings):
        raise invalid("findings_file must be an absolute path")
    if not isinstance(raw["threads"], list):
        raise invalid("threads must be a list")
    if not raw["threads"]:
        raise Stop("EMPTY", "the manifest holds no thread")
    threads = []
    keys = set()
    for index, item in enumerate(raw["threads"]):
        thread = parse_thread(item, index)
        if thread.key in keys:
            raise invalid("the key %r appears twice; keys must be unique" % thread.key)
        keys.add(thread.key)
        threads.append(thread)
    return Manifest(forge, repo, raw["request"], raw["reviewed_sha"], raw["form"], pending,
                    findings, tuple(threads))


# --- the findings file and the run's record -----------------------------------


def posted_value(text):
    """The frontmatter's posted: value with its continuation lines, or None
    when the file has no frontmatter or no posted: line in it."""
    lines = text.splitlines()
    if not lines or lines[0].rstrip() != "---":
        return None
    end = next((i for i in range(1, len(lines)) if lines[i].rstrip() == "---"), None)
    if end is None:
        return None
    for i in range(1, end):
        if lines[i].startswith("posted:"):
            value = [lines[i][len("posted:"):].strip()]
            value += [line.strip() for line in lines[i + 1:end] if line[:1] in (" ", "\t")]
            return " ".join(value)
    return None


def check_postable(manifest, repost):
    try:
        with open(manifest.findings_file, encoding="utf-8") as f:
            text = f.read()
    except OSError as e:
        raise invalid("cannot read the findings file: %s" % e) from None
    value = posted_value(text)
    if value is None:
        raise Stop("NO-FRONTMATTER", "the findings file has no frontmatter posted: line, so there is "
                   "nothing to guard and nowhere to record the post; add the three lines above at "
                   "its top and run again", "---\nposted: null\n---")
    bare = value.split(" #", 1)[0].strip()
    if bare in NULL_VALUES or repost:
        return
    if bare.strip("\"'") == PLACEHOLDER:
        raise Stop("POSTED-UNKNOWN", "posted: holds the migration placeholder, so the file's body may "
                   "hold the posting record. Read the body before deciding; if it shows no post, "
                   "run again with --repost")
    raise Stop("ALREADY-POSTED", "posted: already records a post (%s); run again with --repost "
               "only if this review is to go out a second time" % value)


# --- git ---------------------------------------------------------------------


def git(*args):
    proc = subprocess.run(["git", "-c", "core.quotepath=off", *args], capture_output=True,
                          env=CHILD_ENV)
    if proc.returncode != 0:
        raise subprocess.CalledProcessError(proc.returncode, args, proc.stdout, proc.stderr)
    return proc.stdout


def commit_present(sha):
    return subprocess.run(["git", "cat-file", "-e", sha + "^{commit}"], capture_output=True,
                          env=CHILD_ENV).returncode == 0


def head_lines(head, path):
    """The file's lines at the head, each without its newline; [] if it is absent there."""
    if path not in head.blobs:
        try:
            data = git("show", "%s:%s" % (head.sha, path))
        except subprocess.CalledProcessError:
            data = b""
        lines = data.split(b"\n")
        if lines and lines[-1] == b"":
            lines.pop()
        head.blobs[path] = lines
    return head.blobs[path]


def changed_lines(head, path):
    diff = git("diff", "-U0", "--no-color", "--no-ext-diff", head.merge_base, head.sha, "--", path)
    changed = set()
    for row in diff.decode("utf-8", "replace").split("\n"):
        hunk = HUNK.match(row)
        if hunk:
            start, count = int(hunk.group(1)), int(hunk.group(2) or "1")
            changed.update(range(start, start + count))
    return changed


# --- the forge ---------------------------------------------------------------


@dataclass
class Reply:
    status: Optional[int]
    content_type: str
    body: str
    error: str = ""
    headers: Dict[str, str] = field(default_factory=dict)

    def describe(self):
        if self.status is None:
            return self.error or "no answer"
        return "HTTP %d" % self.status


class Transport:
    def __init__(self, workdir, timeout, token):
        self.workdir = workdir
        self.timeout = timeout
        self.token = token
        self.files = 0

    def workfile(self, stem):
        self.files += 1
        return os.path.join(self.workdir, "%s-%03d.json" % (stem, self.files))

    def gh(self, method, path, input_file=None):
        argv = ["gh", "api", "-i", "-X", method, path]
        if input_file:
            argv += ["--input", input_file]
        try:
            proc = subprocess.run(argv, capture_output=True, timeout=self.timeout, env=CHILD_ENV)
        except subprocess.TimeoutExpired:
            return Reply(None, "", "", "no answer within %ds" % self.timeout)
        except OSError as e:
            return Reply(None, "", "", str(e))
        out = proc.stdout.decode("utf-8", "replace")
        status = re.match(r"HTTP/[\d.]+ (\d{3})", out)
        if not status:
            return Reply(None, "", "", proc.stderr.decode("utf-8", "replace").strip()
                         or "gh printed no status line")
        head, _, body = (re.split(r"(\r?\n\r?\n)", out, maxsplit=1) + ["", ""])[:3]
        headers = {}
        for row in head.splitlines()[1:]:
            name, _, value = row.partition(":")
            headers[name.strip().lower()] = value.strip()
        return Reply(int(status.group(1)), headers.get("content-type", ""), body, "", headers)

    def curl(self, method, url, data_file=None):
        reply_file = self.workfile("reply")
        argv = ["curl", "-K", "-", "-sS", "-X", method, "--max-time", str(self.timeout),
                "-o", reply_file, "-w", "%{http_code} %{content_type}", "-H", "Accept: application/json"]
        if data_file:
            argv += ["-H", "Content-Type: application/json", "--data-binary", "@" + data_file]
        argv.append(url)
        quoted = (":" + self.token).replace("\\", "\\\\").replace('"', '\\"')
        config = ('user = "%s"\n' % quoted).encode("utf-8")
        try:
            proc = subprocess.run(argv, input=config, capture_output=True, timeout=self.timeout + 5,
                                  env=CHILD_ENV)
        except subprocess.TimeoutExpired:
            return Reply(None, "", "", "no answer within %ds" % self.timeout)
        except OSError as e:
            return Reply(None, "", "", str(e))
        code, _, content_type = proc.stdout.decode("utf-8", "replace").partition(" ")
        if proc.returncode != 0 or not code.isdigit() or int(code) == 0:
            return Reply(None, "", "", proc.stderr.decode("utf-8", "replace").strip()
                         or "curl exited %d" % proc.returncode)
        try:
            with open(reply_file, encoding="utf-8", errors="replace") as f:
                body = f.read()
        except OSError:
            body = ""
        return Reply(int(code), content_type.strip(), body)


def stray_backslashes_doubled(text):
    return re.sub(r'\\(["\\/bfnrtu])|\\', lambda m: m.group(0) if m.group(1) else "\\\\", text)


def parse_reply(text):
    """JSON from a forge reply, read leniently: some forges answer a successful
    create with raw control characters and stray backslashes in the echo."""
    for candidate in (text, stray_backslashes_doubled(text)):
        try:
            return json.loads(candidate, strict=False)
        except ValueError:
            continue
    return None


def credential_refused(reply):
    return reply.status in (401, 403, 203) or (
        reply.status is not None and reply.status // 100 == 2 and "json" not in reply.content_type)


def read(fetch: Callable[[], Reply], what, hint):
    """A GET that creates nothing, so it is retried; returns (data, reply)."""
    reply = fetch()
    for _ in range(READ_RETRIES):
        if reply.status is not None and reply.status < 500:
            break
        time.sleep(READ_RETRY_PAUSE)
        reply = fetch()
    if credential_refused(reply):
        raise Stop("AUTH-REFUSED", "the forge refused the credential on %s (%s); %s" % (
            what, reply.describe(), hint))
    if reply.status is None or reply.status // 100 != 2:
        raise Stop("UNVERIFIED", "%s could not be read: %s" % (what, reply.describe()))
    data = parse_reply(reply.body)
    if data is None:
        raise Stop("UNVERIFIED", "%s answered with something other than JSON" % what)
    return data, reply


def dig(data, what, *keys):
    for key in keys:
        if not isinstance(data, dict) or key not in data:
            raise Stop("UNVERIFIED", "%s lacks %s" % (what, ".".join(keys)))
        data = data[key]
    return data


class GitHub:
    HINT = "check gh auth status"

    def __init__(self, manifest, transport):
        self.m = manifest
        self.t = transport
        self.pulls = "repos/%s/%s/pulls/%d" % (manifest.repo + (manifest.request,))

    def head_and_base(self):
        data, _ = read(functools.partial(self.t.gh, "GET", self.pulls), "the request", self.HINT)
        return dig(data, "the request", "head", "sha"), dig(data, "the request", "base", "sha")

    def user(self):
        data, _ = read(functools.partial(self.t.gh, "GET", "user"), "the authenticated user", self.HINT)
        return dig(data, "the authenticated user", "login")

    def list(self, path, what):
        items = []
        page = 1
        while True:
            url = "%s%sper_page=100&page=%d" % (path, "&" if "?" in path else "?", page)
            data, reply = read(functools.partial(self.t.gh, "GET", url), what, self.HINT)
            if not isinstance(data, list):
                raise Stop("UNVERIFIED", "%s is not a list" % what)
            items += data
            if 'rel="next"' not in reply.headers.get("link", ""):
                return items
            page += 1

    def reviews(self):
        return self.list(self.pulls + "/reviews", "the request's reviews")


class Ado:
    HINT = "set %s to a working token" % TOKEN_VAR

    def __init__(self, manifest, transport):
        self.m = manifest
        self.t = transport
        org, project, repo = (urllib.parse.quote(s, safe="") for s in manifest.repo)
        self.org = "https://%s/%s" % (ADO_HOST, org)
        self.pull = "%s/%s/_apis/git/repositories/%s/pullRequests/%d" % (
            self.org, project, repo, manifest.request)

    def head_and_base(self):
        data, _ = read(functools.partial(self.t.curl, "GET", "%s?%s" % (self.pull, ADO_API)),
                       "the request", self.HINT)
        return (dig(data, "the request", "lastMergeSourceCommit", "commitId"),
                dig(data, "the request", "lastMergeTargetCommit", "commitId"))


# --- pre-flight --------------------------------------------------------------


def check_head(manifest, forge):
    head, base = forge.head_and_base()
    if head != manifest.reviewed_sha:
        raise Stop("STALE-HEAD", "the request's head at the forge is %s, the review was made at %s; "
                   "re-anchor the findings at the new head before posting" % (head, manifest.reviewed_sha))
    for sha in (base, head):
        if not commit_present(sha):
            raise Stop("MISSING-COMMIT", "commit %s is not in this clone; run from the review's clone "
                       "and fetch it (git fetch origin), then run again" % sha)
    merge_base = git("merge-base", base, head).decode().strip()
    files = git("diff", "--name-only", "-z", "--no-ext-diff", merge_base, head).decode("utf-8")
    return Head(head, merge_base, {f for f in files.split("\0") if f})


def check_anchors(manifest, head):
    anchored = [t for t in manifest.threads if t.path is not None]
    for t in anchored:
        if t.path not in head.files:
            raise Stop("OUT-OF-DIFF", "%s is anchored on %s, which the request does not change; post it "
                       "at request level with its file:line in the prose" % (t.key, t.path))
    for t in anchored:
        if t.line > len(head_lines(head, t.path)):
            raise Stop("LINE-OUT-OF-FILE", "%s is anchored on %s:%d, past the end of the file at the "
                       "head (%d lines)" % (t.key, t.path, t.line, len(head_lines(head, t.path))))
    if manifest.forge == "github":
        for t in anchored:
            changed = changed_lines(head, t.path)
            off = [n for n in range(t.first_line, t.line + 1) if n not in changed]
            if off:
                raise Stop("OFF-DIFF-LINE", "%s is anchored on %s:%d, not a changed line; GitHub would "
                           "refuse the whole review" % (t.key, t.path, off[0]))


def check_suggestions(manifest, head):
    for t in manifest.threads:
        if t.suggestion is None:
            continue
        lines = head_lines(head, t.path)[t.suggestion.start - 1:t.suggestion.end]
        actual = [line[:-1] if line.endswith(b"\r") else line for line in lines]
        wanted = [o.encode("utf-8") for o in t.suggestion.original]
        if actual != wanted:
            raise Stop("STALE-SUGGESTION", "%s's suggestion replaces %s:%d-%d, whose lines at the head "
                       "differ from the ones the finding recorded; drop the block and keep the prose fix"
                       % (t.key, t.path, t.suggestion.start, t.suggestion.end))
    for t in manifest.threads:
        if t.suggestion is not None and len(t.members) > 1:
            raise Stop("SUGGESTION-IN-GROUP", "%s groups %d findings and carries a suggestion block; "
                       "turn the block into a plain replacement snippet" % (t.key, len(t.members)))


def check_partition(manifest, head):
    for t in manifest.threads:
        inside = ["%s:%s" % m for m in t.members if m[0] in head.files]
        if t.path is None and inside:
            raise Stop("PARTITION", "%s is posted at request level, but its members %s are in the diff "
                       "and would lose their anchor; split the row or anchor it on an in-diff member"
                       % (t.key, ", ".join(inside)))


def outside_code(body):
    return re.sub(r"`[^`\n]*`", "", re.sub(r"(?ms)^(`{3,}|~{3,}).*?^\1", "", body))


def warn_tags(manifest):
    for t in manifest.threads:
        for tag in sorted(set(TAG.findall(outside_code(t.body)))):
            print("warning: %s carries %s outside code; a sanitizer may drop it, and the read-back "
                  "would show it" % (t.key, tag))


def check_pending(manifest, forge, login):
    if not manifest.pending:
        return
    for review in forge.reviews():
        if review.get("state") == "PENDING" and (review.get("user") or {}).get("login") == login:
            raise Stop("PENDING-EXISTS", "%s already has a pending review on this request (id %s); "
                       "submit or delete it first" % (login, review.get("id")))


def preflight(manifest, args, transport):
    check_postable(manifest, args.repost)
    if manifest.forge == "ado" and not transport.token:
        raise Stop("NO-TOKEN", "%s is unset; an Azure DevOps post needs a token there" % TOKEN_VAR)
    forge = GitHub(manifest, transport) if manifest.forge == "github" else Ado(manifest, transport)
    head = check_head(manifest, forge)
    check_anchors(manifest, head)
    check_suggestions(manifest, head)
    check_partition(manifest, head)
    warn_tags(manifest)
    if manifest.forge == "github":
        check_pending(manifest, forge, forge.user())
    return forge, head


# --- the run -----------------------------------------------------------------


def parse_args(argv):
    parser = argparse.ArgumentParser(prog="post-review.py")
    parser.add_argument("manifest", nargs="?")
    parser.add_argument("--resume", action="store_true")
    parser.add_argument("--repost", action="store_true")
    parser.add_argument("--settle", type=int, default=600)
    parser.add_argument("--timeout", type=int, default=60)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--print-status-vocab", action="store_true")
    args = parser.parse_args(argv)
    if not args.print_status_vocab and args.manifest is None:
        parser.error("a manifest path is required")
    return args


def run(args, workdir):
    manifest = load_manifest(args.manifest)
    transport = Transport(workdir, args.timeout, os.environ.get(TOKEN_VAR, ""))
    preflight(manifest, args, transport)
    print("posting is not built yet", file=sys.stderr)
    return 2


def main(argv):
    args = parse_args(argv)
    if args.print_status_vocab:
        print("\n".join(STATUSES))
        return 0
    workdir = tempfile.mkdtemp(prefix="post-review-")
    try:
        rc = run(args, workdir)
    except Stop as stop:
        if stop.detail:
            print(stop.detail)
        print("%s %s" % (stop.status, stop.message))
        rc = 1
    print(workdir)
    return rc


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
