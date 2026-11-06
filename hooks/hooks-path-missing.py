#!/usr/bin/env python3
"""PreToolUse hook (Bash): warn when a commit or push is about to run with its configured hooks missing.

Git reads `core.hooksPath` against the root of the working tree the act runs
in, and where nothing is there it runs no hook and prints exactly what a gated
act prints. Two ways leave it empty: a directory a dependency install generates
is absent from a freshly added worktree, and a temporary-file sweep removes
tracked hook files from a worktree left idle. Either way the first sign is a
defect the gate existed to catch arriving downstream, so this checks the path
at the moment the act runs.

It speaks where the configured path does not exist, or where the directory
exists but a hook file the index tracks for this act is gone from it. A hook
file the repository never had is not a missing gate, and a path that exists but
is not a directory (`/dev/null`) is hooks turned off on purpose.

Warn-only: the act may be meant to run ungated, and only the session can
tell. Fails open on any error - a broken backstop must not block the act.
"""
import json
import os
import posixpath
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from shell_text import blank, git_verb, target_dir  # noqa: E402

ACTS = (
    ("commit", git_verb("commit"), ("pre-commit", "prepare-commit-msg", "commit-msg")),
    ("push", git_verb("push"), ("pre-push",)),
)


def git(args, cwd):
    out = subprocess.run(["git", *args], cwd=cwd, capture_output=True, text=True, timeout=5)
    return out.stdout.strip() if out.returncode == 0 else None


def tracked(top, rel):
    """Paths the index holds under `rel`, relative to the worktree root;
    empty where `rel` lies outside the worktree."""
    if rel == os.pardir or rel.startswith(os.pardir + os.sep):
        return set()
    listed = git(["ls-files", "--", rel], top)
    return set(listed.splitlines()) if listed else set()


def missing_gate(cwd, hooks):
    """(configured path, the hook files gone or None where the whole path
    is, whether the index tracks what is gone) where the act would run fewer
    hooks than the repository set up; None where nothing is missing."""
    configured = git(["config", "--type=path", "--get", "core.hooksPath"], cwd)
    if not configured:
        return None
    top = git(["rev-parse", "--show-toplevel"], cwd)
    if not top:
        return None
    path = os.path.join(top, configured)
    rel = os.path.relpath(path, top)
    if not os.path.exists(path):
        return configured, None, bool(tracked(top, rel))
    if not os.path.isdir(path):
        return None
    index = tracked(top, rel)
    gone = [h for h in hooks
            if posixpath.normpath(posixpath.join(rel.replace(os.sep, "/"), h)) in index
            and not os.path.exists(os.path.join(path, h))]
    return (configured, gone, True) if gone else None


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
        base = payload.get("cwd") or os.getcwd()
        found = None
        for act, pattern, hooks in ACTS:
            verb = pattern.search(blanked)
            if not verb:
                continue
            cwd = target_dir(command, blanked, verb)
            if cwd == "":
                continue
            gate = missing_gate(os.path.join(base, cwd) if cwd else base, hooks)
            if gate:
                found = (act, *gate)
                break
    except Exception:
        return 0
    if not found:
        return 0

    act, configured, gone, is_tracked = found
    if gone is None:
        what = "core.hooksPath points at %s, which does not exist in this worktree" % configured
        lost = "no local hook"
        remedy = (
            "Restore it with `git checkout -- %s` before the act." % configured if is_tracked else
            "Run the step that generates it - usually the dependency install - before the act."
        )
    else:
        what = "%s under core.hooksPath %s %s tracked but gone from this worktree" % (
            ", ".join(gone), configured, "is" if len(gone) == 1 else "are")
        lost = "without " + ("it" if len(gone) == 1 else "them")
        remedy = "Restore it with `git checkout -- %s` before the act." % configured
    sys.stdout.write(json.dumps({
        "systemMessage": "hooks-path-missing: %s, so this %s runs %s. Not blocked." % (what, act, lost),
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "additionalContext": (
                "%s. Git skips a hook the configured path does not hold and reports success "
                "exactly as a gated %s does, so the checks the repository set up do not run and "
                "nothing says so; the first sign is the defect they exist to catch arriving "
                "downstream. %s If this %s is meant to run ungated, go ahead and say so."
                % (what, act, remedy, act)
            ),
        },
    }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
