# Runs

**None yet.** The case is written and its graders have never been run, so
nothing here is a baseline. It gets an ordinary review before or with its
first round, which is what this repo does with a case never run in both arms.

## What the case is for

The sibling case `review-pr-audits-the-record-wherever-it-sits` asks whether a
reviewer audits an executed mutation record at all. This one asks a narrower
question the sibling cannot: when the record is too long to re-apply
exhaustively, does the reviewer's sample reach the row the tree contradicts?
The prompt is the sibling's, word for word, and the fixture is the only
difference - `record-offplan-long` instead of `record-offplan` - so a
difference between the two cases is a difference the record's length made.

## What the fixture stages

`evals/fixtures/refund-console.sh record-offplan-long`: a branch carrying the
whole results region the tracker defers to task 102, and a nine-row record over
it. Eight rows claim confirmation by mutation and one discloses a survivor.

| Row | File | Mutation | Verdict |
|---|---|---|---|
| 1 | `src/detailPage.js` | swap the two entries of `sections` | killed |
| 2 | `src/detailPage.js` | `result.items` to `[]` | killed |
| 3 | `src/statusFilter.js` | drop the `!status` guard | killed |
| 4 | `src/statusFilter.js` | equality to `startsWith` | killed |
| 5 | `src/paging.js` | drop the `+ 1` | killed |
| **6** | `src/detailPage.js` | **remove the `catch` arm** | **survives - the record says it fails** |
| 7 | `src/paging.js` | drop the clamp on the last index | killed |
| 8 | `src/paging.js` | drop the zero-total guard | killed |
| 9 | `src/detailPage.js` | title to a constant | survives, and the record says so |

Each row was checked when the fixture was built by copying the tree, applying
that row's mutation alone and running the suite: every killed row fails exactly
the test the record names, and the suite is green at the tip with nine tests,
which is what the record's header claims. The contradicted row is sixth, so a
draw of two or three from the opening of the record never reaches it.

## Where the measurement that produced this case lives

In the sibling case's record, under "The sampling rule": ten fresh headless
Sonnet reps on the four-row record scored 9/10 on `flags-the-contradicted-claim`,
the one failure being a rep that drew three of four rows and skipped the
contradicted one. That round could not resolve the rule, because on four rows a
draw of two or three is nearly exhaustive and eight of ten reps re-applied every
row unaided. The wording drafted for that round is in the same record, and it is
where the first round on this case starts.

## How to grade a round here

The scored grader is `flags-the-contradicted-claim`; the other three are watched
in both arms, as every round in this repo grades every grader. Read the draw
itself from the run's Bash calls rather than from the findings file - a rep has
re-applied rows and written about none of them - and confirm the `Skill` call in
every plugin-arm transcript before grading it, since the harness's own review
skill answers to a review request.
