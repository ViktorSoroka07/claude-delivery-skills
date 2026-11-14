# review-pr-posts-after-the-author-pushed - manual runs

## Re-anchoring a post after the author pushed, five reps an arm on each model (round moved)

What is tested: whether a session told to post a review whose request moved after the review posts it at the new head through the bundled `post-review.py`, and leaves the findings file's `reviewed_sha` naming the head the review covered. Before the change, nothing satisfied both of the script's checks after a push: the head check wanted the manifest's `reviewed_sha` equal to the forge's head, and the findings-file check wanted it equal to the file's. The only way through was to rewrite `reviewed_sha`, which the next review round starts from, so the author's new commit would never be reviewed.

The wording under test landed in commit `ccfe9fe` on `main`. In `skills/review-pr/references/posting-script.md`:

> - **Before any create, it refuses** a request whose head moved past the head its threads were verified at, an anchor on a file outside the diff, [...]

> - `verified_head`, only after a `STALE-HEAD` stop: the head the threads were re-verified at. Absent, it is `reviewed_sha`.

> | `STALE-HEAD` | The author pushed after the review. `git fetch origin <branch>`, re-verify every thread at the new head per `posting-and-applying.md`'s "Re-verify first" (an anchor follows its line; a suggestion whose lines changed loses its block, its prose stays), update the manifest's threads, set its `verified_head` to the head the message names, and run again. Never change `reviewed_sha`, in the manifest or the findings file: it names the head the review covered, and the next review round starts from it. |
> | `MISSING-COMMIT` | The clone lacks a commit: fetch as the message names, and run again. |

> | `MOVED-MID-RUN` | The author pushed after some threads landed. The run is closed and nothing was posted at the new head. Tell the user which threads landed at which head. To post the rest, take the landed threads out of the manifest and run without `--resume`, then add the first run's ids, printed as landed before the stop, to the findings file's body. If no thread is left, the post is complete at the old head: write its `posted:` line by hand, with `head:` that head. |

> `posted:` is written, with `head:` where the post went out at a head other than `reviewed_sha`; do not write it again.

and the script's `STALE-HEAD` message:

> the request's head at the forge is %s, and the manifest's threads were verified at %s. Fetch it (git fetch origin), re-verify every thread at %s per posting-and-applying.md's "Re-verify first" (an anchor whose line moved follows it; a suggestion whose lines changed loses its block, its prose stays), update the manifest's threads, set its verified_head to %s and run again. Leave reviewed_sha as it is: it names the head the review covered

The treated arm also carried the three smaller changes on the same branch (`5ed879d`, `4367f92`, `069b22e`: `--ignore-item` for an `UNCERTAIN` stop, `NO-FRONTMATTER` on a partial block, a dry run's `DRY-RUN` status). This case reaches only the last, whose status line every treated rep's dry run printed.

The case is the posting case's request plus one commit the author pushed after the review, touching only `package.json`: the forge stand-in serves it as the head (`b17cc90`), the clone reaches it only by a fetch, and the findings file's frontmatter keeps the reviewed head (`bd2f605`). Every anchor holds at the new head.

Graders new to this case, each calibrated before the draw on samples from both sides (a post through the treated script, a post through `main`'s script after rewriting `reviewed_sha`, a review sent at the old head through the stand-in), with the runner's frontmatter expression and Bun's YAML parse:

- `review-at-the-new-head`: the first landed review's payload names the pushed head as `commit_id`. Passed 2 of 3 samples, failed the old-head review.
- `reviewed-sha-kept`: the findings file's frontmatter still reads `reviewed_sha: bd2f605...`. Passed the treated post, failed the rewritten file.

The base case's graders are copied; `review-posted` here counts a rep with no landed review as a fail.

Bar, fixed before the draw: each new grader at 4/5 or better in the treated arm on each model, no existing grader below the baseline, and the baseline read first: a baseline that does not fail stops the round before the treated arm is bought.

Arms: two runner invocations a model, `--ablation none`, each from its own worktree under `/Users/Shared/eval-rounds/`: the baseline at `663afd7` (`main` at `653bfd2` with only this case added), the treatment at `069b22e`. CLI 2.1.325, `--judge-model sonnet` (no judged grader in the case), `--keep-temp`, `-j 3`; the traces name `claude-sonnet-5-5` and `claude-fable-5-2`. Kept as `evals/results/round-moved@baseline.json`, `@baseline-fable.json`, `@fix.json`, `@fix-fable.json`.

| Row | Sonnet baseline | Sonnet fix | Fable baseline | Fable fix |
|---|---|---|---|---|
| `reviewed-sha-kept` | 0/5 | 5/5 | 0/5 | 5/5 |
| `review-at-the-new-head` | 5/5 | 5/5 | 5/5 | 5/5 |
| `review-posted` | 5/5 | 5/5 | 5/5 | 5/5 |
| `posted-by-the-bundled-script` | 5/5 | 5/5 | 5/5 | 5/5 |
| `ran-the-bundled-script` | 4/5 (5/5 by hand) | 5/5 | 5/5 | 5/5 |
| `findings-file-kept` | 1/5 | 5/5 | 5/5 | 5/5 |
| `payload-not-in-the-clone` | 5/5 | 5/5 | 5/5 | 5/5 |
| `clone-left-clean` | 5/5 | 5/5 | 5/5 | 5/5 |
| `authors-notes-kept` | 5/5 | 5/5 | 5/5 | 5/5 |
| `forge-internals-untouched` | 5/5 | 5/5 | 5/5 | 5/5 |
| `skill-was-invoked` | 5/5 | 5/5 | 5/5 | 5/5 |

Per-rep cost: Sonnet baseline $0.245-0.304 (12-19 turns), Sonnet fix $0.240-0.279 (13-19 turns), Fable baseline $1.055-1.293 (16-19 turns), Fable fix $1.055-1.146 (17-20 turns); $13.87 in all, against $13.99 priced from the dearest reps of the posting case's kept records. No rep was curtailed.

Read by hand from each trace: no baseline rep reached `STALE-HEAD`. Each followed "Re-verify first", fetched, saw the push, and rewrote `reviewed_sha` to the new head in the findings file before running the script, which then posted at the new head; four Sonnet reps also rewrote the header line, dropping the reviewed head from the file (`findings-file-kept`). Sonnet baseline rep 3 ran the script through a shell variable (`$S --dry-run ...`), which `ran-the-bundled-script`'s pattern cannot see; its landed create is the script's own payload, so it ran the script. In the treated arm, four Fable reps ran the script, stopped `STALE-HEAD`, set `verified_head` as the message says and posted; the other Fable rep and all five Sonnet reps set `verified_head` from the manifest's documentation before the first run. Every treated rep dry-ran (`DRY-RUN`), then posted once, `LANDED`, with `posted:` carrying `head: b17cc90` and `reviewed_sha` unchanged.

Result: passes on both models and landed.
