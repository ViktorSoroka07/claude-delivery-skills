#!/usr/bin/env python3
"""PreToolUse hook (Bash): warn when a push, `gh pr create` or `gh pr ready` is about to publish fix-up commits.

A `fixup!`, `squash!` or `amend!` commit is a note to the author's own
`rebase --autosquash`; the merge does not fold it. Pushed, it lands on the
target as written under any merge method that keeps commits, so a branch is
folded before it is published, and this reads the branch at that moment.

A push and `gh pr create` read the commits no remote-tracking ref holds yet,
which needs no upstream and fits a first push. `gh pr ready` runs on a branch
usually pushed already, so it reads the commits the remote's default branch
does not hold, and stays silent where `refs/remotes/origin/HEAD` does not
resolve. A push of tags only and a delete are not publishing a branch, and
read as quiet; any other refspec is read as a plain push of HEAD.

Warn-only: a team may push fix-ups on purpose for a reviewer to read, and only
the session knows whether the requester asked for that. No call to the forge
for the repository's merge methods: the warning states the condition instead.
Fails open on any error - a broken backstop must not block the act.
"""
import json
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from shell_text import blank, git_verb, target_dir  # noqa: E402

FIXUP = re.compile(r"(?:fixup|squash|amend)! ")
SEGMENT_END = re.compile(r"[;&|\n]")
SHOWN = 3
ACTS = (
    ("push", git_verb("push"), "remotes"),
    ("pull request creation", re.compile(r"\bgh\b[^|;&\n]*\bpr\s+create(?![-\w])"), "remotes"),
    ("pull request ready", re.compile(r"\bgh\b[^|;&\n]*\bpr\s+ready(?![-\w])"), "default"),
)


def git(args, cwd):
    out = subprocess.run(["git", *args], cwd=cwd, capture_output=True, text=True, timeout=5)
    return out.stdout if out.returncode == 0 else None


def publishes_no_branch(blanked, verb):
    """Whether the push after `verb` sends only tags or deletes."""
    end = SEGMENT_END.search(blanked, verb.end())
    words = blanked[verb.end():end.start() if end else len(blanked)].split()
    flags = [w for w in words if w.startswith("-")]
    refspecs = [w for w in words if not w.startswith("-")][1:]
    if "--delete" in flags or "-d" in flags:
        return True
    if refspecs:
        return all(r.startswith(":") for r in refspecs)
    return "--tags" in flags


def unpublished(cwd, basis):
    """(subjects of the fix-up commits, the base to fold from or None for the
    root) over the commits the basis does not hold, oldest first; None where
    the repository or the basis cannot be read."""
    held = ["--remotes"] if basis == "remotes" else ["refs/remotes/origin/HEAD"]
    listed = git(["log", "--reverse", "--format=%H %s", "HEAD", "--not", *held], cwd)
    if not listed:
        return None
    rows = [line.split(" ", 1) for line in listed.splitlines()]
    subjects = [r[1] for r in rows if len(r) == 2 and FIXUP.match(r[1])]
    if not subjects:
        return None
    parent = git(["rev-parse", "--short", rows[0][0] + "^"], cwd)
    return subjects, parent.strip() if parent else None


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
        for act, pattern, basis in ACTS:
            verb = pattern.search(blanked)
            if not verb or (act == "push" and publishes_no_branch(blanked, verb)):
                continue
            cwd = target_dir(command, blanked, verb)
            if cwd == "":
                continue
            read = unpublished(os.path.join(base, cwd) if cwd else base, basis)
            if read:
                found = (act, basis, *read)
                break
    except Exception:
        return 0
    if not found:
        return 0

    act, basis, subjects, parent = found
    n = len(subjects)
    listed = "; ".join("`%s`" % s for s in subjects[:SHOWN]) + (", and %d more" % (n - SHOWN) if n > SHOWN else "")
    held = "no remote-tracking ref holds" if basis == "remotes" else "the default branch does not hold"
    fold = "GIT_SEQUENCE_EDITOR=true GIT_EDITOR=true git rebase -i --autosquash %s" % (parent or "--root")
    pushed = (
        " The branch is already pushed, so the fold needs a force-push, which the requester approves first."
        if basis == "default" else ""
    )
    count = "%d fix-up commit%s" % (n, "" if n == 1 else "s")
    sys.stdout.write(json.dumps({
        "systemMessage": "fixup-unfolded: this %s publishes %s that %s. Not blocked." % (act, count, held),
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "additionalContext": (
                "This %s publishes %s that %s: %s. The merge does not fold them: under any merge "
                "method that keeps commits they land on the target as written. Fold them before "
                "it unless the requester asked for them to be pushed as they are (`%s` runs "
                "without an editor).%s" % (act, count, held, listed, fold, pushed)
            ),
        },
    }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
