---
name: implement-plan
description: Use when an implementation plan already exists and the work should now be built — "implement this plan", "go ahead with docs/plans/X.md", or continuing after plan-feature. Ensures the plan carries a gates task before starting, delegates execution to the repo's own skill, then runs the gates before anything is called done.
---

# Implement Plan

Picks up where `plan-feature` stops, and works equally well on a plan written days ago, by someone else, or by another model.

**This skill delegates and patches. It does not restate.** Execution belongs to the repo's own skill; this one guarantees the two things that get skipped when a plan is handed straight to an executor.

## Step 1 — Read the plan first

Read it fully before touching anything. Then check two things:

- **Does it still match the repo?** A plan written before a merge can name files, symbols or commands that no longer exist. Raise mismatches with the user rather than improvising around them.
- **Does it end with a gates task?** If not, append one now — before implementation starts, so the executor runs it as part of the plan:

```markdown
### Task N: Implementation gates

- [ ] Run the repo's gates — REQUIRED SUB-SKILL: verification-before-completion
- [ ] Prove the new tests can fail — 10–12 targeted mutations over the lines this plan added, one at a time, reverting between; screen survivors for equivalence (a mutation changing no observable behaviour is not a gap), every real survivor is a missing assertion
- [ ] Re-check the spec's ground-truth claims against what shipped
- [ ] Write only what was executed into any verification section
```

The plan is what `executing-plans` obeys. Patching the plan is what makes the gate run; hoping a skill fires at the end is not.

## Step 2 — Check the plan's premises are settled

If the plan makes claims about behaviour **outside the code being written** — what an API returns, what a frame contains, what a column means — confirm they were settled against evidence, not argued.

A plan that reads well can still rest on a false premise, and implementation will faithfully amplify it. If a claim is unsettled, settle it now: real data beats an existing consumer, which beats documentation, which beats a coherent argument. This costs one query here and a rewrite later.

## Step 3 — Implement

Hand off to the repo's `subagent-driven-development` (preferred where subagents are available) or `executing-plans`. Follow that skill's checkpoints exactly and stop where it says stop.

Announce which one you used, and whether it was the repo's copy or the `superpowers:` one — they are forks and behave differently.

## Step 4 — Gates

Invoke `implementation-gates`.

Report survivors honestly. A survivor is a test gap to close, not a defect to argue away, and "the tests pass" is not evidence that they would have failed.

## Step 5 — Finish

Hand off to the repo's `finishing-a-development-branch`.

Before reporting done, update the project memory: refresh the repo-nuances entry if this work changed gates, commands, or conventions, and record what a next session needs that the repo itself cannot tell it — what merged, what is parked, which decisions are provisional. In repos that do not commit plan documents, always record where this task's executed gates record lives (plan path, branch, date), so a later review can audit the mutation table instead of re-running the sweep. Update existing memory files over creating duplicates.

Then tell the user that review is a separate, billable decision: `/review-pr` triages its axes, and a small diff may not warrant one at all.

## Rules

- **Never start implementation on a plan you have not read end to end.**
- **Plan edits by the user are authoritative** — re-read the plan if they changed it.
- **Never skip a repo skill's own gate** to save time.
- **Stop and ask** at the first blocker rather than guessing.
