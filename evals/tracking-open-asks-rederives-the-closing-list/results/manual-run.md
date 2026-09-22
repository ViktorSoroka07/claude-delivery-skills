# Manual runs

## The baseline read: ten reps, one arm

Ten reps of the baseline arm alone, `--ablation none --model sonnet
--judge-model sonnet --runs 10 -j 3 --keep-temp`, at plugin version 1.10.0 on
CLI 2.1.278. $1.99 and 2.6 minutes wall; the arm is kept as
`round-41@baseline.json` with all ten traces. No rep errored, no paid grader
was skipped, and nothing was curtailed: the turn spread is 7-13 against a
40-turn cap and the duration spread 32-53s against a 600s timeout, so no
finding here is a rep that ran out of room.

**The trigger never fired, in any rep.** `skill-was-invoked` is 0/10, and a
hand read of all ten traces confirms it: the Skill tool is called zero times,
and no sentence of `skills/tracking-open-asks/SKILL.md` appears anywhere in any
trace. The skill was available - the run's `init` event lists it among 34
skills, with the `Skill` tool granted - and the seeded brief did reach the model
(the probe below). The model simply never reached for it. **So every rate below
is what the brief's six-line summary produces on its own, not what the skill
produces**, and a wording landed in the skill's body would reach none of these
reps.

The sibling single-prompt case, run as a control for this at three reps
(`round-41@sibling-control.json`, $0.53), is 0/3 on the same indicator - so it
is not the replay that suppresses the trigger. Across every kept run in
`evals/results/`, the indicator stands at 59/59 on the other cases and 0/13 on
this skill's two. What separates them is the shape of the trigger: every case
that fires names a task the skill owns in its prompt - review this, sync these,
file that, prune the store - while this skill's trigger is a standing rule about
how a message ends, which no prompt ever asks for. **A skill whose condition is
a standing rule rather than a named task is not reached through the Skill tool
at all.**

| Grader | Type | Judge / mechanical | Hand |
|---|---|---|---|
| `answered-item-acted-on` | tool_used | 7/10 | 7/10, and see the git split below |
| `answered-item-off-the-list` | llm | 7/10 | 7/10, same three reps |
| `changelog-carries-the-rename` | regex | 10/10 | 10/10 |
| `changelog-cut-to-the-release` | regex | 10/10 | 10/10 |
| `no-carried-row-in-the-table` | regex | 5/10 | 5/10 |
| **`not-theirs-item-off-the-list`** | **llm** | **4/10** | **4/10** |
| `owner-item-still-listed` | llm | 5/10 | 5/10 |
| `skill-was-invoked` | tool_used | 0/10 | 0/10, hand-confirmed |

**The three judged graders were hand-graded from the reps' own final messages
before any rate was read off them, and the judge agreed on all thirty cells.**
That is the first family here where `--judge-model sonnet` needed no
adjudication, and it is the expected shape: each rubric states one condition
over one short message, which is the form the calibration file says the judge
reads well.

**The carry-forward rate, read as this record requires, is 0/5.** The
denominator is the reps that produced a closing list at all, which
`owner-item-still-listed` selects: reps 1, 3, 4, 6 and 7. Every one of those
five carried the upstream clock question forward as a row the requester is
asked to answer. The four reps the deciding grader passes are passing it for the
reason this record warned of - reps 5, 9 and 10 close with no list at all ("Nothing
outstanding now - all three items from my last message are resolved", which is
also false, item 1 having never been answered), and rep 2 closes with a
one-row list holding neither the owner's question nor the upstream one. **The
defect fires in every rep that reaches the condition**, which is as clean a
baseline failure as this instrument produces.

**The regex screen and the judged grader disagree on exactly one rep, and the
hand read backs the judge.** Rep 8 closes in prose rather than a table -
"question 1 (legacy column order) and question 3 (`booked_at` timezone) - both
unanswered and both block the export-columns plan" - which the row-scoped
pattern cannot see and which does put the upstream question to the requester as
theirs to answer. That is the blind spot this record predicted for the screen,
arriving on the first run.

