#!/usr/bin/env python3
"""Stop hook: name the tracked files a turn leaves uncommitted.

Companion to writing-commit-messages and to the rule that a backlog entry is
committed by the session that writes it: an uncommitted change is a stray every
later session has to explain or step around, and the end of a turn is the last
moment it is cheap to commit.

Stop fires at the end of every turn, so an unconditional line would repeat
through a session that is mid-edit. The line is emitted once per set of
uncommitted paths per session, and again only when that set changes - a commit
clears the set, and the next stray warns again.

Warn-only: the stop is never blocked, and any error emits nothing.
"""
import json
import os
import re
import subprocess
import sys
import tempfile

LISTED = 5


def status_paths(cwd):
    try:
        out = subprocess.run(
            ["git", "status", "--porcelain", "--untracked-files=no"],
            capture_output=True, text=True, timeout=5, cwd=cwd or None)
    except Exception:
        return []
    if out.returncode != 0:
        return []
    paths = []
    for line in out.stdout.splitlines():
        if len(line) < 4:
            continue
        path = line[3:]
        # A rename is reported as "old -> new"; the new name is the one to commit.
        if " -> " in path:
            path = path.split(" -> ", 1)[1]
        paths.append(path.strip('"'))
    return sorted(set(paths))


def already_named(session_id, paths):
    """True when this session was last told about exactly these paths. The
    state lives outside the repo, so the hook never dirties the tree it
    watches."""
    key = re.sub(r"[^A-Za-z0-9_-]", "", session_id or "")[:64]
    if not key:
        return False
    marker = os.path.join(tempfile.gettempdir(), "delivery-skills-uncommitted-%s" % key)
    body = "\n".join(paths)
    try:
        with open(marker, encoding="utf-8") as fh:
            if fh.read() == body:
                return True
    except Exception:
        pass
    try:
        with open(marker, "w", encoding="utf-8") as fh:
            fh.write(body)
    except Exception:
        pass
    return False


def main():
    payload = json.load(sys.stdin)
    paths = status_paths(payload.get("cwd") or os.getcwd())
    if not paths or already_named(payload.get("session_id"), paths):
        return
    shown = ", ".join(paths[:LISTED])
    if len(paths) > LISTED:
        shown += " and %d more" % (len(paths) - LISTED)
    sys.stdout.write(json.dumps({"systemMessage": (
        "uncommitted: %s - commit %s before the session ends, one workstream per "
        "commit, and a backlog entry in a commit of its own."
        % (shown, "it" if len(paths) == 1 else "them"))}))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
