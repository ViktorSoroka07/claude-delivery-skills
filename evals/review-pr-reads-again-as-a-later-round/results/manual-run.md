# review-pr-reads-again-as-a-later-round

The later-round case's history (`review-pr-reviews-only-what-changed`: round 1 seeded at `bd2f605`, a fix commit, `main` merged in at `5dde025`) under a prompt that asks for the review "again" - the most natural way to ask for a second round, and one word away from the Full review mode's trigger "review it all again". Round 69b's prompt avoided the word, so whether it pulls a session into the full mode was unmeasured (plan task 75, item 2). A check of the landed text, no draft.

## Bars, fixed before the first draw

One arm: review-pr on `main` at the landed text, the plugin loaded (`--ablation none`), five reps, `--model sonnet`, `--judge-model sonnet`, `--keep-temp`, the state-folder grant. Kept as `evals/results/round-75b@baseline.json`.

- **Conviction:** any one rep that runs the second round in full and gives the user's request (the word "again", or a full review read into it) as its reason convicts the trigger - a direct sighting, which the floor does not limit. Read from the hand-off and the kept round-2 file's `scope`.
- **A clean five** - every rep reviewing the delta or running in full for another stated reason - clears only a drop to 0/5 against round 69b's 4/5, which five reps can separate; a pull of one or two reps in five is below what this draw sees, and the record says so beside the result.
- `reviewed-the-delta` is classified by hand from each trace's git commands and the kept file's `scope`, as in round 69b.
- A rep whose `skill-was-invoked` is dark, or whose round file lands outside `git.example.org/acme/ticket-gateway/branch-feat-close-ticket/`, never met the condition and is replaced.
- Turns from each trace's `result` records; a rep curtailed at the cap is replaced.
