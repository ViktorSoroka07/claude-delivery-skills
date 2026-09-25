#!/usr/bin/env python3
"""UserPromptSubmit and Stop hook: at a turn's end, hand the session the lines
elsewhere that still say what its change to a rule file replaced.

A rule landed in the file that owns it leaves every other copy of its subject
- a checklist further down, a README's paraphrase, the short form in
CLAUDE.md - reading as complete while wrong. A session asked to find them
searches for the subject's name, which a short form need not carry; what every
copy does carry is the words the change replaced, and nothing else in the work
asks for a search on those. So the hook runs it. At each prompt it copies the
repository's rule files into a state directory outside the tree, keyed by the
prompt and never overwritten. At the turn's end it diffs each rule file the
turn wrote against that copy, takes what the diff says the file said before -
the headlines of a list of two or more items the change joined, the five-word
runs of replaced text or of the paragraphs beside an addition - and lists the
lines elsewhere that still carry them. The list reaches the model as additional
context, at most once per prompt, and a line handed once is never handed again
in the session.

Rule files: SKILL.md, CLAUDE.md, CLAUDE.local.md, AGENTS.md, GEMINI.md,
CONTRIBUTING.md and README.md in any letter case, a .md directly under an
agents/ directory, and a .md under skills/<name>/references/ or under a
references/ directory whose parent holds a SKILL.md. A rule file git
ignores is left out, but for a CLAUDE.local.md, which is ignored by design: the
snapshot copies one outside an ignored directory. A file the turn wrote that no
snapshot covers - outside the working tree, in an ignored directory, or
in a turn whose prompt took none - gets its before-state by undoing the turn's
own Edit and Write calls, read from the transcript.

Fails open: any error emits nothing, and a cap or the time budget ends the
work with whatever it had found.
"""
import bisect
import difflib
import collections
import functools
import hashlib
import itertools
import json
import os
import re
import stat
import subprocess
import sys
import tempfile
import time

TEXT_DOC = re.compile(r"\.(?:md|mdx|markdown|txt|rst|adoc)$", re.I)
RULE_FILE = re.compile(
    r"(?:^|/)(?:SKILL|CLAUDE|CLAUDE\.local|AGENTS|GEMINI|CONTRIBUTING|README)\.md$"
    r"|(?:^|/)agents/[^/]+\.md$"
    r"|(?:^|/)skills/[^/]+/references/.+\.md$",
    re.I)
LOCAL_RULE = re.compile(r"(?:^|/)CLAUDE\.local\.md$", re.I)
REFERENCES = re.compile(r"(?:^|/)references/", re.I)
RUN = 5
LISTED = 8
SHOWN_PHRASES = 3
MAX_PHRASES = 400
MAX_BYTES = 1 << 20
WORD_DIFF = 250000
WORD_DIFF_JUNK = 40 * 1000 * 1000
LINE_DIFF_JUNK = 300000
WALK_ENTRIES = 20000
FORCED_ARGS = 16000
SKIP_DIRS = {"node_modules", "__pycache__"}
BUDGET = {"UserPromptSubmit": 2.0, "Stop": 2.5}
MOVES = re.compile(r"(?:pull|rebase|checkout|reset|merge)\b|commit \(merge\)")
GIT_ENV = {k: v for k, v in os.environ.items()
           if k not in ("GIT_LITERAL_PATHSPECS", "GIT_GLOB_PATHSPECS", "GIT_NOGLOB_PATHSPECS", "GIT_ICASE_PATHSPECS")}

STOP = set("""a an the and or of to in on at by for with from as is are be it its this that
these those what which who how when where not no nor but if then than so do does did can
cant can't each every any all one two three note notes""".split())
LIST_ITEM = re.compile(r"^\s*(?:[-*+]|\d+[.)])\s+(?:\[[ xX]\]\s+)?(.*)$")
HEADING = re.compile(r"^\s{0,3}#{1,6}\s+(.*)$")
FENCE = re.compile(r"^\s{0,3}(`{3,}|~{3,})")
MARKDOWN = re.compile(r"\.(?:md|mdx|markdown)$", re.I)
BOLD_LEAD = re.compile(r"\s*(?:\*\*(.+?)\*\*|__(.+?)__)")
PREFILTER_WORD = re.compile(r"^[a-z0-9]+$")
NOFOLLOW = getattr(os, "O_NOFOLLOW", 0)
ORDERED = re.compile(r"^\s*\d+[.)]\s")
TOKEN_DROP = re.compile(r"[*_`]")
TOKEN_BREAK = re.compile(r"[^\w'\-\s]+")

HAND_OFF = (
    "Landing sweep - this turn changed %s, and these lines still carry %s (read from the "
    "diff: %s; matched in any letter case, across line breaks; lines this turn wrote in a "
    "rule file or with Edit or Write are left out%s):\n%s\n\n"
    "Open each. Where it states or lists the same thing, bring it into line with your "
    "change - a short form its readers use without opening the owner is rewritten to "
    "carry it, never cut to a pointer.%s Where it records or quotes the old wording (a "
    "log, a run record, a changelog, a test fixture or its expected output), means "
    "something else, or is a temporary copy, leave it and say so in your reply. If your "
    "change is itself temporary - a trial wording you will revert - leave every line and "
    "say so.")
