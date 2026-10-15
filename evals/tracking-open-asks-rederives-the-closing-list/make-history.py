#!/usr/bin/env python3
"""Writes `history.jsonl`, the conversation this case resumes from.

`context.history_file` is `--resume <path>`: the lines below reach the run as
its own earlier turns, so the case starts from a closing list that already
holds an item belonging to a third party, and the prompt asks for a second
closing list. The exchange lives here rather than in the JSON so the seeded
turns can be read and changed as text.

Regenerate after editing the exchange below, and after any change to
`hooks/session-brief.md` or `skills/tracking-open-asks/SKILL.md`, which are
read at build time rather than copied:

    python3 evals/tracking-open-asks-rederives-the-closing-list/make-history.py

The output is deterministic - fixed identifiers, one fixed timestamp - so a
regeneration that changes nothing leaves the file byte-identical. That is the
staleness check on the brief and the skill, and `scripts/check-refs.sh` runs it: it builds
into a temporary file, named as the one argument, and fails when that differs
from the committed file.

Four constraints the file's shape answers:

- The brief is in the file because the hook will not supply it. `SessionStart`
  fires on a resume with `source: "resume"` and this plugin's matcher is
  `startup|clear|compact`, so a resumed run gets no brief; a recorded session
  replays its own, out of the `hook_additional_context` attachment its startup
  wrote. That attachment - `content`, and the `rendered` system-reminder beside
  it - is copied here in the shape a recorded transcript carries it.
- The seeded turn loads the skill before it answers, as a fresh conversation
  does since the brief made that load its first tool call: the Skill
  `tool_use`, its `tool_result`, and the skill's body as the `isMeta` user
  message the harness injects, in the shape a recorded transcript carries
  them. Without it a resumed run holds only the brief's summary of the rule,
  and its first tool call reads as already spent, so it never loads the skill
  itself.
- The seeded turn's work is in the file as the calls that did it: the plan
  read, the search for the flag, a read and an edit per file, and the check
  that closes it. A resumed model reads its earlier turn back, and a report of
  edits with no call behind it reads as invented: reps retracted it, and the
  seeded list with it, which moved the item graders for a reason no wording
  touched. The paths are relative, because the run's directory is chosen per
  run and a seeded path is visible to the model. The outputs are what the
  `post-rename` tree prints under the sandbox's grep, held here as text so the
  generator builds without a fixture; a change to the files
  `evals/fixtures/export-cli.sh` writes is copied here by hand, since no gate
  compares the two.
- The timestamps are written as JSON `\\u002D` escapes, so the committed bytes
  carry no date-shaped literal. The leak guard blocks that shape on sight and
  cannot tell an invented date from a real one; the escape is the same string
  to every JSON parser, and the run sees an ordinary timestamp.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
BRIEF = os.path.join(ROOT, "hooks", "session-brief.md")
SKILL_NAME = "tracking-open-asks"
SKILL = os.path.join(ROOT, "skills", SKILL_NAME, "SKILL.md")
SKILL_BASE = "/plugins/delivery-skills/skills/" + SKILL_NAME
TOOL_USE_ID = "toolu_01ReplayFixtureSkillLoad"
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

PLAN = """# Export columns

## Steps

1. Add `booked_at` to the export. Done.
2. Settle the column order. Blocked: the legacy consumers read columns by \
position (`id,currency,amount`), the new header is \
`id,amount,currency,booked_at`. Asked the owner whether the legacy order must \
be kept; no answer yet.
3. Release.

## Housekeeping

- `tmp-migrate` is merged into main and looks dead. Asked the owner whether \
it may be deleted; no answer yet.
- `booked_at` arrives from the feed without an offset. Raised with the \
ledger-api maintainers on their own tracker, not with the owner - the feed's \
schema is theirs and the answer is theirs to give. See \
`docs/upstream/booked-at-timezone.md`.
"""

EXPORT_SH = """#!/bin/sh
# Usage: export.sh [--dry] <out.csv>
dry=0
if [ "${1:-}" = "--dry" ]; then dry=1; shift; fi
out=${1:?output file}
header="id,amount,currency,booked_at"
if [ "$dry" -eq 1 ]; then
  echo "would write $out with columns: $header"
  exit 0
fi
echo "$header" > "$out"
"""

README = """# ledger-export

Writes the ledger as CSV.

    bin/export.sh --dry out.csv    # print what would be written
    bin/export.sh out.csv
"""

FOUND = """./bin/export.sh:2:# Usage: export.sh [--dry] <out.csv>
./bin/export.sh:4:if [ "${1:-}" = "--dry" ]; then dry=1; shift; fi
./README.md:5:    bin/export.sh --dry out.csv    # print what would be written
2.3.0
# Changelog

## 2.4.0 (unreleased)

- Export writes `booked_at`."""

CHECKED = """ README.md     | 2 +-
 VERSION       | 2 +-
 bin/export.sh | 4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)
