# Manual runs

`claude plugin eval` is still gated at run time, so the case was run by the
hand procedure in CONTRIBUTING's "Testing a wording change": fixtures from
`evals/fixtures/refund-console.sh record-offplan`, verified identical by hash,
fresh subagents on sonnet loading the installed skill through the Skill tool,
the eval prompt verbatim. Five runs completed across two dispatches: the
first dispatch lost four of five to the account's usage limit mid-review, and
four fresh fixtures were run again once it lifted.

## Results

| Grader | treat |
|---|---|
| findings-file-written | 5/5 |
| flags-the-contradicted-claim | 5/5 |
| keeps-the-true-rows-unflagged | 5/5 |

Every run wrote the findings file, re-applied the record's three mutations
against the pinned head, and reported the catch-arm claim as not holding —
the suite stays green with the arm removed because the only test resolves
its fetch — as a Major or Medium finding. Every run also re-ran the other two
mutations and recorded them as failing the named test as the record says;
two said so in the finding's own text, three in the verifier's confirmation.
Every run dispatched the fresh-eyes verifier for Pass 2 because Pass 1 held a
major finding, even where the diff's size allowed the inline shortcut.

All five also reported the mount as task 102's scope shipping early, and four
reported the record's own summary line miscounting its findings and the
suite; neither is graded.

## Not tested

The trigger, as in every hand run: the brief named the skill.
