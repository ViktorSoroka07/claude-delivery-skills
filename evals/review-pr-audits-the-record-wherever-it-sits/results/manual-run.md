# Manual runs

`claude plugin eval` is still gated at run time, so the case was run by the
hand procedure in CONTRIBUTING's "Testing a wording change": five fixtures from
`evals/fixtures/refund-console.sh record-offplan`, verified identical by hash,
five fresh subagents on sonnet loading the installed skill through the Skill
tool, the eval prompt verbatim.

## Results

| Grader | treat |
|---|---|
| findings-file-written | 1/1 |
| flags-the-contradicted-claim | 1/1 |
| keeps-the-true-rows-unflagged | 1/1 |

One run completed. It wrote the findings file, re-applied all three recorded
mutations in a detached worktree, reported the catch-arm claim as not holding
(the suite stays green with the arm removed) as its first Medium finding, and
recorded the other two claims as re-run and failing as the record says. The
other four runs were killed by the account's usage limit mid-review — each
had found the contradicted claim in its last message but none had written
its findings file — so the column is one of one, not one of five. The four
are to be re-run before this record counts as the five the procedure asks
for.
