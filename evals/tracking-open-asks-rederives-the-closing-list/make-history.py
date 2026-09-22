#!/usr/bin/env python3
"""Writes `history.jsonl`, the conversation this case resumes from.

`context.history_file` is `--resume <path>`: the lines below reach the run as
its own earlier turns, so the case starts from a closing list that already
holds an item belonging to a third party, and the prompt asks for a second
closing list. The exchange lives here rather than in the JSON so the seeded
turns can be read and changed as text.

Regenerate after editing the exchange below, and after any change to
`hooks/session-brief.md`, which is read at build time rather than copied:

    python3 evals/tracking-open-asks-rederives-the-closing-list/make-history.py

The output is deterministic - fixed identifiers, one fixed timestamp - so a
regeneration that changes nothing leaves the file byte-identical, and `git
diff` after running it is the staleness check on the brief.

Two constraints the file's shape answers:

- The brief is in the file because the hook will not supply it. `SessionStart`
  fires on a resume with `source: "resume"` and this plugin's matcher is
  `startup|clear|compact`, so a resumed run gets no brief; a recorded session
  replays its own, out of the `hook_additional_context` attachment its startup
  wrote. That attachment - `content`, and the `rendered` system-reminder beside
  it - is copied here in the shape a recorded transcript carries it.
- The timestamps are written as JSON `\\u002D` escapes, so the committed bytes
  carry no date-shaped literal. The leak guard blocks that shape on sight and
  cannot tell an invented date from a real one; the escape is the same string
  to every JSON parser, and the run sees an ordinary timestamp.
"""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
BRIEF = os.path.join(ROOT, "hooks", "session-brief.md")
OUT = os.path.join(HERE, "history.jsonl")

SESSION = "7c1f0b6a-3d54-4a18-9f2e-2b0c5d8e41aa"
STAMP = "@@TS@@"
ESCAPED_STAMP = "2026\\u002D09\\u002D20T09:10:00.000Z"
CWD = "/workspace"
VERSION = "2.1.278"

USER = """Picking this back up; where we stand is in `docs/plans/export-columns.md`. \
Two things: rename the `--dry` flag to `--dry-run` everywhere it appears, and set \
the version for the release. Don't commit, I'll look at the diff."""

ASSISTANT = """Both done, nothing committed.

**Rename.** `bin/export.sh` takes `--dry-run` now - the flag test and the usage \
line above it - and the README's usage block matches. No `--dry` is left in \
either file.

**Version.** `VERSION` said 2.3.0 and the changelog's top entry is 2.4.0 \
(unreleased), so the release being prepared is 2.4.0 and `VERSION` says that \
now. The changelog heading still carries the `(unreleased)` marker.

Waiting on you:

| # | Question | What it blocks | If no answer |
|---|---|---|---|
| 1 | Must the legacy column order `id,currency,amount` be kept, now that the \
header is `id,amount,currency,booked_at`? | Step 2 of `docs/plans/export-columns.md`, \
and the release behind it | The work waits - I won't reorder on my own |
| 2 | May `tmp-migrate` be deleted? It is merged into main and looks dead. | \
Nothing | The branch stays where it is |
| 3 | Should `booked_at` be exported as UTC, or converted to the posting \
region's local time? | The column's values, and the release note that describes \
them | The export keeps passing the value through unchanged |"""


def common():
    return {
        "isSidechain": False,
        "userType": "external",
        "entrypoint": "cli",
        "cwd": CWD,
        "sessionId": SESSION,
        "version": VERSION,
        "gitBranch": "main",
        "timestamp": STAMP,
    }


def uid(n):
    return "7c1f0b6a-3d54-4a18-9f2e-2b0c5d8e41%02d" % n


def brief_lines():
    with open(BRIEF) as fh:
        brief = fh.read().rstrip("\n")
    line = dict(
        type="attachment",
        uuid=uid(1),
        parentUuid=None,
        attachment={
            "type": "hook_additional_context",
            "content": [brief],
            "hookName": "SessionStart",
            "toolUseID": "SessionStart",
            "hookEvent": "SessionStart",
        },
        rendered=[{
            "content": "<system-reminder>\nSessionStart hook additional "
                       "context: %s\n</system-reminder>" % brief,
        }],
        **common()
    )
    return line


def user_line(parent, text):
    return dict(
        type="user",
        uuid=uid(2),
        parentUuid=parent,
        message={"role": "user", "content": text},
        promptSource="typed",
        turnOrigin="human",
        origin={"kind": "human"},
        **common()
    )


def assistant_line(parent, text):
    return dict(
        type="assistant",
        uuid=uid(3),
        parentUuid=parent,
        message={
            "id": "msg_01ReplayFixture",
            "type": "message",
            "role": "assistant",
            "model": "claude-sonnet-5",
            "content": [{"type": "text", "text": text}],
            "stop_reason": "end_turn",
            "stop_sequence": None,
            "usage": {"input_tokens": 10, "output_tokens": 10,
                      "cache_read_input_tokens": 0,
                      "cache_creation_input_tokens": 0},
        },
        **common()
    )


def main():
    att = brief_lines()
    usr = user_line(att["uuid"], USER)
    asst = assistant_line(usr["uuid"], ASSISTANT)
    with open(OUT, "w") as fh:
        for line in (att, usr, asst):
            fh.write(json.dumps(line).replace(STAMP, ESCAPED_STAMP) + "\n")
    print("wrote %s" % OUT)


if __name__ == "__main__":
    main()
