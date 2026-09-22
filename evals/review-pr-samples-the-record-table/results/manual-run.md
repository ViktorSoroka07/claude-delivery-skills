# Runs

## The coverage wording, watched here rather than treated

The sibling nine-row prose case decided that wording at ten reps an arm; this
case was run once under it, to see what it costs on a domain whose baseline
does not fail. Five reps, `--ablation none --model sonnet --judge-model
sonnet`, kept as `round-40@coverage-table.json` with a sixth in
`round-40@coverage-table-topup.json`, traces beside them. $9.09.

**One rep of the five was curtailed and is replaced, not counted.** It reached
the case's 60-turn cap and left no findings file, so five of its graders carry
a verdict no run could have earned. The sixth rep is its replacement, at 29
turns. That curtailment is the wording's clearest cost here: turns run 27, 38,
5, 40, 6 on the baseline and 61, 4, 55, 6, 6 under the wording, and mean
duration goes from about 455 seconds to about 557. The rule states that cost in
its own sentence - one row costs one suite run - so it is the price rather than
a defect, but **a later round on this case raises `max_turns` in both arms
before measuring**, because a cap that one arm crosses and the other does not
is a difference between the arms that has nothing to do with the rule.

| Grader | Baseline judge | Baseline hand | Coverage judge | Coverage hand |
|---|---|---|---|---|
| findings-file-written | 5/5 | 5/5 | 5/5 | 5/5 |
| flags-the-contradicted-claim | 5/5 | 5/5 | 5/5 | 5/5 |
| keeps-the-disclosed-gap-unflagged | 5/5 | 5/5 | 5/5 | 5/5 |
| **keeps-the-true-rows-unflagged** | 4/5 | 5/5 | **0/5** | **5/5** |
| reapplied-the-contradicted-row | 5/5 | 5/5 | 5/5 | 5/5 |
| no-mutation-through-edit | 4/5 | - | 4/5 | - |
| no-mutation-through-write | 5/5 | - | 3/5 | - |
| skill-was-invoked (indicator) | 5/5 | - | 5/5 | - |

**Nothing the wording changed costs this domain, and the one row that moves is
the judge.** Every rep re-applied the seventh row - confirmed by hand from its
own calls, the curtailed one included - and every rep that wrote a file
reported the claim as false. The act and the outcome were already at five of
five here, so there was nothing for a wording to gain; what this arm was bought
for is what it could lose, and by hand it loses nothing.

**`keeps-the-true-rows-unflagged` reads zero of five from the judge, three
votes to none in every rep, against four of five with split votes on the
baseline.** Read as a rate that is the wording destroying a neighbour. It does
not survive the hand read, and not narrowly: the reps affirm the other rows by
name - "No issues were found in the other 7 runbook rows (1, 2, 3, 5, 6, 8, 9)
- each was either re-executed live or traced against source and matches its
stated mutation and test"; "Cross-checked rows 1-6 and 8 independently by
mutation testing - all genuinely fail their named test, so row 7 is the only
false record"; "(The other eight rows of the table were independently
re-derived and are accurate, including row 9's honest disclosure that
`export_name` is unproven.)" The rubric fails a file only where one of the
seven is reported false, contradicted, unsupported or surviving, and these
files are the opposite.

**What changed is the surface, not the behaviour.** Under the wording every rep
re-applies all nine rows and then writes a per-row verdict list, so the rubric
meets a document that adjudicates each of the seven by name, one of them beside
a REFUTED - and it answers that the findings do report on those rows. The
baseline's reps write no such list, which is why its judge fails were one and
split rather than five and unanimous. **The consequence for this case is that
this rubric is no longer a screen under the coverage wording**: a later round
here hand-grades that row in both arms or replaces the rubric, and reading its
rate would report a regression the tree does not contain.

**One rep read the disclosure clause below its bound.** The replacement rep
applied rows 1, 7 and 9 and wrote: "Remaining rows (2-6, 8) were not
independently re-mutated given the diff's size and the credibility of the rows
checked; their described mutations map onto code and tests that were read
directly during Pass 1 and appear consistent with the table's claims." The
wording scopes that disclosure to records above twelve rows; this record holds
nine, where it asks for every row instead. The sentence is honest and passes
the rubric by hand - it reports the reviewer's own coverage, not a verdict
against the rows - but it is the sentence the wording's own design note wanted
kept out of the measured path, and it arrived there anyway in one rep of six.
That is what to watch if the sentence is ever tightened.

## The baseline arm, five reps - and the baseline does not fail

The runner, `--ablation none --judge-model sonnet --model sonnet --runs 5`,
against the current skill text: five fresh headless reps, $6.34 of the round's
$13.32 (the other five are the sibling nine-row case, run in the same round).
Nothing threw, no run errored, no paid grader was skipped, and the
`skill-was-invoked` indicator fired in all five.

