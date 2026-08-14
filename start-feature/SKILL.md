---
name: start-feature
description: Use when starting new work from an idea rather than from an existing plan — "I want to build X", "let's add Y", "can we change how Z works". Runs the whole chain end to end - design dialogue, a ground-truth check on external claims, a plan that ends in gates, implementation, and the gates before done - delegating to whichever brainstorming / writing-plans / executing-plans skills the repo provides and supplying the two checks that are missing when it does not.
---

# Start Feature

The front door for new work. One invocation enters the chain; the user should not have to remember the next skill at each hop.

**This skill delegates and patches. It does not restate.** Every step hands off to the repo's own skill where one exists. What it adds is two checks that most chains lack, at the two moments they are cheapest.

Use `superpowers:` prefixed skills only as a fallback: a repo's unprefixed copy is usually a fork that differs substantially, and the fork is the one the team has agreed on.

## Before starting: announce the chain

Name the skills this run will use and where the expensive steps are, so the user can redirect before the spending starts, not after. For example:

> Chain for this: `brainstorming` (repo copy) → ground-truth check → `writing-plans` → `subagent-driven-development` → `implementation-gates`. The design dialogue is interactive; implementation is the expensive part.

If a step's skill is missing in this repo, say so and name what you will do instead.

## Step 1 — Design

Invoke the repo's `brainstorming` skill and follow it exactly, including its approval gate. **Do not bypass it because the change looks small** — that gate is the repo's, not this skill's, and "too simple to need a design" is where unexamined assumptions do the most damage.

## Step 2 — Ground-truth the spec

Before the user reviews the spec, and before any plan is written.

List every claim the design rests on about behaviour **you did not write** — what an API returns, what a stream frame contains, what a column means, what a library does under a flag, what a tool prints. For each, name the check that would settle it and run it.

Evidence, best first:

1. **Real data** — query a local database read-only, read a captured fixture, run the tool once and look.
2. **An existing consumer** — code already depending on the answer encodes the truth.
3. **Documentation**, including the repo's own.
4. **A coherent argument** — not evidence. A claim can be internally consistent, unambiguous, in scope and false; a spec self-review checks the first three and cannot catch the fourth.

If a claim cannot be settled, say so in the spec, name the check that would settle it, and pick the option that fails safe.

Skip this step only if the repo's `brainstorming` already performs it — check its spec self-review section rather than assuming either way.

## Step 3 — Plan

Invoke the repo's `writing-plans` skill. Before implementation begins, confirm the plan **ends with a gates task**; if it does not, append one:

```markdown
### Task N: Implementation gates

- [ ] Run the repo's gates — REQUIRED SUB-SKILL: verification-before-completion
- [ ] Prove the new tests can fail — 10–12 targeted mutations over the lines this plan added, one at a time, reverting between; every survivor is a missing assertion
- [ ] Re-check the spec's ground-truth claims against what shipped
- [ ] Write only what was executed into any verification section
```

This is the load-bearing patch. `executing-plans` runs "verifications as specified" — specified by the plan — so a gate that is not in the plan does not run.

## Step 4 — Implement

Hand off to the repo's `subagent-driven-development` (preferred when subagents are available) or `executing-plans`. Follow that skill's checkpoints; stop where it says stop.

## Step 5 — Gates

Invoke `implementation-gates`. Report survivors honestly: a survivor is a test gap to close, not a defect to argue away.

## Step 6 — Finish

Hand off to the repo's `finishing-a-development-branch`.

Then tell the user review is a separate, billable decision and let them choose: `/review-pr` triages its axes, and a small diff may not warrant one at all.

## Rules

- **Never duplicate a repo skill's content into this one.** If a repo-level `test-driven-development` skill owns the mutation classes, reference it; do not restate the list.
- **Announce which copy of a skill you used** when both a repo copy and a `superpowers:` copy exist — they are forks and behave differently.
- **Never skip a repo skill's own gate** to save time. This skill sequences the chain; it does not have authority to weaken it.
- **Stop and ask** at the first blocker rather than guessing — the repo skills each say this, and it applies to the seams between them too.
