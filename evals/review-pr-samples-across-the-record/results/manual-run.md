# Runs

## Baseline arm, five reps - and why no treatment arm was bought

The runner, `--ablation none --judge-model sonnet --model sonnet --runs 5`,
against the current skill text: five fresh headless reps, $6.97 of the
invocation's $13.32 (the other five reps are the second-domain case, run in the
same round). Nothing threw, no run errored, no paid grader was skipped, and the
`skill-was-invoked` indicator fired in all five - so every rep loaded the skill
under test rather than the harness's own review skill.

| Grader | Judge | Hand |
|---|---|---|
| findings-file-written | 5/5 | 5/5 |
| **flags-the-contradicted-claim** | **2/5** | **2/5** |
| keeps-the-disclosed-gap-unflagged | 4/5 | 5/5 |
| keeps-the-true-rows-unflagged | 3/5 | 5/5 |
| skill-was-invoked (indicator) | 5/5 | - |

The two neighbour fails are the judge, read back against the kept `evidence`
and overturned by hand. On the run it failed for `keeps-the-true-rows`, the
only negative sentences are about the code and about the record's ninth row -
the disclosed survivor, which `keeps-the-disclosed-gap-unflagged` passed in
that same rep - so the judge failed the grader the sentence does not bear on
and passed the one it does. On the other, the run affirms the true rows explicitly ("at most seven of
nine are confirmed, with two unconfirmed") and holds up the ninth row as the
model of honest recording while asking for the sixth to be marked the same way;
the judge read that as flagging them.

## The draw, read from each rep's own tool calls

Which rows a rep re-applied is not in its findings file - a rep has re-applied
rows and written about none of them - so each draw below is taken from the
commands that **write a source file** (a `sed -i`, a `python3` rewrite, an
`Edit`), with the command kept beside it. A first pass that searched every tool
input instead reported two rows that were never applied: the word `catch`
inside a comment, and `result.items` inside a mutation that was removing the
filter call. An anchor has to be the transformation the row names.

| Rep | Rows re-applied, of nine | Reached the sixth? | flags-the-contradicted-claim |
|---|---|---|---|
| 1 | 5, 9 | no | FAIL |
| 2 | 5 | no | FAIL |
| 3 | 3, 5, 7, 9 | no | FAIL |
| 4 | 3, **6**, 9 | **yes** | PASS |
| 5 | 1, 2, 3, 7, 9 | no | PASS |

**Reaching the row is what decides the verdict, and four of five reps line up
exactly.** The one rep that re-applied the sixth row reported the contradiction;
three of the four that did not, missed it. The fifth found it without applying
it - by reading what the two tests stub (`globalThis.fetch` always resolves) and
concluding the `catch` arm is dead code as far as the suite can tell, which the
grader's rubric allows as a pass.

**What the draws are not is narrow in the way the entry assumed.** Three of the
five draws are already spread across the record - 3,5,7,9 and 1,2,3,7,9 and
3,6,9 - rather than stopping at its opening entries. What they lack is
coverage: one to five rows of nine, and the contradicted row is one specific
row, so a spread sample of two or three misses it most of the time by
arithmetic alone.

## Why the treatment arm was not run

The wording drafted for this round (kept in the sibling four-row case's record)
asks for "a draw spread across the record rather than its opening entries" once
a record holds more than five rows. Two things follow from the baseline:

- **The behaviour it asks for is most of what the baseline already does.** Its
  "all of them" clause binds only records of five rows or fewer, and this record
  has nine, so on this case the wording reduces to a spread - which three of
  five reps produce unaided.
- **Even a perfect treatment arm could not be read at five reps.** The baseline
  scores 2/5 on the graded row, so the largest gap available is 5/5 against 2/5,
  a three-in-five split; CONTRIBUTING's floor is that five reps an arm separate
  only a four-in-five gap. The row would have been noise whichever way it fell.

So the arm was not bought, and the $6.97 that would have gone to it is the
saving. What a deciding round needs instead: a
wording about **coverage** rather than spread, at ten reps an arm (10/10 against
4/10 is readable where 5/5 against 2/5 is not) - about $20 more - or a
mechanical grader over the act itself, which at five reps an arm separates
1/5 from 5/5 on "did the rep re-apply the contradicted row".

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
