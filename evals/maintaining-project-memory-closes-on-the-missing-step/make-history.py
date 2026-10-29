#!/usr/bin/env python3
"""Writes `history.jsonl`, the conversation this case resumes from.

`context.history_file` is `--resume <path>`: the lines below reach the run as
its own earlier turns, so the case starts at the end of a working session and
the prompt is the owner closing it. The session worked one pull request
through three review rounds and, in its first turn, stated the rule it held
the change to: a link whose expiry cannot be established is denied, and a
failure on the serving path stops the download rather than being logged. Each
later round of the bot's review found a failure of that same rule next to the route the previous
fix had closed - an expiry that does not parse, an audit failure logged and
served anyway, the preview path left as the download path had been - and each
fix had been pushed checked by the session alone.

So a closing list drawn from it can offer the principles one per failure, each
one the session already held and stated, or the one step that would have
applied them: an attempt to break each fix before it is pushed. That choice is
what the case reads.

Regenerate after editing the exchange below, and after any change to
`hooks/session-brief.md`, which is read at build time rather than copied:

    python3 evals/maintaining-project-memory-closes-on-the-missing-step/make-history.py

The output is deterministic - fixed identifiers, one fixed timestamp - so a
regeneration that changes nothing leaves the file byte-identical, which
`scripts/check-refs.sh` checks at every gate run.

Shape, as in the closing-list case's generator: the brief is in the file
because the hook will not supply it on a resume; no skill load and no tool
call is seeded, so the brief's first-tool-call line is live; the timestamps
are JSON `\\u002D` escapes, so the committed bytes carry no date-shaped literal
the leak guard would block.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
BRIEF = os.path.join(ROOT, "hooks", "session-brief.md")
OUT = os.path.join(HERE, "history.jsonl")

SESSION = "9d3c6e14-7a28-4b5f-b190-3e6a8c2f4d71"
STAMP = "@@TS@@"
ESCAPED_STAMP = "2026\\u002D09\\u002D29T16:40:00.000Z"
CWD = "/workspace"
VERSION = "2.1.289"

TURNS = [
    ("user", """The bot has reviewed PR 12, the share-link expiry change. Work \
through its comments - commit and push the fixes, and reply on the threads."""),
    ("assistant", """One thread, T1, and it is right: a link with no `expires` \
field is served forever. `isExpired()` returns `Date.parse(link.expires) < \
now`, and for a missing field that is `NaN < now`, which is false, so the \
link never expires.

The rule I am holding this change to: a link whose expiry we cannot establish \
is denied - on this path every failure lands on the closed side, never on \
serve - and a failure while serving stops the download rather than being \
logged and passed over.

- `isExpired()` now returns true when `expires` is absent, so such a link \
answers 410.
- New test: a link with no expiry is refused. 3 pass.
- Committed as "Deny a share link with no expiry", pushed, replied on T1 \
naming the commit, and resolved it."""),
    ("user", """The bot re-reviewed the new head and opened two more \
threads:

T2. `expires: "soon"` - any value that does not parse - is still served: \
`Date.parse` gives NaN and NaN < now is false.
T3. When the audit write fails, `serve()` logs a warning and streams the file \
anyway. The PR description says every download is audited.

Fix both."""),
    ("assistant", """Both are real.

T2: I closed the absent field and left every other value that fails to parse \
on the serve side. `isExpired()` now treats any expiry that does not parse to \
a finite time as expired. Test added.
T3: `serve()` caught the audit failure, logged it and went on to stream the \
file. It now answers 503 and sends nothing when the audit write fails. Test \
added.

4 pass, then 5 pass. Two commits, "Deny a share link whose expiry does not \
parse" and "Stop a download whose audit write fails", pushed, replied on T2 \
and T3 naming them, and resolved both."""),
    ("user", "And again on the new head - one more thread."),
    ("assistant", """T4, and it is right too: `servePreview()`, the thumbnail \
path, writes the same audit record and still only logs when the write fails. \
My fix for T3 changed `serve()` and not its sibling.

`servePreview()` now answers 503 and sends nothing when its audit write \
fails, the same as `serve()`. Test added, 6 pass - the suite now covers the \
missing expiry, the unparseable one, and an audit failure on both paths. \
Committed as "Stop a preview whose audit write fails", pushed, replied on T4 \
naming the commit, and resolved it. No thread is open on PR 12."""),
]

def common():
    return {
        "isSidechain": False,
        "userType": "external",
        "entrypoint": "cli",
        "cwd": CWD,
        "sessionId": SESSION,
        "version": VERSION,
        "gitBranch": "feat/link-expiry",
        "timestamp": STAMP,
    }


def uid(n):
    return "9d3c6e14-7a28-4b5f-b190-3e6a8c2f4d%02d" % n


def brief_line():
    with open(BRIEF) as fh:
        brief = fh.read().rstrip("\n")
    return dict(
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


def user_line(n, parent, text):
    return dict(
        type="user",
        uuid=uid(n),
        parentUuid=parent,
        message={"role": "user", "content": text},
        promptSource="typed",
        turnOrigin="human",
        origin={"kind": "human"},
        **common()
    )


def assistant_line(n, parent, text):
    return dict(
        type="assistant",
        uuid=uid(n),
        parentUuid=parent,
        message={
            "id": "msg_01ReplayStep%02d" % n,
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
    out = sys.argv[1] if len(sys.argv) > 1 else OUT
    lines = [brief_line()]
    for i, (role, text) in enumerate(TURNS, start=2):
        make = user_line if role == "user" else assistant_line
        lines.append(make(i, lines[-1]["uuid"], text))
    with open(out, "w") as fh:
        for line in lines:
            fh.write(json.dumps(line).replace(STAMP, ESCAPED_STAMP) + "\n")
    print("wrote %s" % out)


if __name__ == "__main__":
    main()
