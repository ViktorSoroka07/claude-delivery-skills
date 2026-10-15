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

`plan-written` names its file as a bare path, which the runner refuses at load;
it is rewritten as `target: {source: file, path: "docs/plans/task-102.md"}` before
any launch, which a load-only launch then checks.

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
