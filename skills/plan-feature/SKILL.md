---
name: plan-feature
description: Use when starting new work from an idea rather than from an existing plan — "I want to build X", "let's add Y", "can we change how Z works", "plan this feature". Ends at a plan; implementation is a separate skill (implement-plan).
compatibility: Delegates to the superpowers skill set (brainstorming, writing-plans) or a repo's own forks of them - install one or the chain has nothing to call.
---

# Plan Feature

The front door for new work, and it **ends with a plan, not with code**. A plan is the cheapest artifact to correct — stopping here is the highest-leverage pause in the chain. `implement-plan` picks it up afterward.

**This skill delegates and patches. It does not restate.** Every step hands off to the repo's own skill where one exists. What it adds is two checks and a reference sweep that most chains lack, at the moments they are cheapest.

Prefer a repo's unprefixed skill over the `superpowers:` copy — the unprefixed one is usually a fork the team has agreed on, and the two differ substantially.

## Before starting: announce the chain

Name the skills this run will use, so the user can redirect before the spending starts (`budgeting-agentic-work` owns the general price-the-pass rule):

> Chain: `brainstorming` (repo copy) → `implementation-gates` Gate 2 (ground-truth) → `writing-plans` + `writing-plan-docs` → optional plan review → the plan committed on the work's branch, where the repo commits plans (the branch is created only when the session is on the default branch). Ends with a plan; nothing gets built, nothing gets pushed.

If a step's skill is missing in this repo, say so and name what you will do instead.

## Step 1 — Design

Call the Skill tool with the repo's `brainstorming` and follow it exactly, including its approval gates. **Do not bypass them because the change looks small** — those gates belong to the repo, not to this skill.

## Step 2 — Ground-truth the spec

Before the user reviews the spec, and before any plan is written. **This is the step that a plan review cannot replace** — see the note in Step 4.

Call the Skill tool with `implementation-gates` and run its Gate 2 on the spec: list every claim the design rests on about behavior **you did not write**, settle each with the best evidence its ladder allows, and where a claim cannot be settled, say so in the spec, name the check that would settle it, and pick the option that fails safe.

Skip this step only if the repo's `brainstorming` already performs it — read its spec self-review section rather than assuming either way.

## Step 3 — Plan

Call the Skill tool twice — once for the repo's `writing-plans`, once for `writing-plan-docs` — the repo skill governs the plan's content, the personal one governs the document's shape (current-state spec, verification-record rules, reference hygiene) at both lifecycle stages: the plan written now, and the shipped-spec rewrite `implement-plan` performs later. Then confirm the plan **ends with a gates task**; if it does not, append `implementation-gates`' plan task verbatim (its section "The plan task that runs these gates").

This is the load-bearing patch. `executing-plans` runs "verifications as specified" — specified by the plan — so a gate that is not written into the plan does not run. Writing it here means it survives even if the plan is later implemented by a different skill, or in a different session.

Finally, sweep the plan's references against `writing-plan-docs`' reference rules — every reference must resolve at implementation time, against a tree that has moved, not just now.

## Step 4 — Offer a plan review

Ask whether the user wants a fresh-eyes pass before implementation, and **say plainly what it can and cannot do**:

- **It catches:** missing or out-of-order steps, files and symbols that do not exist, scope creep, an absent test strategy, steps that cannot be executed as written, a plan that does not actually satisfy the spec.
- **It cannot catch:** whether the plan's claims about outside systems are true. A false claim that is coherent, complete and well-sequenced passes every read. That is Step 2's job, and no amount of re-reading substitutes for it.

If the user wants it, the pass must be genuinely fresh: dispatch ONE clean-context subagent given the plan file, the spec, and the repo — never this conversation, and never a re-read by this session, which is anchored by what it meant to write rather than what it wrote. Dispatch it per `delegating-to-subagents`: delivery instruction in the spawn prompt, and its findings are claims to verify, not verdicts. One pass, then at most one scoped delta check of the fixes; report each finding with the check that produced it, and hand the continue/stop decision to the user rather than looping.

Never report a plan review as though it validated the plan's premises. If Step 2 left a claim unsettled, say so again here.

## Step 5 — Commit the plan on its branch, then hand off

The plan is the first artifact of the work: `implement-plan` needs a branch to start on, and the plan needs a home on it — a default checkout supplies neither. No delegated link performs this step: a plan-writing skill runs in whatever branch it finds itself in, and a brainstorming fork can assume a branch that no earlier link created (learned from a real planning session). So this skill does it:

1. **Put the plan on the work's branch.** When the session is on the default branch, create the work's branch, named by the repo's own convention — read recent branch names or the contributing guide — and derived from the tracker id where one exists: some repos' commit hooks insert the issue reference only when the branch name carries it, so a branch named later lands its first commits with the wrong subject; ask for the name only when neither a convention nor an id settles it. When the session is already on a non-default branch, that branch is the work's branch — commit there and say so; a second branch would hold the same plan twice.
2. **Where the repo commits plan documents, commit the plan there** as the branch's first commit, per `writing-commit-messages`. Where it does not, leave the plan uncommitted and say where it lives.
3. **Never push.** The push is the user's call, every time.

Then give the user the plan path and the branch it is on, and stop. Tell them `implement-plan <path>` continues, and that they can read or edit the plan first — edits to the plan are honored, since the plan is what implementation obeys; an edit to a committed plan is one more commit on the branch, not a reason to have waited.

## Rules

- **Never duplicate a repo skill's content into this one.** Reference it instead.
- **Announce which copy of a skill you used** when both a repo copy and a `superpowers:` copy exist.
- **Never skip a repo skill's own gate** to save time. This skill sequences the chain; it has no authority to weaken it.
- **Stop and ask** at the first blocker rather than guessing.