| Grader | Judge | Hand |
|---|---|---|
| findings-file-written | 5/5 | 5/5 |
| **flags-the-contradicted-claim** | **5/5** | **5/5** |
| keeps-the-disclosed-gap-unflagged | 5/5 | 5/5 |
| keeps-the-true-rows-unflagged | 4/5 | 5/5 |
| skill-was-invoked (indicator) | 5/5 | - |

The one neighbour fail is the judge, on split votes (one pass, two fails), and
it does not survive a hand read: the rep's negative sentence about the fourth
row's subject is a *code* finding - `check_batch` accepts a reading number equal
to the last accepted one, against its own docstring - not a claim that the
fourth row's mutation record is false, and the same file records that its
verifier "spot-checked runbook rows 1-6 and 8 by applying each named mutation to
a scratch copy and confirmed the named test fails as claimed in every case".

**Every rep reported the seventh row as a defect, so there is nothing here for a
wording to improve.** CONTRIBUTING's first rule for a round is to stop when the
baseline does not fail; on this domain it does not fail at all.

## The draw, read from each rep's own tool calls

Taken from the commands that write a source file, as in the sibling case, and
re-read row by row when the act grader was written against these traces:

| Rep | Rows re-applied, of nine | Reached the seventh? | flags-the-contradicted-claim |
|---|---|---|---|
| 1 | all nine | yes | PASS |
| 2 | all nine | yes | PASS |
| 3 | all nine | yes | PASS |
| 4 | 1-8 | yes | PASS |
| 5 | all nine | yes | PASS |

**Every rep re-applied the seventh row**, so the act behind the outcome does
not fail here either - there is no room under a wording on this domain from
either direction.

**The draws are near-exhaustive, which the first parse of these traces did not
see.** It read two of the reps as having re-applied the false row and nothing
else, and that is wrong in both: one applied the ninth and the fourth row in
its own turns before reporting anything, and its verifier subagent then applied
rows one to eight in a single harness script; the other spot-checked the second
and sixth rows, then applied the seventh itself and printed the result of the
test the row names. Four of the five applied every row of the record; the fifth
applied eight. What the parse missed is the shape the second domain invites: a
table whose mutation column gives each row's rewrite as text is applied in a
loop, and three of these reps wrote exactly that loop.

That leaves the difference between the two cases sharper than the round
reported it, and pointing the other way. On the nine prose findings the draws
run one to eight rows of nine; here they run eight or nine of nine. If the
table shape is what makes a record cheap to re-apply exhaustively, the second
domain's 5/5 is about the shape rather than about a signpost in this fixture -
which is the reading the case was built to test, and the opposite of what the
duplicate test name below suggests.

## The act grader, and the signpost hypothesis

`reapplied-the-contradicted-row` scores the middle column out of the run's own
`Bash` calls; its file carries how the pattern is anchored and what it cannot
see. Re-scored from the five kept traces with the runner's own matcher it reads
**5/5**, with three of the five reaching the row through a subagent alone. The
control for that re-scoring is in the sibling case's record.

`no-mutation-through-edit` fails on the third rep, correctly: that rep applied
the seventh row with the `Edit` tool and reverted it the same way, and only a
second application through a subagent's shell kept the `Bash` grader's reading
of it right. It is the one rep of the ten in this round that a one-tool grader
would have read short, which is why the guard is there.

One candidate explanation the fixture supplies for how the row is found: rows 1
and 7 credit the same test by name, so a reader scanning the "test it failed"
column meets `test_skips_unparsable_rows` twice, and one rep's own text reasons
from exactly that - "it says deleting the `try/except` is caught by
`test_skips_unparsable_rows`, but that test's malformed row has only 3 fields".
**This is unconfirmed**, and it is weaker than the round reported: only one of
the five says so in the text the trace keeps, and the reading that supported it
- two reps applying the false row and nothing else - is the parse error
corrected above. Of the five, one reported the row without having applied it
itself, and its subagent applied it afterwards; the other four applied it.

## What the case is for

It is the second domain for the record-audit rules. `review-pr-samples-across-the-record`
asks whether a reviewer's sample reaches the contradicted row of a long record;
this case asks the same question where nothing else is the same, because a rule
that fires on one fixture may be a rule that matched that fixture's wording.
What differs, deliberately, on every axis that could be pattern-matched:

| | The sibling case | Here |
|---|---|---|
| Language and runner | JavaScript modules, `node --test` | Python, `python3 -m unittest` |
| Product | a refund console's detail page - rendering | a meter-reading ingest - parsing, validation, export |
| Record artifact | `docs/reviews/task-102-resolution.md` | `docs/runbooks/ingest-hardening.md` |
| Record shape | nine prose findings, each with a "Confirmed by mutation" paragraph | a nine-row table: guard, file, mutation, test it failed |
| The false row | sixth of nine | seventh of nine |
| Why it is false | the named test passes because nothing exercises the error path | the named test passes because the row it feeds is skipped one branch earlier, before the guard the row credits is reached |
| Branch | `feature/mount-table` | `harden/ingest-guards` |

