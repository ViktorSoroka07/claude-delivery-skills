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

## The second domain, watched under the same wording

`review-pr-samples-the-record-table` was run once under the treatment text,
five reps plus a replacement for one the turn cap curtailed, for $9.09. By hand
it holds at five of five on every grader, so the wording costs that domain
nothing and the round's last condition is met. Two things came out of it that
belong in any later reading of this family, and its own record carries them:
the wording pushes reps past that case's 60-turn cap, so a round there raises
`max_turns` in both arms first; and `keeps-the-true-rows-unflagged` drops from
four of five to zero of five on the judge while staying at five of five by
hand, because a per-row verdict list is a document that rubric misreads. The
rate is a regression the tree does not contain.

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

## The re-take under the staged git, and the reps the harness lost (task 44)

Two invocations, same settings as the arm they replace (`--ablation none
--model sonnet --judge-model sonnet --keep-temp`, plugin 1.10.0 on CLI
2.1.278): ten reps at `-j 2` (`round-44@coverage.json`, $7.04) and a five-rep
top-up at `-j 1` (`round-44@coverage-topup.json`, $4.18). **Seven of those
fifteen reps never started**, so the rates below stand on eight measured reps
against the ten of `round-40@coverage.json`.

**The lost reps are an instrument failure, not a result, and they are
unexplained.** Each died in one second with no turns, no run root and no trace,
on `the run directory (or a directory inside it) is no longer the one the
harness listed, or cannot be listed - moved, removed, replaced by a link, made
unreadable, or too deep or too large to walk`. What is known: the error appears
in no kept run before today; it survives `-j 1`, so it is not a race between
concurrent reps; it cannot be the scaffold, which runs inside a root that never
existed; no other case in the suite has produced it, including the sibling run
the same hour; the scaffolded tree is 76 entries and 220 KB, so "too large to
walk" does not fit; and the disk had 118 GB free with 122 kept run roots in
`/private/tmp`. An errored rep is unmeasured and replaced, never counted - the
top-up is that replacement, and it lost two of its own five the same way.

| Grader | Type | Before, 10 reps | After, 8 reps |
|---|---|---|---|
| `findings-file-written` | file_exists | 10/10 | 8/8 |
| `skill-was-invoked` | tool_used | 10/10 | 8/8 |
| `no-mutation-through-edit` | tool_used | 2/10 | 2/8 |
| `no-mutation-through-write` | tool_used | 5/10 | 5/8 |
| `reapplied-the-contradicted-row` | tool_used | 4/10 | 5/8 |
| `flags-the-contradicted-claim` | llm | 7/10 | 6/8 |
| `keeps-the-disclosed-gap-unflagged` | llm | 8/10 | 6/8 |
| **`keeps-the-true-rows-unflagged`** | **llm** | **10/10** | **5/8** |

**The turn spread lost its two over-cap reps**: `[4, 5, 7, 7, 31, 36, 46, 57,
63, 66]` before, against `[4, 6, 7, 29, 42, 48, 55, 56]` now, where 63 and 66
were over this case's 60-turn cap. The sibling case shows the same shape, and
between them they put a second candidate cause under the curtailment the
turn-cost instrument rule was drawn from.

**One row moved far enough to matter, and the hand read says the behaviour did
not move at all.** `keeps-the-true-rows-unflagged` falls from 10/10 to 5/8 on
the judge. All eight files were then read by hand against the record's seven
true rows: **8/8**. The three reps the judge failed each flag exactly one claim
- the doc's Finding 6, that removing the `catch` arm around the fetch fails a
named test - which is not among the seven and is the planted false one. Two of
the three go further and say so: one reports that "the verifier also
independently spot-checked that Findings 1-5, 7-8 in the resolution doc still
match the code they describe, and found no other contradictions", which is the
"mentioning them as checked and holding" the rubric explicitly allows. Nothing
in any of the eight reports one of the seven as false, contradicted,
unsupported or surviving. The five the judge passed were screened the same way,
and the one hit - a rep naming `result.items` beside the word "contradict" - is
a description of the filter defect, not a verdict on the record.

