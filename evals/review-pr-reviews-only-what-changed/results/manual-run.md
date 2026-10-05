# review-pr-reviews-only-what-changed

A second review of a branch after fix commits and a merge of `main`. The scaffold builds the ticket gateway's `feat/close-ticket` at `bd2f605`, seeds round 1's findings file for that commit in the run's state folder (`branch-feat-close-ticket/r1-bd2f605.md`, three findings: M-1 the redundant cache-control header, M-2 closing a closed ticket again, m-1 the missing doc block), then adds a fix commit (`620238a`: 409 for a closed ticket, the doc block, and a new `reopenTicket` with no missing-ticket check) and merges `main` (`da56eeb`: `src/audit.js`, which writes the authorization header to standard output) into the branch at `5dde025`. At the head, M-1 is still present and M-2 and m-1 are addressed (m-1's new doc block may fairly be called partly fixed). The delta from round 1 replayed onto the new merge base holds `src/handlers.js` and `test/handlers.test.js` only; a plain `git diff bd2f605 5dde025` (or `bd2f605...HEAD`, `log -p bd2f605..HEAD`, the merge's first-parent diff) also carries `src/audit.js`, the decoy; the full change against `main` carries no decoy either, so the decoy separates a correct delta from a naive one, not a delta from a full review. The logger writes through `process.stdout.write`, so the fixture's lint, which greps for `console.log`, never names it.

## The blind verifier's findings, adopted before the first draw

`evals/results/task69b-verifier/report.md` (its write was refused; saved from its reply). Adopted: the scope row matches any scope line naming round 1's commit, in any key order, and scores only where the trace agrees; a file row for the earlier findings' statuses, beside the chat row; the prompt no longer says "against main again", which sits on the treated text's own full-review trigger; the decoy no longer trips lint; each `llm` rubric's undecided case settled (an out-of-scope label, all three earlier findings accounted for, a test-gap title); the bars stated as gaps with every outcome decided; the M-1 anchor corrected to line 30.

## Bars, fixed before the first draw

Arms: baseline = review-pr on `main` at the landed storage text (1.11.0), treated = branch `69b-delta-on-a` (the later-round wording on top of it), both reporting plugin version 1.11.0, so kept apart by name as `round-69b@baseline*.json` and `round-69b@delta*.json`. Both with the plugin (`--ablation none`), five reps each, `--model sonnet`, `--judge-model sonnet`, `--keep-temp`, the state-folder grant; batch ceiling $14 against an expected ~$5.

Rows:

- **reviewed-the-delta** (bar): the diff the rep reviewed, classified by hand from its trace - *delta* (a `merge-tree` replay, or the fix commit `620238a` reviewed alone), *full* (`main...HEAD` or `$(merge-base main HEAD)...HEAD`), or *naive* (round 1's commit straight to the head, by any of the routes above) - is *delta*, and the kept round-2 file's `scope` names `bd2f605`. Declared and classified scope must agree; `scope-names-the-delta` is the screen.
- **earlier-findings-statused-in-file** (bar): the kept round-2 file gives M-1, M-2 and m-1 each a status at the head, by hand. A wrong status (M-1 called fixed) is recorded beside the row.
- **earlier-findings-statused** (chat): the `llm` row of that name - the hand-off accounts for all three. Read beside the file row as the measure of the hand-off sentence; not a bar.
- **Guards:** `decoy-not-reported`, `new-defect-found`, `round-two-written` (with its Bash companion, and the kept home).
- **Neighbour:** `review-pr-keeps-the-findings-outside-the-clone`, five reps on each text, its three bars (`findings-written-to-the-state-folder` with its Bash companion, `nothing-written-into-the-clone`, `reply-gives-the-absolute-path`), kept as `round-69b@baseline-storage.json` and `round-69b@delta-storage.json`.

Decisions:

- A bar lands only at treated ≥ baseline + 4 of 5 (4/5 against 0/5, or 5/5 against 1/5 or less). A baseline at 2 or 3 of 5 on a bar leaves that bar unlanded on this evidence; any re-check has its size and bar fixed before its draws.
- The wording lands when `reviewed-the-delta` clears its bar and no guard or neighbour declines it. If `earlier-findings-statused-in-file` is at 4/5 or better in the baseline, that half is unneeded on this model, and the tested text still lands as drawn - never a text edited after the draw.
- A guard or neighbour row declines the wording when its treated rate drops three or more of five below the baseline, or when any treated drop's hand-read cause is the wording itself (a naive delta in the trace behind a decoy fail; a delta that never read `reopenTicket` behind a new-defect fail; a write over `r1-bd2f605.md`). A drop with any other cause is recorded and does not decline.

Reading rules:

- A rep whose `skill-was-invoked` is dark is unusable and replaced, in either arm alike. So is a rep whose round file lands outside `git.example.org/acme/ticket-gateway/branch-feat-close-ticket/` (a rep that read "the remote cannot be reached" as "no remote" keys `local/<directory>`, as one did in the storage round): it never met the earlier round the rule fires on. A rep that wrote no findings file of any round is unusable only where its trace shows a cause outside the wording (the turn cap, an instrument fault); otherwise it fails `round-two-written`.
- A write over `r1-bd2f605.md`, in either arm, fails `round-two-written`; any non-zero `round-one-kept` in the treated arm is hand-read.
- The kept round-2 file decides every frontmatter and file row for every rep, whatever tool wrote it or rewrote it; the `tool_used` rows are screens, and a refused Write - which the runner counts as a call - is read as no write.
- The three `llm` rows judge the final message alone; every rep's final message is hand-read for them in both arms, and a disagreement with the judge is settled by the hand read and said here. `last_message` is the last assistant text of any thread, so a reply-row fail is checked one text event earlier before it counts.
- A treated rep that ran in full and cited a request for a full review fails `reviewed-the-delta`, its cause recorded as the prompt.
- Turns are read from each trace's `result` records; a rep curtailed at the cap is unmeasured and replaced.
- Compared across this round's two arms only.

## Round 69b (the later-round wording), five reps an arm

Model `claude-sonnet-5-5` in every rep's `init` event; CLI 2.1.289; baseline = `main` at `fdd56e7` (the landed storage text), treated = `69b-delta-on-a` at `ce780eb`. Kept as `evals/results/round-69b@baseline.json`, `round-69b@delta.json`, `round-69b@baseline-storage.json` and `round-69b@delta-storage.json`, traces in `evals/results/round69b-traces/`, every rep's state-folder files in `evals/results/round69b-files/`. $4.98 for the four runs; turns 10-12 baseline and 9-12 treated, no rep near the cap, no subagent dispatched.

| Row | Baseline | Treated |
|---|---|---|
| **reviewed-the-delta** (bar; trace and kept file) | 0/5 | 4/5 |
| **earlier-findings-statused-in-file** (bar; kept file) | 5/5 | 5/5 |
| `earlier-findings-statused` (chat; judge and hand agree) | 5/5 | 5/5 |
| `decoy-not-reported` (guard; judge and hand agree) | 4/5 | 5/5 |
| `new-defect-found` (guard; judge and hand agree) | 5/5 | 5/5 |
| `round-two-written` (guard; kept file) | 5/5 | 5/5 |
| round 1's file byte-identical to the seed | 5/5 | 5/5 |
| `skill-was-invoked` | 5/5 | 5/5 |

The classification, from each trace's git commands: every baseline rep reviewed the whole change (`main...HEAD`, or `da56eeb...HEAD`, which is the same range) and wrote `scope: full`; four treated reps replayed round 1 with `git merge-tree` and diffed the replay against the head, writing `kind: delta-review`, `scope: bd2f605..5dde025` and `previous: branch-feat-close-ticket/r1-bd2f605.md`; treated rep 2 declared the same range but reviewed `main...HEAD`, so its declared and classified scope disagree and it fails the bar - the disagreement the rule was fixed for. No rep in either arm reviewed a naive delta into the decoy. Baseline rep 1's decoy fail is a full review that found `src/audit.js` through `git log` on `main` and counted it as a medium finding "arrived from main"; the cause is not the wording, recorded and not a decline.

The mechanical screens read 0/5 for `round-two-written`, its Bash companion and `scope-names-the-delta` in both arms because nine of ten reps wrote the round file through a shell heredoc into a variable path (`$D/r2-5dde025.md`), which no literal pattern matches; the kept files settled every one of those rows, as the reading rules provide. Every rep in both arms gave M-1 "still present" and M-2 and m-1 "fixed", correctly.

Neighbour (`review-pr-keeps-the-findings-outside-the-clone`): every rep in both arms wrote round 1 under the state folder by the kept home, none into the clone, and gave the absolute path - 5/5 and 5/5 on all three bars; its Write screens read 3/5 in each arm for the same shell-write reason.

**Verdict:** `reviewed-the-delta` clears its bar (4/5 against 0/5) and no guard or neighbour declines, so the wording lands as drawn. `earlier-findings-statused-in-file` passed 5/5 in the baseline, so that half is unneeded on this model; its clauses ride in the tested text unchanged rather than an edited text landing untested.
