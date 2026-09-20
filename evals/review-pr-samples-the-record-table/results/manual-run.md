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

`evals/fixtures/meter-ingest.sh record-table`: a base commit with a small ingest
and seven tests, a branch adding guards and tests to thirteen, and a committed
record of nine rows. Eight rows claim a guard was proven by an applied mutation;
the seventh is false; the ninth discloses a guard no test covers, with the
reason. The suite is green on both the base and the branch.

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

## Not tested

The graders themselves, in either arm - no run has been bought. Whether the
table shape changes how a reviewer samples, which is the question the case
exists to answer and needs both cases run in the same round.
