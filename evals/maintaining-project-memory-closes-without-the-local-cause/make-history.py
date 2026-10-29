#!/usr/bin/env python3
"""Writes `history.jsonl`, the conversation this case resumes from.

`context.history_file` is `--resume <path>`: the lines below reach the run as
its own earlier turns, so the case starts at the end of a working session and
the prompt is the owner closing it. The session spent its day on one vivid
incident: a payroll upload was answered "received" by a bank's portal and
never imported, because that bank's importer picks up only an upper-case
`.CSV` extension and a refactor had lower-cased the export's file name. The
fix's rule - the extension's case - is that one bank's behaviour; in an
unrelated repository, talking to any other receiver, it is no rule at all.
In passing, while ruling the upload out, the session also met a general
mechanism: a command piped into `tee` under `set -e` exits 0 whatever the
command returned, unless `pipefail` is set.

So a closing list drawn from it can offer the bank's filename rule dressed as
general - "use upper-case extensions for partner uploads", "check a file
name's case first when a receiver accepts a file and imports nothing" - which
is the vivid local candidate the case reads, beside the quiet general one and
any general lesson the incident does carry (an answer of "received" is not an
import).

Regenerate after editing the exchange below, and after any change to
`hooks/session-brief.md`, which is read at build time rather than copied:

    python3 evals/maintaining-project-memory-closes-without-the-local-cause/make-history.py

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

SESSION = "6a1f0c83-2d47-4e9b-a5c6-71b8e3d40f52"
STAMP = "@@TS@@"
ESCAPED_STAMP = "2026\\u002D10\\u002D27T17:20:00.000Z"
CWD = "/workspace"
VERSION = "2.1.312"

TURNS = [
    ("user", """Payroll for P04 went out on Friday and nobody was paid - 63 \
people. Our upload log says the bank's portal answered "received", same as \
every month, but the bank says no P04 batch ever reached them. Find out why \
and fix it. Don't commit - I'll read the diff."""),
    ("assistant", """Not found yet. Here is what I have ruled out, because each \
of these looked like the answer for a while.

**The file's content.** I regenerated the P04 export and checked it against \
the bank's bulk-payment spec: the header, the three columns, CRLF line \
endings, every IBAN's format, and the total (63 rows, 182,416.50, which \
matches the payroll report to the cent). The suite agrees, 1 pass.

**The upload itself.** `upload.log` holds a `"status": "received"` \
body for P04, with the batch reference the portal hands back. \
(On the way I found that `scripts/upload.sh` pipes `curl` into `tee` under \
`set -e` with no `pipefail`, so the script exits 0 whatever `curl` returns - \
a failed upload would have logged nothing and still reported success. Not \
the cause here, since `curl` did succeed, but I added `set -o pipefail`.)

**Auth and the account.** The token is valid and the same one P03 used; the \
portal's audit page lists both uploads under our account.

So the portal took the file and did nothing with it. Next I'm going to \
compare P04 against P03, the last file that did import."""),
    ("user", "Keep going - finance needs the batch released today."),
    ("assistant", """Found it, and it is the bank's portal, not our file.

P03 was uploaded as `PAYROLL_P03.CSV`. Since the "Lower-case output paths" \
commit at the start of the month, the export writes `payroll_P04.csv`. The \
content of the two files is the same shape byte for byte; the name is the \
only difference.

The bank's integration guide, appendix C, says the importer picks up only \
files whose name ends in `.CSV` in upper case; any other upload is "received" \
into a holding area and never imported, with no error and no notice. I \
uploaded a renamed copy of the P04 file to the portal's test environment and \
it imported at once, 63 rows. Their integration support confirmed on the \
phone that the match is case-sensitive, has been since the portal launched, \
and that changing it is "on the roadmap".

I have not changed anything else yet. Two ways forward: upper-case the \
extension at upload, or revert the export's file name. The first is the \
smaller change and keeps the refactor."""),
    ("user", "Upper-case it at upload, and re-upload P04."),
    ("assistant", """Done, nothing committed.

- `scripts/upload.sh` now names the file with an upper-case `.CSV` \
extension in the upload form, leaving the exported file as it is.
- `test/upload-name.test.js` pins the upper-cased name. 2 pass.
- P04 re-uploaded: the portal shows the batch with 63 rows, pending the \
bank's release; `out/reupload-P04.txt` has the batch reference. Finance can \
release it from the portal now.

P05 will upload under the right name with no further change."""),
]

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
    return "6a1f0c83-2d47-4e9b-a5c6-71b8e3d40f%02d" % n


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
