#!/usr/bin/env python3
"""Post a review-pr manifest to GitHub or Azure DevOps, and read it back.

Run from the clone the review was made in:

    post-review.py <manifest.json> [--resume] [--repost] [--settle N] [--timeout N] [--dry-run]
                   [--ignore-item ID ...]
    post-review.py --print-status-vocab
"""

import argparse
import difflib
import functools
import hashlib
import itertools
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
    "NO-STATE", "SETTLING", "MOVED-MID-RUN", "DRY-RUN",
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

TOP_FIELDS = {"schema", "forge", "repo", "request", "reviewed_sha", "verified_head", "form", "pending",
              "findings_file", "threads"}
THREAD_FIELDS = {"key", "path", "line", "start_line", "body", "suggestion", "members"}
SUGGESTION_FIELDS = {"start", "end", "original"}
MEMBER_FIELDS = {"path", "line"}

CHILD_ENV = {k: v for k, v in os.environ.items() if k != TOKEN_VAR}
FINISHED = ("LANDED", "CORRECTED")
CLOSED = FINISHED + ("MOVED-MID-RUN",)
LATEST_REVIEWS = ("query($owner: String!, $name: String!, $number: Int!) { repository(owner: $owner, "
                  "name: $name) { pullRequest(number: $number) { latestReviews(first: 100) { nodes { "
                  "databaseId } } } } }")


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
    verified_head: str
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
    check_fields(raw, TOP_FIELDS, TOP_FIELDS - {"pending", "verified_head"}, "the manifest")
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
    verified_head = raw.get("verified_head", raw["reviewed_sha"])
    if not isinstance(verified_head, str) or not SHA.match(verified_head):
        raise invalid("verified_head must be a full commit SHA")
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
    return Manifest(forge, repo, raw["request"], raw["reviewed_sha"], verified_head, raw["form"],
                    pending, findings, tuple(threads))


# --- the findings file and the run's record -----------------------------------


def frontmatter(text):
    """The lines between the file's opening and closing ---, or None when it has no frontmatter."""
    lines = text.splitlines()
    if not lines or lines[0].rstrip() != "---":
        return None
    end = next((i for i in range(1, len(lines)) if lines[i].rstrip() == "---"), None)
    return None if end is None else lines[1:end]


def scalar(fields, key):
    """A one-line frontmatter value, unquoted and without its comment, or None when the key is absent."""
    for line in fields:
        if line.startswith(key + ":"):
            return line[len(key) + 1:].split(" #", 1)[0].strip().strip("\"'")
    return None


def posted_value(text):
    """The frontmatter's posted: value with its continuation lines, or None
    when the file has no frontmatter or no posted: line in it."""
    fields = frontmatter(text)
    if fields is None:
        return None
    for i, line in enumerate(fields):
        if line.startswith("posted:"):
            value = [line[len("posted:"):].strip()]
            value += [more.strip() for more in itertools.takewhile(
                lambda more: more[:1] in (" ", "\t"), fields[i + 1:])]
            return " ".join(value)
    return None


def check_same_review(manifest, fields):
    """The findings file must be the review of this request at this head: the write-back
    marks it posted, and a file of another request's review would be marked instead."""
    expected = [("pr", str(manifest.request)),
                ("reviewed_sha", manifest.reviewed_sha)]
    for key, want in expected:
        got = scalar(fields, key)
        if got != want:
            raise invalid("the findings file %s, but the manifest posts %s: %s; build the manifest "
                          "from the findings file of the review it posts" % (
                              "has no %s line" % key if got is None else "records %s: %s" % (key, got),
                              key, want))


