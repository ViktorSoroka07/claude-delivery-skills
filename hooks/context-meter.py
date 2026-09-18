#!/usr/bin/env python3
"""UserPromptSubmit hook: inject how far this session is into its context window.

A session cannot see its own meter, so a rule asking it to name a seam before
the window fills has nothing to act on - two wordings of that rule failed for
that reason, and the measurement is what was missing. The size comes from the
usage the last main-thread API call recorded in the transcript, not from an
estimate of the file's length.

Fails open: any error emits nothing and the prompt goes through unannotated.
"""
import json
import os
import sys

DEFAULT_WINDOW = 200000
THRESHOLD = 0.70
TAIL_BYTES = 1 << 20

LINE = (
    "delivery-skills context meter: this session is at %d%% of its context window "
    "(%s of %s tokens). Reach the next seam rather than the next task - finish and "
    "commit the step in hand, then write the hand-over a fresh session would need "
    "(the maintaining-project-memory skill owns it) and say what is left. What is "
    "unwritten when the window fills is what no later session can recover."
)


def window():
    try:
        return int(os.environ["DELIVERY_SKILLS_CONTEXT_WINDOW"])
    except Exception:
        return DEFAULT_WINDOW


def line_groups(path):
    """The transcript's lines, tail first: the usage wanted is the last one
    written, and a transcript runs to megabytes. The seek lands mid-line, so
    the first line of the tail is dropped; the whole file follows as the
    fallback for a tail that holds no usage at all."""
    size = os.path.getsize(path)
    if size > TAIL_BYTES:
        with open(path, "rb") as fh:
            fh.seek(size - TAIL_BYTES)
            yield fh.read().decode("utf-8", "replace").splitlines()[1:]
    with open(path, encoding="utf-8", errors="replace") as fh:
        yield fh.read().splitlines()


def context_tokens(path):
    """What the last main-thread call carried. A sidechain entry is a
    subagent's window rather than this session's, and reading one reports a
    fresh agent's few thousand tokens as the session's own."""
    for lines in line_groups(path):
        for line in reversed(lines):
            try:
                event = json.loads(line)
            except Exception:
                continue
            if event.get("isSidechain"):
                continue
            usage = (event.get("message") or {}).get("usage")
            if not isinstance(usage, dict):
                continue
            return sum(usage.get(k) or 0 for k in (
                "input_tokens", "cache_read_input_tokens", "cache_creation_input_tokens"))
    return 0


def thousands(n):
    return "%dk" % round(n / 1000.0)


def main():
    payload = json.load(sys.stdin)
    path = payload.get("transcript_path") or ""
    if not path or not os.path.isfile(path):
        return
    limit = window()
    tokens = context_tokens(path)
    if tokens < limit * THRESHOLD:
        return
    sys.stdout.write(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": LINE % (
                round(100.0 * tokens / limit), thousands(tokens), thousands(limit)),
        }
    }))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
