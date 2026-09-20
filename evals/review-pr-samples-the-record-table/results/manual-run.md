# Runs

**None yet.** The case is written and its graders have never been run, so
nothing here is a baseline. It gets an ordinary review before or with its first
round, which is what this repo does with a case never run in both arms.

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

The graders themselves, in either arm - no run has been bought. Whether the
table shape changes how a reviewer samples, which is the question the case
exists to answer and needs both cases run in the same round.