def check_postable(manifest, repost):
    try:
        with open(manifest.findings_file, encoding="utf-8") as f:
            text = f.read()
    except OSError as e:
        raise invalid("cannot read the findings file: %s" % e) from None
    value = posted_value(text)
    if value is None:
        fields = frontmatter(text)
        keys = [("pr", manifest.request), ("reviewed_sha", manifest.reviewed_sha), ("posted", "null")]
        if fields is None:
            raise Stop("NO-FRONTMATTER", "the findings file has no frontmatter, so there is nothing to "
                       "guard and nowhere to record the post; add the lines above at its top and run "
                       "again", "---\n%s---" % "".join("%s: %s\n" % kv for kv in keys))
        raise Stop("NO-FRONTMATTER", "the findings file's frontmatter has no posted: line, so there is "
                   "nowhere to record the post; add the lines above inside that block, before its "
                   "closing ---, and run again",
                   "".join("%s: %s\n" % kv for kv in keys if scalar(fields, kv[0]) is None).rstrip("\n"))
    check_same_review(manifest, frontmatter(text))
    bare = value.split(" #", 1)[0].strip()
    if bare in NULL_VALUES or repost:
        return
    if bare.strip("\"'") == PLACEHOLDER:
        raise Stop("POSTED-UNKNOWN", "posted: holds the migration placeholder, so the file's body may "
                   "hold the posting record. Read the body before deciding; if it shows no post, "
                   "run again with --repost")
    raise Stop("ALREADY-POSTED", "posted: already records a post (%s); run again with --repost "
               "only if this review is to go out a second time" % value)


def posted_record(manifest, forge, head):
    fields = [("at", time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())),
              ("form", "pending" if manifest.pending else manifest.form)] + forge.posted()
    if manifest.pending or head.sha != manifest.reviewed_sha:
        fields.append(("head", head.sha[:7]))
    return "{ %s }" % ", ".join("%s: %s" % field for field in fields)


def write_posted(path, value):
    """Replace the frontmatter's posted: value and its continuation lines, leaving every other
    byte of the file as it was; returns the text replaced."""
    with open(path, encoding="utf-8", newline="") as f:
        lines = f.read().splitlines(True)
    end = next(i for i in range(1, len(lines)) if lines[i].rstrip() == "---")
    start = next(i for i in range(1, end) if lines[i].startswith("posted:"))
    stop = start + 1
    while stop < end and lines[stop][:1] in (" ", "\t"):
        stop += 1
    replaced = "".join(lines[start:stop])
    ending = lines[start][len(lines[start].rstrip("\r\n")):]
    lines[start:stop] = ["posted: %s%s" % (value, ending)]
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8", newline="") as f:
        f.write("".join(lines))
    os.replace(tmp, path)
    return replaced


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

    def gh(self, method, path, input_file=None, fields=()):
        argv = ["gh", "api", "-i", "-X", method, path]
        if input_file:
            argv += ["--input", input_file]
        for flag, value in fields:
            argv += [flag, value]
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


def read(fetch: Callable[[], Reply], what, hint, absent_ok=False):
    """A GET that creates nothing, so it is retried; returns (data, reply), and with
    absent_ok (None, reply) for a 404."""
    reply = fetch()
    for _ in range(READ_RETRIES):
        if reply.status is not None and reply.status < 500:
            break
        time.sleep(READ_RETRY_PAUSE)
        reply = fetch()
    if credential_refused(reply):
        raise Stop("AUTH-REFUSED", "the forge refused the credential on %s (%s); %s" % (
            what, reply.describe(), hint))
    if absent_ok and reply.status == 404:
        return None, reply
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


# --- posting and reading back ------------------------------------------------


def classify_create(reply):
    if reply.status is None or reply.status >= 500 or reply.status == 203:
        return "uncertain"
    if 200 <= reply.status < 300:
        return "landed" if "json" in reply.content_type else "uncertain"
    return "rejected"


def forge_message(reply):
    data = parse_reply(reply.body)
    message = data.get("message") if isinstance(data, dict) else None
    return (message or reply.body.strip() or reply.describe())[:300]


def send(record, key, create: Callable[[], Reply]):
    """Run one create, recording it before and after; False when its answer was lost, so the
    create may or may not have landed."""
    record.event("sending", key, time.time())
    reply = create()
    outcome = classify_create(reply)
    if outcome == "landed":
        data = parse_reply(reply.body)
        record.event("landed", key, data.get("id") if isinstance(data, dict) else None)
        return True
    if outcome == "rejected":
        record.event("rejected", key, reply.status)
        raise Stop("REJECTED", "the forge refused %s with %s: %s" % (key, reply.describe(),
                                                                    forge_message(reply)))
    record.event("uncertain", key, time.time())
    print("%s on %s: it may have landed, so it is not retried; reading the request back" % (
        reply.describe(), key))
    return False


