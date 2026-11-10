#!/usr/bin/env python3
"""Stop hook: warn when the turn's final message holds a table a terminal will
not draw as a grid.

Companion to tracking-open-asks, the closing table. The terminal's renderer
draws a markdown table as a grid only while every row fits in MAX_ROW_LINES
wrapped lines; a row needing one more turns the whole table into stacked
label-value records, and a reader expecting a table finds none. A path or
command matters by the width it takes: it cannot wrap, so its column keeps it
and the sentences beside it run past the limit. The remedy is the skill's
shape: each item walked through in a paragraph above, the table an index of
cells a few words long.

The layout is an estimate of the renderer's, fitted to rendered tables: each
column wants its longest cell, gets at least its longest word where the widths
allow, and shares what is left by how much more it wants; cells then wrap by
word. WIDTH is the same guess at a plain terminal as handover-width's, since
the harness does not tell a hook the requester's display width.

Warn-only: the stop is never blocked, and any error emits nothing. The message
is read from the harness's last_assistant_message field; where a harness
version does not send it, the hook stays silent.
"""
import json
import re
import sys
import textwrap

WIDTH = 120
MAX_ROW_LINES = 4
MARGIN = 5
FENCE = re.compile(r"^ {0,3}(`{3,}|~{3,})")
SEPARATOR = re.compile(r"^\s*\|?\s*:?-+:?\s*(\|\s*:?-+:?\s*)*\|?\s*$")
MARKUP = re.compile(r"\*\*|__|`")


def cells(line):
    """The rendered text of each cell in a table line."""
    body = line.strip()
    if body.startswith("|"):
        body = body[1:]
    if body.endswith("|") and not body.endswith("\\|"):
        body = body[:-1]
    parts = re.split(r"(?<!\\)\|", body)
    return [MARKUP.sub("", p).replace("\\|", "|").strip() for p in parts]


def tables(message):
    """Each table in `message` outside fenced blocks, as a list of rows."""
    found, rows, fence, skip = [], [], None, False
    lines = message.splitlines()
    for i, line in enumerate(lines):
        if skip:
            skip = False
            continue
        opened = FENCE.match(line)
        if fence is not None:
            if opened and opened.group(1)[0] == fence[0]:
                fence = None
            continue
        if opened:
            fence = opened.group(1)
            continue
        if rows:
            if line.strip().startswith("|"):
                rows.append(cells(line))
                continue
            found.append(rows)
            rows = []
        nxt = lines[i + 1] if i + 1 < len(lines) else ""
        if line.strip().startswith("|") and "-" in nxt and SEPARATOR.match(nxt):
            rows, skip = [cells(line)], True
    if rows:
        found.append(rows)
    return found


def widths(rows, width):
    """The column widths the renderer is estimated to give `rows` at `width`."""
    n = max(len(r) for r in rows)
    want = [max((len(r[c]) if c < len(r) else 0) for r in rows) for c in range(n)]
    word = [max((max((len(w) for w in r[c].split()), default=0) if c < len(r) else 0)
                for r in rows) for c in range(n)]
    room = width - (3 * n + 1) - MARGIN
    if sum(want) <= room:
        return want
    floor = [max(1, min(want[c], word[c])) for c in range(n)]
    if sum(floor) >= room:
        return [max(1, room * f // sum(floor)) for f in floor]
    extra = room - sum(floor)
    need = [want[c] - floor[c] for c in range(n)]
    return [floor[c] + (extra * need[c] // sum(need) if sum(need) else 0) for c in range(n)]


def row_lines(row, cols):
    """How many lines `row` wraps to in columns `cols` wide."""
    return max(len(textwrap.wrap(cell, width=w, break_long_words=True)) or 1
               for cell, w in zip(row, cols))


def tall_rows(message, width=WIDTH):
    """For each table that would stack, its tallest row's estimated height."""
    found = []
    for rows in tables(message):
        cols = widths(rows, width)
        tallest = max(row_lines(r, cols) for r in rows)
        if tallest > MAX_ROW_LINES:
            found.append(tallest)
    return found


def main():
    payload = json.load(sys.stdin)
    message = payload.get("last_assistant_message")
    if not isinstance(message, str):
        return
    found = tall_rows(message)
    if not found:
        return
    count = "a table" if len(found) == 1 else "%d tables" % len(found)
    sys.stdout.write(json.dumps({"systemMessage": (
        "table-grid: the message above holds %s whose tallest row wraps to about %d lines "
        "at %d columns. A terminal draws a table as a grid only while every row fits in %d "
        "lines; past that it stacks each row as label-value records. Keep each cell a few "
        "words, put the full question, reason and any command in a paragraph above the "
        "table, and let the table index them." % (count, max(found), WIDTH, MAX_ROW_LINES))}))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
