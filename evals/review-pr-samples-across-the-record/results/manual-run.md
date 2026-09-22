# Runs

## The deciding round: a coverage wording at ten reps an arm

Two arms of ten reps on this case alone, `--ablation none --model sonnet
--judge-model sonnet`, at plugin version 1.10.0 on the same CLI build as the
round below. $22.11 and 72 minutes. The arms are kept as
`round-40@baseline-topup.json` and `round-40@coverage.json`, the treatment
arm's ten traces beside its `aggregate-result.json`.

**The wording edits a number the skill already gives** rather than adding a
sentence beside it. Where the current text says to re-apply "2-3 of the
recorded mutations (all of them when the record holds fewer)", the treatment
says to re-apply them one at a time against that baseline - every row where the
record holds twelve or fewer, since one row costs one suite run - with a draw
made across the record above that bound and the rows it did not reach named in
the findings as unchecked, and it states that a row nobody re-applied is
unchecked rather than confirmed. The bound is a count because a trigger phrased
as a category gets judged away; the disclosure clause cannot fire on a nine-row
record, which keeps the measured path clear of the sentence
`keeps-the-true-rows-unflagged` reads as flagging.

**The baseline arm is ten reps from two invocations at one text.** Five are the
round below; five were run for this one. No commit touches
`skills/review-pr/SKILL.md` between them, the CLI build is the same, and the
case's prompt, fixture and graders are unchanged, so the two sets are one arm.
The three `tool_used` graders postdate the first five and were scored on them
from the kept traces with the runner's own matcher, whose control reproduces
the runner's own recorded verdict for `skill-was-invoked` on every rep.

**Five of the baseline arm's ten reps have no trace.** The five run for this
round went without `--keep-temp`, and the runner deletes each workspace it
keeps a `tracePath` for, so three reps that failed `no-mutation-through-edit`
could not have their draw read by hand. What stands in for that read is the
outcome grader, which is blind to tools: all three failed it too, and on this
case reaching the row and reporting it agree in every rep of both arms where
both are readable. The baseline's act rate is therefore the mechanical 3/10
with three reps carrying an unread `Edit` call - a floor on the rate, not a
measurement of it, and the reason the verdict below rests on the outcome, which
is fully read in both arms.

| Grader | Baseline judge | Baseline hand | Coverage judge | Coverage hand |
|---|---|---|---|---|
| findings-file-written | 10/10 | 10/10 | 10/10 | 10/10 |
| **flags-the-contradicted-claim** | 3/10 | **3/10** | 7/10 | **10/10** |
| **reapplied-the-contradicted-row** | 3/10 | see below | 4/10 | **10/10** |
| keeps-the-disclosed-gap-unflagged | 9/10 | 10/10 | 8/10 | 10/10 |
| keeps-the-true-rows-unflagged | 7/10 | 10/10 | 10/10 | 10/10 |
| no-mutation-through-edit | 7/10 | - | 2/10 | - |
| no-mutation-through-write | 9/10 | - | 5/10 | - |
| skill-was-invoked (indicator) | 10/10 | - | 10/10 | - |

**The wording binds, and it binds through the act.** Every rep of the treatment
arm re-applied the sixth row, read from its own calls with `Edit` included, and
every rep reported the contradiction. The gap the verdict rests on is the
outcome grader, hand-read in all twenty reps: three of ten against ten of ten,
seven in ten where ten reps an arm separate a half. Three reps state the
rule back while obeying it, two its arithmetic and one its procedure: "names 9
mutations (<=12, so all were re-applied)", "all 9 rows were re-applied against
the current baseline since 9 <= 12", and "each of the 9 described mutations was
re-applied to the working tree, `node --test` run, and the result reverted
before moving to the next".
Neither neighbour moves - both stand at ten of ten by hand in both arms - and
the judge's two fails on `keeps-the-disclosed-gap-unflagged` do not survive a
hand read: one rep holds the ninth row up as honestly disclosed while asking
for the sixth to be recorded the same way, and the other accepts the survivor
as recorded and faults only the task its missing assertion was deferred to,
which is the finding the rubric admits as a test gap.