@dataclass
class Item:
    """One item of the user's the read-back found: an ADO thread, a GitHub review or comment."""
    id: object
    body: str
    anchor: tuple
    place: object
    ref: object = None
    url: str = ""


@dataclass
class Wanted:
    """What one manifest thread should have become."""
    key: str
    body: str
    anchor: tuple
    place: object


def pair(wanted, items, known_ids):
    """Pair each wanted thread with one item: by the id its create returned, then
    by exact body, then by anchor; a match counts only when it is one-to-one."""
    pairs = {}
    free = list(items)
    stages = (lambda w, i: known_ids.get(w.key) is not None and i.id == known_ids[w.key],
              lambda w, i: i.body == w.body,
              lambda w, i: i.anchor == w.anchor)
    for same in stages:
        open_threads = [w for w in wanted if w.key not in pairs]
        hits = {w.key: [i for i in free if same(w, i)] for w in open_threads}
        for w in open_threads:
            if len(hits[w.key]) == 1:
                item = hits[w.key][0]
                if sum(any(x is item for x in h) for h in hits.values()) == 1:
                    pairs[w.key] = item
        free = [i for i in free if not any(i is p for p in pairs.values())]
    if free:
        ids = ", ".join(str(i.id) for i in free)
        raise Stop("UNCERTAIN", "the request holds new items of yours that pair with no thread (ids %s); "
                   "something landed that this run cannot account for. Ask the user about each: one "
                   "they wrote themselves stays, and --resume --ignore-item <id> leaves it out of the "
                   "pairing; a copy of one of this manifest's threads is theirs to delete before "
                   "--resume" % ids)
    return pairs


def require(pairs, wanted):
    missing = [w.key for w in wanted if w.key not in pairs]
    if missing:
        raise Stop("MISSING", "the read-back does not show %s, even read by id" % ", ".join(missing))
    return pairs


def with_landed(items, record, by_id):
    """The listed items, plus each created id the list lacks, read once by its id."""
    listed = {i.id for i in items}
    for created in record.landed_ids().values():
        if created is not None and created not in listed:
            item = by_id(created)
            if item is not None:
                items.append(item)
    return items


def verdict(body_sent, body_stored, place_sent, place_stored):
    if body_stored != body_sent:
        return "MISMATCH"
    if place_stored != place_sent:
        return "MISPLACED"
    return "LANDED"


class Outcome:
    def __init__(self):
        self.rows = []
        self.diffs = []
        self.notes = []
        self.replaced = None

    def judge(self, wanted, item, where, before=None):
        """Judge one thread as read back; `before` is the body a correction replaced, if any."""
        status = verdict(wanted.body, item.body, wanted.place, item.place)
        row = {"key": wanted.key, "id": item.id, "anchor": where, "status": status}
        if status == "LANDED" and before is not None:
            row.update(status="CORRECTED", before=before, after=item.body)
        self.rows.append(row)
        if status == "MISMATCH":
            self.diffs.append("".join(difflib.unified_diff(
                wanted.body.splitlines(True), item.body.splitlines(True),
                "%s as sent" % wanted.key, "%s as stored" % wanted.key)))
        print("%s %s %s %s" % (row["status"], wanted.key, item.id, where))

    def finish(self):
        statuses = {row["status"] for row in self.rows}
        for status in ("MISMATCH", "MISPLACED"):
            if status in statuses:
                keys = [row["key"] for row in self.rows if row["status"] == status]
                raise Stop(status, "%s did not read back as sent: %s" % (
                    "the stored text of" if status == "MISMATCH" else "the placement of",
                    ", ".join(keys)), "\n".join(self.diffs))
        return "CORRECTED" if "CORRECTED" in statuses else "LANDED"


def label(path, line):
    return "%s:%s" % (path, line) if path else "request-level"


def diff_positions(head, path):
    """{right-side line: position} in the file's unified diff, git's default
    three lines of context, counted from the line under the first hunk header."""
    diff = git("diff", "-U3", "--no-color", "--no-ext-diff", head.merge_base, head.sha, "--", path)
    positions = {}
    position = None
    line = 0
    for row in diff.decode("utf-8", "replace").split("\n"):
        hunk = HUNK.match(row)
        if hunk:
            line = int(hunk.group(1))
            position = 0 if position is None else position + 1
        elif position is not None and row[:1] in ("+", " ", "-"):
            position += 1
            if row[:1] != "-":
                positions[line] = position
                line += 1
    return positions


