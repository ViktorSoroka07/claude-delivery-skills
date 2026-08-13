---
name: implementation-gates
description: Use when implementation work is about to be called done — at the end of an executing-plans run, before finishing-a-development-branch, before opening a PR, or before any "complete" claim. Runs the repo's own gates, then proves the new tests can actually fail and that every claim the plan made about outside behaviour is true. Also use when writing a plan, to fix its ground-truth claims before they become design decisions.
---

# Implementation Gates

`superpowers:verification-before-completion` enforces **honesty**: never claim a gate passed without running it. This skill enforces **sufficiency**: a suite that honestly, verifiably passes can still be too weak to catch the defect you just introduced.

Both failures below shipped on a branch whose gates were green and truthfully reported:

- Thirteen mutations survived. Every new test passed; several passed identically against the pre-change code.
- A design decision rested on what a CLI's `result` frame contains. The plan argued the point coherently for three sentences and was wrong. One read-only query against the local database settled it.

Green is not the bar. **Would it have gone red** is the bar.

## Gate 1 — the repo's own gates

Read the repo's `CLAUDE.md` (root, plus any in the directories you touched) for the gate commands and the test runner. Never guess them, and never substitute a faster command.

Run each, read the real exit status, and quote failures. Two traps:

- **Never grep a gate for a tally.** `Tasks: 8 successful, 11 total` contains the word "successful" and is a failure.
- **A suspiciously instant run did not execute.** Compare duration against a known baseline; a cached turbo task is not evidence.

## Gate 2 — mutation sweep on what you just wrote

The only axis that measures test strength instead of guessing at it. Ten to twelve mutations, targeted at the lines this change introduced — not a whole-file sweep.

**Protocol** (past runs were invalidated by mutations that never applied and test runs that never executed):

1. Green baseline first — record test count *and* duration.
2. One mutation at a time, applied with an `old_string` unique to the target line. **A failed edit means the mutation never applied — never count it as killed.**
3. Re-run; compare count and duration to baseline. Record KILLED (name the failing test) or SURVIVED.
4. Revert; confirm the tree is clean before the next one.
5. **All-killed is suspicious.** Re-apply one and watch it fail before believing the run.

**Aim at the classes that actually survive.** Each of these shipped green in real work:

| Class | Example |
| --- | --- |
| Aggregate swap | `COUNT(*)` ↔ `MAX(col)` — identical on contiguous data, divergent the moment a row is skipped |
| Awaited vs forked | `await run(x)` → `runInBackground(x)` — indistinguishable to any synchronous test stub |
| Presence guard | `sawFlag ?` → `value > 0 ?` — collapses a measured zero into "unknown" |
| Emitted fields | drop one column from a written row — invisible unless a test reads that column |
| Branch arms | delete a new `case` — falls through to a default that usually means "fine" |
| Boundaries, comparators, denominators | `>` ↔ `>=`, sort order, `/ 1000` → `/ 100` |

**Every survivor is a test gap, not a live defect** — cap the severity accordingly, and fix it by adding the missing assertion.

## Gate 3 — ground-truth check on outside claims

Do this **at plan time** if you can, and again before declaring done. It is the cheapest gate here and it catches the most expensive class of defect: one that is correct against the plan and wrong against the world.

List every claim the design rests on about behaviour you did not write — what an API returns, what a stream frame contains, what a column means, what a library does under a flag, what a tool prints. For each, name the check that would settle it, then run it.

Order of evidence, best first:

1. **Real data** — query the local database read-only, read a captured fixture, run the tool once and look.
2. **An existing consumer** — grep for code that already depends on the answer; it encodes the truth and its comments often state it.
3. **Documentation** — including your own repo's.
4. **Inference from a coherent argument** — this is not evidence. A three-sentence justification that never touches reality is exactly how the expensive defects arrive.

If a claim cannot be settled, say so explicitly, name the check that would settle it, and choose the option that fails safe.

## Gate 4 — the verification record says only what happened

If you write a verification section into a plan, spec, or PR body, every line must be something you executed.

- Ran six mutations? Say six. Do not generalise to "no test survives reverting the behaviour it covers" — that is a claim about a suite, and a wider run will contradict it.
- Could not check something? Write **what** was not verified, **why**, and **the check that would settle it**. A wrong reason is worse than no reason: it makes a reachable check look unreachable and nobody retries it.

## Red flags

| Thought | Reality |
| --- | --- |
| "Tests pass, so the tests are good" | They passed before the fix too, in the cases that matter |
| "I wrote a test alongside the fix" | It was shaped by the fix. Name the old rule and the new rule and check the fixture separates them |
| "The plan says the API behaves this way" | The plan is not a source. Find one |
| "It's obvious what this field means" | Two writers to one column disagreed about exactly that |
| "Mutation testing is for the review" | It costs a fraction here, where the context is already loaded |
