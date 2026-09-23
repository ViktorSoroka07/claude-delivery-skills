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

## The committed prompt through the runner

The hand runs above started the agent directly; the committed prompt has a
session dispatch it and relay its report, and all four graders read that
relay. One run of `claude plugin eval` over the suite, three runs per arm,
the runner's own arms and its default judge, on the fixture with the single
trap and the graders anchored on the clamp's row:

| Grader | No plugin | Plugin |
|---|---|---|
| gate-only-failure-recorded-survived | 0/3 | 3/3 |
| gate-only-failure-not-recorded-killed | 3/3 | 3/3 |
| threshold-taken-out-of-the-command | 0/3 | 3/3 |
| clamp-gap-filed-as-a-test-gap | 0/3 | 3/3 |

The clamp's row reached the reply in every plugin run, which is what the two
regex graders need from the relay. The second row passes without the plugin
because no reply there put KILLED in a cell of the clamp's row; its sibling
requires the row to read SURVIVED and fails those runs.

## Not tested

The other rules carried into the contract: a mutation that does not compile,
a staleness gate on a generated artifact, a candidate the type system
settles before a run, a survivor on a subset confirmed against the full
suite.

## The graders follow the report into the file the contract now writes

The contract this case tests changed underneath it: `mutation-tester` writes
its complete report to the path the dispatch names and replies with that path
alone, because a report sent as a reply is cut mid-row by the transport and the
text before the cut reads as a finished sentence. Three of this case's four
graders carried no `focus`, so they read the run's final message, and the case
prompt asked the orchestrator to "reply with the agent's report verbatim and
nothing else" — which now means the orchestrator has to open the file and paste
it before any grader sees a table. That is a second behaviour, belonging to no
skill under test, standing between the agent and its own graders.

The dispatch names the report file instead — `mutation-report.md`, which is the
contract's own default when a dispatch names none — and the orchestrator replies
with the path. All four graders read that file: `focus` on the two rubric
graders, `target` on the two regex ones. The `not_contains` grader keeps the
throw-is-a-fail behaviour every file-targeted grader has, and its body now says
why that is right here: with the path in the prompt, an absent file is a run
that did not report, not a naming miss.

A `tool_used: Agent` indicator marked `arm: with-only` records whether the
plugin's agent was the one dispatched. The arm without the plugin sends a
general agent against the same brief, which is the comparison the case makes,
so the indicator says which of the two produced the report being graded.

### First pass at the new shape, and what it exposed

| Grader | No plugin | Plugin |
|---|---|---|
| clamp-gap-filed-as-a-test-gap | threw 0/3 | 3/3 |
| gate-only-failure-not-recorded-killed | threw 0/3 | 3/3 |
| gate-only-failure-recorded-survived | threw 0/3 | 3/3 |
| threshold-taken-out-of-the-command | threw 0/3 | 3/3 |
| mutation-agent-was-dispatched (indicator) | not evaluated | 3/3 |

$3.03. The plugin arm reads cleanly at the new contract: the agent wrote
`mutation-report.md`, every grader resolved it, and the clamp's row reads
SURVIVED in all three.

The unaided arm wrote no file at all in three runs of three, so all four
graders threw and scored fails — which is the defect this round exists to
remove, arriving from the other side. A general agent given the same brief
replies with its report rather than writing it, and the orchestrator passed
that reply straight back. Scored as four failures it looks like an arm that
recorded the gate exit as a kill; nothing in the tally says the arm was never
read.

The prompt now puts the file in the orchestrator's hands rather than only the
agent's: the report has to end up at that path, and where the agent replies
with the report instead of a path the orchestrator saves what it sent. Both
arms then produce a report at one place, and the four rubrics compare what the
reports say — which is the contrast the case is named for — instead of which
arm happened to write a file.

### Second pass, with the file in the orchestrator's hands — two runs per arm

| Grader | No plugin | Plugin |
|---|---|---|
| report-written-at-the-named-path | 1/2 | 2/2 |
| clamp-gap-filed-as-a-test-gap | 1/2 | 2/2 |
| gate-only-failure-not-recorded-killed | 0/2 | 2/2 |
| gate-only-failure-recorded-survived | 0/2 | 2/2 |
| threshold-taken-out-of-the-command | 0/2 | 2/2 |
| mutation-agent-was-dispatched (indicator) | not evaluated | 2/2 |