def write_payload(transport, payload):
    path = transport.workfile("payload")
    with open(path, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False)
    return path


class GitHub:
    HINT = "check gh auth status"

    def __init__(self, manifest, transport):
        self.m = manifest
        self.t = transport
        self.pulls = "repos/%s/%s/pulls/%d" % (manifest.repo + (manifest.request,))
        self.login = None
        self.review = None

    def head_and_base(self):
        data, _ = read(functools.partial(self.t.gh, "GET", self.pulls), "the request", self.HINT)
        return dig(data, "the request", "head", "sha"), dig(data, "the request", "base", "sha")

    def user(self):
        if self.login is None:
            data, _ = read(functools.partial(self.t.gh, "GET", "user"), "the authenticated user",
                           self.HINT)
            self.login = dig(data, "the authenticated user", "login")
        return self.login

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

    def my_reviews(self):
        return [r for r in self.reviews() if (r.get("user") or {}).get("login") == self.user()]

    def snapshot(self):
        return [r.get("id") for r in self.my_reviews()]

    def payload(self):
        comments = []
        for t in self.m.threads:
            if t.path is None:
                continue
            comment = {"path": t.path, "line": t.line, "side": "RIGHT", "body": t.body}
            if t.start_line:
                comment["start_line"] = t.start_line
                comment["start_side"] = "RIGHT"
            comments.append(comment)
        payload = {"commit_id": self.m.verified_head, "body": self.review_body(), "comments": comments}
        if not self.m.pending:
            payload["event"] = "COMMENT"
        return payload

    def review_body(self):
        return "\n\n".join(t.body for t in self.m.threads if t.path is None)

    def plan(self, head):
        print("would POST %s/reviews with %d inline comments%s" % (
            self.pulls, len(self.payload()["comments"]), ", staged" if self.m.pending else ""))

    def units(self, head):
        """What each create should become: on GitHub the whole review is one create."""
        return [Wanted("review", self.review_body(), (), None)]

    def create(self, key, head):
        return functools.partial(self.t.gh, "POST", self.pulls + "/reviews",
                                 write_payload(self.t, self.payload()))

    def review_item(self, review):
        return Item(review.get("id"), review.get("body") or "", (), None, ("review", review.get("id")),
                    review.get("html_url") or "")

    def review_by_id(self, review_id):
        data, _ = read(functools.partial(self.t.gh, "GET", "%s/reviews/%s" % (self.pulls, review_id)),
                       "review %s" % review_id, self.HINT, absent_ok=True)
        return self.review_item(data) if isinstance(data, dict) else None

    def new_items(self, record):
        listed = [self.review_item(r) for r in self.my_reviews() if r.get("id") not in record.data["snapshot"]]
        return with_landed(listed, record, self.review_by_id)

    def read_back(self, head, record):
        """[(wanted, item, where)] for every thread, paired with what the forge stores."""
        units = self.units(head)
        self.review = require(pair(units, self.new_items(record), record.landed_ids()), units)["review"]
        rows = [(Wanted(t.key, self.review_body(), (), None), self.review, label(None, None))
                for t in self.m.threads if t.path is None]
        inline = [t for t in self.m.threads if t.path is not None]
        if self.m.pending:
            positions = {t.path: diff_positions(head, t.path) for t in inline}
            stored = self.list("%s/reviews/%s/comments" % (self.pulls, self.review.id),
                               "the staged review's comments")
            items = [Item(c.get("id"), c.get("body"), (c.get("path"), c.get("position")),
                          (c.get("path"), c.get("position"), c.get("commit_id")), ("comment", c.get("id")))
                     for c in stored]
            wanted = [Wanted(t.key, t.body, (t.path, positions[t.path].get(t.line)),
                             (t.path, positions[t.path].get(t.line), head.sha))
                      for t in inline]
        else:
            stored = [c for c in self.list(self.pulls + "/comments", "the request's comments")
                      if c.get("pull_request_review_id") == self.review.id]
            items = [Item(c.get("id"), c.get("body"), (c.get("path"), c.get("line")),
                          (c.get("path"), c.get("line"), c.get("start_line"), c.get("side")),
                          ("comment", c.get("id")))
                     for c in stored]
            wanted = [Wanted(t.key, t.body, (t.path, t.line), (t.path, t.line, t.start_line, "RIGHT"))
                      for t in inline]
        pairs = require(pair(wanted, items, {}), wanted)
        return rows + [(w, pairs[w.key], label(t.path, t.line)) for w, t in zip(wanted, inline)]

    def correct(self, item, body):
        """Put the sent body back in place; None where nothing may be edited."""
        if self.m.pending:
            return None
        kind, target = item.ref
        if kind == "review":
            method, path = "PUT", "%s/reviews/%s" % (self.pulls, target)
        else:
            method, path = "PATCH", "repos/%s/%s/pulls/comments/%s" % (self.m.repo + (target,))
        return self.t.gh(method, path, write_payload(self.t, {"body": body}))

    def posted(self):
        return [("review_id", self.review.id), ("url", self.review.url)]

    def notes(self, record):
        """A review whose create lost its answer may exist yet be missing from latestReviews."""
        if not record.ever("uncertain", "review"):
            return []
        fields = [("-f", "query=" + LATEST_REVIEWS), ("-f", "owner=" + self.m.repo[0]),
                  ("-f", "name=" + self.m.repo[1]), ("-F", "number=%d" % self.m.request)]
        data, _ = read(functools.partial(self.t.gh, "POST", "graphql", None, fields),
                       "the request's latestReviews", self.HINT)
        nodes = dig(data, "latestReviews", "data", "repository", "pullRequest", "latestReviews", "nodes")
        if any(isinstance(n, dict) and n.get("databaseId") == self.review.id for n in nodes):
            return []
        return ["review %s landed but is absent from latestReviews, so the request page may not show "
                "it; the reference's remedy, a second minimal review, is a post for you to decide on"
                % self.review.id]



