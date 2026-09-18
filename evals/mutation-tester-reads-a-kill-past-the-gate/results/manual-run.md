# Manual runs

Fixtures from `evals/fixtures/fee-schedule.sh`, five fresh headless Sonnet
sessions per arm, each started as the agent (`claude -p --agent`) with the
brief the case's prompt describes, graded on the agent's report. The baseline
arm is the contract before the change; the treatment arm has the protocol's
later rules carried into its steps.

| Grader | Baseline | Treatment |
|---|---|---|
| gate-only-failure-recorded-survived | 1/5 | 5/5 |
| gate-only-failure-not-recorded-killed | 1/5 | 5/5 |
| threshold-taken-out-of-the-command | 0/5 | 5/5 |
| clamp-gap-filed-as-a-test-gap | 5/5 | 5/5 |

Four baseline reports put KILLED in the named mutation's row and wrote beside
it that all six tests still passed and the exit came from the coverage gate.
They saw the mechanism and recorded the kill anyway, since the contract told
them to re-run the tests and record KILLED or SURVIVED and said nothing of
what a kill is. Every treatment session took the threshold out of the command
before its baseline, said so, and recorded the row SURVIVED; two told the
dispatcher that the earlier record's claim was wrong.

## A first run that reached neither trap

Without a mutation named in the brief, no session in either arm chose one
that lowers coverage without failing an assertion: every one found the clamp
gap through `amount = 0` to `amount = 1`, which leaves coverage alone. The
two arms were the same, five of five. The named mutation is what a record
audit hands the agent, and it is the input on which the arms differ.

The fixture then carried a second trap, a waiver condition whose `tier`
operand only removal exposed. It did not separate the arms either: one
treatment session of five removed the operand, the rest flipped it, and a
flip is killed. No grader read it, so the fixture now pins the operand with a
test of its own and carries the coverage trap alone: the runs above had six
tests, and a build from the current script has seven.

## A mutation that crashes at load

Step 4 said of one event both "a mutation that does not compile or load is
evidence in neither direction, restate it until it builds" and, a few
sentences on, that "a crash at load that fails every test" is recorded
SURVIVED. Gate 1 takes the first side. Five fresh headless Sonnet sessions
per arm, started as the agent, with this brief and nothing else: "Your
worktree is this directory and you have it to yourself. The pinned head is
the current HEAD of `feat/fee`, the test command is `npm test`, and the lines
in scope are the ones the diff `main...feat/fee` adds to `src/fee.js`.
Include these two mutations among your own, both of which an earlier record
claims were killed: `if (amount < 0) {` → `if (false) {` in `src/fee.js`,
and `const CAP = 50;` → `const CAP = RATES.cap.max;` in `src/fee.js`." The
second throws at import, so the test file fails as one unnamed entry and the
count drops from six to two; restated to a form that loads (`RATES.cap`, or
any existing key) it is killed by `the fee is capped`. The baseline arm is
the contract with both sentences; the treatment arm says a crash at load is
the mutation that does not load, restated and never recorded, and carries
the rest of what Gate 1 had and the contract lacked (each new test found by
name in the baseline output, a staleness gate out of the command, candidates
screened against the type system before a run, ten to twelve mutations).

| Read from the report | Baseline | Treatment |
|---|---|---|
| load crash restated, no verdict on the form that does not load | 0/5 | 5/5 |
| load crash not filed as a test gap | 1/5 | 5/5 |
| new tests named as found in the baseline output | 0/5 | 4/5 |
| gate-only-failure-recorded-survived | 5/5 | 5/5 |
| gate-only-failure-not-recorded-killed | 5/5 | 5/5 |
| threshold-taken-out-of-the-command | 5/5 | 5/5 |
| clamp-gap-filed-as-a-test-gap | 5/5 | 5/5 |

Every baseline session recorded the crash SURVIVED, four of them citing the
protocol for it, and four filed it as a finding with a missing assertion to
add: a gap the restated form shows is not there. Every treatment session
marked the row as not loading, restated it, and recorded the restated form
KILLED with the test's name; none filed it. The fifth treatment session
found the new tests without saying so in its report.

One baseline report also turned the cap's condition into `if (false)`, a row
rightly KILLED, and the two regex graders read it as the clamp's row. They
now anchor on the clamp's own condition, and the second counts KILLED only
where it opens a cell, so a row that reads SURVIVED and names the earlier
record's claim passes.

## Not tested

The other rules carried into the contract: a mutation that does not compile,
a staleness gate on a generated artifact, a candidate the type system
settles before a run, a survivor on a subset confirmed against the full
suite. The case's
committed prompt, which has a session dispatch the agent; the hand runs
started the agent directly.
