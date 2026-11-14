# Posting through post-review.py (GitHub and Azure DevOps)

`post-review.py` sits beside `SKILL.md`, in the base directory the skill loader prints on invocation. On GitHub and Azure DevOps it carries out the mechanical half of `posting-and-applying.md`, together with the failure handling a script written for one post gets wrong. **Post through it; never write a posting script of your own.** What goes into the post stays yours: which findings, grouped how, in which form, in which words, and every repair a stop asks for. GitLab is not covered: post there by hand per `posting-and-applying.md`.

What the script does, so the session does not do it again:

- **Before any create, it refuses** a request whose head moved past the head its threads were verified at, an anchor on a file outside the diff, a line past the end of its file, a GitHub anchor off a changed line, a suggestion whose lines changed since the review, a suggestion block in a multi-member compact thread, a compact thread at request level whose members sit in the diff, and a findings file already posted.
- **It posts and reads every thread back:** one review on GitHub, one thread at a time on Azure DevOps. Placement is compared, and so is the whole body, byte for byte, against the string it sent. A body the forge stored altered is put back in place once, and the read after that decides.
- **A create whose answer was lost** (a 5xx, a timeout) is read back from the request, never retried.
- **It writes the findings file's frontmatter `posted:`** after a clean read-back, and no other byte of that file.
- **Its working files go in one temporary directory**, never in the clone.

## Build the manifest

Write it as JSON under `$TMPDIR`, never in the clone:

```json
{
  "schema": 1,
  "forge": "github",
  "repo": "github.com/acme/tickets",
  "request": 42,
  "reviewed_sha": "<the findings file's reviewed_sha>",
  "form": "default",
  "findings_file": "<the findings file's absolute path>",
  "threads": [
    { "key": "M-1", "path": "src/a.ts", "line": 42, "body": "**Medium — ...**\n\nProblem: ..." },
    { "key": "M-2", "path": "src/a.ts", "start_line": 50, "line": 51,
      "body": "**Medium — ...**\n\n...\n\n```suggestion\n...\n```",
      "suggestion": { "start": 50, "end": 51, "original": ["line 50 as reviewed", "line 51 as reviewed"] } },
    { "key": "m-3", "path": null, "body": "**Nit — ...**\n\nProblem: `docs/b.md:3` ..." }
  ]
}
```

- `forge` is `github` or `ado`. `repo`, `request` and `reviewed_sha` are the findings file's `repo`, `pr` and `reviewed_sha`; the script refuses a findings file whose `pr` or `reviewed_sha` differs.
- `verified_head`, only after a `STALE-HEAD` stop: the head the threads were re-verified at. Absent, it is `reviewed_sha`.
- `form` is `default` or `compact`; `"pending": true` stages the review (GitHub only).
- One thread per posted thread, built by the rules of `posting-and-applying.md` and the platform reference: grouping, compact assembly, held open questions, relocated anchors, the GitHub review body's one exception. `key` is unique: the finding's id, or the compact table's row.
- `path: null` is a request-level thread; on GitHub these become the review's body, joined in manifest order.
- `start_line` only for a multi-line anchor. `suggestion` only where the body ends in a suggestion block: `start` and `end` are the replaced lines, `original` their text as the finding recorded it, one string a line.
- `members`, only on a compact thread whose row has more than one member: `[{"path": ..., "line": ...}]`, every member's location.
- An unknown field is refused, so a misspelled key cannot post a wrong anchor.

## Run it

From the clone the review was made in:

    python3 <skill dir>/post-review.py "$TMPDIR/<manifest>.json"

`--dry-run` runs every check, reading the request from the forge, and prints the creates it would make. On Azure DevOps the token comes from `AZURE_DEVOPS_EXT_PAT`; never put a token on the command line. The last two lines of the output are the status line and the run's temporary directory, whose `result.json` lists every thread's key, id, anchor and status, and each correction's before and after. Exit 0 is `LANDED` or `CORRECTED`, or `DRY-RUN` on a dry run.

## What each stop asks of you