**Three reps could not perform the graded act, for a reason outside the rule -
since fixed, and re-taken in the section below.**
Inside the eval sandbox, plain `git` resolves to the Xcode command-line-tools
stub at `/usr/bin/git`, which dies writing an `xcrun` cache file outside the
paths the sandbox allows. The working binary is `/opt/homebrew/bin/git`, and it
runs when named in full - but it loses the PATH search from any position, being
a symbolic link into a Cellar the sandbox will not let the shell stat, which
task 44's probe settled after this arm was read. Seven reps found the absolute
path and deleted the branch; reps 2, 3 and 7 did not, reported the deletion as
blocked, and put it to the requester instead. Their `answered-item-acted-on`
fail is therefore an instrument failure and not a behaviour, and
`answered-item-off-the-list` fails in the same three reps for the same reason -
a run that cannot perform an act and escalates it is doing the right thing with
the list. **Both of those rates were unusable until a working git was staged
for the run**; the two graders the round turns on,
`not-theirs-item-off-the-list` and `owner-item-still-listed`, touch no git and
were unaffected. The re-take below replaces both.

Read before counting, as this record requires: the three reps failing
`answered-item-acted-on` were checked against their traces for whether the
replay reached them, and all three looked up `tmp-migrate` by name - a branch
nothing in the prompt mentions and only the seeded list names. The replay
reached every rep, so none is unmeasured and none was replaced.

## The re-take, once the sandbox had a working git

Ten reps again, the same command and the same versions - `--ablation none
--model sonnet --judge-model sonnet --runs 10 -j 3 --keep-temp`, plugin 1.10.0
on CLI 2.1.278 - kept as `round-44@baseline.json` with all ten traces. $1.34
and 94 seconds, against $1.99 and 155 seconds for the arm above. Nothing
errored and nothing was curtailed: the turn spread is 5-7 against a 40-turn cap
and the duration spread 21-28s against a 600s timeout. The only difference
between the two arms is the line every case's `fixture.sh` now carries,
`evals/fixtures/stage-git.sh`, which puts a working git first on the run's own
PATH.

| Grader | Type | Before | After | Hand, after |
|---|---|---|---|---|
| `answered-item-acted-on` | tool_used | 7/10, unusable | **10/10** | 10/10 |
| `answered-item-off-the-list` | llm | 7/10, unusable | **10/10** | 10/10, judge agrees on all ten |
| `changelog-carries-the-rename` | regex | 10/10 | 10/10 | 10/10 |
| `changelog-cut-to-the-release` | regex | 10/10 | 10/10 | 10/10 |
| `no-carried-row-in-the-table` | regex | 5/10 | 4/10 | 4/10 |
| **`not-theirs-item-off-the-list`** | **llm** | **4/10** | **3/10** | 3/10, judge agrees on all ten |
| `owner-item-still-listed` | llm | 5/10 | 6/10 | 6/10, one borderline below |
| `skill-was-invoked` | tool_used | 0/10 | 0/10 | 0/10 |

**The two rates this record marked unusable are usable, and both are clean
sweeps.** Ten of ten reps deleted the branch. The traces say why more plainly
than the replies do: across the arm above, `xcrun` failures run 12 to 24 per
rep and seven reps name `/opt/homebrew/bin/git` in full, while in this arm the
string `xcrun` appears in no trace, no rep names an absolute path, and no rep
mentions the wrapper it is using. The instrument also stopped charging the reps
for the defect - 5 to 7 turns against 7 to 13 - because none of them is
debugging its tools.

**The deciding rates moved by one rep each and the reading is unchanged.** The
carry-forward rate, read as this record requires over the reps that produced a
closing list at all - reps 1, 2, 3, 5, 9 and 10, which `owner-item-still-listed`
selects - is **0/6**: every one of them carries the upstream clock question
forward as a row the requester is asked to answer. It was 0/5 in the arm above.
The defect still fires in every rep that reaches the condition.

**Rep 4 is the borderline one, and it is on the denominator's grader.** It
closes in prose - "Nothing left of these three waiting on you. Still open from
before: whether `id,currency,amount` order must be preserved (blocks plan step
2), and whether `booked_at` should be UTC or local time" - which contradicts
itself in its first clause and restates both questions in its second. The judge
failed it on `owner-item-still-listed`; a hand read can pass it, the question
being answerable from that sentence alone. It fails
`not-theirs-item-off-the-list` either way, so the carry-forward rate is 0/6 on
the judge's denominator and 0/7 on the lenient one. Rep 4 is also the one rep
where the regex screen and the judged grader disagree, the carried item being
prose rather than a table row - the blind spot this record predicted, in its
second run and in a different rep from the first.

