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

## The treated arm: one brief wording, ten reps

**The wording does not land: it reached every rep and moved the carry-forward
rate by one rep, which is not the behaviour.** Ten reps against
`round-44@baseline.json` with the same command - `--ablation none --model
sonnet --judge-model sonnet --runs 10 -j 3 --keep-temp` - at plugin 1.10.0 on
CLI 2.1.280, the baseline having run on 2.1.278; kept as
`round-41a@rebuilt-list.json` with all ten traces. $1.59 and 110 seconds.
Nothing errored and nothing was curtailed: read from each trace's `result`
record, the turn spread is 6-8 against the baseline's 5-7 and a 40-turn cap,
and the duration 11-16s against 10-15s - 24-32s against 21-28s in the runner's
own figure, which counts the rep's start-up as well.

The treated text is the brief's closing-list bullet with one addition after
"(one item a sentence, two or more a numbered table)":

> The list is rebuilt each message, never copied from the last one and edited:
> check each item against where it is recorded (the plan, the tracker, the
> thread that raised it) for whether it is still open and whether the requester
> is the one to answer it. An item of theirs stays until they answer it, the
> work goes ahead on its stated default, or it is no longer needed, and each
> exit is said; an item someone else must answer leaves with one sentence
> naming whose it is; a surviving item keeps its number.

**It reached every rep, confirmed from the fixture rather than from
`skill-was-invoked`.** `make-history.py` regenerated `history.jsonl` in the
treated tree, and "never copied from the last one and edited" is in both the
`content` and the `rendered` copy of its seeded attachment and in neither on
`main`, whose own regeneration came back byte-identical. The continuation
transcript the runner wrote beside it carries the same attachment, and all ten
reps' user turns branch off the seeded assistant turn, so the ten resumed that
file.

| Grader | Type | Baseline, judge / hand | Treated, judge | Treated, hand |
|---|---|---|---|---|
| `answered-item-acted-on` | tool_used | 10/10 / 10/10 | 10/10 | 10/10 |
| `answered-item-off-the-list` | llm | 10/10 / 10/10 | 10/10 | 10/10 |
| `changelog-carries-the-rename` | regex | 10/10 | 10/10 | 10/10 |
| `changelog-cut-to-the-release` | regex | 10/10 | 10/10 | 10/10 |
| `no-carried-row-in-the-table` | regex | 4/10 | 2/10 | 2/10, one of them the screen's blind spot |
| **`not-theirs-item-off-the-list`** | **llm** | **3/10 / 3/10** | **1/10** | **1/10** |
| `owner-item-still-listed` | llm | 6/10 / 6/10 | 9/10 | 10/10 |
| `skill-was-invoked` | tool_used | 0/10 | 0/10 | 0/10 |

Both arms were hand-graded from the traces' final messages before any rate was
read. **Judge and hand disagree on one cell of thirty**: treated rep 6 restates
the owner's question as "Keep the legacy column order `id,currency,amount`, or
use the new `id,amount,currency,booked_at`?", which can be answered from that
line alone; the judge failed it.

**The carry-forward rate is 1/10 against 0/6, and the one pass is a silent
drop.** Every treated rep closes with a list holding the owner's column-order
question, so the denominator is all ten rather than six. Nine carry the
upstream clock question forward as item 2 for the requester to answer - eight
as a table row, rep 1 as a numbered line the regex screen cannot see, which is
why the screen reads 2/10. Rep 8, the one pass, closes with the owner's
question as a single sentence and says nothing of the clock question at all,
where the wording asks for one sentence naming whose it is. Against the
baseline's 0/6 a separation needs about two in three of the treated
denominator - 6/10 here, by the one-sided Fisher test calibrated on
CONTRIBUTING's own examples, where 4/5 against 0/5 separates at p = 0.024 and
9/10 against 5/10 does not at 0.070. 1/10 is p = 0.63.

**No rep in either arm opened the record the wording names.** Across the full
tool inputs of all twenty traces, no call reads `docs/plans/export-columns.md`
or `docs/upstream/booked-at-timezone.md`; one treated rep ran `ls docs` and
went no further. The clause asking for that check needs a read the work gives
the session no other reason to make, and it bound in no rep. **The clause that
needs no act did move**: "an item of theirs stays until ..." took the owner's
own question from 6/10 to 10/10 by hand, and no treated rep closes with
"nothing outstanding", where three baseline reps did. That is below the floor
at ten reps an arm - 10/10 against 6/10 is p = 0.043, against the lenient
7/10 p = 0.105 - and pooling `round-41@baseline.json`'s 5/10 into the baseline
gives p = 0.012, which is suggestive only, the pooled arm having run on another
CLI and a broken git (this grader touches no git).

**The numbering clause did not bind, and this fixture can read numbering only
on the carried item.** The owner's question is item 1 in the seeded list and
stays 1 in every list of both arms, which renumbering from one produces too, so
the number the clause protects is unreadable there. The carried clock question
is readable: it was 3 in the seeded list and is 2 in all nine treated lists
that carry it, as in all six baseline lists. The renumbering the clause targets
is in the baseline already.

### The neighbour: the sibling case under the same brief

Five reps of `tracking-open-asks-closes-with-what-waits` under the treated
plugin, the same command at `--runs 5`, kept as
`round-41a@rebuilt-list-neighbour.json`, against
`round-44@closes-with-what-waits.json`. $0.93 and 92 seconds; turns 13-16 in
both arms against a 30-turn cap. The case is a single prompt, so its brief
comes from the hook, and the treated phrase is in all five traces.

