#!/usr/bin/env python3
"""PreToolUse hook (Bash): warn when a commit's staged diff adds narrative comments.

The write-time companion matches the edit tools. A session that writes files another
way - shell heredocs, sed, a generator script - never triggers it, and that is the
mode in which the most editing happens. This one reads the staged diff instead, so it
sees the change however it was authored, at the last point before it lands.

Warn-only by design: whether a comment earns its place is a judgment the skill owns
and a regex cannot make. Fails open on any error - a broken backstop must not block
committing.
"""
import json
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from comment_tells import SKIP_SUFFIXES, tells_in  # noqa: E402

GIT_COMMIT = re.compile(r"\bgit\b[^|;&]*\bcommit\b")
STAGES_TRACKED = re.compile(r"\bcommit\b[^|;&]*(?:\s-\w*a|\s--all\b)")


def added_comment_lines(diff_args):
    excludes = [":(exclude,top)*%s" % s for s in SKIP_SUFFIXES]
    try:
        out = subprocess.run(
            ["git", "diff", "-U0", *diff_args, "--", ":/", *excludes],
            capture_output=True, text=True, timeout=10,
        )
    except Exception:
        return []
    if out.returncode != 0:
        return []
    return [ln for ln in out.stdout.splitlines() if ln.startswith("+") and not ln.startswith("+++")]


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0
    if payload.get("tool_name") != "Bash":
        return 0
    command = (payload.get("tool_input", {}) or {}).get("command", "") or ""
    if not GIT_COMMIT.search(command):
        return 0

    added = added_comment_lines(["--cached"])
    if STAGES_TRACKED.search(command):
        added += added_comment_lines([])

    hits = tells_in(added)
    if not hits:
        return 0

    sys.stdout.write(json.dumps({
        "systemMessage": "writing-code-comments backstop: %d staged comment line(s) carry narrative tells. Not blocked." % len(hits),
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "additionalContext": (
                "%d staged comment line(s) carry narrative tells: %s. Per the skill: state the "
                "invariant in present tense, make the load-bearing fact executable, or delete the "
                "comment where a test already locks the behaviour in. Some of these words are "
                "legitimate in some sentences - judge each one rather than stripping them."
                % (len(hits), "; ".join(hits[:3]))
            ),
        },
    }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
