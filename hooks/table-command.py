#!/usr/bin/env python3
"""Stop hook: warn when the turn's final message puts a command inside a
table cell.

Companion to tracking-open-asks, the closing table. A terminal wraps a cell at
its column's edge, so a command in one is copied in fragments the shell runs
one by one; and a command's unbroken length fixes its column's width, which
squeezes the cells beside it until their rows wrap past what the terminal will
draw as a grid. The remedy is the skill's: the command whole in a fenced block
above the table, under the item's number, and the cell pointing to it.

What counts as a command: an inline code span in a table cell that opens with
"! ", the form the harness runs from its prompt, or with a common command word
followed by an argument. A span naming a file or a flag alone is not one, and
nor is a command a fenced block in the same message holds whole: the cell then
points at a copy that can be taken in one piece.

Warn-only: the stop is never blocked, and any error emits nothing. The message
is read from the harness's last_assistant_message field; where a harness
version does not send it, the hook stays silent.
"""
import json
import re
import sys

FENCE = re.compile(r"^ {0,3}(`{3,}|~{3,})")
SEPARATOR = re.compile(r"^\s*\|?\s*:?-+:?\s*(\|\s*:?-+:?\s*)*\|?\s*$")
SPAN = re.compile(r"(`+)(.+?)\1")
COMMANDS = ("git", "gh", "glab", "az", "npm", "npx", "pnpm", "yarn", "bun", "node",
            "python", "python3", "pip", "uv", "uvx", "sh", "bash", "zsh", "cd", "rm",
            "mv", "cp", "mkdir", "make", "docker", "kubectl", "curl", "brew", "claude",
            "dotnet", "cargo", "go", "terraform", "ssh", "scp", "sed", "chmod")
COMMAND = re.compile(r"^(?:! \S|(?:sudo\s+)?(?:%s)\s+\S)" % "|".join(COMMANDS))
SHOWN = 48


def table_rows(message):
    """The lines of every table outside fenced blocks."""
    rows, fence, in_table = [], None, False
    lines = message.splitlines()
    for i, line in enumerate(lines):
        opened = FENCE.match(line)
        if fence is not None:
            if opened and opened.group(1)[0] == fence[0]:
                fence = None
            continue
        if opened:
            fence, in_table = opened.group(1), False
            continue
        piped = line.strip().startswith("|")
        if in_table and piped:
            rows.append(line)
            continue
        in_table = False
        nxt = lines[i + 1] if i + 1 < len(lines) else ""
        if piped and "-" in nxt and SEPARATOR.match(nxt):
            in_table = True
            rows.append(line)
    return rows


def fenced_text(message):
    """The text of every fenced block in `message`, joined."""
    held, fence = [], None
    for line in message.splitlines():
        opened = FENCE.match(line)
        if fence is None:
            if opened:
                fence = opened.group(1)
            continue
        if opened and opened.group(1)[0] == fence[0]:
            fence = None
            continue
        held.append(line)
    return "\n".join(held)


def commands_in_cells(message):
    """Each command a table cell holds that no fenced block repeats whole."""
    found = []
    fenced = fenced_text(message)
    for row in table_rows(message):
        for span in SPAN.finditer(row):
            text = span.group(2).strip()
            if COMMAND.match(text) and text.lstrip("! ") not in fenced:
                found.append(text)
    return found


def main():
    payload = json.load(sys.stdin)
    message = payload.get("last_assistant_message")
    if not isinstance(message, str):
        return
    found = commands_in_cells(message)
    if not found:
        return
    first = found[0] if len(found[0]) <= SHOWN else found[0][:SHOWN] + "..."
    count = "a command" if len(found) == 1 else "%d commands" % len(found)
    sys.stdout.write(json.dumps({"systemMessage": (
        "table-command: the message above puts %s inside a table cell (first: %s). A terminal "
        "wraps a cell at its column's edge, so the command is copied in fragments, and its "
        "length squeezes the other cells until the table stops drawing as a grid. Put each "
        "command whole in a fenced block above the table, under its item's number, and let "
        "the cell point to it." % (count, first))}))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