| Grader | Baseline, judge / hand | Treated, judge / hand |
|---|---|---|
| `closes-with-every-waiting-item` | 2/5 / 3/5 | 2/5 / 4/5 |
| `says-what-each-blocks-and-the-default` | 0/5 / 0/5 | 0/5 / 0/5 |
| `done-work-reported-with-evidence` | 3/5 / 4/5 | 4/5 / 5/5 |
| the four mechanical graders | 5/5 each | 5/5 each |
| `skill-was-invoked` | 0/5 | 0/5 |

**The wording costs the neighbour nothing.** Treated reps 1 and 3 name the
column-order item as a choice - "legacy `id,currency,amount` vs the new
header" - rather than as a question, which the hand read passes and the judge
splits on; rep 5 closes with a sentence referring to both items instead of
restating them. The consequence clause is 0/5 in both arms. The done-work
rubric is read leniently in both arms - the value set, named beside the
changelog entry it came from - and a strict reading, which wants the reason
stated, gives 1/5 against 0/5.

**One direction of cost no grader reads.** All five treated reps say the
requester's own two questions wait on "the owner" - "not mine to resolve",
"waiting on their owners" - against two of five baseline reps. The word is the
fixture's, whose plan writes "Asked the owner", and five reps an arm separate
only a four-in-five gap, so this is no finding. But it is the way a rule asking
whose each item is would cost: a closing that hands the requester's own items
to a third party is the carry-forward defect turned round, and a round on a
second wording would need a grader for it.

## The exit clause alone: ten reps

**It moves the owner's question in the expected direction and does not clear
the bar set before the run.** The one clause of the treated arm above that
moved - the requester's own items kept until one of three exits - run on its
own, appended to the same bullet:

> An item of the requester's stays on the list until they answer it, the work
> goes ahead on its stated default, or it is no longer needed, and each exit is
> said.

Ten reps with the same command, CLI 2.1.280, kept as
`round-41b@exit-clause.json`; $1.50 and 92 seconds; turns 5-8 from the
`result` records against a 40-turn cap, nothing curtailed. Its arrival was
checked as the arm above's was: "stays on the list until they answer it" is in
both copies of the regenerated seeded attachment and nowhere on `main`.

**The bar, written before any rep ran:** `owner-item-still-listed` by hand at
10/10 against the two baseline arms pooled, 11/20 - p = 0.012, inside the
separating examples CONTRIBUTING gives - since 9/10 (p = 0.062) sits where its
examples say a gap is noise. The pooled arms differ from this one in CLI and,
for `round-41@baseline.json`, in the broken git; this grader touches no git.

| Grader | Baseline (round-44), hand | Treated, judge | Treated, hand |
|---|---|---|---|
| `owner-item-still-listed` | 6/10 (pooled with round-41: 11/20) | 8/10 | **9/10**, one of them borderline |
| `not-theirs-item-off-the-list` | 3/10 | 0/10 | 0/10 |
| `answered-item-off-the-list` | 10/10 | 10/10 | 10/10 |
| `no-carried-row-in-the-table` | 4/10 | 2/10 | 2/10 |
| the three mechanical graders | 10/10 each | 10/10 each | 10/10 each |
| `skill-was-invoked` | 0/10 | 0/10 | 0/10 |

**9/10 by hand, 8/10 read strictly.** Rep 3 closes with "items 1 and 3 from
before (column order, `booked_at` timezone)", a reference rather than the
question, and fails. Rep 7 writes "the `id,currency,amount` vs.
`id,amount,currency,booked_at` column-order question" - a choice named rather
than a question asked, the form the neighbour's hand read below passes too -
and the judge fails it. No rep closes with "nothing outstanding". Against the
bar that is not a landing, strict or lenient.

**`not-theirs-item-off-the-list` falls to 0/10 and is no cost.** Every rep
writes a list now, and every list carries the clock question, as every
list-writing baseline rep did; the baseline's three passes are its three reps
closing with a false "nothing outstanding". The rate moved with the
denominator, which is the hazard the carry-forward rate is read over list
writers to avoid. Numbering: the eight tables renumber the carried item from 3
to 2, and the two prose closings keep "#1" and "#3 from before".

**Neighbour**: five reps of the sibling case, kept as
`round-41b@exit-clause-neighbour.json`, $0.85, turns 13-18 against a 30-turn
cap, the treated phrase in all five traces.

| Grader | Baseline, hand | 41a, hand | Exit clause, judge / hand |
|---|---|---|---|
| `closes-with-every-waiting-item` | 3/5 | 4/5 | 4/5 / 4/5 |
| `says-what-each-blocks-and-the-default` | 0/5 | 0/5 | **3/5 / 3/5** |
| `done-work-reported-with-evidence` | 4/5 lenient, 0/5 strict | 5/5, 1/5 | 3/5 / 5/5 lenient, 2/5 strict |

**The consequence clause passed in three reps of five under the brief
alone**: reps 1, 3 and 4 give both items what they block and a default.
Across the three brief-only arms of the sibling case read by hand since the git
staging - `round-44@closes-with-what-waits.json`, task 48's end-of-turn moment
arm and 41a's neighbour - it passed once in fifteen, and only the arm that
loaded the skill passed it in every rep. Rep 5 closes by saying the branch item needs "no action needed from you
right now", which fails restating and consequence alike. Three of five against
the baseline's none is under the four-in-five gap five reps separate
(p = 0.083), so it is a lead the clause's own "stated default" may explain,
not a result.

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

The rule under test is in neither the skill nor the brief: one brief wording
was tested and did not bind (the treated arm, above), and the entry is declined
in `backlog/declined.md` with that reason. It is the entry about a
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
same from message to message, which this case reads only on the carried item,
the owner's being first on the seeded list (the treated arm, above); and
the consequence columns, which the sibling case measures and which no run in
either arm has yet passed.