SAID_BEFORE = "what the changed text said before"
SAID_BESIDE = "what the changed text said before, or what the paragraphs beside your addition say"
BESIDE_ONLY = (" A line marked \"beside\" was found only through the paragraphs beside your "
               "addition: it repeats that neighbouring text, and needs your change only where it "
               "covers the same ground.")
CUT_SHORT = "; the search stopped at its time limit, so there may be more"
SOURCES = (
    ("item", "the items of the list your change joined"),
    ("replaced", "the words it replaced"),
    ("beside", "the paragraphs beside what it added"),
)


class Budget:
    def __init__(self, seconds):
        self.end = time.monotonic() + seconds

    def left(self):
        return self.end - time.monotonic()

    def spent(self):
        return self.left() <= 0


def budget_for(event):
    try:
        return Budget(float(os.environ["DELIVERY_SKILLS_SWEEP_BUDGET"]))
    except Exception:
        return Budget(BUDGET[event])


def git(root, args, budget, ok=(0,), stdin=None):
    if budget.spent():
        return None
    try:
        r = subprocess.run(["git", "-C", root] + args, capture_output=True, input=stdin, env=GIT_ENV,
                           timeout=max(0.05, budget.left()))
    except Exception:
        return None
    if r.returncode not in ok:
        return None
    return r.stdout.decode("utf-8", "surrogateescape")


def key(s):
    return re.sub(r"[^A-Za-z0-9_-]", "", s or "")[:64]


def state_dir(session_id):
    """Per user and private: the state holds copies of the repository's rule
    files, and a shared temp directory is other users' too."""
    k = key(session_id)
    top = "delivery-skills-landing-sweep-%s" % getattr(os, "getuid", lambda: "u")()
    return os.path.join(tempfile.gettempdir(), top, k) if k else None


def private_dir(path):
    """Creates the state's two levels 0700 and refuses either where it is a
    link, another user's, or open to others: an existing directory is used as
    it stands, and one another user planted would take this user's files."""
    for d in (os.path.dirname(path), path):
        os.makedirs(d, mode=0o700, exist_ok=True)
        st = os.lstat(d)
        if not stat.S_ISDIR(st.st_mode):
            raise OSError("not a directory: %s" % d)
        if hasattr(os, "getuid") and (st.st_uid != os.getuid() or st.st_mode & 0o077):
            raise OSError("not private: %s" % d)


def read_bytes(path):
    try:
        if not stat.S_ISREG(os.stat(path).st_mode):
            return None
        with open(path, "rb") as fh:
            data = fh.read(MAX_BYTES + 1)
    except Exception:
        return None
    return None if len(data) > MAX_BYTES or b"\0" in data[:8192] else data


def read_text(path):
    data = read_bytes(path)
    return None if data is None else data.decode("utf-8", "replace")


def write_new(path, body):
    """Writes `path` only where it does not exist yet; False where it did or the
    write failed."""
    try:
        fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL | NOFOLLOW, 0o600)
    except Exception:
        return False
    with os.fdopen(fd, "wb") as fh:
        fh.write(body if isinstance(body, bytes) else body.encode("utf-8"))
    return True


def write_over(path, body):
    tmp = "%s.%s.tmp" % (path, os.urandom(6).hex())
    with os.fdopen(os.open(tmp, os.O_WRONLY | os.O_CREAT | os.O_EXCL | NOFOLLOW, 0o600), "wb") as fh:
        fh.write(body if isinstance(body, bytes) else body.encode("utf-8"))
    os.replace(tmp, path)


def load_json(path, default):
    try:
        with open(path, encoding="utf-8") as fh:
            return json.load(fh)
    except Exception:
        return default


def toplevel(directory, budget, cache={}):
    if directory not in cache:
        out = git(directory, ["rev-parse", "--show-toplevel"], budget) if os.path.isdir(directory) else None
        cache[directory] = os.path.realpath(out.strip()) if out and out.strip() else None
    return cache[directory]


def walk(root, budget):
    """Every file under `root` a walk reaches within its entry cap and the
    budget, dot directories and dependency trees left out; True as the second
    value only where the walk finished."""
    out, seen = [], 0
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = sorted(d for d in dirnames if not d.startswith(".") and d not in SKIP_DIRS)
        for name in sorted(filenames):
            seen += 1
            if seen > WALK_ENTRIES or budget.spent():
                return out, False
            out.append(os.path.relpath(os.path.join(dirpath, name), root))
    return out, True


@functools.lru_cache(maxsize=256)
def holds_skill(directory):
    try:
        return any(n.lower() == "skill.md" for n in os.listdir(directory))
    except Exception:
        return False


def is_rule(path, base=""):
    """`path`, relative to `base` or absolute, is a rule file: RULE_FILE's, or
    a .md under a references/ directory whose parent holds a SKILL.md - a
    skill's own layout wherever it sits, a single-skill repository's root
    included. Elsewhere a references/ with no SKILL.md beside it is any docs
    folder; RULE_FILE's skills/<name>/references/ needs none."""
    posix = path.replace(os.sep, "/")
    if RULE_FILE.search(posix):
        return True
    return posix.lower().endswith(".md") and any(
        holds_skill(os.path.join(base, posix[:m.start()]) if m.start() else (base or "."))
        for m in REFERENCES.finditer(posix))