Nothing was created by a stop before the post, so fix the cause and run the same command again:

| Status | Do |
|---|---|
| `MANIFEST-INVALID`, `EMPTY` | Fix the manifest as the message says. |
| `NO-FRONTMATTER` | Add the lines the stop prints where it says: a file without frontmatter takes the whole block at its top; a file whose frontmatter lacks `posted:` takes only the printed lines, inside that block. |
| `ALREADY-POSTED` | The review went out already. `--repost` only when the user wants it out a second time; the result's `replaced` holds the earlier record, which you move into the file's body. |
| `POSTED-UNKNOWN` | Read the findings file's body for a record of a post; with none, `--repost`. |
| `NO-TOKEN`, `AUTH-REFUSED` | Tell the user the forge needs a credential (`gh auth status`, or `AZURE_DEVOPS_EXT_PAT`); never ask for the token itself. |
| `STALE-HEAD` | The author pushed after the review. `git fetch origin <branch>`, re-verify every thread at the new head per `posting-and-applying.md`'s "Re-verify first" (an anchor follows its line; a suggestion whose lines changed loses its block, its prose stays), update the manifest's threads, set its `verified_head` to the head the message names, and run again. Never change `reviewed_sha`, in the manifest or the findings file: it names the head the review covered, and the next review round starts from it. |
| `MISSING-COMMIT` | The clone lacks a commit: fetch as the message names, and run again. |
| `OUT-OF-DIFF` | Move the thread to request level with its `file:line` in the prose. |
| `LINE-OUT-OF-FILE`, `OFF-DIFF-LINE` | Re-anchor per the platform reference's anchor rules. |
| `STALE-SUGGESTION` | Drop the block and its `suggestion`; the prose fix stays. |
| `SUGGESTION-IN-GROUP` | Turn the block into a plain snippet, as compact posting requires. |
| `PARTITION` | Repack the compact row: the members the message names belong in an anchored thread. |
| `PENDING-EXISTS` | The user already has a staged review on the request: ask them. |

After a create the script keeps a record, so **a plain re-run of the same manifest is refused** (`UNFINISHED-RUN`), and it is the retry that would double every thread:

| Status | Do |
|---|---|
| `REJECTED` | The forge refused a thread. On GitHub the review is one submission and nothing landed: fix it and run again. On Azure DevOps the threads before it landed: fix the thread, then `--resume`, which posts only what has not landed. |
| `UNCERTAIN` | A create's answer was lost and the read-back could not account for it. `--resume`: it refuses (`SETTLING`) until a late copy has had time to land, then posts only what is missing. Where the message names items of yours that pair with no thread, ask the user about each before resuming: one they wrote themselves stays, and `--resume --ignore-item <id>`, once per item, leaves it out of the pairing; a copy of one of the manifest's threads is theirs to delete, then `--resume`. |
| `SETTLING` | Run `--resume` again after the time it names. |
| `UNVERIFIED` | A read failed; any thread created before it is listed as landed. `--resume` reads again, and answers `NO-STATE` when nothing was sent. |
| `MISSING`, `MISMATCH`, `MISPLACED` | A thread is absent, its text still differs after the one correction (the diff is printed), or it sits elsewhere than sent. Report it to the user with the script's lines; moving or re-posting is theirs to decide. |
| `NO-STATE` | `--resume` found no unfinished run: run without it. |
| `MOVED-MID-RUN` | The author pushed after some threads landed. The run is closed and nothing was posted at the new head. Tell the user which threads landed at which head. To post the rest, take the landed threads out of the manifest and run without `--resume`, then add the first run's ids, printed as landed before the stop, to the findings file's body. If no thread is left, the post is complete at the old head: write its `posted:` line by hand, with `head:` that head. |

## After a clean run

`posted:` is written, with `head:` where the post went out at a head other than `reviewed_sha`; do not write it again. Bring the findings file's prose into line with what was posted, as `posting-and-applying.md` requires, and record each correction from `result.json`. A `note:` line (a GitHub review missing from the request's latest reviews) goes to the user.
