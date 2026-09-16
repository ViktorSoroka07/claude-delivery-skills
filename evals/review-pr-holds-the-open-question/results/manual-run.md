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
