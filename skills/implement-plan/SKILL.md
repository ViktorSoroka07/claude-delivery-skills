---
name: implement-plan
description: Use when a plan document already exists and the work should now be built — "implement this plan", "execute the plan", "go ahead with docs/plans/X.md" — or when continuing after plan-feature.
compatibility: Delegates execution to the superpowers skill set (subagent-driven-development or executing-plans, verification-before-completion, finishing-a-development-branch) or a repo's own forks of them.
---

# Implement Plan

Picks up where `plan-feature` stops, and works equally well on a plan written days ago, by someone else, or by another model.

**This skill delegates and patches. It does not restate.** Execution belongs to the repo's own skill; this one guarantees the things that get skipped when a plan is handed straight to an executor.

## Step 1 — Read the plan first

Read it fully before touching anything. Then check two things:

- **Does it still match the repo?** A plan written before a merge can name files, symbols or commands that no longer exist. Raise mismatches with the user rather than improvising around them.
- **Does it end with a gates task?** If not, append `implementation-gates`' plan task verbatim (its section "The plan task that runs these gates") now — before implementation starts, so the executor runs it as part of the plan.

The plan is what `executing-plans` obeys. Patching the plan is what makes the gate run; hoping a skill fires at the end is not.

## Step 2 — Check the plan's premises are settled

If the plan makes claims about behavior **outside the code being written** — what an API returns, what a frame contains, what a column means — confirm they were settled against evidence, not argued. Call the Skill tool with `implementation-gates` and run its Gate 2 on those claims now.

A plan that reads well can still rest on a false premise, and implementation will faithfully amplify it. Settling a claim costs one query here and a rewrite later.

## Step 3 — Implement

Call the Skill tool with the repo's `subagent-driven-development` (preferred where subagents are available) or `executing-plans`. Follow that skill's checkpoints exactly and stop where it says stop.

The work's branch already exists: plan-feature's hand-off names it, and where the plan is committed its log shows it. Where the execution skill offers a worktree, the worktree checks out that branch — `git worktree add <path> <branch>` — never a new one; git checks a branch out in one worktree at a time, so where the main checkout already sits on it, move that checkout to the default branch first. A branch created here leaves two branches holding the plan and strands the one the commit hook keys on.

Where execution dispatches subagents, apply `delegating-to-subagents` on top — above all its audit of each delegated diff before the orchestrator commits it: discipline stated in a brief does not survive delegation. Where execution will spend at scale, `budgeting-agentic-work` governs the phase sizing and pricing of expensive passes.

Announce which one you used, and whether it was the repo's copy or the `superpowers:` one — they are forks and behave differently.

## Step 4 — Gates

Call the Skill tool with `implementation-gates`.

Report survivors honestly. A survivor is a test gap to close, not a defect to argue away, and "the tests pass" is not evidence that they would have failed.

## Step 5 — Finish

Four steps, in this order:

1. **Rewrite the plan document as the spec of what shipped** — call the Skill tool with `writing-plan-docs` and follow its shipped-spec stage (strip checkboxes, re-tense to what landed, record what was and was not verified, no review history, no volatile counts). This happens **before** offering merge/PR options, not after.
2. **Call the Skill tool with the repo's `finishing-a-development-branch`.**
3. **Update the project memory** per `maintaining-project-memory` (it owns the write discipline — what memory holds, and the starter prompt a continuing session ends with). Refresh the `review-repo-nuances` entry (that exact name — it is the one `review-pr` and `implementation-gates` read) if this work changed gates, commands, or conventions, and record what a next session needs that the repo itself cannot tell it — what is parked, which decisions are provisional. In repos that do not commit plan documents, record in that same entry where this task's executed gates record lives — plan path, branch, the SHA the gates ran at — so a later review can audit the mutation table instead of re-running the sweep. Update existing memory files over creating duplicates.
4. **Tell the user that review is a separate, billable decision:** `/review-pr` triages its axes, and a small diff may not warrant one at all.

## Rules

- **Never start implementation on a plan you have not read end to end.**
- **Plan edits by the user are authoritative** — re-read the plan if they changed it.
- **Never skip a repo skill's own gate** to save time.
- **Stop and ask** at the first blocker rather than guessing.