**The act grader reads 4/10 where the act happened 10/10, and the wording is
why.** It names `Bash`, and the treatment text pushes the work onto `Edit`: the
skill's own mutation protocol states one-at-a-time as "applied with a unique
`old_string`", so a rule that asks for every row one at a time is read as a
rule to use that tool. `no-mutation-through-edit` falls from 7/10 to 2/10
across the arms and `no-mutation-through-write` from 9/10 to 5/10, which is the
two graders doing exactly the job their files claim - reporting that this rep's
draw has to be read by hand. Read that way, six of the ten treatment reps
applied the sixth row through `Edit`, with the arm's `old_string` carrying the
`try`/`catch` wrapper and its `new_string` carrying the body without it.

**A grader blind to one channel is not a constant error when the arms differ in
which channel they use.** Had this round been read off the act grader alone it
would have scored 4/10 against 3/10 and been written up as noise; the same
grader is sound on the baseline, where no rep of the first five mutated source
with either tool. That is the mechanism this round adds to the backlog.

## The draw the coverage wording produces

Screened from each rep's source-writing calls, with the sixth row confirmed by
hand in all ten. The screen under-reports: a whole-file body carries every
untouched line, so the fifth and eighth rows read as applied whenever paging's
source is written whole, and the sixth is missed where an `Edit` replaces the
`try` block without the function header. The counts are what to read.

| Rep | Source-writing calls | Reached the sixth? | Reported it? |
|---|---|---|---|
| 1 | 7 | yes | yes |
| 2 | 7 | yes | yes |
| 3 | 5 | yes | yes |
| 4 | 3 | yes | yes |
| 5 | 3 | yes | yes |
| 6 | 19 | yes | yes |
| 7 | 19 | yes | yes |
| 8 | 20 | yes | yes |
| 9 | 11 | yes | yes |
| 10 | 23 | yes | yes |

Against the baseline's four, five, four, five and nine. **One rep re-applied
less than it reported:** its file says the record's nine rows were all
re-applied because nine is at or under twelve, and its calls carry two of them,
the rest "verified by direct reasoning/execution against the pure functions".
The rule moved what it claims and most of what it does; that rep is the shape
to watch if the sentence is ever tightened.

## What this round did not buy

The second-domain case, `review-pr-samples-the-record-table`, was not run under
the treatment text. Its record holds nine rows as well, so the new bound asks
of it what its baseline already does - eight or nine rows of nine in every rep,
at 5/5 on both graders - and the wording can only cost there. The approved
spend was this case alone, so that watch is the one condition of a landing that
this round leaves unobserved; it is five reps and about $7.

## The first round: the baseline at five reps, and the spread wording that was not bought

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
the outcome, which a rep can reach by reading the tests. The ten-rep round that decided
the entry is the first section above, and it found the limit of this grader
rather than of the rate: the wording under test moved the act onto a tool the
grader does not name. The one reading that would separate the arms at five is a
count of rows drawn per rep rather than a rate - the draws run 2, 1, 4, 3, 8 of
nine, which nine row-graders would report directly. That instrument is a
different one from this grader: counting coverage wants recall, and a grader
whose fail decides a verdict wants precision.

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
saving. The coverage wording that replaced it, and the ten-rep round that
decided it, are the first section of this file; that round cost $22.11, of
which $7.50 bought the five reps that took this baseline to ten.

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
before counting it - and read the two rates across the arms, not per rep: a
wording that changes which tool applies a mutation changes how much of the act
the grader can see, and then the arms differ in the grader's coverage as well
as in their behaviour. The coverage round is the case in point, at 7/10 against
2/10 on `no-mutation-through-edit`. Run every arm with `--keep-temp`: the runner
deletes each workspace otherwise, and a `no-mutation-through-*` fail whose
trace is gone cannot be read by hand at all.
