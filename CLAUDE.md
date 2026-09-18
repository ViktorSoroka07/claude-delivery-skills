# Working in this repository

`CONTRIBUTING.md` owns the process; this file is the short form a session reads first. Where the two disagree, CONTRIBUTING wins and this file is fixed.

## What to do, in which order

The order of work lives outside the tree: the maintainer keeps a plan under `docs/plans/` (git-ignored) and a memory note that holds the current ordered steps. Read those before choosing a task; do not infer the order from the git log. A session covers the tasks its plan assigns and stops at the boundary the plan names, even with context to spare; at the stop it commits, rewrites the memory note's current steps in place, hands over any push, and says whether a fresh session can continue from the files alone.

## Commits

- One workstream per commit; a change that would be reverted separately is a separate commit. Subject is the outcome, body is the mechanism; no session narration, no attribution trailers.
- **A `BACKLOG.md` entry is committed by the session that writes it, in a commit of its own, as soon as it is written.** The commit body carries the observation behind the entry, which the one-sentence entry cannot; and an uncommitted entry is a stray change every later session has to explain or step around.
- A skill, agent or brief edit that changes behaviour is tested before it lands (CONTRIBUTING, "Testing a wording change"): a baseline that fails, one wording, five fresh sessions per arm, every grader of the case in both arms, the result written into the case's `results/manual-run.md`. A wording that costs a neighbouring grader is declined with its reason, not reworded a third time on the session's own judgement.
- The version bump goes in the commit that changes behaviour; a bumped manifest releases on push.

## Review

Most changes here are verified by something stronger than a reading before they land: wording-tested contracts, grader patterns tested on captured runs and scored by the runner, fixtures built under a hostile global git config. Do not re-review those. Review the prose that loads into sessions — `hooks/session-brief.md`, `skills/*/SKILL.md`, `agents/*.md`, `CONTRIBUTING.md`, `README.md` — as one doc-vs-code pass over its diff: each changed sentence against the file it cites and its neighbouring copies (brief core against skill, agent contract against owning skill, README paraphrase against skill). Run records and `BACKLOG.md` carry no behaviour and are not reviewed. Shell under `scripts/` and `evals/fixtures/`, and any eval case never run in both arms, get an ordinary review.

Findings files (`review-findings-*.md`) are point-in-time and git-ignored; delete one once everything in it is closed or carried into the plan.

## Gates

The eight local gates are the steps of `.github/workflows/guard.yml` minus the skills-spec validator, which is not installed locally; run them at the head before handing over a push. The local shellcheck is newer than CI's, so a clean local lint does not prove CI's lint step.

## Evals

- `evals/results/` is git-ignored and holds the baseline JSON of each release; the runner keeps each run's findings file or reply as grader `evidence` in that JSON, which is what to hand-grade when a judge verdict looks wrong. The judge is unreliable on long files and on findings renumbered at a merge.
- A file-targeted grader whose target is absent throws and is scored a fail, `not_contains` included; a behaviour that legitimately deletes a file cannot be graded through that file.
- The runner's `--case` filter takes one `*` glob.
- A rule about restraint (what a session must not do) needs its baseline taken on the strongest model the maintainer runs as well as on the eval instrument: the stronger model over-applies a rule it has understood, and the weaker one may never have exhibited the failure.
