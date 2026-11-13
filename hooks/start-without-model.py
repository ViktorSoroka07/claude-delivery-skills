#!/usr/bin/env python3
"""PreToolUse hook (Bash, and the desktop app's session-start tool): refuse a
call that starts another Claude Code session without naming its model.

A session started with no model runs on its starter's, and a coordinator runs
on the dearest one, so a build meant for a smaller model runs on the largest
and only the bill says so; a child started that way starts its own children
the same way. The rule that a start names its model lives in
coordinating-sessions, which nothing makes a coordinator load, and a gate on
loading it does not move the act, so the check sits on the act. The refusal
names the requester's model, or one tier below the session's own, and no model
id: the hook cannot know the session's tier, and ids change.

Two routes are read. The desktop app's start tool, bar four shapes, which pass
as its own schema words them: a proposal's start, which carries the proposal's
id and otherwise only a wake flag or, after an offer card, the brief; an offer
card, which carries a title alone; a fork, for which `model` is marked "fresh"
only; and a cloud session, for which `model` does not apply. And a terminal
multiplexer's `send`, `send-panel` or `--command` text that runs `claude`, on
its own, behind a `cd`, or by path, with neither `--model` nor
`ANTHROPIC_MODEL` set. Help, version, headless and subcommand runs pass, as
does a start whose words a shell variable or substitution holds, which the hook
cannot read. A launcher of the user's own is not read: how it names a model is
its own.

A subagent dispatch is left out: its model comes from its agent definition,
which delegating-to-subagents owns.

Fails open on any error: a refusal this hook cannot justify blocks real work
in every session on the machine.
"""
import json
import os
import re
import shlex
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from shell_text import blank  # noqa: E402

START_TOOL = "mcp__ccd_session__start_session"
SEPARATOR = re.compile(r"(?<!>)\||[;&\n]")
CMUX = re.compile(r"(?:^|\s)(?:\S*/)?cmux\s")
SEND = ("send", "send-panel")
SEND_VALUED = ("--workspace", "--surface", "--window", "--panel")
LINE_BREAK = re.compile(r"\\[nr]|[\n\r]")
CHAIN = re.compile(r"&&|\|\||;")
ASSIGNMENT = re.compile(r"[A-Za-z_]\w*=")
SUBCOMMAND = re.compile(r"[a-z][a-z-]*")
NO_SESSION = {"-h", "--help", "-v", "--version", "-p", "--print"}
UNREADABLE = re.compile(r"[$`]")


def sent_texts(words):
    """The texts a cmux call types or runs: the text of a send, and every
    --command value."""
    texts = []
    for i, word in enumerate(words):
        if word == "--command" and i + 1 < len(words):
            texts.append(words[i + 1])
        elif word.startswith("--command="):
            texts.append(word.split("=", 1)[1])
    verb = next((i for i, w in enumerate(words) if w in SEND), None)
    if verb is None:
        return texts
    i = verb + 1
    while i < len(words):
        word = words[i]
        if word == "--":
            i += 1
            break
        if word in SEND_VALUED:
            i += 2
        elif word.startswith("-"):
            i += 1
        else:
            break
    if i < len(words):
        texts.append(words[i])
    return texts


def unnamed_start(words):
    env_model = False
    while words and ASSIGNMENT.match(words[0]):
        env_model = env_model or words[0].startswith("ANTHROPIC_MODEL=")
        words = words[1:]
    if words and words[0] == "exec":
        words = words[1:]
    if not words or os.path.basename(words[0]) != "claude" or env_model:
        return False
    args = words[1:]
    if NO_SESSION.intersection(args) or (args and SUBCOMMAND.fullmatch(args[0])):
        return False
    if any(UNREADABLE.search(a) for a in args):
        return False
    for i, arg in enumerate(args):
        if arg == "--model" and i + 1 < len(args) and args[i + 1].strip():
            return False
        if arg.startswith("--model=") and arg[len("--model="):].strip():
            return False
    return True


def text_starts_unnamed(text):
    for line in LINE_BREAK.split(text):
        for part in CHAIN.split(line):
            try:
                words = shlex.split(part)
            except ValueError:
                continue
            if unnamed_start(words):
                return True
    return False


def bash_starts_unnamed(command):
    _, stripped = blank(command)
    start = 0
    for end in [m.start() for m in SEPARATOR.finditer(stripped)] + [len(stripped)]:
        seg, raw = stripped[start:end], command[start:end]
        start = end + 1
        if not CMUX.search(" " + seg):
            continue
        try:
            words = shlex.split(raw)
        except ValueError:
            continue
        if any(text_starts_unnamed(t) for t in sent_texts(words)):
            return True
    return False


def filled(value):
    return isinstance(value, str) and bool(value.strip())


def tool_starts_unnamed(tool_input):
    if filled(tool_input.get("proposal_id")) or tool_input.get("initiation") == "offer":
        return False
    if tool_input.get("context") == "fork" or tool_input.get("target") == "cloud":
        return False
    return not filled(tool_input.get("model"))


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0
    if not isinstance(payload, dict):
        return 0
    tool = payload.get("tool_name")
    tool_input = payload.get("tool_input")
    if not isinstance(tool_input, dict):
        return 0
    if tool == START_TOOL:
        unnamed, where = tool_starts_unnamed(tool_input), "the call's `model` field"
    elif tool == "Bash" and isinstance(tool_input.get("command"), str):
        unnamed, where = bash_starts_unnamed(tool_input["command"]), "`--model <id>` on the command line"
    else:
        return 0
    if not unnamed:
        return 0
    sys.stdout.write(json.dumps({
        "systemMessage": (
            "delivery-skills refused a session start that named no model, which would have run "
            "the new session on this session's model; the session names one and starts it again. "
            "Claude Code labels every hook stop a \"hook error\"; nothing failed."
        ),
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": (
                "Not an error: delivery-skills refuses a start of another session that names no "
                "model, because the new session then runs on yours, the dearest choice, made "
                "silently. Name the model the requester named for this work, or, where none was "
                "named, one tier below your own; put it in %s and send the call again. Say which "
                "model and why in the line that announces the start, so the requester can overrule "
                "it before the new session spends anything (`delivery-skills:coordinating-sessions` "
                "holds the rule)." % where
            ),
        }
    }))
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        sys.exit(0)
