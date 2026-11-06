#!/usr/bin/env python3
"""Stop hook: warn when the turn's final message hands over a command line too
wide to copy whole.

Companion to tracking-open-asks, an action handed to the requester. A command
is copied from the display it was shown in, and a display that wrapped it hands
the wraps over as line breaks: the shell then runs each fragment as a command of
its own - a truncated first half that is itself a valid and different command, a
bare path tried as a command - so what ran is not what was handed over. The
remedy is a line short enough not to wrap: short names in place of deep paths,
or a script written to a file and its one-line invocation.

What counts as a command line: a line inside a fenced block whose info string is
empty or names a shell, and an inline code span opening with "! ", the form the
harness runs from its prompt. A span sits mid-paragraph and wraps sooner than
the same text on a line of its own, so the threshold under-reports there.

WIDTH is a guess at a plain terminal's columns, not a measurement: the
harness does not tell a hook how wide the requester's display is, and 120 sits
above the 80 a stock terminal opens at and below a maximised window's width.

Warn-only: the stop is never blocked, and any error emits nothing. The message
is read from the harness's last_assistant_message field; where a harness
version does not send it, the hook stays silent.
"""
import json
import re
import sys

WIDTH = 120
SHELL_INFO = {"", "sh", "bash", "zsh", "shell", "console", "shell-session",
              "fish", "powershell", "pwsh", "ps1"}
FENCE = re.compile(r"^ {0,3}(`{3,}|~{3,})\s*([^\s`]*)")
BANG_SPAN = re.compile(r"(`+)(! [^`].*?)\1")
SHOWN = 48


def wide_lines(message):
    """The command lines in `message` wider than WIDTH, in message order."""
    found = []
    fence = None
    shell = False
    for line in message.splitlines():
        opened = FENCE.match(line)
        if fence is None:
            if opened:
                fence = opened.group(1)
                shell = opened.group(2).lower() in SHELL_INFO
                continue
            for span in BANG_SPAN.finditer(line):
                text = span.group(2).strip()
                if len(text) > WIDTH:
                    found.append(text)
            continue
        if opened and opened.group(1)[0] == fence[0] and len(opened.group(1)) >= len(fence) \
                and not opened.group(2):
            fence = None
            continue
        text = line.expandtabs(8).rstrip()
        if shell and len(text) > WIDTH:
            found.append(text.strip())
    return found


def main():
    payload = json.load(sys.stdin)
    message = payload.get("last_assistant_message")
    if not isinstance(message, str):
        return
    found = wide_lines(message)
    if not found:
        return
    widest = max(found, key=len)
    head = widest if len(widest) <= SHOWN else widest[:SHOWN] + "..."
    count = "a command line" if len(found) == 1 else "%d command lines" % len(found)
    sys.stdout.write(json.dumps({"systemMessage": (
        "handover-width: the message above hands over %s past %d columns (widest %d: %s). "
        "Copied from a display that wrapped it, each wrap arrives as a line break and the "
        "shell runs the fragments as separate commands. Hand it over again as one line "
        "short enough not to wrap - short names for deep paths, or a script written to a "
        "file and its one-line invocation - whose truncated prefix is harmless."
        % (count, WIDTH, len(widest), head))}))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
