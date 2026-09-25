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