**One sandbox artefact is left, and it is not the git split.** `git branch -d`
prints `error: could not lock config file .git/config` and deletes the branch
anyway: the sandbox denies writing a repository's `.git/config`, and git tries
to drop the branch's config section. It appears the same number of times in
both arms, so it predates the staging and is not caused by it. Every rep
notices it and says so in its reply, which is worth knowing for any rubric read
over the closing message.

## What the probe settled before the reps

A throwaway probe kept at `docs/plans/task41-replay-probe/` ran this fixture for
$0.03 before the arm was bought. It answered three things, one of them against
what this record had assumed:

- **A case carrying both a `scaffold_script` and a `history_file` validates and
  runs.** No case in the suite had carried both, and the runner validates only
  when a rep runs, so nothing short of a run said so.
- **The seeded turns reach the model as its own earlier turns**, and it counts
  the seeded table's three rows, so it holds the whole assistant turn.
- **The seeded brief reaches the model: `BRIEF-PRESENT`.** The earlier probe
  answered `BRIEF-ABSENT` and is what this record's open question rested on, but
  that probe predates the `hook_additional_context` attachment in the generator.
  With the attachment in place a resume does re-render the brief. The
  consequence this record flagged is now a live hazard rather than a
  hypothetical: **should this case ever be run with both arms, the seeded brief
  reaches the arm meant to be without the plugin**, and that row understates it.

**Every rep branches off the seed rather than chaining onto the rep before it.**
The runner copies the seeded transcript to one file named for its session id -
one file for the whole invocation, not one per rep - and each rep appends its own
turns there. It is the parent chain that keeps them apart: every rep's user turn
carries the seeded assistant turn's uuid as its `parentUuid`, so no rep can see
another's answer, and any concurrency is safe. Read that chain rather than the
file's line order, which interleaves the reps.

## What it stages

The rule under test is not in the skill yet. It is the queued entry about a
closing-ledger item carried forward from the previous message and never
re-tested against the rule that admitted it: once an item belonging to someone
else enters the list, editing the list each round rather than deriving it
afresh keeps it there indefinitely, and the drift is silent because a requester
cannot tell that an item is not theirs and answers from what they do know.

Every other case in this suite is a single prompt, so no rep reaches a second
closing round and both arms would score alike for a reason having nothing to do
with the wording. This case seeds the first round instead of hoping for it.
`context.history_file` is `--resume <path>`: the three lines in
`history.jsonl` - the plugin's session brief as the attachment a recorded
session writes, one user turn, one assistant turn - reach the run as its own
earlier turns. The seeded assistant turn closes with a table of three items
said to wait on the requester, and the prompt asks for a second closing list.
The condition is staged by construction, so every rep starts from it.

The third row is the defect, and it is the only one the fixture carries:

| # | The seeded list asks | Whose it is |
|---|---|---|
| 1 | Must the legacy column order be kept? | The requester's, unanswered |
| 2 | May the merged scratch branch be deleted? | The requester's - answered in the prompt |
| 3 | Is the timestamp column exported as UTC or converted to local time? | The upstream team's, raised on their tracker |

The tree says so in two places a run that re-derives will read:
`docs/upstream/booked-at-timezone.md`, committed as the durable record of where
the question was raised, and the last line of `docs/plans/export-columns.md`,
which names the same owner. Both say in as many words that it is not the
requester's call. Nothing in the prompt points at either: a run that carries
the previous list forward and edits it never opens them, which is the whole
mechanism.

The prompt answers item 2 and asks for changelog work. That gives the case
three things at once: an item that must leave the list because it was answered,
an act to grade (the branch deletion), and work whose result is in the tree
rather than in the reply.

## The fixture

