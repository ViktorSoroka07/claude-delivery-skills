# review-pr-reads-again-as-a-later-round

The later-round case's history (`review-pr-reviews-only-what-changed`: round 1 seeded at `bd2f605`, a fix commit, `main` merged in at `5dde025`) under a prompt that asks for the review "again" - the most natural way to ask for a second round, and one word away from the Full review mode's trigger "review it all again". Round 69b's prompt avoided the word, so whether it pulls a session into the full mode was unmeasured (plan task 75, item 2). A check of the landed text, no draft.

## Bars, fixed before the first draw

The prompt is a minimal pair with round 69b's: the same sentence with "please take another look" replaced by "please review it again", nothing else moved. The fixture is the later-round case's, delegated at the commit that adds these bars. The skill text differs from round 69b's treated arm by two commits: `17b7a12` (the replay command takes the tree from the first line of a names-only merge-tree, and a replay that cannot run becomes a reason to run in full - the reason cannot fire here, where round 1 is `full`, `bd2f605` is present and git is 2.56) and `3a5d736` (the output called the findings file throughout, wording only). So only a rep that cites the request is evidence about the prompt.

One arm: review-pr on `main`, the plugin loaded (`--ablation none`), five reps, `--model sonnet`, `--judge-model sonnet`, `--keep-temp`, the full grant `--allow-tools Bash Write Edit Agent 'Write(~/.local/state/**)' 'Edit(~/.local/state/**)'`. Kept as `evals/results/round-75b@baseline.json`; every trace and every kept home's state folder are copied under `evals/results/` the moment the run ends. `earlier-findings-statused` is kept from round 69b's graders so the final message survives in the run JSON as the judge's evidence.

Two readings, both decided now:

1. **Conviction:** any one rep that runs the second round in full and cites the request - "again", or a full review read into it - convicts the trigger, a direct sighting the floor does not limit. Each conviction records the words the rep quotes.
2. **The delta rate:** classified by hand from each trace's git commands and the kept round-2 file's `scope`, as in round 69b. A rep that runs in full with no reason, or declares the range while reviewing `main...HEAD`, counts as non-delta. This fixture offers no legitimate reason to run in full, so any other stated reason is false and is recorded as a finding about step 4.5, not as a clean rep. Against round 69b's 4/5, five reps separate only a drop to 0/5, so a delta rate of 1/5 or more with no conviction says nothing about the prompt, and the record says so.

- A rep whose `skill-was-invoked` is dark, or whose round file lands outside `git.example.org/acme/ticket-gateway/branch-feat-close-ticket/`, never met the condition and is replaced.
- Turns from each trace's `result` records and the CLI version from the run JSON, beside round 69b's 2.1.289; a rep curtailed at the cap is replaced.

## The baseline draw

Model `claude-sonnet-5-5`, CLI 2.1.289 (round 69b's was the same), `main` at `92b7475`; $1.25, 10-13 turns, no rep replaced. Kept as `evals/results/round-75b@baseline.json`, traces in `evals/results/round75b-traces/`, every kept home's state folder in `round75b-files/`.

- **No conviction.** No rep ran the second round in full, and none cited the request as a reason for anything; one hand-off offered "a deep or full review" as a next step, which is §7's closing line, not a mode taken.
- **The delta rate: 5/5.** Every rep replayed round 1 with `git merge-tree` (`diff-replayed-screen` 5/5) and diffed the replay against the head, and every kept round-2 file reads `kind: delta-review`, `scope: bd2f605..5dde025`, `previous: branch-feat-close-ticket/r1-bd2f605.md`; declared and classified scope agree in all five. `earlier-findings-statused` passed 5/5 on the judge, and the hand read of each hand-off agrees.
- **What it settles:** "review it again" does not pull a second round into the full mode on this model in five reps; a pull of one rep in five is below what this draw sees. Round 69b's treated 4/5 was taken without the word, so the two rates are not a measured difference either way.

The mechanical screens read 0/5 on `round-two-written` (Write) and `scope-names-the-delta` (a Write screen) and 4/5 on the shell companion: every rep wrote the round file by shell, four spelling the file name (`"$D/r2-5dde025.md"`), which the file-name anchor caught, and one building it from the head (`$D/r2-${H:0:7}.md`), which no literal pattern matches - the shape CONTRIBUTING's shell-companion rule names. The kept homes decided every row.
