#!/usr/bin/env python3
"""UserPromptSubmit hook: inject how far this session is into its context window.

A session cannot see its own meter, so a rule asking it to name a seam before
the window fills has nothing to act on - two wordings of that rule failed for
that reason, and the measurement is what was missing. The size comes from the
usage the last main-thread API call recorded in the transcript, not from an
estimate of the file's length.

Fails open: any error emits nothing and the prompt goes through unannotated.

The window itself cannot be read from the transcript - the same model id runs
with different windows - so it is assumed, and the assumption is checked: a
session that has passed the configured window is running in a larger one,
because the call that carried it would have been refused otherwise. Past that
point the percentage is meaningless, and saying so is the only honest thing
the hook can do; telling such a session to wind down is a false alarm on every
prompt it sends.

Below the wind-down band, a session past a fixed size whose last turn pushed,
handed a push over or opened a request is told once per phase what each turn
now costs: every turn re-reads the whole context, and that turn is the point
where the work is durable enough to write a brief and compact.
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from shell_text import PR_CREATE, blank, git_verb  # noqa: E402
from transcript import phase, told  # noqa: E402

DEFAULT_WINDOW = 200000
THRESHOLD = 0.70
COST_TOKENS = 300000

HANDED = re.compile(r"!\s*git push\b")
GIT_PUSH = git_verb("push")

MISCALIBRATED = (
    "delivery-skills context meter: this session has passed %s tokens while the meter "
    "is set to a %s-token window, so the window is bigger than the meter assumes and "
    "its percentage says nothing about how much room is left. Read nothing into it "
    "here; setting DELIVERY_SKILLS_CONTEXT_WINDOW to this session's real window makes "
    "the meter work again."
)

LINE = (
    "delivery-skills context meter: this session is at %d%% of its context window "
    "(%s of %s tokens). Reach the next seam rather than the next task - finish and "
    "commit the step in hand, then write the hand-over a fresh session would need "
    "(the maintaining-project-memory skill owns it) and say what is left. What is "
    "unwritten when the window fills is what no later session can recover."
)

COST_MARK = "each turn from here costs the whole transcript"

COST = (
    "delivery-skills context meter: this session carries %s tokens of context and "
    "every turn re-reads all of it, so " + COST_MARK + ". The last turn pushed, "
    "handed a push over or opened a request, so the work in hand is durable and this "
    "is a seam: write the brief the next phase needs (the maintaining-project-memory "
    "skill owns it), then compact here or go on in a fresh session, rather than "
    "carrying this phase into every later turn."
)


def window():
    try:
        return int(os.environ["DELIVERY_SKILLS_CONTEXT_WINDOW"])
    except Exception:
        return DEFAULT_WINDOW


def context_tokens(path):
    for event in phase(path):
        usage = (event.get("message") or {}).get("usage")
        if isinstance(usage, dict):
            return sum(usage.get(k) or 0 for k in (
                "input_tokens", "cache_read_input_tokens", "cache_creation_input_tokens"))
    return 0


def is_prompt(event):
    if event.get("type") != "user" or event.get("isMeta"):
        return False
    content = (event.get("message") or {}).get("content")
    if not isinstance(content, list):
        return True
    return not any(isinstance(b, dict) and b.get("type") == "tool_result" for b in content)


def opens_a_seam(content):
    """A push handed over as the harness's own `! <command>` line, or a push or
    a request create the turn ran itself; a sentence that only names the
    command is neither, nor is a heredoc's or a quoted span's text."""
    for block in content if isinstance(content, list) else [content]:
        if isinstance(block, str):
            block = {"type": "text", "text": block}
        if not isinstance(block, dict):
            continue
        if block.get("type") == "text" and HANDED.search(block.get("text") or ""):
            return True
        command = (block.get("input") or {}).get("command") if block.get("type") == "tool_use" else None
        if isinstance(command, str):
            _, stripped = blank(command)
            if GIT_PUSH.search(stripped) or PR_CREATE.search(stripped):
                return True
    return False


def last_turn_is_a_seam(path):
    said = False
    for event in phase(path):
        if event.get("type") == "assistant":
            said = True
            if opens_a_seam((event.get("message") or {}).get("content")):
                return True
        elif said and is_prompt(event):
            return False
    return False


def thousands(n):
    return "%dk" % round(n / 1000.0)


def main():
    payload = json.load(sys.stdin)
    path = payload.get("transcript_path") or ""
    if not path or not os.path.isfile(path):
        return
    limit = window()
    tokens = context_tokens(path)
    if tokens > limit:
        context = MISCALIBRATED % (thousands(tokens), thousands(limit))
    elif tokens >= limit * THRESHOLD:
        context = LINE % (
            round(100.0 * tokens / limit), thousands(tokens), thousands(limit))
    elif tokens >= COST_TOKENS and last_turn_is_a_seam(path) and not told(path, COST_MARK):
        context = COST % thousands(tokens)
    else:
        return
    sys.stdout.write(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": context,
        }
    }))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