def ignored_local(root, budget):
    """The CLAUDE.local.md files git ignores, which is that file's usual state.
    `--directory` keeps git out of ignored trees - a dependency tree's walk
    costs seconds - so one inside an ignored directory is not listed."""
    out = git(root, ["ls-files", "-z", "-o", "-i", "--exclude-standard", "--directory"], budget)
    return [n for n in (out or "").split("\0") if LOCAL_RULE.search(n)]


def rule_files(root, in_git, budget):
    if in_git:
        out = git(root, ["ls-files", "-z", "-c", "-o", "--exclude-standard"], budget)
        if out is None:
            return [], False
        names = [n for n in out.split("\0") if n] + ignored_local(root, budget)
        complete = True
    else:
        names, complete = walk(root, budget)
    full = (lambda n: n) if in_git else (lambda n: os.path.join(root, n))
    return sorted({n for n in names if is_rule(full(n), root if in_git else "")}), complete


def snapshot(payload, budget):
    sd, pk = state_dir(payload.get("session_id")), key(payload.get("prompt_id"))
    if not sd or not pk:
        return
    path = os.path.join(sd, "snap-%s.json" % pk)
    cwd = os.path.realpath(payload.get("cwd") or os.getcwd())
    started = time.time()
    root = toplevel(cwd, budget)
    in_git = root is not None
    root = root or cwd
    names, complete = rule_files(root, in_git, budget)
    head = (git(root, ["rev-parse", "HEAD"], budget) or "").strip() if in_git else ""
    private_dir(sd)
    blobs = os.path.join(sd, "blobs")
    os.makedirs(blobs, mode=0o700, exist_ok=True)
    files = {}
    for rel in names:
        if budget.spent():
            complete = False
            break
        data = read_bytes(os.path.join(root, rel))
        if data is None:
            continue
        digest = hashlib.sha1(data).hexdigest()
        blob = os.path.join(blobs, digest)
        if not os.path.exists(blob):
            write_over(blob, data)
        files[rel] = digest
    write_new(path, json.dumps({"root": root, "git": in_git, "head": head, "time": started,
                                "complete": complete, "files": files}))


def load_snapshot(sd, pk):
    """This prompt's snapshot, else the session's latest: a prompt typed while a
    turn runs is screened inside that turn and carries its id, so its own turn
    has none."""
    own = load_json(os.path.join(sd, "snap-%s.json" % pk), None)
    if own:
        return own
    latest = None
    try:
        names = [n for n in os.listdir(sd) if n.startswith("snap-") and n.endswith(".json")]
    except Exception:
        return None
    for name in names:
        snap = load_json(os.path.join(sd, name), None)
        if snap and (latest is None or snap.get("time", 0) > latest.get("time", 0)):
            latest = snap
    return latest


def blob_text(sd, digest):
    try:
        with open(os.path.join(sd, "blobs", digest), "rb") as fh:
            return fh.read().decode("utf-8", "replace")
    except Exception:
        return None


def moved_by_git(root, snap, budget):
    """The files an in-turn pull, rebase, checkout, reset or merge rewrote,
    and the commit HEAD moved from first."""
    head = (git(root, ["rev-parse", "HEAD"], budget) or "").strip()
    if not head or head == snap.get("head"):
        return set(), None
    out = git(root, ["reflog", "show", "--date=unix", "--format=%H%x09%gd%x09%gs", "-n", "500", "HEAD"], budget)
    entries = []
    for line in (out or "").splitlines():
        parts = line.split("\t", 2)
        m = re.search(r"@\{(\d+)\}", parts[1]) if len(parts) == 3 else None
        if m:
            entries.append((parts[0], int(m.group(1)), parts[2]))
    moved, first = set(), None
    for i, (sha, when, subject) in enumerate(entries):
        if when < int(snap.get("time", 0)):
            break
        if MOVES.match(subject) and i + 1 < len(entries):
            names = git(root, ["diff", "--name-only", "-z", entries[i + 1][0], sha], budget) or ""
            moved.update(n for n in names.split("\0") if n)
            first = entries[i + 1][0]
    return moved, first


def committed_before(root, snap, first, budget):
    """The files the turn committed before its first move: a rebase or soft
    reset after them rewrites them, and the change is still the turn's."""
    if not first or not snap.get("head"):
        return set()
    out = git(root, ["diff", "--name-only", "-z", snap["head"], first], budget) or ""
    return {n for n in out.split("\0") if n}


def entry_of(line):
    try:
        entry = json.loads(line)
    except Exception:
        return {}
    return entry if isinstance(entry, dict) else {}


def blocks_of(entry):
    message = entry.get("message")
    content = message.get("content") if isinstance(message, dict) else None
    return [c for c in content if isinstance(c, dict)] if isinstance(content, list) else []