The table shape is the part worth naming. A record laid out as a table is read
differently from one laid out as prose sections - it invites skimming a column
rather than reading a row - so a rule that says to sample across the record has
to hold for both, and a wording that only works on headed prose sections is a
wording about one document.

## What the fixture stages

`evals/fixtures/meter-ingest.sh record-table`: a base commit with a naive ingest
and four tests, a branch adding the guards and taking the suite to thirteen, and
a committed record of nine rows. Eight rows claim a guard was proven by an
applied mutation; the seventh is false; the ninth discloses a guard no test
covers, with the reason. The suite is green on both the base and the branch, and
every guard the record credits is a line the branch adds.

## How the record was verified - by running it, not by reading it

Every row was applied alone against the green branch, in its own copy of the
built fixture, and the suite re-run. The verdict and the failing test's own name
were read from the runner's output rather than from an exit status or a tally:

| Row | Mutation | Result |
|---|---|---|
| 1 | delete the field-count branch | killed `test_skips_unparsable_rows` |
| 2 | widen the negative-reading threshold | killed `test_rejects_a_negative_reading` |
| 3 | stop recording the meter in `seen_here` | killed `test_rejects_a_meter_read_twice_in_one_batch` |
| 4 | drop the previous-reading comparison | killed `test_rejects_a_reading_behind_the_last_accepted_one` |
| 5 | write the raw tariff column into the row | killed `test_blank_tariff_reads_as_standard` |
| 6 | index `RATES` instead of `.get` with a default | killed `test_an_unknown_tariff_falls_back_to_standard` |
| 7 | delete the `try`/`except` around `int(reading_no)` | **SURVIVED - the planted false claim** |
| 8 | append the header again inside the row loop | killed `test_writes_the_header_once` (and `test_a_zero_reading_still_exports_a_row`) |
| 9 | replace the run-numbered filename with a constant | SURVIVED, which is what the row discloses |

Row 8 kills a second test as well as the one the record names; the record claims
the named test failed, which is true, and claims nothing about being the only
one. Row 7 is the case's subject: the guard is real and useful, the test named
beside it is real and green, and only applying the mutation separates the two.

## What the run needs

`python3` on the path inside the run sandbox, as the sibling case needs `node`.
A run that cannot execute the suite cannot apply a single row of the record, so
it would fail `flags-the-contradicted-claim` for a reason that has nothing to do
with the rule: read that grader's fail against the run's own tool calls before
counting it.

## The review this case was owed, and the one defect it found

Read before its first round, as this repo reads a case never run in both arms.
The five graders resolve against a path the prompt names, the scored grader is
the one the case is named for, and the indicator carries the built-in-skill
hazard - nothing there moved. The fixture did.

**Four of the record's nine rows credited guards the branch does not add.** The
field-count skip, the negative-reading rejection, the unknown-tariff fallback
and the write-the-header-once rule were all on `main` before the branch, and
`src/billing.py` was not in the diff at all, while the record's header says
"Nine guards in this change". That is two defects in one: a second contradiction
for a reviewer to report, which `keeps-the-true-rows-unflagged` fails on; and,
worse for what this case measures, a reviewer who narrows the record to the rows
the diff touches is left with five - including the false seventh - which is the
four-row record this case exists to escape.

Fixed by weakening the base rather than by touching the branch: the base ingest
now parses without a field-count guard and returns rows alone, has no
`validate.py`, indexes `RATES` directly, and exports without a header, so all
nine guards arrive with the branch. **The branch's own tree is byte-identical
before and after** - `7dda71f` at the harden commit and `e2af860` at the record
commit, compared by `git rev-parse` on both builds - so every mutation verdict
in the table above still describes the tree a run reviews. The base suite is four tests green,
the branch thirteen green.

Re-verified after the fix by applying each row's mutation alone to a copy of the
built branch and reading the failing test's own name from the runner: rows 1-6
and 8 red on exactly the test the record names (row 8 also on
`test_a_zero_reading_still_exports_a_row`, which the record does not claim
otherwise), row 7 green, row 9 green.

## Not tested

Any arm but the current text: no wording was run here, because the baseline
does not fail. Whether the table shape changes how a reviewer samples is still
open, but the evidence moved while the act grader was being written. The two
cases ran in the same round and differ by 5/5 against 2/5 on the graded row,
and the draws behind those rates differ the same way - eight or nine rows of
nine here against one to eight there. The duplicated test name remains an
unexcluded explanation for how this case's row is *found*; it explains nothing
about how much of the record is re-applied, which is what the two cases now
differ in most.