def ado_end_offset(raw_line):
    """Apply replaces exactly the span, counted in UTF-16 units, with a CRLF terminator outside it."""
    text = raw_line.decode("utf-8").rstrip("\r")
    return len(text.encode("utf-16-le")) // 2 + 1


def ado_context(t, head):
    if t.path is None:
        return None
    end = ado_end_offset(head_lines(head, t.path)[t.line - 1]) if t.suggestion else 2
    return {"filePath": "/" + t.path, "rightFileStart": {"line": t.first_line, "offset": 1},
            "rightFileEnd": {"line": t.line, "offset": end}}


def context_fields(context):
    if not context:
        return None
    return {k: context.get(k) for k in ("filePath", "rightFileStart", "rightFileEnd")}


class Ado:
    HINT = "set %s to a working token" % TOKEN_VAR

    def __init__(self, manifest, transport):
        self.m = manifest
        self.t = transport
        org, project, repo = (urllib.parse.quote(s, safe="") for s in manifest.repo)
        self.org = "https://%s/%s" % (ADO_HOST, org)
        self.pull = "%s/%s/_apis/git/repositories/%s/pullRequests/%d" % (
            self.org, project, repo, manifest.request)
        self.threads_url = "%s/threads?%s" % (self.pull, ADO_API)
        self.user_id = None
        self.ids = []

    def head_and_base(self):
        data, _ = read(functools.partial(self.t.curl, "GET", "%s?%s" % (self.pull, ADO_API)),
                       "the request", self.HINT)
        return (dig(data, "the request", "lastMergeSourceCommit", "commitId"),
                dig(data, "the request", "lastMergeTargetCommit", "commitId"))

    def user(self):
        if self.user_id is None:
            data, _ = read(functools.partial(self.t.curl, "GET", self.org + "/_apis/connectionData"),
                           "the authenticated user", self.HINT)
            self.user_id = dig(data, "the authenticated user", "authenticatedUser", "id")
        return self.user_id

    def first_comment(self, thread):
        """The thread's opening comment when the user wrote it, else None."""
        comments = sorted(thread.get("comments") or [], key=lambda c: c.get("id", 0))
        if comments and (comments[0].get("author") or {}).get("id") == self.user():
            return comments[0]
        return None

    def my_threads(self):
        data, _ = read(functools.partial(self.t.curl, "GET", self.threads_url), "the request's threads",
                       self.HINT)
        threads = dig(data, "the request's threads", "value")
        return [(thread, self.first_comment(thread)) for thread in threads if self.first_comment(thread)]

    def snapshot(self):
        return [thread.get("id") for thread, _ in self.my_threads()]

    def payload(self, t, head):
        payload = {"comments": [{"parentCommentId": 0, "content": t.body, "commentType": 1}],
                   "status": 1}
        context = ado_context(t, head)
        if context:
            payload["threadContext"] = context
        return payload

    def plan(self, head):
        for t in self.m.threads:
            print("would POST %s for %s at %s" % (self.threads_url, t.key, label(t.path, t.line)))

    def units(self, head):
        return [Wanted(t.key, t.body, (t.path, t.first_line),
                       (False, "active", context_fields(ado_context(t, head))))
                for t in self.m.threads]

    def create(self, key, head):
        thread = next(t for t in self.m.threads if t.key == key)
        return functools.partial(self.t.curl, "POST", self.threads_url,
                                 write_payload(self.t, self.payload(thread, head)))

    def item(self, thread, comment):
        context = thread.get("threadContext")
        anchor = ((context.get("filePath") or "").lstrip("/"),
                  (context.get("rightFileStart") or {}).get("line")) if context else (None, None)
        return Item(thread.get("id"), comment.get("content"), anchor,
                    (bool(thread.get("isDeleted")), thread.get("status"), context_fields(context)),
                    (thread.get("id"), comment.get("id")))

    def thread_by_id(self, thread_id):
        url = "%s/threads/%s?%s" % (self.pull, thread_id, ADO_API)
        thread, _ = read(functools.partial(self.t.curl, "GET", url), "thread %s" % thread_id, self.HINT,
                         absent_ok=True)
        comment = self.first_comment(thread) if isinstance(thread, dict) else None
        return self.item(thread, comment) if comment else None

    def new_items(self, record):
        listed = [self.item(thread, comment) for thread, comment in self.my_threads()
                  if thread.get("id") not in record.data["snapshot"]]
        return with_landed(listed, record, self.thread_by_id)

    def read_back(self, head, record):
        wanted = self.units(head)
        pairs = require(pair(wanted, self.new_items(record), record.landed_ids()), wanted)
        self.ids = [pairs[w.key].id for w in wanted]
        return [(w, pairs[w.key], label(t.path, t.line)) for w, t in zip(wanted, self.m.threads)]

    def correct(self, item, body):
        thread_id, comment_id = item.ref
        url = "%s/threads/%s/comments/%s?%s" % (self.pull, thread_id, comment_id, ADO_API)
        return self.t.curl("PATCH", url, write_payload(self.t, {"content": body}))

    def posted(self):
        return [("threads", "[%s]" % ", ".join(str(i) for i in self.ids))]

    def notes(self, record):
        return []



