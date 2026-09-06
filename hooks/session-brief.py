#!/usr/bin/env python3
"""SessionStart hook: inject the plugin's standing rules as session context.

The rules in session-brief.md hold across every task and each names the
skill that owns it, so a user's CLAUDE.md no longer has to carry a copy -
they travel with the plugin. Fails open: any error emits nothing, and the
session starts without the brief rather than not at all.
"""
import json
import os
import sys


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "session-brief.md"), encoding="utf-8") as fh:
        brief = fh.read().strip()
    if not brief:
        return
    sys.stdout.write(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": brief,
        }
    }))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
