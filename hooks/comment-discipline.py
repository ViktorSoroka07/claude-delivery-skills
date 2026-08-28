#!/usr/bin/env python3
"""PostToolUse hook (Edit|Write): warn when an edit adds narrative code comments.

Companion to the writing-code-comments skill: the skill owns the judgment;
this is the mechanical backstop for the patterns that kept recurring.
Warn-only by design - it feeds the tell back to the model, never blocks.
Fails open on any error: a broken backstop must not break editing.
"""
import json
import re
import sys

# Comment markers across the common languages the skill's corpus covered.
COMMENT_LINE = re.compile(r"^\s*(//|#(?!!)|/\*|\*|<!--|--)\s?(.*)")

# The skill's own draft-grep tells, kept conservative to avoid false positives
# on code and strings: each must appear inside a comment line.
TELLS = re.compile(
    r"(Regression:|Locks in\b|used to\b|previously\b|without this\b|"
    r"would otherwise\b|no longer\b|which is immaterial|harmless because|"
    r"acceptable since|does not matter here)",
    re.IGNORECASE,
)

# Files where prose is the content, not commentary.
SKIP_SUFFIXES = (".md", ".markdown", ".txt", ".rst", ".adoc", ".json", ".lock")


def added_text(payload):
    tool = payload.get("tool_name", "")
    ti = payload.get("tool_input", {}) or {}
    path = ti.get("file_path", "") or ""
    if path.lower().endswith(SKIP_SUFFIXES):
        return path, ""
    if tool == "Write":
        return path, ti.get("content", "") or ""
    if tool == "Edit":
        return path, ti.get("new_string", "") or ""
    return path, ""


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0
    path, text = added_text(payload)
    if not text:
        return 0
    hits = []
    for line in text.splitlines():
        m = COMMENT_LINE.match(line)
        if not m:
            continue
        if TELLS.search(line):
            hits.append(line.strip()[:120])
    if not hits:
        return 0
    sys.stderr.write(
        "writing-code-comments backstop: the edit to %s adds comment lines "
        "with narrative tells (%s). Per the skill: state the invariant in "
        "present tense, make the load-bearing fact executable, or delete the "
        "comment.\n" % (path or "the file", "; ".join(hits[:3]))
    )
    return 2  # PostToolUse: exit 2 surfaces stderr to the model, non-blocking


if __name__ == "__main__":
    sys.exit(main())