# --- the run's record ---------------------------------------------------------


def record_path(findings_file):
    root = os.environ.get("XDG_STATE_HOME") or os.path.join(os.path.expanduser("~"), ".local", "state")
    digest = hashlib.sha256(os.path.realpath(findings_file).encode("utf-8")).hexdigest()[:16]
    return os.path.join(root, "delivery-skills", "post-review", digest, "state.json")


class Record:
    """The run's state outside the clone: what was sent and what landed, so a
    stop leaves an exact account and a plain re-run cannot double a post."""

    def __init__(self, path, data):
        self.path = path
        self.data = data

    @classmethod
    def load(cls, path):
        try:
            with open(path, encoding="utf-8") as f:
                return cls(path, json.load(f))
        except FileNotFoundError:
            return None
        except (OSError, ValueError) as e:
            raise Stop("UNFINISHED-RUN", "the run record %s cannot be read (%s); read it before "
                       "posting again" % (path, e)) from None

    def save(self):
        os.makedirs(os.path.dirname(self.path), exist_ok=True)
        tmp = self.path + ".tmp"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(self.data, f, indent=1)
        os.replace(tmp, self.path)

    def event(self, *fields):
        self.data["events"].append(list(fields))
        self.save()

    def last_events(self):
        last = {}
        for event in self.data["events"]:
            last[event[1]] = event
        return last

    def landed_ids(self):
        return {key: e[2] for key, e in self.last_events().items() if e[0] == "landed"}

    def ever(self, verb, key):
        return any(e[0] == verb and e[1] == key for e in self.data["events"])

    def unfinished(self):
        return self.data.get("status") not in CLOSED and any(
            e[0] in ("sending", "landed", "uncertain") for e in self.last_events().values())

    def in_doubt_since(self):
        """When the latest create still in doubt was made: one whose answer was lost, or one
        whose run died before its outcome was written. None when no call is in flight."""
        times = [e[2] for e in self.last_events().values() if e[0] in ("sending", "uncertain")]
        return max(times) if times else None


