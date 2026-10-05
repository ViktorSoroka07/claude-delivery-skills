# Manual runs

Fixtures from `evals/fixtures/ledger-sync.sh post-findings`, five fresh
Sonnet subagents per arm, the eval prompt verbatim, graded on the forge's
`posted.md`, the forge log, and the reply. The baseline arm is the posting
reference before the rule; the treatment arm has the rule.

| Grader | Baseline | Treatment |
|---|---|---|
| open-question-finding-held | 0/5 | 5/5 |
| settled-findings-posted | 5/5 | 5/5 |
| hold-named-in-the-reply | 0/5 | 5/5 |
| head-reverified-before-posting | 5/5 | 5/5 |

Every baseline rep posted all three findings, the third with its open
question kept in as a caveat; two said in so many words that they posted
the question "as the review left it". Every treatment rep posted the two
settled findings, held the third, searched the repository for an answer
first, and named in the reply who could settle it.

The fixture's first version carried findings that duplicated threads the
bots had already raised, and every baseline rep declined to post any of
them, which was right; the findings were rewritten so none is on the PR.

## Not tested

The trigger: the prompt says "post its findings", which names the mode.

## As a neighbour of the findings-storage round (69a)

Model `claude-sonnet-5-5` in every rep's `init` event; CLI 2.1.289; both arms with the plugin and the state-folder grant (`--allow-tools ... 'Write(~/.local/state/**)' 'Edit(~/.local/state/**)'`), `--judge-model sonnet`; baseline = `main` at `4014fa1`, treated = branch `69a-storage` at `009d9d5` (the findings-storage wording). Compared across these two arms only. Kept as `evals/results/round-69a@baseline-holds.json`, `round-69a@storage-holds.json` and `round-69a@storage-holds-topup.json`. The case's turn cap was raised from 40 to 60 and its timeout from 600 to 900 seconds before the draw; reps used 7-14.

| Grader | Baseline (5) | Treated (4 usable of 6) |
|---|---|---|
| head-reverified-before-posting | 5/5 | 4/4 |
| hold-named-in-the-reply | 5/5 | 4/4 |
| open-question-finding-held | 5/5 | 4/4 |
| settled-findings-posted | 5/5 | 4/4 |
| skill-was-invoked | 5/5 | 4/6 |

Every usable treated rep re-verified the head from this fixture's header-line findings file, which the wording's fallback for a file written before the frontmatter covers. Two of six treated reps never loaded review-pr - each read the findings file and the forge's usage and then posted all three findings, the open question included - against none of five on the current text. Both dark reps were read. The one part of the treated diff that can move a trigger is the description's later-asks list, which the wording extended with "or list and open earlier reviews". At 2/6 against 0/5 the gap is below what five reps can separate, so it stands as a watched cost of that one line rather than a measured regression; it is one indicator of this case's five graders.

The storage wording landed without the description line (1.11.0, on the owner's ruling), so this case's indicator is the neighbour of that line's own round rather than a cost carried by the landed text.