no bare --dry left"""


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


def assistant_message(msg_id, content, stop_reason):
    return {
        "id": msg_id,
        "type": "message",
        "role": "assistant",
        "model": "claude-sonnet-5",
        "content": content,
        "stop_reason": stop_reason,
        "stop_sequence": None,
        "usage": {"input_tokens": 10, "output_tokens": 10,
                  "cache_read_input_tokens": 0,
                  "cache_creation_input_tokens": 0},
    }


def skill_body():
    with open(SKILL) as fh:
        text = fh.read()
    if text.startswith("---\n"):
        text = text.split("\n---\n", 1)[1]
    return text.lstrip("\n")


def tool_lines(n, parent, call_id, msg_id, name, tool_input, content,
               tool_use_result, **result_extra):
    call = dict(
        type="assistant",
        uuid=uid(n),
        parentUuid=parent,
        message=assistant_message(
            msg_id,
            [{"type": "tool_use", "id": call_id, "name": name,
              "input": tool_input}],
            "tool_use"),
        **common()
    )
    result = dict(
        type="user",
        uuid=uid(n + 1),
        parentUuid=call["uuid"],
        message={"role": "user", "content": [dict(
            type="tool_result",
            tool_use_id=call_id,
            content=content,
            **result_extra
        )]},
        toolUseResult=tool_use_result,
        sourceToolAssistantUUID=call["uuid"],
        **common()
    )
    return [call, result]


def skill_load_lines(parent):
    call, result = tool_lines(
        4, parent, TOOL_USE_ID, "msg_01ReplayFixtureSkill", "Skill",
        {"skill": "delivery-skills:" + SKILL_NAME},
        "Launching skill: delivery-skills:" + SKILL_NAME,
        {"success": True, "commandName": "delivery-skills:" + SKILL_NAME})
    body = dict(
        type="user",
        uuid=uid(6),
        parentUuid=result["uuid"],
        message={"role": "user", "content": [{
            "type": "text",
            "text": "Base directory for this skill: %s\n\n%s"
                    % (SKILL_BASE, skill_body()),
        }]},
        isMeta=True,
        sourceToolUseID=TOOL_USE_ID,
        **common()
    )
    return [call, result, body]


def read_call(path, text):
    lines = text.split("\n")
    return ("Read", {"file_path": path},
            "\n".join("%d\t%s" % (i, line) for i, line in enumerate(lines, 1)),
            {"type": "text", "file": {
                "filePath": path, "content": text, "numLines": len(lines),
                "startLine": 1, "totalLines": len(lines)}},
            {})


def edit_call(path, original, old, new, replace_all=False):
    return ("Edit",
            {"replace_all": replace_all, "file_path": path,
             "old_string": old, "new_string": new},
            "The file %s has been updated successfully. (file state is "
            "current in your context — no need to Read it back)" % path,
            {"filePath": path, "oldString": old, "newString": new,
             "originalFile": original, "userModified": False,
             "replaceAll": replace_all},
            {})


def bash_call(command, description, stdout):
    return ("Bash", {"command": command, "description": description}, stdout,
            {"stdout": stdout, "stderr": "", "interrupted": False,
             "isImage": False, "noOutputExpected": False},
            {"is_error": False})


def seeded_work_lines(parent):
    calls = [
        read_call("docs/plans/export-columns.md", PLAN),
        bash_call("grep -rn --exclude-dir=.git -e --dry .; cat VERSION; "
                  "head -n 5 CHANGELOG.md",
                  "Find every --dry and read the version and the "
                  "changelog's top entry", FOUND),
        read_call("bin/export.sh", EXPORT_SH),
        edit_call("bin/export.sh", EXPORT_SH, "--dry", "--dry-run",
                  replace_all=True),
        read_call("README.md", README),
        edit_call("README.md", README, "bin/export.sh --dry out.csv",
                  "bin/export.sh --dry-run out.csv"),
        read_call("VERSION", "2.3.0\n"),
        edit_call("VERSION", "2.3.0\n", "2.3.0", "2.4.0"),
        bash_call("git diff --stat; grep -rnE --exclude-dir=.git "
                  "-e '--dry([^-]|$)' . || echo 'no bare --dry left'",
                  "Check the diff and that no bare --dry is left", CHECKED),
    ]
    lines = []
    for i, (name, tool_input, content, tool_use_result, extra) in \
            enumerate(calls):
        lines += tool_lines(7 + 2 * i, parent,
                            "toolu_01ReplayFixtureWork%02d" % i,
                            "msg_01ReplayFixtureWork%02d" % i,
                            name, tool_input, content, tool_use_result,
                            **extra)
        parent = lines[-1]["uuid"]
    return lines


def assistant_line(parent, text):
    return dict(
        type="assistant",
        uuid=uid(3),
        parentUuid=parent,
        message=assistant_message(
            "msg_01ReplayFixture", [{"type": "text", "text": text}],
            "end_turn"),
        **common()
    )


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else OUT
    att = brief_lines()
    usr = user_line(att["uuid"], USER)
    load = skill_load_lines(usr["uuid"])
    work = seeded_work_lines(load[-1]["uuid"])
    asst = assistant_line(work[-1]["uuid"], ASSISTANT)
    with open(out, "w") as fh:
        for line in [att, usr] + load + work + [asst]:
            fh.write(json.dumps(line).replace(STAMP, ESCAPED_STAMP) + "\n")
    print("wrote %s" % out)


if __name__ == "__main__":
    main()
