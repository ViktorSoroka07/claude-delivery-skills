---
name: implementation-gates
description: Use when implementation work is about to be called done, after the repo's own gates have passed — proves the new tests could actually fail, that the plan's claims about outside systems are true, and that any written verification record states only what ran. Also use while writing a plan or spec, to settle its external claims before they become design decisions.
---

# Implementation Gates

**This skill does not run the repo's gates or police completion claims.** The repo's own `verification-before-completion` owns both — use it, do not restate it here.

What it adds is the step after: a suite that honestly, verifiably passes can still be too weak to catch the defect you just introduced. Both failures below shipped on a branch whose gates were green and truthfully reported.

- Thirteen mutations survived. Every new test passed; several passed identically against the pre-change code.
- A design decision rested on what a CLI's `result` frame contains. The plan argued the point coherently for three sentences and was wrong. One read-only query against the local database settled it.

Green is not the bar. **Would it have gone red** is the bar.

## Gate 1 — mutation sweep over what you just wrote

The repo already mandates red-green: write the test, revert the fix, watch it fail. That covers **a regression test for a bug that existed**. It says nothing about new feature code, where there is no fix to revert — and that is where survivors live.

Ten to twelve mutations, targeted at the lines this change introduced. Not a whole-file sweep.

**Protocol** — past runs were invalidated by mutations that never applied and test runs that never executed:

1. Green baseline first — record test count *and* duration, using the test command the repo's CLAUDE.md or repo-nuances project memory records (some repos' obvious command is wrong — the runtime's bare test runner may choke where the package script works).
2. One at a time, applied with an `old_string` unique to the target line. **A failed edit means the mutation never applied — never count it as killed.**
3. Re-run; compare count and duration to baseline. Record KILLED (name the failing test) or SURVIVED.
4. Revert; confirm the tree is clean before the next.
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

**Screen survivors for equivalence, then treat the rest as test gaps, not live defects** — a mutation that changes no observable behaviour (a guard duplicated by a downstream consumer, a defensive clause every caller pre-filters) is an equivalent mutant, not a gap. Cap the severity accordingly, and fix each real gap by adding the missing assertion.

## Gate 2 — ground-truth check on outside claims

Cheapest gate here, and it catches the most expensive class: a change that is correct against the plan and wrong against the world. **Do this at plan time if you can** — after implementation, the code has already been built faithfully on the wrong premise.

List every claim the design rests on about behaviour you did not write — what an API returns, what a stream frame contains, what a column means, what a library does under a flag, what a tool prints. For each, name the check that would settle it, then run it.

Evidence, best first:

1. **Real data** — query the local database read-only, read a captured fixture, run the tool once and look.
2. **An existing consumer** — code that already depends on the answer encodes the truth, and its comments often state it.
3. **Documentation**, including your own repo's.
4. **A coherent argument** — this is not evidence. An internally consistent, unambiguous, in-scope claim can still be false, and that is precisely how the expensive defects arrive.

If a claim cannot be settled, say so, name the check that would settle it, and choose the option that fails safe.

## Gate 3 — written records state only what ran

Distinct from claims made in conversation, which the repo's skill already governs. This is about verification sections written into plans, specs, and PR bodies, where they outlive the session and are read as fact.

- Ran six mutations? Say six. Do not generalise to "no test survives reverting the behaviour it covers" — that is a claim about a whole suite, and a wider run will contradict it.
- Could not check something? Write **what** was not verified, **why**, and **the check that would settle it**. A wrong reason is worse than no reason: it makes a reachable check look unreachable, and nobody retries it.

## Red flags

| Thought | Reality |
| --- | --- |
| "Tests pass, so the tests are good" | They passed before the fix too, in the cases that matter |
| "I wrote a test alongside the fix" | It was shaped by the fix. Name the old rule and the new rule, and check the fixture separates them |
| "Red-green covered it" | Only for a bug that existed. New code has no fix to revert |
| "The plan says the API behaves this way" | The plan is not a source. Find one |
| "It's obvious what this field means" | Two writers to one column disagreed about exactly that |
| "Mutation testing is for the review" | It costs a fraction here, where the context is already loaded |