def turn_calls(transcript, prompt_id, cwd):
    """The turn's successful Edit and Write calls, oldest first, as
    (path, name, input, result) - the turn being the tool results its prompt's
    id marks, and a relative path the session's own directory's."""
    uses, calls = {}, []
    use_mark = re.compile(rb'"name"\s*:\s*"(?:Edit|Write)"')
    with open(transcript, "rb") as fh:
        lines = fh.readlines()
    for line in lines:
        if b'"tool_use"' in line and use_mark.search(line):
            entry = entry_of(line)
            if entry.get("isSidechain"):
                continue
            for c in blocks_of(entry):
                if c.get("type") == "tool_use" and c.get("name") in ("Edit", "Write"):
                    uses[c.get("id")] = (c.get("name"), c.get("input") or {})
    if not uses:
        return calls
    mark = prompt_id.encode()
    for line in lines:
        if b'"tool_result"' not in line or mark not in line:
            continue
        entry = entry_of(line)
        if entry.get("promptId") != prompt_id or entry.get("isSidechain"):
            continue
        result = entry.get("toolUseResult")
        for c in blocks_of(entry):
            if c.get("type") == "tool_result" and c.get("tool_use_id") in uses \
                    and not c.get("is_error"):
                name, inp = uses[c["tool_use_id"]]
                path = inp.get("file_path")
                if isinstance(path, str) and path:
                    calls.append((os.path.realpath(os.path.join(cwd, path)), name, inp,
                                  result if isinstance(result, dict) else {}))
    return calls


def undo(text, calls):
    """The file as it stood before `calls`, or None where one cannot be undone."""
    for _, name, inp, result in reversed(calls):
        original = result.get("originalFile")
        if isinstance(original, str):
            text = original
        elif name == "Write" and result.get("type") == "create":
            text = ""
        elif name == "Edit":
            new, old = inp.get("new_string"), inp.get("old_string")
            if not isinstance(new, str) or not isinstance(old, str) or not new or new not in text:
                return None
            text = text.replace(new, old) if inp.get("replace_all") else text.replace(new, old, 1)
        else:
            return None
    return text


def turn_writes(sd, snap, calls, budget):
    """{real path: before-state} of every file the turn wrote: a rule file the
    snapshot covers by its copy there, any other by undoing the turn's calls.
    A file a move rewrote is the turn's only where the turn edited it - its
    before-state then the text the undone edits leave, so the move's own
    change is not handed as the turn's - or committed it before the move."""
    written, covered = {}, set()
    by_path = {}
    for call in calls:
        by_path.setdefault(call[0], []).append(call)
    if snap:
        root = snap.get("root") or ""
        moved, first = moved_by_git(root, snap, budget) if snap.get("git") else (set(), None)
        committed = committed_before(root, snap, first, budget) if moved else set()
        names = set(snap.get("files") or {})
        if snap.get("complete"):
            names |= set(rule_files(root, snap.get("git"), budget)[0])
        for rel in sorted(names):
            path = os.path.realpath(os.path.join(root, rel))
            digest = (snap.get("files") or {}).get(rel)
            before = blob_text(sd, digest) if digest else ""
            if before is None:
                continue
            covered.add(path)
            now = read_text(path)
            if now is None:
                continue
            if rel in moved:
                if path in by_path:
                    undone = undo(now, by_path[path])
                    before = undone if undone is not None else before
                elif rel not in committed:
                    continue
            if now != before:
                written[path] = before
    for path, own in by_path.items():
        if path in covered:
            continue
        now = read_text(path)
        before = undo(now, own) if now is not None else None
        if before is not None and before != now:
            written[path] = before
    return written


def norm(s):
    s = re.sub(r"[*_`]", "", s.lower())
    s = re.sub(r"[^\w'\- ]+", " ", s)
    return re.sub(r"\s+", " ", s).strip()


def content_words(words):
    return [w for w in words if w not in STOP and len(w) > 2]


def headline(item):
    m = BOLD_LEAD.match(item)
    text = (m.group(1) or m.group(2)) if m else re.split(r"\s[-–—]\s|:\s|\.\s|\.$|;", item, maxsplit=1)[0]
    return " ".join(text.split()[:6])


def is_item(lines, i):
    return 0 <= i < len(lines) and LIST_ITEM.match(lines[i])


def is_cont(lines, i):
    return 0 <= i < len(lines) and lines[i].startswith((" ", "\t")) and lines[i].strip()


def blank_run(lines, i, step):
    while 0 <= i < len(lines) and not lines[i].strip():
        i += step
    return i


def list_block(lines, at, loose=False):
    """[(line index, text)] of the items of the list touching line index `at`,
    and its [start, end); with `loose`, blank lines stay inside the list
    before an item nested under the item above them, or of the same depth and
    kind - both numbered or both bulleted - as the nearest item above them at
    its depth."""
    def part(i):
        return is_item(lines, i) or is_cont(lines, i)

    def depth(i):
        return len(lines[i]) - len(lines[i].lstrip(" \t"))

    def joins(above, below):
        k = above
        while k >= 0 and (part(k) or not lines[k].strip()):
            if is_item(lines, k) and depth(k) <= depth(below):
                return depth(k) < depth(below) or \
                    bool(ORDERED.match(lines[k])) == bool(ORDERED.match(lines[below]))
            k -= 1
        return False

    i = at - 1
    while i >= 0:
        if part(i):
            i -= 1
        elif loose and is_item(lines, i + 1) and part(blank_run(lines, i, -1)) \
                and joins(blank_run(lines, i, -1), i + 1):
            i = blank_run(lines, i, -1)
        else:
            break
    j = at
    while j < len(lines):
        if part(j):
            j += 1
        elif loose and j > at and is_item(lines, blank_run(lines, j, 1)) \
                and joins(j - 1, blank_run(lines, j, 1)):
            j = blank_run(lines, j, 1)
        else:
            break
    items = []
    for k in range(i + 1, j):
        m = LIST_ITEM.match(lines[k])
        if m:
            items.append([k, m.group(1)])
        elif items and lines[k].strip():
            items[-1][1] += " " + lines[k].strip()
    return [tuple(it) for it in items], i + 1, j