`evals/fixtures/export-cli.sh`, variant `post-rename` - the same tree as the
sibling case `tracking-open-asks-closes-with-what-waits`, left as the seeded
exchange left it: the rename and the version done and **uncommitted**, because
the seeded requester asked for a diff rather than a commit, and the changelog
untouched. The upstream note and the plan's third line are committed, being a
record older than the session. The scratch branch is merged, so `git branch -d`
succeeds on it.

## What each grader reads

| Grader | Type | What it is for |
|---|---|---|
| `not-theirs-item-off-the-list` | llm | The deciding one: the upstream question is not put to the requester to answer |
| `owner-item-still-listed` | llm | Its pair: the genuinely open owner question is restated as the question |
| `answered-item-off-the-list` | llm | The neighbour: an answered item leaves the list |
| `no-carried-row-in-the-table` | regex | The mechanical screen over the deciding condition |
| `changelog-cut-to-the-release` | regex | The work landed in the tree, not only in the reply |
| `changelog-carries-the-rename` | regex | The other half of the work |
| `answered-item-acted-on` | tool_used | The answered item was acted on - and the replay reached the model |
| `skill-was-invoked` | tool_used, `arm: with-only` | The trigger fired, and the skill's own text was loaded |

**The deciding grader is judged, not a `not_contains` on the item's literal.**
That was the shape this case was planned with, and it scores the wrong thing:
the skill's own rule says an item leaving the list is stated rather than
dropped in silence, so a run that behaves correctly may well name the upstream
question while saying it has left the list and why. A pattern on the literal
fails exactly those runs, and it fails them hardest in the arm that behaves.
What has to be read is whether the question stands in the closing list as
something the requester is asked to answer, and the boundary between a row and
a sentence about a row is not one a pattern reaches. The regex beside it is
scoped to a table row for the dominant shape and is a screen, not the verdict.

**Read the carry-forward rate over the reps that produced a list at all.** A
final message with no closing list passes the deciding grader for a reason that
has nothing to do with ownership; `owner-item-still-listed` is what separates
the two, and the sibling case measured the plugin arm closing with its list in
two runs of three. A rep that fails the pair is a rep the list rule did not
bind, and it says nothing about carrying forward.

**A rep that fails `answered-item-acted-on` is read before it is counted.**
"2 is a yes" resolves only against the seeded list, so a run that never
received the earlier turns cannot know what was answered - and its other
graders would then be scoring a single-prompt case. Where the trace shows the
run had no earlier list, the replay did not reach it: the rep is unmeasured and
replaced, the way a curtailed rep is, rather than counted as a fail.

## Answered by the first run, and what remains

**Whether a resume re-renders the seeded brief into the run's context: it
does.** The `SessionStart` hook does not fire it - the matcher is
`startup|clear|compact`, and a resume is neither - so the fixture carries the
brief as the `hook_additional_context` attachment a recorded session writes,
with the `rendered` system-reminder beside it. The probe answered
`BRIEF-PRESENT` on this fixture, so the attachment is the working remedy and the
earlier `BRIEF-ABSENT` result belongs to a fixture that carried no attachment.

**And the inference this record drew from it was wrong.** It read
`skill-was-invoked` as one of the two things that would answer whether the brief
arrived, "since the brief is what sends a session to the skill". The run
separates them: the brief arrived in every rep and the skill was invoked in
none. A brief that names a skill and tells the session to call it is not
evidence that the session will, so the indicator measures the trigger and
nothing else - which is the job it was given in the first place, and the reason
it is worth its place in a case that can otherwise only see outcomes.

**This case has no second arm**, and it now has a second reason not to grow
one. A replay case contributes no ablation row - the one earlier run that used
`context.history_file` under `with-without` reported a single arm - and the
seeded brief is now known to reach the model, so an arm meant to be without the
plugin would be handed the plugin's own rules by the fixture and would
understate the difference. Both arms of any round here hold the brief and can
differ only in text the reps actually read.

**What the fixture freezes.** `history.jsonl` carries the brief as it stood
when it was generated. `make-history.py` beside it reads `hooks/session-brief.md`
at build time and is deterministic, so regenerating it and finding no diff is
the staleness check - run it after any change to the brief.

## Not tested here

That an item left on a default is said to have been; that the numbers stay the
same from message to message, which this case's answered item makes moot; and
the consequence columns, which the sibling case measures and which no run in
either arm has yet passed.
