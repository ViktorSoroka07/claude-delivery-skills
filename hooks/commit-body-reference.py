#!/usr/bin/env python3
"""PreToolUse hook (Bash): warn when a commit body carries a `#` before a word where commitlint lints it.

commitlint's parser reads a `#` followed by a word in the body as an issue
reference or a footer token, and the footer starts at that line. The body text
after it is then footer, and a repository that holds `footer-leading-blank` at
error level refuses a message that has no footer at all: a second issue number
in a paragraph, a colour value mid-sentence. Which forms trip it depends on the
parser's major version (one wants a digit after the `#`, the next a line shaped
like a trailer), so this reads every `#` before a word outside the trailers.

It reads the message when the commit command runs - from each `-m`, a heredoc
inside one, or a `-F` file or heredoc on stdin - because a refused commit costs
a retry, and the retry is where a placeholder body gets committed.

Warn-only: some such `#` are meant, and the skill owns the shape. Fails open on
any error - a broken backstop must not block committing.
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from shell_text import HEREDOC, argument_at, blank, git_verb, target_dir  # noqa: E402

COMMIT = git_verb("commit")
COMMAND_END = re.compile(r"&&|\|\||[;|\n]")
MESSAGE_FLAG = re.compile(
    r"(?<!\S)(?:-[A-Za-z]*(?P<short>[mF])|--(?P<long>message|file)(?==|\s))=?"
)
SUBSTITUTED_HEREDOC = re.compile(r"""\s*"\$\(\s*cat\s*$""")
STDIN_HEREDOC = re.compile(r"\s*-\s*$|\s*-\s+\S")
HASH_WORD = re.compile(r"#\w[\w-]*")
TRAILER = re.compile(r"(?:BREAKING CHANGE|[\w-]+)(?::\s|\s+#)|\s")
CONFIG_FILE = re.compile(r"(?:commitlint\.config\.|\.commitlintrc)")


def heredoc_from(command, pos, lead):
    """The body of the first heredoc after `pos`, when the text between is
    only `lead`; None otherwise."""
    doc = HEREDOC.search(command, pos)
    if doc and lead.match(command, pos, doc.start()):
        return doc.group("body")
    return None


def read_text(path, cwd):
    if not path or "$" in path:
        return None
    path = os.path.expanduser(path)
    if not os.path.isabs(path):
        path = os.path.join(cwd or os.getcwd(), path)
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            return fh.read()
    except OSError:
        return None


def message_of(command, blanked, verb, cwd):
    """The message the commit records, or None where a part of it cannot be
    read here (an editor, a substitution other than a heredoc, a variable).
    Several -m join as paragraphs, as git joins them."""
    end = COMMAND_END.search(blanked, verb.end())
    end = end.start() if end else len(blanked)
    parts = []
    for flag in MESSAGE_FLAG.finditer(blanked, verb.end(), end):
        pos = flag.end()
        if (flag.group("short") or flag.group("long")[0]) in ("F", "f"):
            if STDIN_HEREDOC.match(command, pos):
                text = heredoc_from(command, command.index("-", pos) + 1, re.compile(r"\s*$"))
            else:
                text = read_text(argument_at(command, pos), cwd)
        else:
            text = heredoc_from(command, pos, SUBSTITUTED_HEREDOC)
            if text is None:
                text = argument_at(command, pos)
                if text is not None and "$(" in text:
                    text = None
        if text is None:
            return None
        parts.append(text.strip("\n"))
    return "\n\n".join(parts) if parts else None


def lints_with_commitlint(cwd):
    """Whether commitlint finds a configuration from `cwd`, searching upward
    as it does, through the repository root."""
    d = os.path.abspath(cwd or os.getcwd())
    while True:
        try:
            names = os.listdir(d)
        except OSError:
            return False
        if any(CONFIG_FILE.match(n) for n in names):
            return True
        if "package.json" in names:
            try:
                with open(os.path.join(d, "package.json"), encoding="utf-8") as fh:
                    if "commitlint" in json.load(fh):
                        return True
            except Exception:
                pass
        parent = os.path.dirname(d)
        if ".git" in names or parent == d:
            return False
        d = parent


def body_hashes(message):
    """(line number, token) for each `#` before a word in the body: every
    line after the subject except a closing paragraph made only of trailers."""
    lines = message.splitlines()
    last = len(lines)
    tail = max((i for i, ln in enumerate(lines) if not ln.strip()), default=None)
    if tail is not None and tail + 1 < len(lines) and all(TRAILER.match(ln) for ln in lines[tail + 1:]):
        last = tail
    return [(n + 1, m.group(0)) for n in range(1, last) for m in HASH_WORD.finditer(lines[n])]


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0
    if payload.get("tool_name") != "Bash":
        return 0
    command = (payload.get("tool_input", {}) or {}).get("command", "") or ""
    try:
        _, blanked = blank(command)
        verb = COMMIT.search(blanked)
        if not verb:
            return 0
        cwd = target_dir(command, blanked, verb)
        if cwd == "":
            return 0
        cwd = cwd or payload.get("cwd")
        message = message_of(command, blanked, verb, cwd)
        if not message or not lints_with_commitlint(cwd):
            return 0
        hits = body_hashes(message)
    except Exception:
        return 0
    if not hits:
        return 0

    sys.stdout.write(json.dumps({
        "systemMessage": "writing-commit-messages backstop: %s at line %d of the message body may open commitlint's footer. Not blocked." % (hits[0][1], hits[0][0]),
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "additionalContext": (
                "The message body carries %s (first: %s at line %d of the message). commitlint's "
                "parser reads a `#` followed by a word in the body as an issue reference or a "
                "footer token, so the footer starts at that line, and a repository holding "
                "footer-leading-blank at error level refuses the commit. Put an issue reference "
                "in a trailer in the closing paragraph (`Refs #12`), and write any other value "
                "without its `#` in the body; a `#` the message truly needs there stays, and "
                "the refusal, if it comes, names the rule."
                % (", ".join(sorted({t for _, t in hits})), hits[0][1], hits[0][0])
            ),
        },
    }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