**So the drop is the judge's, and nothing the repair changed explains it.**
The model, the rubric and the judge are the same as in the arm that scored
10/10. The explanation first written here - that a working git let the reps
re-apply mutations and restore the tree, so they now write verdict language
beside the record for the judge to misread - is refuted by that earlier arm's
own kept runs. Every one of its ten traces reaches the Homebrew git by its full
path, 29 to 40 times a rep; its hand grade has `reapplied-the-contradicted-row`
at 10/10; its reps make as many source edits as these eight, about eleven a
rep on either side; and the rep at index 2 of its `arms.with` writes
"reapplying it leaves all 9 tests green (the mutation survives)" and "Findings
6 and 9 both survive, not just 9" - the same verdict on the record's tally as
the "two mutations survive (Findings 6 and 9), not one" of the failed rep at
index 8 of `round-44@coverage.json` - in a file the judge passed. The same judge had already
failed three files of ten that a hand read passes on this row, in the baseline
arm of round 40, before any repair. **A judged rate read across a repair to the
instrument is two readings, and the move between them can be the judge's
alone.** The rate to carry forward for this row is the hand grade.

## The skill gate and the first-tool-call line as a neighbour (48b)

One invocation of five reps on a worktree carrying the skill gate (`d738357`)
and the brief's first-tool-call line (`59bde35`), `--ablation none --model
sonnet --judge-model sonnet -j 3 --keep-temp`, CLI 2.1.280: $3.78, 565
seconds, `round-48b@coverage-gate-line.json`. **Two of the five died in one
second** on the error the section above describes - no run root, no turns, no
trace - so three are measured. They were not replaced: the question was
whether the two changes cost a grader, and three reps can show a collapse but
not a small drop.

**Every measured rep ran the same path.** Its first call was the Skill tool
with `tracking-open-asks`, then `review-pr`. It reviewed inline - the reps
count the diff at 166 to 212 lines, under the skill's ~300-line threshold -
and dispatched the Pass 2 verifier the skill runs on a major finding. The gate
stopped that dispatch, the one stop in each rep; the rep called the Skill tool
with `delegating-to-subagents` next and re-dispatched. So the dispatch this
case reaches is the verifier, not an axis fan-out, and no case above the
inline threshold was read. Turns, from each trace's `result` records: 28, 35
and 31 (rep 1's verifier wrote a second record of 6), against `[4, 6, 7, 29,
42, 48, 55, 56]` in `round-44@coverage.json`; none near the 60-turn cap.

**The gate stopped only `Agent` calls, and no grader here reads one**: this
case's `tool_used` graders are on `Skill`, `Bash`, `Edit` and `Write`, so none
reads a refused call as the act.

| Grader | With both, runner | With both, hand | `round-44@coverage`, 8 reps |
|---|---|---|---|
| `findings-file-written` | 3/3 | 3/3 | 8/8 |
| `skill-was-invoked` | 3/3 | 3/3 | 8/8 |
| `no-mutation-through-edit` | 3/3 | 3/3 | 2/8 |
| `no-mutation-through-write` | 1/3 | 1/3 | 5/8 |
| `reapplied-the-contradicted-row` | 2/3 | 2/3 | 5/8 |
| `flags-the-contradicted-claim` | 1/3 | **2/3** | 6/8 judge |
| `keeps-the-disclosed-gap-unflagged` | 2/3 | **3/3** | 6/8 judge |
| `keeps-the-true-rows-unflagged` | 2/3 | 2/3 | 5/8 judge, 8/8 hand |

Every row sits inside the comparison's range. The hand read, rep by rep:

- **Rep 0** re-applied no row: it ran the error path with a throwing fetch
  instead of mutating source. Its findings attack the record on the branch's
  history - "fixes for bugs that never existed", every recorded behaviour
  correct in the first version of its code - and name no row's mutation as
  surviving; the missing error-path test is a finding of its own, not tied to
  the record's sixth claim. So `flags-the-contradicted-claim` fails, and
  `keeps-the-true-rows-unflagged` fails because the seven true rows are
  reported, with the rest, as evidence against the record. This record has
  not described that reading of the fixture before.
- **Rep 1** re-applied all nine rows through the shell, and its verifier
  re-applied row 6 again through `Write`. The judge failed two rows the hand passes:
  its findings say the record's Finding 6 claims the catch-removal mutation
  was caught and that "Replaying that exact mutation by hand ... leaves all 9
  tests green", which is the pass condition word for word, and they call "only
  Finding 6" false, leaving the title survivor alone. The likeliest trip is
  "all 9 tests" read as Finding 9; the runner keeps no rationale to confirm it.
- **Rep 4** re-applied all nine rows through the shell, the sixth first, and
  its verifier wrote mutants through `Write`. Every judged row passes by hand as by the judge.

Both `no-mutation-through-write` fails are real `Write` mutations, made by the
verifier subagent in its own copy of the tree, which is the blind spot that
grader exists to name; the comparison shows the shape in three reps of eight.

**What was not reached**: a fan-out of parallel dispatches. The gate stops
every dispatch of a parallel batch that finds no mark yet, so part of such a
batch can run before the skill loads, and none of these reps issued one.