def paragraph_above(lines, at):
    k = at - 1
    while k >= 0 and not lines[k].strip():
        k -= 1
    out = []
    while k >= 0 and lines[k].strip() and not HEADING.match(lines[k]):
        out.insert(0, k)
        k -= 1
    return out


def paragraph_below(lines, at):
    k = at
    while k < len(lines) and not lines[k].strip():
        k += 1
    out = []
    while k < len(lines) and lines[k].strip() and not HEADING.match(lines[k]):
        out.append(k)
        k += 1
    return out


def heading_above(lines, at):
    for k in range(min(at, len(lines)) - 1, -1, -1):
        m = HEADING.match(lines[k])
        if m:
            return m.group(1).strip()
    return None


@functools.lru_cache(maxsize=64)
def opcodes(before, after):
    b, a, ops = diff_lines(before, after)
    return b, a, [op for op in ops if op[0] != "equal"]


@functools.lru_cache(maxsize=64)
def diff_lines(before, after):
    """Every opcode, equal ones included. Lines repeated many times over a long
    file make the exact diff grow far past linear, so such a file is diffed
    with the popular lines junked."""
    b, a = before.splitlines(), after.splitlines()
    common = max(collections.Counter(b + a).values(), default=0)
    junk = max(len(a), len(b)) * common > LINE_DIFF_JUNK
    return b, a, difflib.SequenceMatcher(None, b, a, autojunk=junk).get_opcodes()


def lost_runs(old_lines, new_lines, budget):
    """The five-word runs of the old lines that overlap the words the change
    lost. A block too large to diff word by word exactly is diffed row by row
    where it kept its line count and every row pair is alike, as a table's
    rows are; otherwise as a whole with the popular words junked, and past a
    ceiling only in the row pairs that are alike."""
    whole = (" ".join(old_lines).split(), " ".join(new_lines).split())
    pairs = [whole]
    size = len(whole[0]) * len(whole[1])
    if size > WORD_DIFF and len(old_lines) == len(new_lines):
        rows = [(o.split(), n.split()) for o, n in zip(old_lines, new_lines)]
        alike = [difflib.SequenceMatcher(None, o, n).quick_ratio() >= 0.5 for o, n in rows]
        if all(alike):
            pairs = rows
        elif size > WORD_DIFF_JUNK:
            pairs = [row for row, like in zip(rows, alike) if like]
    for old, new in pairs:
        size = len(old) * len(new)
        if budget.spent() or size > WORD_DIFF_JUNK:
            continue
        words = difflib.SequenceMatcher(None, [norm(t) for t in old], [norm(t) for t in new], autojunk=size > WORD_DIFF)
        for wt, x1, x2, _, _ in words.get_opcodes():
            if wt in ("replace", "delete"):
                for st in range(max(0, x1 - RUN + 1), min(len(old) - RUN, x2 - 1) + 1):
                    yield " ".join(old[st:st + RUN])


def key_word(words, shown):
    """Index of the word a phrase is found by: its longest word that the raw
    text holds verbatim, so a search on the raw file for it cannot miss the
    phrase - `session_id` normalizes to `sessionid`, which no raw file holds.
    None where no word qualifies."""
    low = shown.lower()
    verbatim = [i for i, w in enumerate(words) if w in low]
    plain = [i for i in verbatim if PREFILTER_WORD.match(words[i])] or verbatim
    return max(plain, key=lambda i: len(words[i])) if plain else None


def before_items(before, after, members, start, end):
    """The items the list held before the turn: a member line no change wrote
    as it stands, and in place of the lines a change wrote - this change or
    another of the same turn - the items that change replaced or deleted."""
    b, _, ops = diff_lines(before, after)
    items, used = [], set()
    for k, text in members:
        op = next(o for o in ops if o[3] <= k < o[4])
        if op[0] == "equal":
            items.append(text)
        elif op not in used:
            used.add(op)
            items += [LIST_ITEM.match(x).group(1) for x in b[op[1]:op[2]] if LIST_ITEM.match(x)]
    for op in ops:
        if op[0] == "delete" and start <= op[3] <= end and op not in used:
            items += [LIST_ITEM.match(x).group(1) for x in b[op[1]:op[2]] if LIST_ITEM.match(x)]
    return items


def to_before(before, after, k):
    """The before-text's line index that line index k of the after-text stands
    for: itself where no change touched it, else where the change began."""
    _, _, ops = diff_lines(before, after)
    for tag, i1, i2, j1, j2 in ops:
        if j1 <= k < j2:
            return i1 + (k - j1) if tag == "equal" else i1
    return len(before.splitlines())


