---
name: plan-feature
description: Use when starting new work from an idea rather than from an existing plan — "I want to build X", "let's add Y", "can we change how Z works". Takes it from idea to a reviewed plan and then stops, so the plan can be read before anything is built. Runs the design dialogue, checks the spec's claims about outside systems against evidence, and makes sure the plan ends with a gates task. Implementation is a separate skill.
---

# Plan Feature

The front door for new work, and it **ends with a plan, not with code**. A plan is the cheapest artifact to correct — stopping here is the highest-leverage pause in the chain. `implement-plan` picks it up afterwards.

**This skill delegates and patches. It does not restate.** Every step hands off to the repo's own skill where one exists. What it adds is two checks that most chains lack, at the two moments they are cheapest.

Prefer a repo's unprefixed skill over the `superpowers:` copy — the unprefixed one is usually a fork the team has agreed on, and the two differ substantially.

## Before starting: announce the chain

Name the skills this run will use, so the user can redirect before the spending starts:

> Chain: `brainstorming` (repo copy) → ground-truth check → `writing-plans` → optional plan review. Ends with a plan; nothing gets built.

If a step's skill is missing in this repo, say so and name what you will do instead.

## Step 1 — Design

Invoke the repo's `brainstorming` skill and follow it exactly, including its approval gates. **Do not bypass them because the change looks small** — those gates belong to the repo, not to this skill.

## Step 2 — Ground-truth the spec

Before the user reviews the spec, and before any plan is written. **This is the step that a plan review cannot replace** — see the note in Step 4.

List every claim the design rests on about behaviour **you did not write**: what an API returns, what a stream frame contains, what a column means, what a library does under a flag, what a tool prints. For each, name the check that would settle it and run it.

Evidence, best first:

1. **Real data** — query a local database read-only, read a captured fixture, run the tool once and look.
2. **An existing consumer** — code already depending on the answer encodes the truth.
3. **Documentation**, including the repo's own.
4. **A coherent argument** — not evidence.

If a claim cannot be settled, say so in the spec, name the check that would settle it, and pick the option that fails safe.

Skip this step only if the repo's `brainstorming` already performs it — read its spec self-review section rather than assuming either way.

## Step 3 — Plan

Invoke the repo's `writing-plans` skill. Then confirm the plan **ends with a gates task**; if it does not, append one:

```markdown
### Task N: Implementation gates

- [ ] Run the repo's gates — REQUIRED SUB-SKILL: verification-before-completion
- [ ] Prove the new tests can fail — 10–12 targeted mutations over the lines this plan added, one at a time, reverting between; every survivor is a missing assertion
- [ ] Re-check the spec's ground-truth claims against what shipped
- [ ] Write only what was executed into any verification section
```

This is the load-bearing patch. `executing-plans` runs "verifications as specified" — specified by the plan — so a gate that is not written into the plan does not run. Writing it here means it survives even if the plan is later implemented by a different skill, or in a different session.

## Step 4 — Offer a plan review

Ask whether the user wants a fresh-eyes pass before implementation, and **say plainly what it can and cannot do**:

- **It catches:** missing or out-of-order steps, files and symbols that do not exist, scope creep, an absent test strategy, steps that cannot be executed as written, a plan that does not actually satisfy the spec.
- **It cannot catch:** whether the plan's claims about outside systems are true. A false claim that is coherent, complete and well-sequenced passes every read. That is Step 2's job, and no amount of re-reading substitutes for it.

If the user wants it, the pass must be genuinely fresh: dispatch ONE clean-context subagent given the plan file, the spec, and the repo — never this conversation, and never a re-read by this session, which is anchored by what it meant to write rather than what it wrote. One pass, then at most one scoped delta check of the fixes; report each finding with the check that produced it, and hand the continue/stop decision to the user rather than looping.

Never report a plan review as though it validated the plan's premises. If Step 2 left a claim unsettled, say so again here.

## Step 5 — Hand off

Give the user the plan path and stop. Tell them `implement-plan <path>` continues, and that they can read or edit the plan first — edits to the plan are honoured, since the plan is what implementation obeys.

## Rules

- **Never duplicate a repo skill's content into this one.** Reference it instead.
- **Announce which copy of a skill you used** when both a repo copy and a `superpowers:` copy exist.
- **Never skip a repo skill's own gate** to save time. This skill sequences the chain; it has no authority to weaken it.
- **Stop and ask** at the first blocker rather than guessing.
