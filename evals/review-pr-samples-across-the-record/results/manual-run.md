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
| 5 | 1, 2, 3, 4, **6**, 7, 8, 9 | **yes** | PASS |

**The fifth row is a correction**, made when the act grader was written against
these same traces and disagreed with the hand parse. The rep applied the sixth
row in a `python3` here-doc that replaces the try/catch block with its body,
asserts the replacement changed something, writes the file and runs the suite -
which stayed green, the contradiction seen rather than reasoned about. Its own
findings file says so: "re-ran the exact catch-removal mutation independently;
9/9 tests still pass". Two more of its draws were missed as well - the fourth
row's `startsWith` and the eighth row's dropped zero-total guard, both applied
by its verifier subagent as whole-file writes into a scratch copy of the tree.
A whole-file write is the shape that is hard to read either way: the body it
writes carries every unchanged line, so a hand parse looking for a rewrite sees
nothing to count, while a pattern anchored on one identifier sees every row at
once - in the call that dropped the zero-total guard, the untouched `+ 1` and
clamp read as two further rows applied.

**Reaching the row is what decides the verdict, and five of five line up.**
Both reps that re-applied the sixth row reported the contradiction, and the
three that did not, missed it. No call in those three names the `catch` arm at
all - in any tool, main agent or subagent - so nothing in the traces supports
the earlier reading that one rep found the contradiction without applying it.

**What the draws are not is narrow in the way the entry assumed.** They run
from one row of nine to eight - 5,9 / 5 / 3,5,7,9 / 3,6,9 / 1,2,3,4,6,7,8,9 -
and not one of the five stops at the record's opening entries. What they lack
is coverage, and the contradicted row is one specific row, so a spread sample
of two or three misses it most of the time by arithmetic alone.

## The act grader, and what a round can now read

`reapplied-the-contradicted-row` scores that middle column out of the run's own
`Bash` calls, and two `no-mutation-through-*` graders beside it report the
blind spot a one-tool grader has. The grader's own file carries how its pattern
is anchored and what it cannot see; what belongs here is what it measures on
this baseline and what that leaves the sampling entry.

Re-scored from the five kept traces with the runner's own matcher - tool name
equal, `input_match` tested against `JSON.stringify(input)`, count against
`min`/`max` - it reads **2/5**, the reps that applied the row being exactly the
reps that reported it. The same run over `skill-was-invoked` reproduces the
explanation string the runner itself recorded for all ten reps of the round,
which is the control that says the re-scoring is the runner's arithmetic and
not a second implementation of it. The traces, and a `regrade.mjs` that does
this, are kept beside the round's `aggregate-result.json`.

**The arithmetic the entry was waiting on does not come out.** The route was
bought on a reading of 1/5, against which a perfect treatment arm would have
been the four-in-five gap five reps an arm can separate. At 2/5 the largest gap
available is three in five, under the floor - and it is the same rate the
judged outcome grader already gives, on the same two reps. What the act grader
buys is not a wider gap: it is a rate that costs nothing per rep, cannot be
misread by a judge, and moves with the act the rule prescribes rather than with
the outcome, which a rep can reach by reading the tests. A round that decides
the entry is still a ten-rep round (10/10 against 4/10), and the one reading
that would separate the arms at five is a count of rows drawn per rep rather
than a rate - the draws run 2, 1, 4, 3, 8 of nine, which nine row-graders would
report directly. That instrument is a different one from this grader: counting
coverage wants recall, and a grader whose fail decides a verdict wants
precision.

## Why the treatment arm was not run

The wording drafted for this round (kept in the sibling four-row case's record)
asks for "a draw spread across the record rather than its opening entries" once
a record holds more than five rows. Two things follow from the baseline:

- **The behaviour it asks for is what the baseline already does.** Its "all of
  them" clause binds only records of five rows or fewer, and this record has
  nine, so on this case the wording reduces to a spread - and no rep of the five
  stopped at the record's opening entries.
- **Even a perfect treatment arm could not be read at five reps.** The baseline
  scores 2/5 on the graded row, so the largest gap available is 5/5 against 2/5,
  a three-in-five split; CONTRIBUTING's floor is that five reps an arm separate
  only a four-in-five gap. The row would have been noise whichever way it fell.

So the arm was not bought, and the $6.97 that would have gone to it is the
saving. What a deciding round needs instead is a wording about **coverage**
rather than spread, at ten reps an arm - 10/10 against 4/10 is readable where
5/5 against 2/5 is not - which is about $20 more. The act grader written after
this round does not change that arithmetic, for the reason the section above
gives: it reads the same 2/5, mechanically.

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

The two graders the case turns on are `flags-the-contradicted-claim`, the
outcome, and `reapplied-the-contradicted-row`, the act - on this baseline they
agree rep for rep. The others are graded in both arms as well, as every round
in this repo grades every grader. The draw beyond the contradicted row is not
graded: read it from the run's own commands that write a source file, as the
table above does, and remember that a whole-file write carries every unchanged
line with it. Confirm the `Skill` call in every plugin-arm transcript before
grading it, since the harness's own review skill answers to a review request.
A fail on either `no-mutation-through-*` grader means that rep mutated source
through a tool the act grader cannot see, so read that rep's draw by hand
before counting it.