$2.49. The plugin arm passes everything. One unaided run of two now writes the
report at the named path, and what it says is the contrast the case exists for:
it recorded the clamp mutation as KILLED — the pattern the `not_contains` grader
forbids was found — and wrote no SURVIVED row for it. That is the gate's exit
read as a kill, with no assertion behind it, which is the defect the contract
names. Before this round that run was four throws and said nothing.

The other unaided run still wrote no file. Naming the path in the prompt raised
the unaided arm's compliance from none of three to one of two; it does not
compel it, and it should not — an arm that ignores an explicit instruction is
an observation, not an instrument fault. What changed is that the observation
now has its own row. `report-written-at-the-named-path` fails where no report
reached the path, so a reader sees one zero with four unreadable rows beneath
it rather than four failures that look like a verdict on the report's content.

## The skill gate and the first-tool-call line, read by hand (48b)

Five fresh headless sessions on the plugin carrying the skill gate
(`9f4f543`) and the brief's first-tool-call line (`f754b47`), bought at the
owner's ask after 48b landed both, $1.16 in all. **Not through the runner**:
Docker Desktop was running and had to stay up, and the runner needs `~/.docker`
moved aside, which is unsafe under a live Docker. Each rep scaffolded
`evals/fixtures/fee-schedule.sh` into its own scratch workspace and ran the
case prompt as `claude -p` with the runner's own permission settings -
`--permission-mode dontAsk --allowedTools Read Grep Glob Bash Write Edit
Agent`, 60 turns, 900 seconds - on Sonnet, CLI 2.1.280, default output style.
The maintainer's global instruction files stayed in place, since other sessions
were running; nothing in them concerns coverage thresholds.

**The case's tool list does not take the Skill tool away.** `Skill` is absent
from `allowed_tools`, but under `dontAsk` a Skill call is not refused: every
rep loaded `tracking-open-asks` as its first call. So this read exercises the
gate's ordinary path here, not the stop reason's clause for a session without
the tool. Whether the runner refuses `Skill` on this case is unknown - no
runner trace of it is kept.

**The gate did what it was built to do.** Reps 1 to 4 were stopped once at
their `mutation-tester` dispatch, loaded `delegating-to-subagents` as the next
call and re-dispatched; rep 5 loaded that skill unprompted before dispatching,
so the gate stood aside. Turns 8 or 9, 65 to 82 seconds a rep.
`mutation-agent-was-dispatched` passes all five, and in reps 1 to 4 on two
calls, one refused - so a rep that gave up after its refusal would pass it
too, which is the refused-call rule's instance on this case.

| Grader | Hand, this read | Kept runner arms on the same texts, hand |
|---|---|---|
| `report-written-at-the-named-path` | 5/5 | 5/5 |
| `gate-only-failure-recorded-survived` | 5/5 (the regex) | 5/5 |
| `gate-only-failure-not-recorded-killed` | 5/5 (the regex) | 5/5 |
| `clamp-gap-filed-as-a-test-gap` | 5/5 | 5/5 |
| **`threshold-taken-out-of-the-command`** | **2/5** | **5/5** |
| `mutation-agent-was-dispatched` | 5/5, indicator | 5/5 |

The comparison is `task11-18-mutation.json` and `-rerun.json`, five runner reps
taken after the last change to the agent contract and the delegation skill,
so on today's texts; their reports were re-read by hand for the threshold row,
and each strips the threshold from its baseline and says so.

**The threshold row dropped, and nothing seen ties it to the gate.** The
contract has the baseline taken with the test command's coverage threshold
taken out. Reps 2 and 3 did. Reps 1 and 4 took a green baseline with `npm
test` as given and then swept with the threshold removed, which the rubric
fails; rep 5 swept with the threshold in and separated the gate's exits
afterwards. The orchestrator's dispatch briefs are the channel the gate could
have changed, and they do not split the reps: every brief, before the stop and
after it, passes `npm test` with a note that it fails under full coverage, and
the rewrites after the stop change nothing about the threshold. What does
differ from the comparison is the instrument (hand sessions against the
runner), the CLI (2.1.280 against 2.1.273) and a working git. 2/5 against 5/5
is under the four-in-five gap five reps separate. **A runner re-take of this
case in both arms, once Docker can be closed, is what separates the
instrument from the change.**
