#!/usr/bin/env python3
"""PostToolUse hook (Bash): warn when a command lands a branch on its target.

Companion to the landing-merged-work skill: the skill owns the close-out, this
fires at the moment the work lands, whichever way it happened - a merge through
one of the three forge CLIs, or a local merge run from the default branch. The
moment has no other trigger: the finishing skill hands off while the request is
still open, and the landing usually happens in a later session.

Warn-only by design, and fails open on any error - a broken backstop must not
disturb a merge that already succeeded.
"""
import json
import re
import subprocess
import sys

QUOTED = re.compile(r"\"[^\"]*\"|'[^']*'")
HEREDOC = re.compile(
    r"<<-?\s*(?P<q>[\"']?)(?P<tag>\w+)(?P=q)[^\n]*\n(?P<body>.*?)\n[ \t]*(?P=tag)[ \t]*(?=\n|$)",
    re.DOTALL,
)

# Matched against the command with quoted spans and heredoc bodies blanked:
# both carry message text, and message text names merges without running
# them. The trailing guard on `merge` keeps the plumbing commands
# (merge-base, merge-tree) out.
FORGE_MERGE = re.compile(
    r"\bgh\b[^|;&]*\bpr\b[^|;&]*\bmerge(?![-\w])"
    r"|\bglab\b[^|;&]*\bmr\b[^|;&]*\bmerge(?![-\w])"
    r"|\baz\b[^|;&]*\brepos\b[^|;&]*\bpr\b[^|;&]*--status\s+completed\b"
)
LOCAL_MERGE = re.compile(r"\bgit(?:\s+-[\w-]+(?:=\S*)?|\s+-[Cc]\s+\S+)*\s+merge(?![-\w])")
INERT = re.compile(r"--(abort|continue|quit|help|dry-run)\b|\s-h\b")

ADVICE = (
    "landing-merged-work backstop: this command lands a branch on its target, and the "
    "close-out has no other trigger. Run it now rather than at the end of the session: "
    "confirm the local tip is contained in the request's recorded head (ancestry commands "
    "report every squash-merge as unmerged), sweep the branch and any worktree this tooling "
    "created - announcing each deleted tip SHA with the command that restores it - prune the "
    "memory entries and plan docs that name the branch, and close the tracker item where it "
    "is yours, asking for any effort figures rather than inferring them. Call the Skill tool "
    "with landing-merged-work for the full procedure.\n"
)


def git(args):
    try:
        out = subprocess.run(["git", *args], capture_output=True, text=True, timeout=5)
    except Exception:
        return ""
    return out.stdout.strip() if out.returncode == 0 else ""


def on_default_branch():
    """HEAD sits on the branch the repo integrates into. A merge run from there
    lands work; the same command on a feature branch syncs the target in."""
    head = git(["symbolic-ref", "--short", "HEAD"])
    if not head:
        return False
    ref = git(["symbolic-ref", "--short", "refs/remotes/origin/HEAD"])
    default = ref.split("/", 1)[1] if "/" in ref else ""
    return head == default if default else head in ("main", "master")


def blank_body(m):
    start, end = m.span("body")
    return m.group(0)[: start - m.start()] + " " * (end - start) + m.group(0)[end - m.start():]


def failed(payload):
    response = payload.get("tool_response")
    if not isinstance(response, dict):
        return False
    return bool(response.get("is_error") or response.get("interrupted"))


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0
    if payload.get("tool_name") != "Bash" or failed(payload):
        return 0
    command = (payload.get("tool_input", {}) or {}).get("command", "") or ""
    stripped = HEREDOC.sub(blank_body, command)
    stripped = QUOTED.sub(lambda m: " " * len(m.group(0)), stripped)
    if INERT.search(stripped):
        return 0
    landed = FORGE_MERGE.search(stripped) or (
        LOCAL_MERGE.search(stripped) and on_default_branch()
    )
    if not landed:
        return 0
    sys.stderr.write(ADVICE)
    return 2  # PostToolUse: exit 2 surfaces stderr to the model, non-blocking


if __name__ == "__main__":
    sys.exit(main())
