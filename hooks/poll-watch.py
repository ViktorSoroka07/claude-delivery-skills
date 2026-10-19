#!/usr/bin/env python3
"""PostToolUse hook (Bash): say once per phase that polling a run costs a turn per check.

Every turn re-reads the whole context, so a session that asks a CI run or a
request's checks whether they are done, one call at a time, pays a turn of its
whole transcript for each answer that says not yet, where one blocking wait
pays one. A skill sentence would not reach that moment - budgeting-agentic-work,
where it would sit, is not loaded while a session polls - so the hook speaks at
it instead: the third answer in a row from the same forge query that still
names a pending state.

A poll is re-typed between checks - another --jq filter, a 2>&1, a sleep in
front - so the query is its leading words up to the first flag, which carry the
run or request number. And only a forge CLI's answer is read for a pending
state: code and documents other commands print name "pending" with nothing
waiting. The tool's own wait is the blocking call the line recommends, never a
check, though its output repeats the pending rows it printed while waiting.

Fails open: any error emits nothing.
"""
import json
import os
import re
import shlex
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from shell_text import blank  # noqa: E402
from transcript import phase, told  # noqa: E402

CHECKS = 3
FORGES = ("gh", "az", "glab")

PENDING = re.compile(
    r"\b(?:in_progress|IN_PROGRESS|inProgress|queued|QUEUED|notStarted|PENDING"
    r"|pending(?![ \t]+[A-Za-z]))\b"
)
ANSI = re.compile(r"\x1b\[[0-9;]*m")
SETUP = re.compile(r"\s*(?:(?:command\s+)?sleep\b|cd\b|export\b|[A-Za-z_]\w*=)[^;&|\n]*(?:;|&&|\n)")
SEPARATOR = re.compile(r"[;&|\n]")
ASSIGNMENT = re.compile(r"[A-Za-z_]\w*=")
WAIT_FLAGS = ("--watch", "--live")
DURATION = re.compile(r"\d+(?:\.\d+)?[smhd]?$")

MARK = "each check costs a whole-context turn"

LINE = (
    "delivery-skills poll watch: `%s` has answered %s three times running. Every turn "
    "re-reads the whole context, so " + MARK + ", while one blocking wait costs a "
    "single turn however long the run takes: the tool's own wait (`gh run watch <id>`, "
    "`gh pr checks <n> --watch`), a loop with a timeout in one call where the tool has "
    "none, or either run in the background, whose completion notice wakes the session once."
)


def query(command):
    """The forge query a command runs, as its leading words up to the first flag
    or redirection and whether it is the tool's own wait, or None for any other
    command - a wait loop among them, whose first word is the loop's. Setup in
    front of it (a sleep, a cd, an assignment, a timeout) is skipped, and quoted
    spans and heredoc bodies are read as text. The wait is read from the command,
    never from its answer: `-w` waits only on `gh pr checks`, being
    `--workflow` on `gh run list`."""
    unfenced, stripped = blank(command)
    start = 0
    while True:
        m = SETUP.match(stripped, start)
        if not m:
            break
        start = m.end()
    end = SEPARATOR.search(stripped, start)
    first = unfenced[start:end.start() if end else len(unfenced)]
    try:
        words = shlex.split(first)
    except ValueError:
        words = first.split()
    while words and ASSIGNMENT.match(words[0]):
        words.pop(0)
    if words and words[0] == "timeout":
        words.pop(0)
        while words and (words[0].startswith("-") or DURATION.match(words[0])):
            words.pop(0)
    lead = []
    for word in words:
        if word.startswith("-") or "<" in word or ">" in word:
            break
        lead.append(word)
    if not lead or lead[0] not in FORGES:
        return None
    wait = ("watch" in lead or any(w in WAIT_FLAGS or w.split("=")[0] in WAIT_FLAGS for w in words)
            or (lead[:3] == ["gh", "pr", "checks"] and "-w" in words))
    return " ".join(lead), wait


def pending(answer):
    """The pending state an answer names, or None."""
    m = PENDING.search(ANSI.sub("", answer or ""))
    return m.group(0) if m else None


def result_text(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        return "\n".join(b.get("text") or "" for b in content if isinstance(b, dict))
    return ""


def earlier_pending(path, key, current_id):
    """How many answers in a row, just before this call and in this phase, the
    same query gave that still name a pending state. A failed call neither
    counts nor breaks the run; the tool's own wait on the same query ends it,
    as an answer that is no longer pending does. Only the session's own assistant and user records
    are read: the copy of each API request a transcript also keeps repeats every
    call under the same id, and read as a second check it fires on two."""
    results = {}
    run = 0
    for event in phase(path):
        if event.get("type") not in ("assistant", "user"):
            continue
        content = (event.get("message") or {}).get("content")
        if not isinstance(content, list):
            continue
        for block in reversed(content):
            if not isinstance(block, dict):
                continue
            if block.get("type") == "tool_result":
                results[block.get("tool_use_id")] = block
            elif block.get("type") == "tool_use" and block.get("name") == "Bash" \
                    and block.get("id") != current_id:
                command = (block.get("input") or {}).get("command")
                seen = query(command) if isinstance(command, str) else None
                if not seen or seen[0] != key:
                    continue
                if seen[1]:
                    return run
                result = results.get(block.get("id"))
                if result is None or result.get("is_error"):
                    continue
                if not pending(result_text(result.get("content"))):
                    return run
                run += 1
    return run


def main():
    payload = json.load(sys.stdin)
    if payload.get("tool_name") != "Bash":
        return
    response = payload.get("tool_response")
    if not isinstance(response, dict) or response.get("interrupted"):
        return
    seen = query((payload.get("tool_input") or {}).get("command") or "")
    if not seen or seen[1]:
        return
    key = seen[0]
    state = pending("%s\n%s" % (response.get("stdout") or "", response.get("stderr") or ""))
    if not state:
        return
    path = payload.get("transcript_path") or ""
    if not path or not os.path.isfile(path):
        return
    if earlier_pending(path, key, payload.get("tool_use_id")) + 1 < CHECKS or told(path, MARK):
        return
    sys.stdout.write(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PostToolUse",
            "additionalContext": LINE % (key, state),
        }
    }))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