def phrases_of(before, after, budget):
    """What the owning file said before the change, as (source, words, shown,
    key): the headlines of a list of two or more items the change added an
    item to, and that list's heading; every five-word run of replaced or
    deleted text overlapping the words it lost; and the five-word runs of the
    paragraphs on either side of a prose insertion - an item inserted into a
    list of one, or a list started, included, since no copy enumerates such a
    list.
    Returned with the 1-based lines of `after` those paragraphs stand on."""
    b, a, ops = opcodes(before, after)
    raw, beside_lines = [], set()
    for tag, i1, i2, j1, j2 in ops:
        if budget.spent():
            break
        if tag in ("replace", "delete"):
            raw.extend(("replaced", run) for run in lost_runs(b[i1:i2], a[j1:j2], budget))
        joined = sum(1 for x in a[j1:j2] if LIST_ITEM.match(x)) - sum(1 for x in b[i1:i2] if LIST_ITEM.match(x))
        listed = False
        if joined > 0:
            first = next(j for j in range(j1, j2) if LIST_ITEM.match(a[j]))
            members, start, end = list_block(a, first, loose=True)
            items = before_items(before, after, members, start, end)
            listed = len(items) >= 2
            if listed:
                raw.extend(("item", headline(it)) for it in items)
                heading = heading_above(b, to_before(before, after, start))
                if heading:
                    raw.append(("item", heading))
        if tag == "insert" and not listed and len(list_block(b, i1)[0]) < 2:
            beside_lines.update(k + 1 for k in paragraph_above(a, j1) + paragraph_below(a, j2))
            for para in (paragraph_above(b, i1), paragraph_below(b, i1)):
                toks = " ".join(b[k] for k in para).split()
                for st in range(0, max(0, len(toks) - RUN) + 1):
                    raw.append(("beside", " ".join(toks[st:st + RUN])))
    seen, out = set(), []
    for source, text in sorted(raw, key=lambda r: ("item", "replaced", "beside").index(r[0])):
        words = tuple(norm(text).split())
        shown = " ".join(re.sub(r"[*`]", "", text).split())
        if len(content_words(words)) < (2 if source == "item" else 3) or words in seen:
            continue
        k = key_word(words, shown)
        if k is None:
            continue
        seen.add(words)
        out.append((source, words, shown, k))
    return out[:MAX_PHRASES], beside_lines


def changed_lines(before, after, whole_list):
    """1-based lines of `after` the change wrote, widened to the whole list it
    sits in (the owning file) or to its list item, else its paragraph (any
    other file). Outside the owning file the rest of a list and the paragraphs
    beside the lines written stay unwidened, so a copy given the same change
    can still be handed back by them. A deletion writes no line, so it widens to nothing - the paragraph or list
    after it is not the turn's."""
    _, a, ops = opcodes(before, after)
    out = set()
    s, e = 0, 0
    for _, _, _, j1, j2 in ops:
        if j1 == j2:
            continue
        if whole_list:
            if not s <= j1 < e:
                _, s, e = list_block(a, j1, loose=True)
            lo, hi = min(j1, s), max(j2, e)
        else:
            lo, hi = j1, j2
            for j in range(j1, j2):
                s, e = item_span(a, j)
                lo, hi = min(lo, s), max(hi, e)
        out.update(range(lo + 1, hi + 1))
    return out


def item_span(lines, at):
    k = at
    while k >= 0 and not LIST_ITEM.match(lines[k]) and lines[k].startswith((" ", "\t")) and lines[k].strip():
        k -= 1
    if k >= 0 and LIST_ITEM.match(lines[k]):
        e = k + 1
        while e < len(lines) and not LIST_ITEM.match(lines[e]) and lines[e].startswith((" ", "\t")) \
                and lines[e].strip():
            e += 1
        return k, e
    if LIST_ITEM.match(lines[at]) or not lines[at].strip():
        return at, at + 1
    s, e = at, at + 1
    while s > 0 and lines[s - 1].strip() and not HEADING.match(lines[s - 1]) and not LIST_ITEM.match(lines[s - 1]):
        s -= 1
    while e < len(lines) and lines[e].strip() and not HEADING.match(lines[e]) and not LIST_ITEM.match(lines[e]):
        e += 1
    return s, e


def heading_lines(lines):
    """1-based numbers of the lines that are Markdown headings: a line opening
    with # and a space outside a fenced code block. Inside one, as in a file
    that is not Markdown, such a line is a comment. A backtick run followed by
    another backtick on its line opens nothing - it is inline code."""
    out, fence = set(), None
    for n, line in enumerate(lines, 1):
        m = FENCE.match(line)
        if fence:
            if m and m.group(1)[0] == fence[0] and len(m.group(1)) >= len(fence) and not line[m.end():].strip():
                fence = None
        elif m and not (m.group(1)[0] == "`" and "`" in line[m.end():]):
            fence = m.group(1)
        elif HEADING.match(line):
            out.add(n)
    return out


class Text:
    def __init__(self, text, anchors, markdown):
        self.lines = text.splitlines()
        self.headings = heading_lines(self.lines) if markdown else set()
        low = TOKEN_BREAK.sub(" ", TOKEN_DROP.sub("", text.lower()))
        per_line = [line.split() for line in low.splitlines()]
        self.words = list(itertools.chain.from_iterable(per_line))
        self.ends = list(itertools.accumulate(len(ws) for ws in per_line))
        self.where = {}
        for i, w in enumerate(self.words):
            if w in anchors:
                self.where.setdefault(w, []).append(i)

    def line_of(self, i):
        return bisect.bisect_right(self.ends, i) + 1

    def find(self, words, k):
        """(first line, last line) of each place the words run in order,
        across line breaks, looked up by the word at index k."""
        spans = []
        for p in self.where.get(words[k], ()):
            s = p - k
            if s >= 0 and tuple(self.words[s:s + len(words)]) == words:
                spans.append((self.line_of(s), self.line_of(s + len(words) - 1)))
        return spans