# --- pre-flight --------------------------------------------------------------


def check_head(manifest, forge):
    head, base = forge.head_and_base()
    if head != manifest.verified_head:
        raise Stop("STALE-HEAD", "the request's head at the forge is %s, and the manifest's threads were "
                   "verified at %s. Fetch it (git fetch origin), re-verify every thread at %s per "
                   "posting-and-applying.md's \"Re-verify first\" (an anchor whose line moved follows "
                   "it; a suggestion whose lines changed loses its block, its prose stays), update the "
                   "manifest's threads, set its verified_head to %s and run again. Leave reviewed_sha "
                   "as it is: it names the head the review covered"
                   % (head, manifest.verified_head, head, head))
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


def check_record(manifest, resume):
    record = Record.load(record_path(manifest.findings_file))
    if resume:
        if record is None or not record.unfinished():
            raise Stop("NO-STATE", "no unfinished run is recorded for this findings file, so there is "
                       "nothing to resume; run without --resume")
        return record
    if record is not None and record.unfinished():
        held = [key for key, e in record.last_events().items() if e[0] != "rejected"]
        raise Stop("UNFINISHED-RUN", "an earlier run on this findings file stopped %s with %s landed "
                   "or in doubt; posting the manifest again would double them, so continue it with "
                   "--resume" % (record.data.get("status"), ", ".join(held)))
    return None


def check_settled(record, settle):
    since = record.in_doubt_since()
    if since is None:
        return
    left = since + settle - time.time()
    if left > 0:
        raise Stop("SETTLING", "a create made %ds ago lost its answer and may still land; resume in "
                   "%ds, so that a late copy is on the request before the read that decides what "
                   "to post again" % (time.time() - since, left + 1))


def preflight(manifest, args, transport):
    check_postable(manifest, args.repost)
    record = check_record(manifest, args.resume)
    if record is not None:
        check_settled(record, args.settle)
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
    return forge, head, record


# --- the run -----------------------------------------------------------------


def parse_args(argv):
    parser = argparse.ArgumentParser(prog="post-review.py")
    parser.add_argument("manifest", nargs="?")
    parser.add_argument("--resume", action="store_true")
    parser.add_argument("--repost", action="store_true")
    parser.add_argument("--settle", type=int, default=600)
    parser.add_argument("--timeout", type=int, default=60)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--ignore-item", type=int, action="append", default=[])
    parser.add_argument("--print-status-vocab", action="store_true")
    args = parser.parse_args(argv)
    if not args.print_status_vocab and args.manifest is None:
        parser.error("a manifest path is required")
    return args


def reconcile(forge, head, record, keys):
    """Pair the request's new items with the creates named, record each pairing with the
    forge's id, and return the keys nothing on the request pairs with."""
    wanted = [w for w in forge.units(head) if w.key in keys]
    pairs = pair(wanted, forge.new_items(record), record.landed_ids())
    for w in wanted:
        if w.key in pairs and record.landed_ids().get(w.key) != pairs[w.key].id:
            record.event("landed", w.key, pairs[w.key].id)
    return [w.key for w in wanted if w.key not in pairs]


