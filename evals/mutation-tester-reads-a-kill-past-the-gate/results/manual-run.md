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

The fixture's second trap, a waiver condition whose `tier` operand only
removal exposes, did not separate the arms either: one treatment session of
five removed the operand, the rest flipped it, and a flip is killed. One
operand at a time is what the protocol asks for and what both arms did;
removing an operand is a different mutation, which nothing yet asks for.

## Not tested

The other rules carried into the contract: a mutation that does not build, a
crash at load that fails every test, a staleness gate on a generated
artifact, a survivor on a subset confirmed against the full suite. The case's
committed prompt, which has a session dispatch the agent; the hand runs
started the agent directly.