def prefilter_words(phrases):
    return sorted({words[k] for _, words, _, k in phrases})


def candidates(root, in_git, words, budget):
    """Files under `root` holding any of `words` in any letter case: git grep
    over tracked and unignored untracked files where there is git, and where
    there is none a bounded walk over text documents only - a tree outside git
    holds transcripts, editor backups and caches that quote any file.
    `--untracked` applies the ignore rules to tracked files too, so the tracked
    files those rules match - usually none - get a grep of their own after it,
    by `:(literal)` pathspecs, which git's pathspec settings would reinterpret
    and so are dropped from its environment; past FORCED_ARGS characters of
    them, well inside a Windows command line, a grep over every tracked file."""
    if in_git:
        args = ["grep", "-l", "-z", "-I", "-i", "-F"]
        for w in words:
            args += ["-e", w]
        out = git(root, args + ["--untracked"], budget, ok=(0, 1))
        found = {n for n in (out or "").split("\0") if n}
        forced = [n for n in (git(root, ["ls-files", "-z", "-c", "-i", "--exclude-standard"], budget) or "").split("\0") if n]
        if forced:
            paths = ["--"] + [":(literal)" + n for n in forced]
            paths = [] if sum(len(x) + 3 for x in paths) > FORCED_ARGS else paths
            out = git(root, args + paths, budget, ok=(0, 1))
            found.update(n for n in (out or "").split("\0") if n)
        return sorted(found)
    names, _ = walk(root, budget)
    found = []
    for rel in names:
        if budget.spent():
            break
        if not TEXT_DOC.search(rel):
            continue
        text = read_text(os.path.join(root, rel))
        if text is not None:
            low = text.lower()
            if any(w in low for w in words):
                found.append(rel)
    return found


def ignored(root, rels, budget):
    if not rels:
        return set()
    out = git(root, ["check-ignore", "-z", "--stdin"], budget, ok=(0, 1),
              stdin="\0".join(rels).encode("utf-8", "surrogateescape"))
    return {n for n in (out or "").split("\0") if n}


def reading_order(rel, written, root):
    """The files the turn wrote first, then rule files, then other Markdown:
    the budget runs out on the files least likely to hold a copy."""
    posix = rel.replace(os.sep, "/")
    return (0 if rel in written else 1 if is_rule(rel, root) else 2 if posix.lower().endswith(".md") else 3,
            posix)


def sweep(written, cwd, budget):
    """[(owner, path, Text, {phrase: [(first, last)]})] for every file handed.
    A written file is searched in the repository it sits in; one in no
    repository through the working directory where it sits under it, and
    alone where it does not."""
    groups = {}
    cwd_git = toplevel(cwd, budget) is not None
    for path in written:
        d = os.path.dirname(path)
        root = toplevel(d, budget)
        if root:
            scope = (root, "git")
        elif path.startswith(cwd + os.sep) and not cwd_git:
            scope = (cwd, "walk")
        else:
            scope = (d, "alone")
        groups.setdefault(scope, []).append(path)
    hits = []
    for (root, how), paths in sorted(groups.items()):
        rels = {p: os.path.relpath(p, root) for p in paths}
        if how == "git":
            skip = ignored(root, sorted(rels.values()), budget)
            rels = {p: r for p, r in rels.items() if r not in skip or LOCAL_RULE.search(r)}
        befores = {r: written[p] for p, r in rels.items()}
        afters = {r: read_text(p) or "" for p, r in rels.items()}
        owners = sorted(r for p, r in rels.items() if (is_rule(r, root) if how == "git" else is_rule(p)))
        per_owner = [(o,) + phrases_of(befores[o], afters[o], budget) for o in owners]
        per_owner = [po for po in per_owner if po[1]]
        if not per_owner:
            continue
        every = [ph for _, phrases, _ in per_owner for ph in phrases]
        anchors = {ph[1][ph[3]] for ph in every}
        found_in = set(befores)
        if how != "alone":
            found_in |= set(candidates(root, how == "git", prefilter_words(every), budget))
        for rel in sorted(found_in, key=lambda r: reading_order(r, befores, root)):
            if budget.spent():
                return hits
            text = afters[rel] if rel in afters else read_text(os.path.join(root, rel))
            if text is None:
                continue
            tx = Text(text, anchors, MARKDOWN.search(rel))
            for owner, phrases, beside_lines in per_owner:
                skip = changed_lines(befores[rel], afters[rel], rel == owner) if rel in befores else set()
                read_from = skip | beside_lines if rel == owner else skip
                found = {}
                for ph in phrases:
                    spans = [(s, e) for s, e in tx.find(ph[1], ph[3])
                             if s not in (read_from if ph[0] == "beside" else skip) and s not in tx.headings]
                    if spans:
                        found[ph] = spans
                if found and len(found) >= (1 if rel in befores else min(2, len(phrases))):
                    hits.append((os.path.join(root, owner), os.path.join(root, rel), tx, found))
    return hits


def line_key(path, text):
    return hashlib.sha1(("%s\0%s" % (path, text.strip())).encode("utf-8", "replace")).hexdigest()