def check_same_head(record, head, keys, todo):
    """A run posts every thread at one head. A resume after the request moved goes on only
    when nothing of the run is on the request; otherwise it stops and closes the run."""
    if record.data["head"] == head.sha:
        return
    if len(todo) == len(keys):
        record.data["head"] = head.sha
        record.save()
        return
    on_request = [key for key in keys if key not in todo]
    raise Stop("MOVED-MID-RUN", "%s landed at %s before the request moved to %s%s. A run posts at one "
               "head, so this one is closed here. Tell the user which threads landed at which head. "
               "To post the rest at %s, take the landed threads out of the manifest and run again "
               "without --resume; if none is left, the post is complete at %s, and its posted: line, "
               "with head: %s, is written by hand" % (
                   ", ".join(on_request), record.data["head"][:7], head.sha[:7],
                   "; %s did not" % ", ".join(todo) if todo else "", head.sha[:7],
                   record.data["head"][:7], record.data["head"][:7]))


def post(forge, head, record, keys, settle):
    for key in keys:
        if send(record, key, forge.create(key, head)):
            continue
        sent = [w.key for w in forge.units(head) if w.key in record.last_events()]
        absent = reconcile(forge, head, record, sent)
        if absent:
            raise Stop("UNCERTAIN", "the request does not show %s, and a create whose answer was lost "
                       "may still land, so nothing is retried; run again with --resume once %ds have "
                       "passed: it reads the request first and posts only what is still absent"
                       % (", ".join(absent), settle))


def verify(forge, head, record, outcome):
    """Read every thread back, put a stored body that differs from the one sent back in place
    once, and judge each thread by the read that follows the correction."""
    rows = forge.read_back(head, record)
    replaced = {}
    for wanted, item, _ in rows:
        if item.ref not in replaced and verdict(wanted.body, item.body, None, None) == "MISMATCH":
            if forge.correct(item, wanted.body) is not None:
                replaced[item.ref] = item.body
    if replaced:
        rows = forge.read_back(head, record)
    for wanted, item, where in rows:
        outcome.judge(wanted, item, where, replaced.get(item.ref))


def run(args, workdir, outcome, started):
    manifest = load_manifest(args.manifest)
    transport = Transport(workdir, args.timeout, os.environ.get(TOKEN_VAR, ""))
    forge, head, record = preflight(manifest, args, transport)
    if args.dry_run:
        forge.plan(head)
        print("DRY-RUN every check passed and nothing was posted; the lines above are the creates a "
              "run would make")
        return "DRY-RUN"
    keys = [w.key for w in forge.units(head)]
    if record is None:
        record = Record(record_path(manifest.findings_file), {
            "started": time.time(), "head": head.sha, "snapshot": forge.snapshot(), "events": [],
            "status": None})
        record.save()
        started.append(record)
        todo = keys
    else:
        started.append(record)
        record.data["snapshot"] += [i for i in args.ignore_item if i not in record.data["snapshot"]]
        todo = reconcile(forge, head, record, keys)
        check_same_head(record, head, keys, todo)
        print("resuming: %d of %d already on the request; posting %s" % (
            len(keys) - len(todo), len(keys), ", ".join(todo) or "nothing"))
    post(forge, head, record, todo, args.settle)
    verify(forge, head, record, outcome)
    status = outcome.finish()
    for note in forge.notes(record):
        print("note: " + note)
        outcome.notes.append(note)
    replaced = write_posted(manifest.findings_file, posted_record(manifest, forge, head))
    if args.repost:
        outcome.replaced = replaced
    record.data["status"] = status
    record.save()
    print("%s %d threads posted and read back as sent%s; posted: written" % (
        status, len(manifest.threads), ", some after a correction" if status == "CORRECTED" else ""))
    return status


def main(argv):
    args = parse_args(argv)
    if args.print_status_vocab:
        print("\n".join(STATUSES))
        return 0
    workdir = tempfile.mkdtemp(prefix="post-review-")
    outcome = Outcome()
    started = []
    try:
        status = run(args, workdir, outcome, started)
        rc = 0
    except Stop as stop:
        status = stop.status
        for record in started:
            record.data["status"] = stop.status
            record.save()
            for key, created in record.landed_ids().items():
                print("landed before the stop: %s %s" % (key, created))
        if stop.detail:
            print(stop.detail)
        print("%s %s" % (stop.status, stop.message))
        rc = 1
    with open(os.path.join(workdir, "result.json"), "w", encoding="utf-8") as f:
        result = {"status": status, "threads": outcome.rows, "notes": outcome.notes}
        if outcome.replaced is not None:
            result["replaced"] = outcome.replaced
        json.dump(result, f, indent=1)
    print(workdir)
    return rc


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
