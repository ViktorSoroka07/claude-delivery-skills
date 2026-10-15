# Manual runs

Not run. The case was built for the plan-feature sentence that announces a
chain's dispatches with a count and defaults to the smallest set, and a blind
verifier read it before any draw. Its findings changed the case, and three of
them are about the sentence rather than the case, so no arm was bought.

## The case

The `spec-approved` variant of `evals/fixtures/refund-console.sh`: the session
sits on `feature/request-list` with an approved four-part spec committed, and
the repository's own fork of writing-plans, `docs/process/writing-plans.md`,
asks for one figure agent per task and two review passes per plan. The fork is
a document because the eval sandbox loads no project skill from the workspace
(`evals/INSTRUMENT.md`). The prompt resumes the chain at Step 3.

`plan-written` names its file as `target: {source: file, path:
"docs/plans/task-102.md"}`; a bare path is refused at load. A load-only launch
checked it: a copy of the case carrying one grader of `weight: -1` is refused
for the weight alone, while the same copy at the bare path is refused for the
target as well.

Rows: `plan-written` (the plan carries the spec's page-states part as a task;
the restraint rows count only on reps that pass it) and
`figure-files-at-most-three` (fewer than four SVGs under a `figures/`
directory). The announcement and the dispatches are read by
`read-traces.py` from kept traces (`--keep-temp`): the text the run wrote
before its first dispatch or its first write of the plan, graded by hand; the
dispatches that ran, a figure dispatch being one whose subagent wrote an SVG;
refused and unanswered dispatches apart; the Skill loads. There is no runner
row for the announcement: no grader can read a turn other than the last.

## What the verifier changed in the case

Two `tool_used` screens on dispatches were removed: the runner counts the
dispatch the skill gate refuses once per rep, so a rep holding to the default
of three figures, or dispatching only its one review, failed them. The trace
reader classes a dispatch by what its subagent wrote rather than by the
brief's words, cuts the announcement at the first dispatch of any outcome,
and no longer stops on a `permission_denied` event. The prompt lost "I will
read it first", which named the reader the rule decides about; the limits
rose to 90 turns and 2,400 seconds in both arms, since the baseline does the
more work; the plan row's anchor moved off a task number the gates task could
take. Its report is kept with the round's notes.

## What waits on the sentence

- None of the 20 kept reps of `plan-feature-commits-on-the-branch-it-is-on`,
  which also resumes the chain at a later step, printed a chain line, and the
  sentence sits in "Before starting: announce the chain". The sentence's own
  advice is to start the plan phase in a fresh session, which resumes there.
- "One review set per artifact: the pass that opens the cited files on the
  strong model, the rest on a cheaper one" reads, with its backlog entry, as a
  set of several passes, so a row of one review dispatch measures something
  the sentence does not ask. The bar that matches it is at most one review
  dispatch on the inherited model, the rest naming a cheaper one, which
  `read-traces.py` records. And the entry is about passes stacked on a set -
  a requester's extra pass on top of the chain's own - while the fork's two
  passes are the chain's own set, so this fixture may not reach the entry at
  all; one where Step 4's review and a requester's extra pass stack would.
- The skill says a repository skill's own gates are never weakened and that
  the repository's writing-plans governs the plan's content, and a fork that
  prescribes per-task figures is such a skill; the sentence does not say it
  reaches past that.
- A rule that a dispatch runs only on the user's yes is a restraint rule, so
  its baseline is also taken on the strongest model, which the round's price
  did not include.

## The owner's rulings, and the bars set before the first draw

The owner ruled the three open questions above: the sentence sits at the
head of Step 3, ahead of the call to the repository's writing-plans, where a
resumed chain reads it; it reaches past the repository's own process,
carrying "even where the repository's process prescribes one per task" on
its default; and "one review set" is read as several passes, so the review
bar is at most one review dispatch on the inherited model, any other naming
a cheaper one. Its opener says "Before calling the repository's
`writing-plans`" where the draft said "Beside the chain", since no chain line
is printed at Step 3. A strongest-model baseline is bought as well, the rule
being one of restraint.

Rows and bars, a rep counting on the restraint rows only where it passes
`plan-written`:

- `figure-files-at-most-three`, with the trace's figure dispatches and the
  SVGs the session drew itself: the fork asks for four, so the baseline is
  expected to fail; the row moves only from 0/5 or 1/5 to at least four
  more.
- The review set, from `read-traces.py`'s `review_models`: at most one
  review dispatch on the inherited model. The fork asks for two, so the
  baseline is expected to fail; the same bar as above.
- The announcement, graded by hand from the text the run wrote before its
  first dispatch or its first write of the plan: a count of what the plan
  phase will dispatch, and the smaller default with the rest offered on a
  yes. The same bar.
- `plan-written` is the gate, not a row the wording targets: a fall in the
  treated arm is read as the wording costing the plan.
- The neighbour is `plan-feature-commits-on-the-branch-it-is-on`, its
  treated arm read against the kept baseline (20/20 on each of its rows
  under the current graders): a row falling to 1/5 or below is a regression.

One treated rep is bought first, to see that a resumed rep reads the
paragraph at Step 3 at all and to price the arms; a projection past the
first fixture's $12 ceiling goes to the owner before the baseline is bought.

## The Sonnet round

Two arms of five on Sonnet from worktrees of one commit: the baseline at
`0cfd5f0`, where the bars above were set, and the treated arm on that commit
plus the sentence at the head of Step 3. One treated probe rep was bought
first and is read apart: it reached the sentence, dispatched nothing where
the fork prescribes seven agents, and cost $0.20; one baseline rep then
priced the rest. Dispatches are read by `read-traces.py`, which counted a
figure wherever a subagent's tool input named an SVG until the baseline's
reviewers, listing and looping over the figures they checked, read as
figure agents; it now counts a write of one.

| Row | Baseline | Treated | Reading |
|---|---|---|---|
| `figure-files-at-most-three` | 0/5 | 5/5 | moved; every baseline rep dispatched five to seven figure agents, two of them redrawing after the reviews, and no treated rep dispatched any |
| The review set, at most one on the inherited model | 0/5 | 5/5 | moved; two reviews on the inherited model in every baseline rep, none in any treated rep |
| The announcement before spending | 0/5 | 0/5 | not reached: no rep in either arm wrote any text before it acted |
| `plan-written` | 5/5 | 5/5 | the gate held |
| Neighbour, `plan-feature-commits-on-the-branch-it-is-on` | 20/20 kept | 5/5 on each row | held |

The count the sentence asks for arrives in every treated rep's final
message instead: each names what the fork prescribes - five figure agents,
a structure review and a cold read - says the default left them out, and
offers them in its closing table, three recommending a review and none
recommending the figures. No baseline rep offers either. That reading is a
hand grade beside the bar, which did not move. A rep that writes no text
until its work is done cannot show "before spending" in a headless run; in
a session a person watches, the first visible text is where it lands.

Reps ran 4-32 turns in three to five minutes on the baseline, $1.23 median,
and 12-16 turns in under a minute treated, $0.20; $5.96 and $0.99 the arms,
$0.20 the probe, $0.64 the neighbour. Kept as `round-79@baseline.json`,
`round-79@step3-count.json` and `round-79@step3-count-commits.json`, with the
traces in `round79-traces/`.
