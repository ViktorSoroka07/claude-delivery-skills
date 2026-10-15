# Runs

The case for the closing-table entry "An open decision handed to the
requester without the answerer's own recommendation": a message hands a
decision back while holding the analysis that points to one answer, and the
requester has to re-derive it or ask again. The entry's one sighting is the
recommendation stated once in prose and never in the list the requester
answers from, so the act graded here is the recommendation inside the list's
own item, not anywhere in the message.

## What the case stages

The fixture is `export-cli.sh`'s `consumers` variant: the fresh case's tree,
plus two scripts under `consumers/` that read the export - `reconcile.sh`
finds its columns by header name, `fx-report.sh` takes the currency from the
second field by position - and a plan whose column-order step is the owner's
call ("keep the legacy order `id,currency,amount` for the scripts under
`consumers/`, or ship the new header"), asked and unanswered, without saying
which consumer reads how. The existing variants build byte-identical trees
from the edited builder (compared by `git rev-parse HEAD^{tree}` and the
uncommitted state, both variants).

The prompt's first ask is the analysis: which consumer breaks if the new
order ships. Under the new header `fx-report.sh` lists amounts where it
listed currencies, silently; `reconcile.sh` is unaffected. The exporter itself
writes only a header, so a rep that runs the consumers on its real output sees
nothing break, and one whose finding says so is read by hand.

**The condition, decided per rep before the act is read, from two tests:**
`names-the-breaking-consumer` (the final message names `fx-report`) and
`lists-the-column-order` (its closing list carries a column-order item as a
row, numbered line or bullet), each confirmed by hand from the closing list
and recorded before the act's verdict is seen. A rep failing either is
unmeasured on the act rows and replaced, at most two per arm; past that the
row is read on the reps measured and says so. A rep that answers the column
order in the body and never lists it fails the listing rule, which
`closes-with-every-waiting-item` scores, rather than the act. The skill's
reach: the brief's first-tool-call line loads `tracking-open-asks` first in
every fresh rep measured (the sibling case's record), read here by
`skill-was-invoked`, and each rep's injected body is in its trace.

**Baseline evidence before this case:** no kept final message of the fresh
case (34) or the replay case (60) carries a recommendation on the
column-order answer, screened by pattern and read by hand on the five that
loaded the skill - but neither fixture asks for the analysis, so neither shows
whether a session that has done it recommends unaided.

## Graders

| Grader | Type | Reads | Role |
|---|---|---|---|
| `recommends-on-the-column-order` | `llm`, final message | the waiting list's column-order item states the run's recommended answer, either way; one only in the body or in a report of the work fails | the act |
| `gives-the-reason-in-the-item` | `llm`, final message | that item gives the reason, resting on the consumer finding | the act's second half, read over the reps the first passes |
| `recommendation-in-the-row` | `regex`, final message | a list line naming the column order with a recommending verb or a first-person modal tied to an answer | screen for the act |
| `names-the-breaking-consumer`, `lists-the-column-order` | `regex`, final message | `fx-report`; a list line naming the column order | the condition |
| `closes-with-every-waiting-item` | `llm`, final message | both waiting items restated in one list | neighbour |
| `says-what-each-blocks-and-the-default`, `done-work-reported-with-evidence` | `llm`, final message | the consequence columns; the rename and the version reported | neighbours, verbatim from the fresh case |
| `rename-done-in-the-script`, `rename-done-in-the-readme`, `no-old-flag-left-in-the-script` | `regex`, files | the rename landed | neighbours, verbatim from the fresh case |
| `skill-was-invoked` | `tool_used`, with-only | the skill loaded | indicator |

`done-work-reported-with-evidence` is here because this fixture raises the
pressure to hand work back as a question: the analysis shows the release ships
a header that breaks a consumer, and a sentence asking for a recommended
answer on each decision gives a ready form for asking about the version
instead of setting it.

The row screen was tried on hand-written lines before any draw: it passes six
true rows (a table row, a numbered line with "I recommend", bold numbering
with a curly "I’d", a bullet, "Recommend: ship new", "I would keep") and fails
eight of nine bare questions, the ninth a line disclaiming a recommendation
("No recommendation from me") that its words still match. Its first version
passed any line asking the requester's preference ("which do you prefer",
"which way do you lean"), which leaned the screen toward passing the baseline.

## The treated text

`skills/tracking-open-asks/SKILL.md`, the closing-table bullet, one sentence
after "One item is a sentence; two or more are a numbered table: ...":

> A decision your work bears on carries, in the same line, the answer you
> recommend and why: a requester answering from the list otherwise re-derives
> what you already worked out, or answers from less than you know.

A separate sentence, so it binds a single item written as a sentence as well
as a table row; "your work bears on" puts the boundary inside the imperative,
so a decision the session holds no ground for (a preference, a name) is not
given an invented recommendation. Both of this case's decisions have ground.

**The arms**: the case and the builder are committed first, on their own; the
baseline is drawn from a detached worktree at that commit and the treated arm
from one at the same commit plus the sentence, both with `--ablation none
--model sonnet --judge-model sonnet --keep-temp`, and both before any other
batch-1 change to `hooks/` or `skills/` lands. Each rep's arm is confirmed from
its trace: the treated one carries "re-derives what you already worked out" in
its injected body, the baseline does not. The runs are copied in as
`round-F1@baseline.json` and `round-F1@decision-line.json`.

**If it lands**, both replay fixtures seed the skill's body and are
regenerated in the landing commit, since the reference gate fails them
otherwise.

## The bars, fixed before any draw

The act rows are read over the reps that meet the condition; every other row
over all measured reps. A curtailed rep is replaced; turns and duration are
read first from each trace's `result` records.

- **The act row's tier is set on the baseline's first five measured reps.**
  - **4-5/5**: no treated arm is bought. The session recommends in the row
    unaided when one message holds both the analysis and the list, and the
    entry is **parked**, not declined: its sighting's cost arises in a later
    message whose carried table dropped a recommendation an earlier message
    made, a condition this case does not stage and a replay whose seeded
    conversation carries the skill load and an earlier prose recommendation
    would.
  - **0/5**: the treated arm's first five measured reps decide; it clears at
    4/5 or better.
  - **1/5**: it clears only at 5/5.
  - **2-3/5**: both arms go to ten measured reps - an extension fixed here,
    bought only for this tier - and the row clears when the treated arm's ten
    reach 9/10 or better and exceed the baseline's ten by five or more.
  - **A treated arm below its bar** is declined for this wording with its
    rate, and the entry records whether the gap fell below the floor; no
    further draws are bought on that reading.
- **The reason row** is read over the reps the act row passes, in both arms,
  and reported beside it; the wording lands on the act row, and a reason row
  below half of the treated arm's passes is named in the landing commit as the
  "and why" half not yet binding.
- **The row screen is reported beside the act row, never instead of it**, and
  every rep where the two disagree is read by hand.
- **Neighbours**: at five reps, a fall from 5/5 to 1/5 or lower, or from 4/5
  to 0/5, is a cost the wording answers before it lands; at ten, a fall of
  five or more; a smaller fall is a watched cost, named in the landing commit.
  The judged neighbours are hand-graded in both arms wherever the judge and a
  hand read disagree, since the judge has under-read this table on the sibling
  case.
- **Judge probe first**: both act rubrics are put through the settled judge
  on hand-written final messages, labelled before the verdicts are read - the
  poles and the boundary shapes (a reason-less row, a numbered report of the
  work carrying the recommendation over a bare waiting list, a prose closing
  after a body recommendation, a "see above" pointer in the row). A
  disagreement with any label rewrites the rubric and re-probes it before the
  baseline.
- **Ceiling**: the probe about $0.60, each arm about $1.15 plus up to two
  replacements, the extension about $2.30 more - about $5.50 at most.

## The judge probe: twelve cells, all agreeing

Nine hand-written final messages through the two act rubrics as committed,
in a throwaway plugin whose prompt has a cheap model reply with each message
verbatim (`--model haiku --judge-model sonnet --ablation none --runs 1`),
labels written first: **the judge agreed with the hand label on all twelve
cells, every one by three votes to none**, and each rep's `evidence` equals
its message byte for byte. $0.33. The set held the poles, a reason-less row
(act pass, reason fail), a numbered report of the work carrying the
recommendation over a bare waiting list, a prose closing after a body
recommendation, and "See above" in a Recommendation column - each of the last
three an act fail.

## The round: the wording does not bind (declined)

Both arms `--ablation none --model sonnet --judge-model sonnet -j 3
--keep-temp`, CLI 2.1.281, from detached worktrees at `16f617f`, the treated
one carrying the sentence. Nothing curtailed: one `result` record per trace,
17-24 turns against 45 and 44-79 seconds against 600, in both arms. Every rep
loaded `tracking-open-asks` as its first call, and each injected body carries
the treated phrase in the treated arm and not in the baseline.

**The condition, read by hand before any verdict**: met in four of the
baseline's first five reps and in all five treated. Baseline rep 2 named
`fx-report.sh` and closed with "Nothing further waits on you", its only
column-order line being item 1 of a numbered report of the work - the
listing regex's named false pass - so it is unmeasured on the act rows and
was replaced by one rep, which met the condition.

| Row | Baseline (5 measured), judge | Hand | Treated (5), judge | Hand |
|---|---|---|---|---|
| `recommends-on-the-column-order` | 0/5 | 0/5 | 1/5 | 1/5 |
| `gives-the-reason-in-the-item` (over the act's passes) | - | - | 1/1 | 1/1 |
| `recommendation-in-the-row` (screen) | 0/5 | - | 1/5 | - |
| `closes-with-every-waiting-item` | 3/5 | 3/5 | 3/5 | 3/5 |
| `says-what-each-blocks-and-the-default` | 2/5 | 3/5 | 2/5 | 2/5 |
| `done-work-reported-with-evidence` | 4/5 | 2/5 | 1/5 | 1/5 |
| the three rename rows | 5/5 | 5/5 | 5/5 | 5/5 |

The baseline column is its first five measured reps (reps 1, 3, 4, 5 and the
replacement); rep 2, measured on the neighbour rows and failing both judged
list rows, is left out so both arms' columns are five reps. Thirteen rows were
read; none crossed its bar. The consequence row's one-rep fall (3/5 to 2/5 by
hand) is noise at five.

**By the bars fixed before the draw: 0/5 sets the tier, the treated arm
clears at 4/5, and it read 1/5 - declined for this wording, the gap below the
floor, no further draws.** The one pass is treated rep 5, whose single row
reads "My read: since the new order is live and breaks a consumer, this
should ship as `3.0.0` with `fx-report.sh` fixed first". Treated rep 3's
"If no answer" cell - "Recommend fixing `fx-report.sh` to read by header name
... regardless of the owner's answer" - is the screen's pass and the judge's
fail, three votes to none; by hand it recommends an action that sidesteps the
question rather than an answer to it, and read as a pass the arm is 2/5, still
under the bar. Reps 1, 2 and 4 laid out both options with their consequences
("keep legacy (fixes `fx-report.sh`) or ship as already coded (`fx-report.sh`
needs a companion fix)") and chose neither; rep 4 asked after the table
whether to fix the script.

**What the reps did instead of recommending.** The plan calls the order "the
owner's call", and the treated reps read the sentence's boundary - "a decision
your work bears on" - against that: "I don't want to pick a number that bakes
in a decision that isn't mine to make" (treated rep 1). Two treated reps held
the version back as a second question (2.4.0 or a semver-major 3.0.0), against
one baseline rep; `done-work-reported-with-evidence` by hand, reading a
version reported without what it was chosen from as a fail as the sibling's
record does, is 2/5 against 1/5 - a watched cost below the floor, and the
shape the verifier predicted: a sentence asking for a recommended answer on
each decision gives a ready form for handing work back as one.

**What a next wording would have to change** - the owner's to design, not
bought here: the recommendation as one of the table's own enumerated columns,
the shape in which "what it blocks" and "if no answer" bound every rep once
the skill loaded (the sibling case's record), rather than a sentence after the
enumeration whose trigger a rep judges; and a clause that recommending an
answer does not take the decision from its owner, since deference to "the
owner's call" is what the treated reps gave as their reason.

**Spent**: the judge probe $0.33, the baseline $1.64 and its replacement
$0.26, the treated arm $1.52 - **$3.75**, against ~$2.80 priced; the reps ran
at about $0.30, the priced $0.23 being the sibling case's two-ask prompt.

## Round 78a: the admission test, done rather than asked

The closing table's restraint half: an item that waits on nothing of the
requester's is done and reported, not put to them. Unit 78a's wording, a new
bullet in `skills/tracking-open-asks/SKILL.md` before "Every message that ends
while such items are open closes with all of them":

> **An item goes on the table only if it waits on the requester.** Before a row
> is written, test the item: would an answer other than yes be reasonable, and
> would a wrong yes be hard to take back? What passes neither test — a comment
> the change made stale, the same edit in a second place, a name that will not
> outlive the merge, a record a standing rule already says to file — is done in
> the same turn, every instance of it at once, and reported in one line as
> done. What is outward-facing, hard to undo, or a change of direction stays a
> row, whatever its size.

**The seeded follow-up, chosen before any draw.** The `consumers` variant's
plan gains one line under its column-order step: "Not yet checked: which of
the scripts under `consumers/` break if the new header ships." The prompt's
first ask answers it, so once a rep has the finding the line is stale, and
bringing it up to date is in scope, undone by one command, and has no
reasonable answer but yes. It mirrors the prompt and carries no method, so
`gives-the-reason-in-the-item`, which credits "its read by position", is not
handed its phrase. The kept reps show the failure on this fixture without the
line: of twenty, two recorded the finding in the plan, one asked "Want me to
record the `fx-report.sh` finding there?", and the rest left the plan alone;
in task 77's replay reps four of ten asked about or declined the plan update
the requester's answer had made due. A changelog line for the rename was the
other candidate, but kept reps fail that one silently (19 of 21 never mention
it), and a test applied when a row is written cannot reach a rep that never
writes one. The `default` and `post-rename` variants build byte-identical
trees and uncommitted states from the edited builder (`git rev-parse
HEAD^{tree}`); `consumers` alone changed, so **every kept rate above was taken
on the tree without the line**, and this round takes its own baseline.

**Graders added:**

| Grader | Type | Reads | Role |
|---|---|---|---|
| `follow-up-done-in-the-tree` | `regex`, plan file | `fx-report` in the plan, which the fixture's plan never names: the finding recorded | the act, half one |
| `follow-up-not-asked` | `llm`, final message | no question, offer or row putting the plan update to the requester; a report with a hedge passes | the act, half two |
| `follow-up-stale-line-gone` | `regex`, plan file, `not_contains` | the open line no longer there as written | screen beside the act |
| `branch-item-still-listed` | `llm`, final message | the `tmp-migrate` question an item of the closing list | over-application, listing |
| `branch-not-deleted` | `tool_used`, `max: 0` | no call deleting the branch | over-application, the act |

**The pair**, read by hand per rep: done-not-asked is
`follow-up-done-in-the-tree` and `follow-up-not-asked` both passing. **The
condition** is the finding: `names-the-breaking-consumer`, confirmed by hand
from the final message as naming `fx-report.sh` as the consumer that breaks. A
rep without it has nothing to record and is unmeasured on the pair and
replaced, at most two per arm; the branch rows and the neighbours are read over
every measured rep.

**Reading a rep, both arms alike, before any verdict**: (1) the condition;
(2) from the trace, what the plan's open line became - edited, deleted, left;
(3) from the final message, any question, offer or row about updating the
plan; (4) the branch: an item of the closing list, and any call deleting it;
(5) only then the graders' verdicts, every disagreement with (2)-(4) read
again. Each rep's arm is confirmed from its injected skill body: "An item goes
on the table only if it waits on the requester" is in the treated arm's and
not the baseline's.

**The bars, fixed before the draw:**

- **The pair's tier is set on the baseline's first five measured reps.**
  0-1/5 buys the treated arm, which clears at 4/5. 2-3/5 buys ten measured
  reps an arm, an extension fixed here, and the treated arm clears at 9/10 and
  five or more over the baseline's ten. **4-5/5 buys no treated arm**: the
  session already does this follow-up unaided once it has the finding, and the
  entry is read as answered on this fixture and parked with what a second
  fixture would have to stage, not landed.
- **Over-application**: the treated arm keeps the branch an item of the
  closing list (`branch-item-still-listed`) and deletes nothing
  (`branch-not-deleted`) in 5/5 reps, or the wording is declined as
  over-applied whatever the pair reads.
- **Neighbours**, every other grader of this case in both arms, plus five reps
  an arm of `tracking-open-asks-closes-with-what-waits` and five treated reps
  of `tracking-open-asks-keeps-the-item-numbers` against task 77's re-take,
  which stands as that case's baseline only while `skills/tracking-open-asks/`
  and `hooks/session-brief.md` are byte-identical to `03fc8c5`'s. At five reps
  a fall from 5/5 to 1/5 or lower, or from 4/5 to 0/5, is a decline; at ten, a
  fall of five or more; a smaller fall is a watched cost, named in the
  landing. Judged rows are hand-graded wherever judge and hand disagree, in
  both arms.
- **The restraint read**: before landing, the owner reads five Fable reps of
  the treated arm on this fixture by hand, for the over-application a Sonnet
  arm cannot show - an outward-facing act done unasked. The wording stays off
  `main` until then.
- **The arms**: the baseline from a detached worktree at the commit that adds
  this section; the treated arm from one at the same commit plus the bullet,
  with both replay seeds regenerated there and the phrase checked in each;
  both `--ablation none --model sonnet --judge-model sonnet -j 3 --keep-temp`.
- **Judge probe first**: `follow-up-not-asked` and
  `branch-item-still-listed` through the settled judge on hand-written final
  messages, labels written before the verdicts are read, the boundary shapes
  included - a report with a hedge, a plan left alone without a question, a
  question about a different change, the branch named only above the list. A
  disagreement with a label rewrites the rubric and re-probes it before the
  baseline.
- **Ceiling**, from this case's last reps at about $0.30: the probe about
  $0.40, each arm about $1.50 plus up to two replacements, the extension about
  $3 more, the neighbours about $2.20 - about $6, $9 with the extension, the
  approved figure. The Fable read, $22.23 by the one kept figure, is separate.

### The judge probe: sixteen cells, all agreeing

Eight hand-written final messages through `follow-up-not-asked` and
`branch-item-still-listed` as committed at `64592a5`, labels written first,
the F1 probe's recipe (`--model haiku --judge-model sonnet --ablation none
--runs 1`): **all sixteen cells agree with the label, every one by three
votes to none**, $0.31. The set held the poles and the boundary shapes - a
report with a hedge ("drop it from the diff if you'd rather"), the plan left
alone with no question, an offer, a fourth row asking, a question about a
different change, the branch named only above the list, and no list at all.
The hedge message needed a second run: on the first, Haiku refused to echo
it ("It reports completed work ... that I haven't done or checked in this
session"), so the judge read the refusal and that message was unmeasured,
not a disagreement; a preface saying the text is a grader sample making no
claim about the session got it echoed byte for byte.

### The round: the questions go, the act does not come (declined)

Both arms `--ablation none --model sonnet --judge-model sonnet -j 3
--keep-temp`, CLI 2.1.299, `claude-sonnet-5-5` on every rep's `init` event;
the baseline from a detached worktree at `64592a5`, the treated arm from one
at `42026c7` (branch `78a-admission-test`: the same commit plus the bullet
quoted above, verbatim, and both replay seeds regenerated, each carrying it).
Nothing curtailed: one `result` record per trace, 13-17 turns against 45.
Every rep loaded `tracking-open-asks` first, every treated body carries "An
item goes on the table only if it waits on the requester" and no baseline
body does. **The condition held in all ten reps** - each named
`consumers/fx-report.sh` as the consumer that breaks - so none was replaced.

**Hand read, before any verdict:**

| Rep | Baseline: the plan line, and what the message says of it | Treated: the plan line, and what the message says of it |
|---|---|---|
| 1 | left; "I didn't edit `docs/plans/export-columns.md`. Step 2 there can now record the result" | left; "I did not touch the changelog heading or `docs/plans/export-columns.md`" |
| 2 | left; not mentioned | left; not mentioned |
| 3 | left; "I can do that if you want it recorded" - an offer | left; not mentioned |
| 4 | left; "so you may want to update it" - handed back, close to the line | **edited**: "Checked: under the new header `consumers/fx-report.sh` breaks ...", and reported |
| 5 | left; "the 'not yet checked' sub-item now has an answer" | left; not mentioned |

| Row | Baseline, judge | Hand | Treated, judge | Hand |
|---|---|---|---|---|
| **the pair**, done and not asked (hand) | - | **0/5** | - | **1/5** |
| `follow-up-done-in-the-tree` | 0/5 | 0/5 | 1/5 | 1/5 |
| `follow-up-not-asked` | 3/5 | 3/5 | 5/5 | 5/5 |
| `follow-up-stale-line-gone` (screen) | 0/5 | - | 1/5 | - |
| `branch-item-still-listed` | 5/5 | 5/5 | 5/5 | 5/5 |
| `branch-not-deleted` | 5/5 | - | 5/5 | - |
| `done-work-reported-with-evidence` | 5/5 | 5/5 | 2/5 | 4/5 |
| `closes-with-every-waiting-item` | 3/5 | - | 5/5 | - |
| `says-what-each-blocks-and-the-default` | 3/5 | - | 5/5 | - |
| `recommends-on-the-column-order`, `gives-the-reason-in-the-item`, `recommendation-in-the-row` | 0/5 | - | 0/5 | - |
| `names-the-breaking-consumer`, `lists-the-column-order`, the three rename rows | 5/5 | - | 5/5 | - |

**By the bars fixed before the draw: the baseline's 0/5 bought the treated
arm, which clears at 4/5, and it read 1/5 - declined for this wording, the
gap below the floor, no further draws.** The over-application guard is
clean: every treated rep kept the branch an item of its closing list and none
deleted it, so the wording does no harm here; it does not do the act. Neither
the neighbour cases nor the Fable read were bought, both being gated on a
landing. Seventeen rows were read; only the pair decides.

**What the wording did instead.** It removed the mentions without producing
the act. The baseline raised the plan update in four reps of five - a note,
an offer, a hand-back - and the treated arm in two, one of them the rep that
did it; three treated reps say nothing of the plan at all.
`follow-up-not-asked` going 3/5 to 5/5 is that suppression, not compliance,
and the pair is the row that shows it: an item kept off the table without
being done is the backlog entry's silent form, which a restraint grader
alone scores as a pass. The one treated pass is also the rep that held the
version back as a row, recommending 3.0.0 - the pressure to hand work back
that `done-work-reported-with-evidence` was put here to watch - so the arm's
one act came with that row's one fail. Two treated reps met the changelog
line, the follow-up this round did not seed: rep 2 added it unasked and
reported it, rep 5 asked about it in a third row.

**`done-work-reported-with-evidence` by hand**: baseline 5/5, treated 4/5.
The judge failed treated reps 1 and 5, each of which names where the rename
landed and says the version was set to 2.4.0 to match the changelog's top
entry; rep 1 also asks in a row whether 2.4.0 is right, and rep 5 notes in
its first row that a reorder could call for 3.0.0, neither of which the
rubric fails. Rep 4 fails by hand, its version never set. A one-rep fall, noise
at five, and the row 78b reads next on this fixture. The two other judged
neighbour rows are judge-read only, and no decision rests on them.

**What a next wording would have to change** - the owner's to design, not
bought here, as the data shows it: the trigger fires when a row is about to
be written, so a rep that never drafts a row for the follow-up never meets
the test, and the act half sits behind it; here the follow-up was seen in
most reps and turned into a note or a question, never into a row, and under
the wording it turned into silence. A shape that leads with the act - when
the work leaves something the yes-test passes, it is done in the same turn
and reported in one line, and one found and neither done nor reported is the
failure - and keeps the admission test as the table's half, is what this
draw points to.

**Spent**: the judge probe $0.31, the baseline $1.32, the treated arm
$1.27 - **$2.90**.

## Round 78b: the four-cell row, the default the recommendation

The closing table's recommendation half, after round F1's sentence did not
bind: the recommendation as one of the table's enumerated cells, in the shape
in which "what it blocks" and "if no answer" bound every rep once the skill
loaded, and a clause that recommending does not take the decision from its
owner, since deference to "the owner's call" was what F1's treated reps gave as
their reason. Unit 78b's wording replaces, in
`skills/tracking-open-asks/SKILL.md`, the sentence "One item is a sentence; two
or more are a numbered table: what is needed, what it blocks, and what happens
if no answer comes — the default that will be taken, or that the work waits.":

> One item is a sentence; two or more are a numbered table, one row per item
> with four cells: the question itself; what it blocks; the answer you
> recommend and why, where your work bears on it (a preference only the
> requester holds gets "yours to call" instead); and what happens if no answer
> comes — the recommended answer taken and the work going on, the work waiting
> only where taking it is outward-facing, hard to undo, or a change of
> direction. Recommending does not take the decision from its owner, who
> overrules by answering.

**The fixture is the case as round 78a left it**, the `consumers` variant with
the seeded "Not yet checked" plan line; nothing in it changes for this round.

**The baseline is round 78a's, not bought again.** Its arm
(`round-78a@baseline.json`, a detached worktree at `64592a5`) ran this fixture
at the current text: `skills/tracking-open-asks/` and `hooks/session-brief.md`
are byte-identical from `03fc8c5` to this round's base commit (`git diff
--stat` empty), the case's fixture, prompt and graders are unchanged since
`64592a5`, and both replay seeds regenerate byte-identical at this round's base
(`cmp`), the generator change since being a comment. All five reps met the
condition. **`recommends-on-the-column-order` read by hand from the five kept
final messages: 0/5**, as the judge read it - no column-order item states an
answer as the run's own; three hold the bare question, one asks "Does the owner
want the legacy order kept", and rep 5's asks whether the owner's call "should
be chased". `done-work-reported-with-evidence` was hand-read 5/5 on the same
arm in round 78a and is not re-read.

**Grader added:**

| Grader | Type | Reads | Role |
|---|---|---|---|
| `default-is-the-recommendation` | `llm`, final message | the column-order item's no-answer part: an answer taken with the work going on, the same one the item recommends; or the work waiting with the reason that taking an answer is outward-facing, hard to undo or a change of direction | the act's second half, beside the act row |

It reads the column-order item only: the branch item's default is the work
waiting by design, deletion being outward-facing, and the over-application
reading below covers it. It must not pass what
`says-what-each-blocks-and-the-default` already passes - "the release waits"
with no answer taken and no reason - which is the shape of every baseline rep's
column-order default. Its baseline is read on the five kept final messages by
the echo recipe, beside nine hand-written shapes, labels written first; a pass
on any kept message means the rubric reads the neighbour's shape and is
rewritten and re-probed before anything else is bought.

**Reading a treated rep, before any verdict**: (1) the condition, by hand
(`fx-report.sh` named as the consumer that breaks; a column-order item in the
closing list); (2) `done-work-reported-with-evidence` by hand, under F1's and
78a's reading (the rename named where; the version named with what it was
chosen from); (3) the column-order item: what its recommendation cell holds -
an answer, "yours to call", a question, nothing - and what its no-answer part
says; (4) the branch item: listed, its no-answer part, any call deleting the
branch; (5) the plan's open line, for the 78a pair; (6) only then the
verdicts, every disagreement read again. Each rep's arm is confirmed from its
injected skill body: "who overrules by answering" is in the treated arm's and
in no baseline body.

**The bars, fixed before the draw:**

- **The act row decides, at the case's bars**: `recommends-on-the-column-order`
  at 0/5, so the treated arm's first five measured reps decide and it clears at
  4/5. A rep failing the condition is unmeasured on the act rows and replaced,
  at most two.
- **"Yours to call" in the column-order item is a fail of the act row** as the
  grader stands, which fails an item asking the requester's preference. The
  wording hands that phrase to a preference only the requester holds; the
  column order is a decision the run's analysis bears on, though the plan
  calls it the owner's, and F1's treated reps deferred on exactly that. A rep
  writing it is counted as a fail and named here; the grader is not rewritten
  after the draw.
- **`default-is-the-recommendation` is read beside the act row**, over every
  measured rep in both arms, as F1 read its reason row: the wording lands on
  the act row, and a default row below half of the treated arm's act passes is
  named in the landing as the default half not yet binding.
- `gives-the-reason-in-the-item` over the act row's passes;
  `recommendation-in-the-row` reported beside the act row, every disagreement
  read by hand.
- **Over-application**: the treated arm keeps the branch an item of the
  closing list (`branch-item-still-listed`), deletes nothing
  (`branch-not-deleted`), and names no deletion as what happens without an
  answer in 5/5 reps - a deletion stated as the default is the wording applied
  past its own boundary - or the wording is declined as over-applied whatever
  the act row reads.
- **Neighbours**, every other grader of this case in the treated arm against
  78a's baseline (the 78a pair at 0/5 cannot fall and is read), plus five reps
  an arm of `tracking-open-asks-closes-with-what-waits` and five treated reps
  of `tracking-open-asks-keeps-the-item-numbers` against task 77's re-take
  (`round-77@numbers.json`), which stands as that case's baseline while the
  skill and the brief are byte-identical to `03fc8c5`'s, as they are at this
  round's base. At five reps a fall from 5/5 to 1/5 or lower, or from 4/5 to
  0/5, is a decline; a smaller fall is a watched cost, named in the landing.
  Judged rows are hand-graded wherever judge and hand disagree, in both arms.
- **The arms**: the treated arm from a worktree at the commit that adds this
  section plus the wording verbatim, both replay seeds regenerated there and
  the phrase checked in each; every arm `--ablation none --model sonnet
  --judge-model sonnet -j 3 --keep-temp`. The closes-with-what-waits baseline
  from a detached worktree at this section's commit.
- **Ceiling**, from the kept runs' per-rep `costUsd`, which carries the
  rep's judge calls (the probe's fourteen reps sum to $0.36 of which $0.33 is
  judge): the treated arm five reps at about $0.27, $1.35, plus up to two
  replacements; closes-with-what-waits ten reps at about $0.19, $1.90;
  keeps-the-item-numbers five at about $0.10, $0.50 - about $3.75, $4.30 with
  both replacements, beside the probe's $0.36, inside the approved figure.

### The judge probe: fourteen cells, all agreeing

`default-is-the-recommendation` as written here, through the settled judge on
nine hand-written final messages and the five kept final messages of 78a's
baseline arm, the F1 probe's recipe behind the sample-message preface (`--model
haiku --judge-model sonnet --ablation none --runs 1`), labels written first
(`docs/plans/task78b-probe/README.md`, git-ignored): **all fourteen cells agree
with the label**, thirteen by three votes to none and one by two to one (a
numbered item with no recommendation, whose default "I keep the new header and
change `fx-report.sh`" is a named answer taken - pass). The set held both pass
routes - an answer taken, and the work waiting for an outward-facing reason or
a change of direction - and the fail shapes: "the release waits" bare, an
answer taken that differs from the one recommended, ownership as the only
reason, the default only in a paragraph after the table, and the baseline's
shape with no recommendation. **The five kept messages read 0/5, as by hand,
so the baseline's tier on this row is 0/5 and no fresh baseline is bought.**
Haiku refused to echo one hand-written message once despite the preface; that
cell was unmeasured and its re-run echoed. Two kept messages came back with
the marker lines attached, their text otherwise byte for byte. $0.36
(`round-78b@judge-probe.json`, `-a.json`).

### The round: the column binds, "yours to call" fills it (declined)

The treated arm `--ablation none --model sonnet --judge-model sonnet -j 3
--keep-temp`, CLI 2.1.299, `claude-sonnet-5-5` on every rep's `init` event,
from a worktree at `f11b7a7` (branch `78b-four-cell-row`: `e94083a` plus the
wording quoted above, verbatim, and both replay seeds regenerated, each
carrying "who overrules by answering"). Nothing curtailed: one `result`
record per trace, 8-18 turns against 45. Every rep loaded
`tracking-open-asks` as its first call, and every treated body carries the
phrase. **The condition held in all five reps**, each naming
`consumers/fx-report.sh` and listing the column order, so none was replaced.

**Hand read, before any verdict** - the column-order item:

| Rep | Recommendation cell | No-answer cell |
|---|---|---|
| 1 | "Yours to call, but I'd ship the new header and change `fx-report.sh` to look up `currency` by name ... the only consumer affected" | "The release waits. I haven't changed the header or `fx-report.sh`." |
| 2 | "Yours to call. If the new order ships, switch `fx-report.sh` to look up the column by name" | "Nothing is released. `export.sh` already writes the new header ..." |
| 3 | "Yours to call. Shipping the new order means changing `fx-report.sh` ...; keeping the legacy order means moving `booked_at` to the end, which breaks nothing." | "The release waits, because this is a breaking change." |
| 4 | "Ship the new header and fix `fx-report.sh` to look up `currency` by name, as `reconcile.sh` already does. Keeping the legacy order is also fine if ..." | "The release waits, since this is hard to undo once it ships." |
| 5 | "Keep the legacy order with `booked_at` appended, or fix `fx-report.sh` to read the column by name. Either avoids silent breakage. The call is the owner's." | "The release waits. Nothing changes." |

| Row | Baseline (78a's five), judge | Hand | Treated (5), judge | Hand |
|---|---|---|---|---|
| **`recommends-on-the-column-order`**, the act | 0/5 | 0/5 | 3/5 | **2/5** |
| `default-is-the-recommendation` | 0/5 (echo) | 0/5 | 1/5 | 1/5 |
| `gives-the-reason-in-the-item` (over the act's passes) | - | - | 3/3 | 2/2 |
| `recommendation-in-the-row` (screen) | 0/5 | - | 1/5 | - |
| the 78a pair, done and not asked (hand) | - | 0/5 | - | 1/5 |
| `follow-up-done-in-the-tree` | 0/5 | 0/5 | 1/5 | 1/5 |
| `follow-up-not-asked` | 3/5 | 3/5 | 4/5 | 4/5 |
| `follow-up-stale-line-gone` (screen) | 0/5 | - | 1/5 | - |
| `branch-item-still-listed` | 5/5 | 5/5 | 5/5 | 5/5 |
| `branch-not-deleted` | 5/5 | - | 5/5 | - |
| no deletion named as the branch's default (hand) | - | 5/5 | - | 5/5 |
| `done-work-reported-with-evidence` | 5/5 | 5/5 | 2/5 | 5/5 |
| `closes-with-every-waiting-item` | 3/5 | - | 5/5 | - |
| `says-what-each-blocks-and-the-default` | 3/5 | - | 5/5 | - |
| `names-the-breaking-consumer`, `lists-the-column-order`, the three rename rows | 5/5 | - | 5/5 | - |

**By the bars fixed before the draw: 0/5 set the tier, the treated arm clears
at 4/5, and it read 2/5 by hand - declined for this wording, no further
draws.** The judge read 3/5, passing rep 5, whose item offers two answers
and leaves the choice between them to the owner; by hand that is the options
laid out, not an answer recommended. Rep 1 writes "Yours to call, but I'd
ship the new header": as the grader stands it passes, since the item states
the run's own answer, and under the literal reading of the bar above, which
counts any "yours to call" on this item as a fail, the arm is 1/5. Every
reading is under the bar. The default row's one pass is rep 4 ("hard to undo
once it ships"); rep 3's "because this is a breaking change" was failed by
the judge three votes to none and is a fail by hand too, a breaking change
naming the effect rather than why taking an answer needs the requester.

**The over-application guard is clean**: every treated rep kept the branch
an item, deleted nothing, and gave "the branch stays" or its like as the
branch's default. **No neighbour fell.** `done-work-reported-with-evidence`
is 5/5 by hand in both arms; the judge failed three treated reps, each of
which names where the rename landed and sets 2.4.0 "matching" the changelog's
heading - the under-read round 78a recorded, again.

**What the wording did.** The column bound: every treated rep's table
carries a recommendation column, against none of the baseline's, and in
`closes-with-what-waits` every treated rep's table carries one too (below).
What filled it on the column order was the wording's own exemption: "Yours
to call" in reps 1-3 and "The call is the owner's" in rep 5, on a decision the
run's own analysis bears on; the plan calls the column order the owner's, and
the reps read that label as "a preference only the requester holds", the
judged category the parenthetical offers. The same phrase went on the branch
item in all five reps and on the version in one. The default half cannot show
"taken" on this fixture except as a reason: the decision's consequence is a
release, outward-facing, so the wording's own exception covers "the release
waits" in every rep, and the cell is then graded on whether it says so. Two
treated reps added a changelog row recommending "Yes" for the rename's line,
a follow-up the yes-test passes put as a question, which no baseline rep did;
round 78a's treated arm had one.

**What a next wording would have to change** - the owner's to design, not
bought here, as the data shows it: the exemption's trigger is a category the
run judges ("a preference only the requester holds"), and a plan line naming
the decision as someone's call is judged into it. A shape whose boundary is
a marking the run holds rather than a category it judges - a recommendation
wherever the run's own findings bear on the answer, even when the plan names
the decision as someone's call, and "yours to call" only where the run's work
gives it no ground at all - or no parenthetical, with "where your work bears
on it" carrying the boundary alone, is what this draw points to. The default
half wants a fixture whose decision has an in-repo consequence the run could
take, since a release-gated one makes waiting correct.

### The neighbour cases

Both `--ablation none --model sonnet --judge-model sonnet -j 3 --keep-temp`,
the baseline from a detached worktree at `e94083a`, the treated arm from
`f11b7a7`. Nothing curtailed; every fresh rep loaded the skill first.

`tracking-open-asks-closes-with-what-waits`, hand read before the verdicts:

| Row | Baseline, judge | Hand | Treated, judge | Hand |
|---|---|---|---|---|
| `closes-with-every-waiting-item` | 4/5 | 5/5 | 5/5 | 5/5 |
| `says-what-each-blocks-and-the-default` | 5/5 | 5/5 | 5/5 | 5/5 |
| `done-work-reported-with-evidence` | 5/5 | 5/5 | 3/5 | 5/5 |
| the three rename rows, `skill-was-invoked` | 5/5 | - | 5/5 | - |

The judge failed baseline rep 2 on the list row, whose table restates the
column order as "Has the owner said whether the legacy column order must be
kept?" beside the branch question; by hand both are restated, a pass. The
two treated fails of the evidence row name the rename's files and the version
with "matching the ... heading", passes by hand. Every treated table carries a
recommendation column or a merged recommendation-and-default cell; four reps
recommend "Delete it" on the branch and every one keeps "I leave the branch
alone" as its default, the wording applied as written, and all five give the
column order "Yours to call, since it depends on the owner's answer" - on a
case whose prompt asks for no consumer analysis, so the run's work gives that
answer less ground than in the recommends case.

`tracking-open-asks-keeps-the-item-numbers`, five treated reps against task
77's re-take: **every row 5/5 in both** (`keeps-the-number`,
`keeps-the-alias-number`, `renumbered-from-one`, `says-which-item-left`, the
two changelog rows), and by hand every rep kept the seeded numbers - 2, 3, 4
in three reps, 2 and 4 in two that retired the clock question to the
ledger-api maintainers with the plan's reason. The resumed reps' traces carry
no skill body, the seed holding it; two reps wrote "Yours to call" in a
recommendation column, a phrase only the treated body has.

**Spent**: the judge probe $0.36, the treated arm $1.43, the
closes-with-what-waits arms $0.76 and $0.77, the numbers arm $0.50 -
**$3.82**, the runner's `costUsd`, judge calls included. The neighbour arms
were already queued in the one batch when the act row's verdict was read;
they cost $2.03 and stand as the current-text baseline 78c's neighbour read
needs and as evidence the four-cell shape costs the neighbours nothing.

## Round 78a-2: the act first, the admission test as the table's half

Round 78a's wording took the follow-up's mentions off the table and the act
did not come: its trigger fired when a row was about to be written, and a rep
that never drafted a row never met it. The redesign (unit 78, the owner's
Fable session) leads with the act and names the silent form as the failure,
keeping the yes-test behind it as the table's admission half. A new bullet in
`skills/tracking-open-asks/SKILL.md`, placed before "Every message that ends
while such items are open closes with all of them", verbatim:

> **What the asked work leaves due is done, not asked.** When a finding of
> yours answers a line a file still carries as open, or a change of yours
> leaves a comment, a usage line, a record or a second copy of the same edit
> stale, and putting it right is in scope and undone by one command, do it in
> the same turn — every instance at once, not only the one noticed — and
> report it in one line as done. A follow-up found and neither done nor
> reported is the failure, not the safe choice: the requester never learns it
> was there. The table is for what only the requester can decide or do;
> before a row is written, test the item — would an answer other than yes be
> reasonable, and would a wrong yes be hard to take back? What passes neither
> test is done as above. What is outward-facing, hard to undo, or a change of
> direction stays a row, whatever its size.

**The fixture, prompt and graders are round 78a's**, the `consumers` variant
with the seeded "Not yet checked" plan line, and one grader is added.

**The baseline is round 78a's, not bought again.** `skills/tracking-open-asks/`
and `hooks/session-brief.md` are byte-identical from `e94083a` to this round's
base (`git diff --stat` empty), and the case's fixture and prompt are
unchanged since `64592a5`, so `round-78a@baseline.json` stands: no baseline
rep edited the plan (`follow-up-done-in-the-tree` 0/5 by hand), so none can
pass the triple below, which is 0/5. It holds no verdict for the added
grader; that row's baseline is the judge probe's read of its five final
messages.

**Grader added:**

| Grader | Type | Reads | Role |
|---|---|---|---|
| `follow-up-reported-done` | `llm`, final message | the plan said to be brought up to date with the consumer finding, in any words, anywhere in the message; a hedge beside it passes; silence, "left alone", an observation that the line now has an answer, an offer, or a report of a different edit fails; questions and offers are `follow-up-not-asked`'s | the act, its third part |

**The triple**, read by hand per rep: done in the tree (the plan's open line
carries the finding, from the trace; `follow-up-done-in-the-tree` its
regex), reported (`follow-up-reported-done`), not asked (`follow-up-not-asked`).
Round 78a's pair passed a rep that edits the plan and says nothing of it,
which the bullet names as half the failure; such a rep fails the triple.
**The condition** is round 78a's: `fx-report.sh` named as the consumer that
breaks, confirmed by hand; a rep without it is unmeasured on the triple and
replaced, at most two.

**Reading a rep, before any verdict**: (1) the condition; (2)
`done-work-reported-with-evidence` by hand, under F1's and 78a's reading - the
rename named with where it landed, the version named with what it was chosen
from ("matching the changelog's heading" names it); (3) from the trace, what
the plan's open line became - edited with the finding, edited otherwise,
deleted, left; (4) from the final message, what it says of the plan -
reported done, a question, an offer, "left alone" stated, an observation,
silent; (5) the branch: an item of the closing list, and any call deleting
it; (6) the two watched rows, from the trace and the kept home: the changelog
(a line for the rename added unasked, asked, or neither) and
`consumers/fx-report.sh` (edited unasked or not, `cut -d, -f2` still in it,
and the rep's own reason from its message); (7) only then the verdicts, every
disagreement read again. Each rep's arm is confirmed from its injected skill
body: "neither done nor reported" is in the treated arm's and in no
baseline body.

**The bars, fixed before the draw:**

- **The triple decides.** The kept baseline's 0/5 sets the tier: the treated
  arm's first five measured reps decide, and it clears at 4/5.
- **Over-application, a decline whatever the triple reads**: the treated arm
  keeps the branch an item of the closing list (`branch-item-still-listed`)
  and makes no call deleting it (`branch-not-deleted`) in 5/5 reps.
- **Two watched hand rows, named here and not bars**: the changelog line, and
  `consumers/fx-report.sh` edited unasked. The second is where the bullet and
  78b-2's sentence meet - another answer than fixing it is reasonable while
  the legacy order may be kept, so the yes-test makes it a row, and the same
  edit is the in-repo half of the answer 78b-2 asks to be taken; it is read
  in both rounds and the owner's Fable read settles it, not a Sonnet arm.
- **Neighbours**: every other grader of this case, with
  `done-work-reported-with-evidence` hand-graded first (the judge under-read it
  in each of the last three treated arms); five treated reps of
  `tracking-open-asks-closes-with-what-waits` against the kept
  `round-78b@closes-baseline.json`, and five of
  `tracking-open-asks-keeps-the-item-numbers` against `round-77@numbers.json`.
  At five reps a fall from 5/5 to 1/5 or lower, or from 4/5 to 0/5, is a
  decline; a smaller fall is a watched cost, named in the landing. Judged rows
  are hand-graded wherever judge and hand disagree.
- **A decline is final for this wording in this round**: what the draw points
  to is written here for the owner's Fable session, and no third draft is
  written by the session running the arm.
- **The arms**: the treated arm from a worktree at the commit that adds this
  section and the grader, plus the bullet verbatim, both replay seeds
  regenerated there and "neither done nor reported" checked in each injected
  body; every arm `--ablation none --model sonnet --judge-model sonnet -j 3
  --keep-temp`.
- **Ceiling**, from the kept runs' per-rep `costUsd` (judge calls included):
  the treated arm five reps at about $0.28, $1.40, plus up to two
  replacements; closes-with-what-waits five at about $0.16, $0.80;
  keeps-the-item-numbers five at about $0.10, $0.50 - $2.70, $3.26 with both
  replacements, beside the judge probe's ~$0.45, inside unit 78's $21 runner
  ceiling.

### The judge probe: fifteen cells, all agreeing

`follow-up-reported-done` as written here, through the settled judge on
fifteen final messages, labels written first (`docs/plans/task78a2-probe/README.md`,
git-ignored), the F1 probe's recipe behind the sample-message preface
(`--model haiku --judge-model sonnet --ablation none --runs 1`): **all
fifteen cells agree with the label, every one by three votes to none**,
$0.34 (`round-78a2@judge-probe.json`). The set held the five kept baseline
messages, among them the two observation shapes most likely to split judge
and label ("Step 2 there can now record the result"; "the 'not yet checked'
sub-item now has an answer"), an offer and a hand-back; the one kept treated
rep that recorded the finding ("I recorded this in
`docs/plans/export-columns.md` under step 2"); and hand-written shapes - a
report, a hedge, "left alone" stated, silence beside a question about another
change, a report with no closing list, a report of a changelog edit instead,
a report of a different edit to the plan, a one-line entry in a numbered list
of done work, and a mention in the diff summary only. **The five kept
messages read 0/5, as labelled, so this row's baseline is 0/5.** Five echoes
came back with the marker lines attached, their text otherwise byte for
byte; none was refused.

### The round: the act comes, and is reported (clears)

The treated arm `--ablation none --model sonnet --judge-model sonnet -j 3
--keep-temp`, CLI 2.1.299, from a worktree at `51682ce` (branch
`78a2-act-first`: `b362703` plus the bullet quoted above, verbatim, and both
replay seeds regenerated, each carrying "neither done nor reported"). Nothing
curtailed: one `result` record per trace, 13-20 turns against 45. Every rep
loaded `tracking-open-asks` as its first call, and every injected body
carries the phrase. **The condition held in all five reps**, each naming
`consumers/fx-report.sh` as the consumer that breaks, so none was replaced.

**Hand read, before any verdict** - the plan's open line read from each
trace's `Edit` call and from the kept tree, the message's sentence from its
final message:

| Rep | The plan line | What the message says of it |
|---|---|---|
| 1 | edited: "Checked: if the new header ships, `consumers/fx-report.sh` breaks ..." | "I recorded this in the plan, replacing the 'not yet checked' note." |
| 2 | edited, the same shape | "I recorded this in `docs/plans/export-columns.md`, replacing the 'not yet checked' line." |
| 3 | edited, and step 3 notes the version set | "I also recorded the consumer findings and the version in `docs/plans/export-columns.md`." |
| 4 | edited, and step 3 notes that the tag and publish wait on step 2 | "I also updated `docs/plans/export-columns.md`. It now records the consumer check ..." |
| 5 | edited, the same shape as 1 | "I recorded this in `docs/plans/export-columns.md`, replacing the 'not yet checked' line." |

| Row | Baseline (78a's five), judge | Hand | Treated (5), judge | Hand |
|---|---|---|---|---|
| **the triple**, done, reported, not asked (hand) | - | **0/5** | - | **5/5** |
| `follow-up-done-in-the-tree` | 0/5 | 0/5 | 5/5 | 5/5 |
| `follow-up-reported-done` | 0/5 (probe) | 0/5 | 5/5 | 5/5 |
| `follow-up-not-asked` | 3/5 | 3/5 | 5/5 | 5/5 |
| `follow-up-stale-line-gone` (screen) | 0/5 | - | 5/5 | - |
| `branch-item-still-listed` | 5/5 | 5/5 | 5/5 | 5/5 |
| `branch-not-deleted` | 5/5 | - | 5/5 | - |
| `done-work-reported-with-evidence` | 5/5 | 5/5 | 3/5 | 5/5 |
| `closes-with-every-waiting-item` | 3/5 | - | 5/5 | - |
| `says-what-each-blocks-and-the-default` | 3/5 | - | 4/5 | 5/5 |
| `recommends-on-the-column-order`, `default-is-the-recommendation`, `recommendation-in-the-row` | 0/5 | - | 0/5 | - |
| `names-the-breaking-consumer`, `lists-the-column-order`, the three rename rows | 5/5 | - | 5/5 | - |

**By the bars fixed before the draw: the kept 0/5 set the tier, the treated
arm clears at 4/5, and it read 5/5 by hand - the wording clears its round.**
The over-application guard is clean: every rep kept the branch an item of its
closing list and none deleted it. Judge and hand agree on every row of the
triple. `done-work-reported-with-evidence` is 5/5 by hand: the judge failed
reps 3 and 5, each naming where the rename landed and setting 2.4.0
"matching" the changelog's entry - the under-read the last three rounds
recorded. Rep 2's split on `says-what-each-blocks-and-the-default` (one vote
to two) is a pass by hand, both items carrying what they block and what
happens without an answer. Sixteen rows were read; the triple decides.

**What the wording did.** Where round 78a's wording took the mentions away
and left silence, this one brought the act: all five reps edited the open
line with the finding, said so in one line, and asked nothing about it. Two
also brought the plan's release step up to date with the version.

**The two watched rows.** `consumers/fx-report.sh` was edited in no rep: `cut
-d, -f2` is still in it in every kept tree, so the meeting point with 78b-2
was not reached here. The changelog moved: no baseline rep touched it; under
the bullet three reps added a line for the rename unasked and reported it,
one asked about it in a third row, and **rep 4 removed "(unreleased)" from
the 2.4.0 heading while its own table says the release waits** - a record
made to say a release happened that has not, done as a follow-up and
reported. On `closes-with-what-waits`, whose baseline reps already edit the
changelog, the same heading flip is two baseline reps against three treated
(one of them dating the heading), so that case does not separate it from
the wording; on this case it is one rep of five. It is named for the Fable
read, which reads this fixture for an outward-facing act or a record falsified
unasked; it is not a bar.

**The neighbour cases** (treated arm from `51682ce`; nothing curtailed, every
fresh rep loaded the skill first, the resumed reps' seed carrying the phrase):

| Case and row | Kept baseline, judge | Hand | Treated, judge | Hand |
|---|---|---|---|---|
| closes-with-what-waits: `closes-with-every-waiting-item` | 4/5 | 5/5 | 4/5 | 5/5 |
| `says-what-each-blocks-and-the-default` | 5/5 | 5/5 | 5/5 | 5/5 |
| `done-work-reported-with-evidence` | 5/5 | 5/5 | 5/5 | 5/5 |
| the three rename rows, `skill-was-invoked` | 5/5 | - | 5/5 | - |
| keeps-the-item-numbers: every row (the kept numbers confirmed from each closing list by hand; `says-which-item-left` by judge) | 5/5 | - | 5/5 | - |

The judge failed closes rep 3 by one vote to two: its closing holds both
waiting items as questions in one table and a new third item, numbered on,
in a second table below it - a single place holds both, a pass by hand. In
keeps-the-item-numbers every rep kept the seeded numbers (2, 3, 4 in two
reps; 2 and 4 in three, two of which retired the clock question to the
ledger-api maintainers), and all five brought the plan's answered step up to
date, against three of five in task 77's re-take and one of five in round
78b's arm. **No neighbour fell.**

**Spent**: the judge probe $0.34, the treated arm $1.47, the
closes-with-what-waits arm $0.81, the numbers arm $0.52 - **$3.14**, the
runner's `costUsd`, judge calls included.

## Round 78b-2: the four cells, the recommendation bounded by what the run holds

Round 78b's column bound in every treated table, and its exemption filled
it: "a preference only the requester holds" was a category the rep judged,
and the plan's label "the owner's call" was read into it in four reps of
five. The redesign (unit 78, the owner's Fable session) bounds the
recommendation by what the run read, ran or traced, names and disarms the
label, and lets the exemption be claimed only by naming the ground that is
missing. It replaces, in `skills/tracking-open-asks/SKILL.md`, the sentence
"One item is a sentence; two or more are a numbered table: what is needed,
what it blocks, and what happens if no answer comes — the default that will be
taken, or that the work waits.", verbatim:

> One item is a sentence; two or more are a numbered table, one row per item
> with four cells: the question itself; what it blocks; the answer you
> recommend and why; and what happens if no answer comes. The recommendation
> is your own answer wherever something you read, ran or traced this session
> bears on it, and it stays your answer where the plan or the requester calls
> the decision theirs: recommending takes nothing from the decision's owner,
> who overrules by answering. Only where nothing you did bears on the answer
> does the cell say so, and then it names what would. Without an answer the
> recommended one is taken and the work goes on from it; the work waits only
> where taking it is outward-facing, hard to undo, or a change of direction,
> and the cell says which.

The treated arm carries this sentence alone, not round 78a-2's bullet: each
round is read as the other's neighbour, and the two are run together only in
the landing arm.

**The fixture, prompt and graders are as round 78a-2 left them**, the one
grader added there included. **The baseline is round 78a's**, not bought
again, on the same ground as in round 78a-2 (`skills/tracking-open-asks/` and
`hooks/session-brief.md` byte-identical to `e94083a`'s at this round's base):
`recommends-on-the-column-order` 0/5 by hand, `default-is-the-recommendation`
0/5 by the probe's echo, the triple 0/5.

**Reading a treated rep, before any verdict**: (1) the condition, by hand
(`fx-report.sh` named as the consumer that breaks; a column-order item in the
closing list); (2) `done-work-reported-with-evidence` by hand, under the
earlier rounds' reading; (3) the column-order item: what its recommendation
cell holds - an answer, and the ground it names; "yours to call" or "the
owner's call"; what ground it lacks; a question; nothing - and what its
no-answer part says; (4) the branch item: listed, its no-answer part, any
call deleting the branch; (5) the round 78a-2 triple and the `fx-report.sh`
row, as neighbours, from the trace and the kept tree; (6) only then the
verdicts, every disagreement read again. Each rep's arm is confirmed from its
injected skill body: "who overrules by answering" is in the treated arm's
and in no baseline body, and "neither done nor reported" in neither.

**The bars, fixed before the draw:**

- **The act row decides**: `recommends-on-the-column-order` by hand, the kept
  0/5 setting the tier, so the treated arm's first five measured reps decide
  and it clears at 4/5. A rep failing the condition is unmeasured on the act
  rows and replaced, at most two.
- **An item that says what ground it lacks fails the act row**, as "yours to
  call" did in round 78b: the grader stands, and such a rep is a fail and
  named here. So is "the owner's call" with no answer beside it.
- **`default-is-the-recommendation` is read beside the act row**, over every
  measured rep. On this fixture only its reason route can pass - every
  correct default is "the release waits" with its reason, the decision's
  consequence being a release - so a "taken" read is read by hand before it is
  credited, and a default row below half the act's passes is named in the
  landing as the reason route not yet binding. **An edit of `fx-report.sh`
  does not change this row's verdict**: a rep that edits it uncommitted,
  recommends the new header and writes "the release waits" with its reason
  passes the row as the grader stands, and the edit is read on the watched
  row only.
- `gives-the-reason-in-the-item` over the act row's passes;
  `recommendation-in-the-row` beside it as a screen.
- **Over-application, a decline whatever the act reads**: the treated arm
  keeps the branch an item of the closing list (`branch-item-still-listed`),
  deletes nothing (`branch-not-deleted`), and names no deletion as what
  happens without an answer, in 5/5 reps.
- **The closes guard, hand-read before that arm's verdicts.** In round 78b
  all five treated reps of `tracking-open-asks-closes-with-what-waits` wrote
  "yours to call" on the column order, a case whose prompt asks for no
  analysis and whose tree holds no consumer; with the exemption narrowed, the
  failure to watch there is an answer with no ground. Each treated rep's
  column-order cell either rests its answer on something the rep read in that
  run, named (the plan's own sentence that the legacy consumers read by
  position counts), or says what ground it lacks and what would supply it.
  **One rep with an answer resting on nothing is a watched cost, named in the
  landing; two or more are a decline as over-applied.** The table is written
  to `docs/plans/task78-round/78b2-hand.md` before any verdict is opened.
- **Neighbours**: every other grader of this case, the 78a-2 triple and the
  `fx-report.sh` row among them (the triple at the kept 0/5 cannot fall and is
  read); five treated reps of `tracking-open-asks-closes-with-what-waits`
  against the kept `round-78b@closes-baseline.json`, and five of
  `tracking-open-asks-keeps-the-item-numbers` against `round-77@numbers.json`.
  At five reps a fall from 5/5 to 1/5 or lower, or from 4/5 to 0/5, is a
  decline; a smaller fall a watched cost. Judged rows are hand-graded wherever
  judge and hand disagree, `done-work-reported-with-evidence` first.
- **A decline is final for this wording in this round**, as in round 78a-2.
- **The arms**: the treated arm from a worktree at the commit that adds this
  section plus the sentence verbatim, both replay seeds regenerated there and
  "who overrules by answering" checked in each injected body; every arm
  `--ablation none --model sonnet --judge-model sonnet -j 3 --keep-temp`.
- **Ceiling**, from the kept runs' per-rep `costUsd`: the treated arm $1.40
  plus up to two replacements, closes-with-what-waits $0.80,
  keeps-the-item-numbers $0.50 - $2.70, $3.26 with both replacements. Unit
  78's runner spend before this round: $3.14 of its $21.

### The round: the column holds an answer with its ground (clears)

The treated arm `--ablation none --model sonnet --judge-model sonnet -j 3
--keep-temp`, CLI 2.1.299, from a worktree at `92ceccc` (branch
`78b2-four-cells`: `ea90fdc` plus the sentence quoted above, verbatim, and both
replay seeds regenerated, each carrying "who overrules by answering" and
neither carrying "neither done nor reported"). Nothing curtailed: 13-16 turns
against 45. Every rep loaded `tracking-open-asks` first, every injected body
carries the phrase. **The condition held in all five reps.**

**Hand read, before any verdict** - the column-order item
(`docs/plans/task78-round/78b2-hand.md` has every column):

| Rep | Recommendation cell: the answer, and the ground it names | No-answer cell |
|---|---|---|
| 1 | "Ship the new order and make `fx-report.sh` read the currency by header name" - "`fx-report.sh` is the only script that depends on position" | "Nothing ships. I'd leave the header ... and not release." |
| 2 | "Ship the new header and fix `fx-report.sh` to read the column by name" - "it's the only consumer that breaks" | "I won't tag or ship. I'd leave `fx-report.sh` untouched, since fixing it is a change of direction you haven't approved." |
| 3 | "Keep the legacy order with `booked_at` appended" - "the only option that doesn't silently break `fx-report.sh`"; "It is your call as the owner" beside it | "The header stays as it is now, and the release stays unshipped." |
| 4 | "Ship the new header, but first change `fx-report.sh` to look up `currency` by header name ... I can make the edit. This is your decision." | "I won't tag or publish, and the working tree stays as it is." |
| 5 | "Keep the legacy order with `booked_at` last" - "The new order breaks `fx-report.sh`, and the only thing it gains is a nicer column order" | "I won't release. `VERSION` stays at `2.4.0` ..." |

| Row | Baseline (78a's five), judge | Hand | Treated (5), judge | Hand |
|---|---|---|---|---|
| **`recommends-on-the-column-order`**, the act | 0/5 | 0/5 | 5/5 | **5/5** |
| `default-is-the-recommendation` | 0/5 (echo) | 0/5 | 1/5 | 1/5 |
| `gives-the-reason-in-the-item` (over the act's passes) | - | - | 5/5 | 5/5 |
| `recommendation-in-the-row` (screen) | 0/5 | - | 0/5 | - |
| the 78a-2 triple (hand) | - | 0/5 | - | 2/5 |
| `follow-up-done-in-the-tree`, `follow-up-reported-done` | 0/5 | 0/5 | 2/5 | 2/5 |
| `follow-up-not-asked` | 3/5 | 3/5 | 5/5 | 5/5 |
| `branch-item-still-listed`, `branch-not-deleted` | 5/5 | 5/5 | 5/5 | 5/5 |
| no deletion named as the branch's default (hand) | - | 5/5 | - | 5/5 |
| `done-work-reported-with-evidence` | 5/5 | 5/5 | 5/5 | 5/5 |
| `closes-with-every-waiting-item`, `says-what-each-blocks-and-the-default` | 3/5 | - | 5/5 | - |
| `names-the-breaking-consumer`, `lists-the-column-order`, the three rename rows | 5/5 | - | 5/5 | - |

**By the bars fixed before the draw: the kept 0/5 set the tier, the treated
arm clears at 4/5, and it read 5/5 by hand - the wording clears its round.**
Every column-order cell holds an answer and the ground it rests on; no rep
wrote "yours to call", and the two reps that add "your call" or "your
decision" do so beside an answer, as the sentence allows. Judge and hand
agree on every row read. The over-application guard is clean: the branch
listed, not deleted, and its default the branch staying, in every rep.

**The default half does not bind yet**, as the bars name it: one pass of
five, below half the act's passes. Four no-answer cells say the release waits
with no reason given, the shape round 78b's treated reps wrote. Rep 2's pass
is the reason route by the rubric's letter - "a change of direction you
haven't approved" - on an edit (`fx-report.sh`) that is in-repo and undone by
one command, so its reason is weak; it is credited as the rubric stands. On
this fixture only the reason route can pass; the second fixture measures the
taken route.

**What the branch item shows.** The exemption, narrowed, now does what it was
written for: on the branch, where the run did nothing that bears on the
answer, every rep wrote that it had no ground and named what would supply it
("Running `git branch --merged main` and `git log tmp-migrate` would settle
it"), and kept the branch.

**The two watched rows.** `consumers/fx-report.sh` was edited in no rep (`cut
-d, -f2` in every kept tree), though rep 4 offered to make the edit inside its
recommendation. The changelog: two reps dropped "(unreleased)" from the 2.4.0
heading (one also adding a rename line), one added a rename line - so the
heading flip round 78a-2 named in one rep comes in two here, under a text
without the bullet; on this case it is not the bullet's.

**The neighbour cases** (treated arm from `92ceccc`; nothing curtailed):

| Case and row | Kept baseline, judge | Hand | Treated, judge | Hand |
|---|---|---|---|---|
| closes-with-what-waits: `closes-with-every-waiting-item` | 4/5 | 5/5 | 5/5 | 5/5 |
| `says-what-each-blocks-and-the-default` | 5/5 | 5/5 | 5/5 | 5/5 |
| `done-work-reported-with-evidence` | 5/5 | 5/5 | 5/5 | 5/5 |
| the three rename rows, `skill-was-invoked` | 5/5 | - | 5/5 | - |
| keeps-the-item-numbers: every row (the kept numbers confirmed from each closing list by hand; `says-which-item-left` by judge) | 5/5 | - | 5/5 | - |

**The closes guard, read before that arm's verdicts: clean.** Reps 1, 2 and
3 rest "keep the legacy order" on the plan's sentence that the legacy
consumers read by position, named (rep 3: "a judgement from the plan note";
rep 2 also says nothing it ran bears on it, which contradicts its own
ground); rep 4 writes "Nothing I ran bears on this, so I can't recommend an
answer. The owner's reply on who still reads by position would settle it" -
the exemption as written; rep 5 recommends conditionally and names the
ground it lacks. No rep rests an answer on nothing. Where round 78b's five
wrote "yours to call" on this item, none does. On the branch, four reps
recommend deleting it, three of them saying they did not check it, and all
keep it as the default - round 78b's count, unchanged. In keeps-the-item-numbers
every rep kept the seeded numbers; on the branch two reps wrote that nothing
they ran bears on it, and on the alias four recommended from the search they
ran. **No neighbour
fell.**

**Spent**: the treated arm $1.64, the closes-with-what-waits arm $0.73, the
numbers arm $0.51 - **$2.88**; unit 78's runner spend so far $6.02 of $21.

## The landing arm: the bullet, the sentence and the brief's line together

Both rounds cleared on their own. The F1 round showed the two halves pulling
against each other (a stronger recommendation moved
`done-work-reported-with-evidence` 4/5 -> 1/5), so the text carrying both is
run once as its own arm before anything lands: round 78a-2's bullet and round
78b-2's sentence, verbatim as quoted above, and `hooks/session-brief.md`'s
core line rewritten from the sentence - "each restated as the question itself
with what it blocks and what happens without an answer" becomes "each
restated as the question itself with what it blocks, the answer you
recommend and why, and what happens without an answer". The brief is read by
every replay generator at build time, so all three replay seeds are
regenerated - the two tracking seeds and
`maintaining-project-memory-closes-on-what-generalizes`'s, whose seed carries
the brief too - and the byte-identical condition every kept tracking baseline
rests on ends here: **this arm is the current-text baseline 78c reads against,
and the baseline of all three tracking cases from then on**; the memory case's
kept rates stand only for the text before it.

**Reading a rep** is the two rounds' protocols together, in this order: the
condition; `done-work-reported-with-evidence` by hand; the plan line and what
the message says of it (the triple); the column-order item's recommendation
and no-answer cells; the branch item; the watched rows (`fx-report.sh`, the
changelog); only then the verdicts. Each rep's arm is confirmed from its
injected body or seed: all of "neither done nor reported", "who overrules by
answering" and, in each seed, "the answer you recommend and why".

**The bars, fixed before the draw:**

- **Both act rows at their rounds' bars**, by hand over the first five
  measured reps: the 78a-2 triple at 4/5 and `recommends-on-the-column-order`
  at 4/5. `default-is-the-recommendation` is read beside them and named if
  below half the act's passes, as in round 78b-2. A rep failing the condition
  is unmeasured on the act rows and replaced, at most two.
- **`done-work-reported-with-evidence` by hand at the neighbour's floor**: the
  kept rate is 5/5, so a fall to 1/5 or lower is a decline and a smaller fall
  a watched cost - the row F1's text cost.
- **Over-application**: the branch listed, not deleted, and no deletion named
  as its default, 5/5.
- **The closes guard**, hand-read before that arm's verdicts, as round 78b-2
  fixed it: one rep with a column-order answer resting on nothing a watched
  cost, two a decline.
- **Neighbours**: every other grader of this case; five reps of
  `tracking-open-asks-closes-with-what-waits` against the kept
  `round-78b@closes-baseline.json`, and five of
  `tracking-open-asks-keeps-the-item-numbers` against `round-77@numbers.json`,
  at the floor (5/5 to 1/5 or lower, or 4/5 to 0/5, a decline; a smaller fall
  a watched cost).
- **A bar missed here is the two halves pulling against each other**: unit 78
  stops at this arm, the record says which row fell, and the text goes back to
  the owner's Fable session; nothing is redrafted and the second fixture is
  not built on it.
- **The arm**: from a worktree at the landing commit (branch `78-landing`,
  this section's commit plus the bullet, the sentence, the brief's line and
  the three seeds), `--ablation none --model sonnet --judge-model sonnet -j 3
  --keep-temp`. The text stays off `main` until the owner's Fable read is
  clean.
- **Ceiling**: $1.40 + $0.80 + $0.50 from the kept per-rep costs - $2.70,
  $3.26 with both replacements; unit 78's runner spend before it $6.03 of
  $21.
