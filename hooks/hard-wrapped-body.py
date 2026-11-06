#!/usr/bin/env python3
"""PreToolUse hook (Bash): warn when a pull request body about to be sent is hard-wrapped.

A forge renders every newline inside a paragraph as a line break, so a body
wrapped at a column arrives as chopped lines that never reflow. The skill says
so; this reads the body at the moment the create or edit command runs, from
wherever the command takes it - a body file, a command substitution over one, a
heredoc, a quoted literal - because that is the last point before the text is
public, and the one a session steered toward the shell always passes.

Warn-only: a deliberate line break reads the same as a wrapped one, and the
skill owns the judgment. Fails open on any error - a broken backstop must not
block the send.
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from shell_text import CD_ANCHOR, HEREDOC, argument_at, blank  # noqa: E402

PR_SEND = re.compile(
    r"\bgh\b[^|;&\n]*\bpr\s+(?:create|edit)(?![-\w])"
    r"|\baz\b[^|;&\n]*\brepos\s+pr\s+(?:create|update)(?![-\w])"
)
FLAGS = {
    "gh": {"file": ("--body-file", "-F"), "text": ("--body", "-b")},
    "az": {"file": (), "text": ("--description", "-d")},
}
CAT = re.compile(r"""^\s*\$\(\s*cat\s+(?:"([^"]*)"|'([^']*)'|(\S+))\s*\)\s*$""")

FENCE = re.compile(r"\s*(?:```|~~~)")
STRUCTURAL = re.compile(r"\s*(?:#|\||>|<|!\[|\[[^\]]*\]:)")
LIST_ITEM = re.compile(r"\s*(?:[-*+]|\d+[.)])\s")
ENDS_OPEN = re.compile(r"[A-Za-z0-9,;)`]$")
STARTS_LOWER = re.compile(r"\s*[a-z]")


def flag_value(command, blanked, names):
    """The argument after the first of `names` found outside quotes, read
    from the original at the same offset, which the length-preserving
    blanking guarantees is the right place; None when no flag is present."""
    pattern = re.compile(r"(?<!\S)(?:%s)(?:=|\s)" % "|".join(re.escape(n) for n in names))
    m = pattern.search(blanked)
    if not m:
        return None
    return argument_at(command, m.end())


def read_file(path, blanked, cwd):
    """The file's text, or None where the path cannot be settled here: a
    variable in it, stdin, or a relative path behind a cd the command makes."""
    if not path or path == "-" or "$" in path:
        return None
    path = os.path.expanduser(path)
    if not os.path.isabs(path):
        if CD_ANCHOR.search(blanked):
            return None
        path = os.path.join(cwd or os.getcwd(), path)
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            return fh.read()
    except OSError:
        return None


def body_of(command, cwd):
    unfenced, blanked = blank(command)
    m = PR_SEND.search(blanked)
    if not m:
        return None
    flags = FLAGS["gh" if blanked[m.start():m.start() + 2] == "gh" else "az"]
    path = flag_value(command, blanked, flags["file"]) if flags["file"] else None
    if path is not None:
        return read_file(path, blanked, cwd)
    text = flag_value(command, blanked, flags["text"])
    if text is None:
        return None
    cat = CAT.match(text)
    if cat:
        return read_file(cat.group(1) or cat.group(2) or cat.group(3), blanked, cwd)
    if "$(" in text:
        doc = HEREDOC.search(text)
        return doc.group("body") if doc else None
    return text


def wrapped_joins(text):
    """Line numbers of each line that continues the sentence the line above
    left open: the one above ends on a word or a comma, this one starts
    lowercase and starts no list item. Fenced code, headings, tables, quotes
    and HTML are not paragraphs, and neither is a blank line's neighbour."""
    joins = []
    fenced = False
    prev = None
    for n, line in enumerate(text.splitlines(), 1):
        if FENCE.match(line):
            fenced = not fenced
            prev = None
            continue
        if fenced or not line.strip() or STRUCTURAL.match(line):
            prev = None
            continue
        if (prev is not None and ENDS_OPEN.search(prev.rstrip())
                and STARTS_LOWER.match(line) and not LIST_ITEM.match(line)):
            joins.append(n)
        prev = line
    return joins


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0
    if payload.get("tool_name") != "Bash":
        return 0
    command = (payload.get("tool_input", {}) or {}).get("command", "") or ""
    try:
        body = body_of(command, payload.get("cwd"))
    except Exception:
        return 0
    if not body:
        return 0
    joins = wrapped_joins(body)
    if not joins:
        return 0

    sys.stdout.write(json.dumps({
        "systemMessage": "writing-pr-descriptions backstop: the body carries %d hard-wrapped line(s), first at line %d. Not blocked." % (len(joins), joins[0]),
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "additionalContext": (
                "%d line(s) of the body (first at line %d) continue a sentence the line above left "
                "open. The forge renders every newline inside a paragraph as a line break, so "
                "the paragraph arrives as chopped lines that never reflow. Join each wrapped "
                "paragraph or list item into one line before sending; each list item still "
                "starts its own line, and a table row or a code block keeps its lines."
                % (len(joins), joins[0])
            ),
        },
    }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