def entries_of(hits, handed):
    """One entry per run of adjacent handed lines in a file, each with the
    phrases found there, leaving out any span whose lines were all handed
    earlier in the session."""
    spans = {}
    for owner, path, tx, found in hits:
        for ph, places in found.items():
            for s, e in places:
                keys = [line_key(path, tx.lines[n - 1]) for n in range(s, e + 1)]
                if all(k in handed for k in keys):
                    continue
                spans.setdefault(path, {"tx": tx, "spans": []})["spans"].append((s, e, ph, owner))
    entries = []
    for path, got in spans.items():
        cur = None
        for s, e, ph, owner in sorted(got["spans"], key=lambda x: (x[0], x[1])):
            if cur and s <= cur["last"] + 1:
                cur["last"] = max(cur["last"], e)
            else:
                cur = {"path": path, "first": s, "last": e, "phrases": [], "owners": set(), "tx": got["tx"]}
                entries.append(cur)
            if ph not in cur["phrases"]:
                cur["phrases"].append(ph)
            cur["owners"].add(owner)
    entries.sort(key=lambda en: (-sum(ph[0] != "beside" for ph in en["phrases"]),
                                 -sum(ph[0] == "beside" for ph in en["phrases"]), en["path"], en["first"]))
    return entries


def shown(path, cwd):
    return os.path.relpath(path, cwd) if path.startswith(cwd + os.sep) else path


def beside_only(entry):
    return all(ph[0] == "beside" for ph in entry["phrases"])


def chosen(entries):
    """The entries a hand-off lists, and the rest: where none of the first
    places holds a line found only beside the addition, the last one does."""
    listed, rest = entries[:LISTED], entries[LISTED:]
    if rest and not any(beside_only(en) for en in listed) and any(beside_only(en) for en in rest):
        spare = next(en for en in rest if beside_only(en))
        rest = [listed[-1]] + [en for en in rest if en is not spare]
        listed = listed[:-1] + [spare]
    return listed, rest


def hand_off(listed, rest, cwd, cut_short):
    lines = []
    for en in listed:
        at = "%d" % en["first"] if en["first"] == en["last"] else "%d-%d" % (en["first"], en["last"])
        quoted = ", ".join('"%s"' % ph[2] for ph in en["phrases"][:SHOWN_PHRASES])
        more = en["phrases"][SHOWN_PHRASES:]
        lines.append("- `%s:%s` - %s%s%s" % (shown(en["path"], cwd), at, "beside: " if beside_only(en) else "",
                                             quoted, " and %d more" % len(more) if more else ""))
    if rest:
        lines.append("- and %d more line%s in %d file%s" % (
            len(rest), "" if len(rest) == 1 else "s", len({en["path"] for en in rest}),
            "" if len({en["path"] for en in rest}) == 1 else "s"))
    owners = sorted({o for en in listed for o in en["owners"]})
    sources = {ph[0] for en in listed for ph in en["phrases"]}
    said = [label for source, label in SOURCES if source in sources]
    return HAND_OFF % (
        and_list(["`%s`" % shown(o, cwd) for o in owners]),
        SAID_BESIDE if "beside" in sources else SAID_BEFORE,
        and_list(said),
        CUT_SHORT if cut_short else "",
        "\n".join(lines),
        BESIDE_ONLY if "beside" in sources else "")


def and_list(items):
    return items[0] if len(items) == 1 else ", ".join(items[:-1]) + " and " + items[-1]


def stop(payload, budget):
    sd, pk = state_dir(payload.get("session_id")), key(payload.get("prompt_id"))
    if not sd or not pk:
        return
    pending = os.path.join(sd, "handed-%s.json" % pk)
    record = load_json(pending, None)
    if record is not None:
        if payload.get("stop_hook_active") and not record.get("seen"):
            handed = set(load_json(os.path.join(sd, "handed.json"), []))
            handed.update(record.get("lines") or [])
            write_over(os.path.join(sd, "handed.json"), json.dumps(sorted(handed)))
            record["seen"] = True
            write_over(pending, json.dumps(record))
        return
    cwd = os.path.realpath(payload.get("cwd") or os.getcwd())
    snap = load_snapshot(sd, pk)
    transcript = payload.get("transcript_path") or ""
    calls = turn_calls(transcript, payload.get("prompt_id"), cwd) if os.path.isfile(transcript) else []
    written = turn_writes(sd, snap, calls, budget)
    if not any(is_rule(p) for p in written):
        return
    handed = set(load_json(os.path.join(sd, "handed.json"), []))
    entries = entries_of(sweep(written, cwd, budget), handed)
    cut_short = budget.spent()
    if not entries:
        return
    listed, rest = chosen(entries)
    lines = sorted({line_key(en["path"], en["tx"].lines[n - 1])
                    for en in listed for n in range(en["first"], en["last"] + 1)})
    if not write_new(pending, json.dumps({"lines": lines, "seen": False})):
        return
    sys.stdout.write(json.dumps({"hookSpecificOutput": {
        "hookEventName": "Stop", "additionalContext": hand_off(listed, rest, cwd, cut_short)}}))


def main():
    payload = json.load(sys.stdin)
    event = payload.get("hook_event_name")
    if event == "UserPromptSubmit":
        snapshot(payload, budget_for(event))
    elif event == "Stop":
        sd = state_dir(payload.get("session_id"))
        if sd:
            private_dir(sd)
        stop(payload, budget_for(event))


if __name__ == "__main__":
    try:
        main()
        sys.stdout.flush()
    except Exception:
        pass
    os._exit(0)
