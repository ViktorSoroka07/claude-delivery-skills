# Working in this repository

`CONTRIBUTING.md` owns the process; this file is the short form a session reads first. Where the two disagree, CONTRIBUTING wins and this file is fixed.

## What to do, in which order

The order of work lives outside the tree: the maintainer keeps a plan under `docs/plans/` (git-ignored) and a memory note that holds the current ordered steps. Read those before choosing a task; do not infer the order from the git log. A session covers the tasks its plan assigns and stops at the boundary the plan names, even with context to spare; at the stop it commits, rewrites the memory note's current steps in place, hands over any push, and says whether a fresh session can continue from the files alone.

A session that finds something worth doing beyond its assigned tasks does not drop it, and does it beside those tasks, never instead of them. What is plainly right, within this repository's purpose and undone by one commit if wrong - a sentence a change made stale, a copy that disagrees with its source, a sighting the queue lacks, a check that would have caught a defect met here - is done in its own commit and reported in a line, after a word with the advisor where one is configured. What needs a round, a spend or a change to the order is appended to the plan's task list with a line in the memory note and named in the closing. What the session declines is named with its reason. Nothing found leaves the session unmentioned.

## Commits

- One workstream per commit; a change that would be reverted separately is a separate commit. Subject is the outcome, body is the mechanism; no session narration, no attribution trailers.
- **A backlog entry is committed by the session that writes it, in a commit of its own, as soon as it is written** — the queue line in `BACKLOG.md`, or the move that files one under `backlog/`. The commit body carries the observation behind the entry, which the one-sentence entry cannot; and an uncommitted entry is a stray change every later session has to explain or step around.
- A skill, agent or brief edit that changes behaviour is tested before it lands (CONTRIBUTING, "Testing a wording change"): a baseline that fails, one wording, five fresh sessions per arm - on each of two models, twenty in all, where the rule is one of restraint, since that baseline is taken on the strongest model too - every grader of the case in both arms, the result written into the case's `results/manual-run.md` with the wording under test quoted verbatim - or, for one that landed, the commit on `main` that landed it named - since a round's branch is deleted once it is read and its SHA then names nothing. A wording that costs a neighbouring grader is declined with its reason, not reworded a third time on the session's own judgement.
- The version bump goes in the commit that changes behaviour; a bumped manifest releases on push.

## Backlog

- **A new entry starts with a search, not with a line.** `grep -rin` the mechanism — two or three words of what goes wrong, not the words an entry would have used — over all three files, `BACKLOG.md` **and `backlog/`**, because the queue is in the first and everything that has left it is in the other two, and a search reaching only the queue writes a new line for a mechanism already filed. A hit in the queue takes a sighting in that entry's parenthetical instead of a second line; a hit in `backlog/parked.md` moves that entry back to its tier with the new circumstance, already carrying two; a hit in `backlog/declined.md` is the answer to the line rather than a reason to write it. Only a session that hit the mechanism itself adds a sighting; an entry carrying no count stands at the one sighting that queued it, so the first sighting added makes two.
- **A new entry is placed, not appended.** The order within a tier is the order a round takes entries up, so a line at the end runs last whatever it is worth: place it where its value sits among its neighbours - by how often and how much the mechanism costs the operator, and whether its failure landed or was measured - say in the commit body which entry it sits above and why, and in the closing message where it landed; `BACKLOG.md`'s header carries the ordering, and a parked entry moving back is placed the same way.
- Recurrence is the promotion filter: two sightings — other work or another place, never the same failure met twice in one pass — or one sighting whose failure was measured - a rate, a run, or a failure that landed and whose cost the entry names, never a near miss caught before it cost anything - is what makes an entry worth a wording round, and an entry that has reached neither by the time a round reads it is parked into `backlog/parked.md`, keeping its sentence and naming what a second sighting would be, which is a finding about the mechanism rather than a decline. `BACKLOG.md`'s header carries the shape, CONTRIBUTING's "Where a lesson waits" the reasoning.

## Review

Most changes here are verified by something stronger than a reading before they land: wording-tested contracts, grader patterns tested on captured runs and scored by the runner, fixtures built under a hostile global git config. Do not re-review those. Review the prose that loads into sessions — `hooks/session-brief.md`, `skills/*/SKILL.md` and the references they point at, `agents/*.md`, `CONTRIBUTING.md`, `README.md`, `CLAUDE.md` itself, which loads automatically into every session here and is therefore the least reviewed and the most obeyed, and `evals/INSTRUMENT.md`, which an eval session reads first in place of the Evals section CLAUDE.md once carried — as one doc-vs-code pass over its diff: each changed sentence against the file it cites and its neighbouring copies (brief core against skill, agent contract against owning skill, a reference against the SKILL.md clause that points at it, README paraphrase against skill, this file's short form against the CONTRIBUTING section it compresses). Run records and the backlog's entries carry no behaviour and are not reviewed — but the headers of `BACKLOG.md` and the two files under `backlog/` are instruction prose a session obeys at intake, and the range below leaves all three out, so those headers are read in the same pass from a diff of their own (`git diff prose-passed..HEAD -- BACKLOG.md backlog`). Shell under `scripts/` and `evals/fixtures/`, and any eval case never run in both arms, get an ordinary review.

**The range is the watermark, not the last push:** `git diff prose-passed..HEAD -- hooks skills agents CLAUDE.md CONTRIBUTING.md README.md evals/INSTRUMENT.md`, where `prose-passed` is a lightweight local tag marking the commit through which this prose has actually been read. The pass is its own unit of work, never started inside a task; it is due at about 150 changed lines, at a push whatever the size, or after two task units that changed a path in that range or one of the backlog's three headers; and it closes by moving that tag to the head it read, which is its only durable output (CONTRIBUTING, "Before pushing", has the mechanics and why a push is the wrong anchor).

Review findings are point-in-time, and review-pr keeps them in its folder outside the clone (its §5), where a later round and any pass over many reviews read them - so none is deleted there. A `review-findings-*.md` in this repo's root is that skill's fallback, git-ignored: once the folder can be written, move it into its request's folder as the next round.

## Gates

The eleven local gates are the steps of `.github/workflows/guard.yml` minus the skills-spec validator, which is not installed locally - the Python lint runs as `uvx ruff@0.12.0 check`; run them at the head before handing over a push. The local shellcheck is newer than CI's, so a clean local lint does not prove CI's lint step.

## Evals

The instrument's rules live in `evals/INSTRUMENT.md`; a session that designs, runs or reads a round reads that file first, in full. Five things bind every session here whatever it does:

- No eval run launches from the main checkout: run from a worktree of the commit under test, with any probe case under that worktree's git-ignored `docs/plans/`.
- The runner needs Docker Desktop closed and `~/.docker` moved aside for the run; say so once, with the end time, never in every message.
- `--judge-model sonnet` on any invocation whose verdicts will be read, and `--keep-temp` on any arm whose acts will be hand-read.
- `--case` takes one `*` glob; a batch's `--max-cost-usd` sits above its expected spend, since the run that reaches it has its judged graders scored as fails.
- A curtailed rep is unmeasured and replaced, never counted; a judged row is hand-graded from the run JSON's `evidence` before any decision rests on it.
