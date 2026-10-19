"""Shared reading of a session transcript for the hooks that look back through one.

One definition, because a compaction keeps every earlier line and a subagent's
turns land in the same file, and two copies of the walk that skips both drift
until one hook reads summarised-away context as the session's own.
"""
import json
import os

TAIL_BYTES = 1 << 20


def events_last_first(path):
    """The transcript's records, last first: what is wanted sits near the end,
    and a transcript runs to megabytes. The last megabyte is read first and
    the rest only if a caller walks past it, the line the seek split rejoined."""
    size = os.path.getsize(path)
    start = max(0, size - TAIL_BYTES)
    with open(path, "rb") as fh:
        fh.seek(start)
        lines = fh.read().split(b"\n")
        split = lines.pop(0) if start else b""
        for line in reversed(lines):
            yield from parsed(line)
        if start:
            fh.seek(0)
            head = (fh.read(start) + split).split(b"\n")
            for line in reversed(head):
                yield from parsed(line)


def parsed(line):
    try:
        event = json.loads(line.decode("utf-8", "replace"))
    except Exception:
        return
    if isinstance(event, dict):
        yield event


def phase(path):
    """This session's main-thread records since its last compaction, last first.
    A compaction keeps every earlier line, so a usage above its summary is the
    context that was summarised away; and a sidechain entry is a subagent's
    window rather than this session's."""
    for event in events_last_first(path):
        if event.get("isCompactSummary"):
            return
        if not event.get("isSidechain"):
            yield event


def told(path, mark):
    """Whether a hook's own line carrying `mark` was injected in this phase.
    Only the harness's record of hook context counts: a tool result or a file
    that quotes the line is not the line, and read as one it silences the hook
    for the rest of the phase."""
    for event in phase(path):
        attachment = event.get("attachment")
        if isinstance(attachment, dict) and attachment.get("type") == "hook_additional_context":
            content = attachment.get("content")
            if any(mark in text for text in (content if isinstance(content, list) else [content])
                   if isinstance(text, str)):
                return True
    return False
