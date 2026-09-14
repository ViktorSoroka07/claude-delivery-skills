---
name: implementation-gates
description: Use when implementation work is about to be called done or complete, after the repo's own gates have passed — and while writing a plan or spec, to settle its claims about outside systems (APIs, data, libraries) against evidence before they become design decisions.
---

# Implementation Gates

**This skill does not run the repo's gates or police completion claims.** The repo's own `verification-before-completion` owns both — call the Skill tool with it rather than restating it here.

What it adds is the step after: a suite that honestly, verifiably passes can still be too weak to catch the defect you just introduced. Both failures below shipped on a branch whose gates were green and truthfully reported.

- Thirteen mutations survived. Every new test passed; several passed identically against the pre-change code.
- A design decision rested on what a CLI's `result` frame contains. The plan argued the point coherently for three sentences and was wrong. One read-only query against the local database settled it.

Green is not the bar. **Would it have gone red** is the bar.

## Gate 1 — mutation sweep over what you just wrote

The repo already mandates red-green: write the test, revert the fix, watch it fail. That covers **a regression test for a bug that existed**. It says nothing about new feature code, where there is no fix to revert — and that is where survivors live.

Ten to twelve mutations, targeted at the lines this change introduced. Not a whole-file sweep. A change adding no executable code under test — docs-only, config-only — runs none and records exactly that: not applicable, no executable target.

**Protocol** — past runs were invalidated by mutations that never applied and test runs that never executed:

1. Green baseline first — record test count *and* duration, using the test command the repo's CLAUDE.md or `review-repo-nuances` project memory records (some repos' obvious command is wrong — the runtime's built-in test runner may not be what the repo's own scripts run). If neither records one, discover it, confirm it really executed (non-zero test count), and save it into that memory. The sweep's command is the recorded test command with any coverage threshold removed, never the gated form: a mutation can lower coverage, and the gate's non-zero exit reads as a kill with no failing assertion; record it as the memory's mutation-axis test command. Before trusting the baseline, find each new test's own name in the run's output, with a per-test reporter where the default prints only files — a shard filter, a path glob, or a match pattern drops a new file with no signal, locally as much as in a pipeline.
2. One at a time, applied with an `old_string` unique to the target line. **A failed edit means the mutation never applied — never count it as killed.**
3. Re-run; compare count and duration to baseline. A kill is a non-zero failure count *and* the runner's failure exit, never one alone: the tally can show no failures on a run that then failed, a zero-test run can exit green, and a coverage gate or tooling error exits non-zero with nothing failing. Read the failing test's name and error before attributing it: failures outnumbering the tests that target the mutated line may be a load-time or unrelated crash rather than any assertion — attribute by name and error, never by count. Record KILLED (name the failing test) or SURVIVED.
4. Revert; confirm the tree is clean before the next. The change under test is committed before the sweep starts: a revert by `git checkout -- <file>` restores the last commit, so on an uncommitted change it silently wipes the work the sweep was measuring. A detached worktree at the pinned commit is immune; the working tree is not.
5. **All-killed is suspicious.** Re-apply one and watch it fail before believing the run.
6. A survivor found against a scoped subset of the suite is not a gap until the full suite confirms it — a value the scoped area exports may be pinned elsewhere.

This protocol has one statement, here. The plugin's `mutation-tester` agent is its executable form: `review-pr`'s mutation axis dispatches it, and so does this gate when the sweep is handed to a subagent rather than run in the current context.

**Aim at the classes that actually survive.** Each of these shipped green in real work:

| Class                                   | Example                                                                                         |
|-----------------------------------------|-------------------------------------------------------------------------------------------------|
| Aggregate swap                          | `COUNT(*)` ↔ `MAX(col)` — identical on contiguous data, divergent the moment a row is skipped   |
| Awaited vs forked                       | `await run(x)` → `runInBackground(x)` — indistinguishable to any synchronous test stub          |
| Presence guard                          | `sawFlag ?` → `value > 0 ?` — collapses a measured zero into "unknown"                          |
| Emitted fields                          | drop one column from a written row — invisible unless a test reads that column                  |
| Branch arms                             | delete a new `case` — falls through to a default that usually means "fine"                      |
| Boundaries, comparators, denominators   | `>` ↔ `>=`, sort order, `/ 1000` → `/ 100`                                                      |
| Whole-feature removal                   | delete the registration or call site — still green means the assertions never reached it        |

**A negative assertion is its own survivor class.** "Did not occur" passes when the observation window closes before the action runs, or when the matcher has silently stopped matching. Span the whole action, and prove the matcher live with a positive control on an event the system under test produced — never a literal the test restates.

**Screen survivors for equivalence, then treat the rest as test gaps, not live defects** — a mutation a correct implementation could also produce (behavior the spec leaves free, a guard duplicated by a downstream consumer, a defensive clause every caller pre-filters) is an equivalent mutant, not a gap. This sentence owns the definition; the other skills' screens restate it. Cap the severity accordingly, and fix each real gap by adding the missing assertion.

## Gate 2 — ground-truth check on outside claims

Cheapest gate here, and it catches the most expensive class: a change that is correct against the plan and wrong against the world. **Do this at plan time if you can** — after implementation, the code has already been built faithfully on the wrong premise.

List every claim the design rests on about behavior you did not write — what an API returns, what a stream frame contains, what a column means, what a library does under a flag, what a tool prints. For each, name the check that would settle it, then run it — every check read-only: query, read, observe; never a call that mutates state.

Evidence, the best first:

1. **Real data** — query the local database read-only, read a captured fixture, run the tool once and look.
2. **An existing consumer** — code that already depends on the answer encodes the truth, and its comments often state it.
3. **Documentation**, including your own repo's.
4. **A coherent argument** — this is not evidence. An internally consistent, unambiguous, in-scope claim can still be false, and that is precisely how the expensive defects arrive.

When the tool is a compiled or bundled binary, read it as source rather than as a dump of strings: list the strings once to locate the feature, then find the function that resolves the value — a message string near the logic is not the logic, and proximity has inverted a root cause. Enum members and defaults sit in schema-shaped records; a field's presence in a structure says nothing about whether it is displayed, so find the render site; minified names differ per chunk, so a name found in one chunk proves nothing about another. Record the version you read in whatever artifact keeps the claim.

A count is a claim too: a query whose filter parameter is silently ignored returns the whole population, indistinguishable from a real count. One control call precedes any use of the number, with a filter value whose honoured result cannot equal the unfiltered population — an impossible value for an inclusive filter, a known-present one for an exclusion.

If a claim cannot be settled, say so, name the check that would settle it, and choose the option that fails safe.

This list owns the evidence order and the plan-time check; `plan-feature` and `implement-plan` call this gate rather than restating it.

## Gate 3 — written records state only what ran

Distinct from claims made in conversation, which the repo's skill already governs. This is about verification sections written into plans, specs, and PR bodies, where they outlive the session and are read as fact.

- Ran six mutations? Say six. Do not generalize to "no test survives reverting the behavior it covers" — that is a claim about a whole suite, and a wider run will contradict it.
- Could not check something? Write **what** was not verified, **why**, and **the check that would settle it**. A wrong reason is worse than no reason: it makes a reachable check look unreachable, and nobody retries it.

## The plan task that runs these gates

A plan ends with this task, copied verbatim. `plan-feature` writes it at plan time; `implement-plan` appends it when a plan lacks one. It is what makes the gates run: the executor runs the verifications the plan specifies, so a gate that is not written into the plan does not run.

```markdown
### Task N: Implementation gates

- [ ] Run the repo's gates — REQUIRED SUB-SKILL: verification-before-completion
- [ ] Confirm each new test's own name appears in the test run's output, with a per-test reporter where the default prints only files
- [ ] Prove the new tests can fail — 10–12 targeted mutations over the lines this plan added, one at a time, reverting between; screen survivors for equivalence (a mutation a correct implementation could also produce is not a gap), every real survivor is a missing assertion; run the repo's test command with any coverage threshold removed, and count a kill only as a named failing test whose error is the mutated behaviour — not a non-zero exit, a coverage gate, or a load-time crash; a plan adding no executable code under test (docs-only, config-only) runs none and records exactly that
- [ ] Re-check the spec's ground-truth claims against what shipped
- [ ] Write only what was executed into any verification section
```

## Red flags

| Thought                                  | Reality                                                                                            |
|------------------------------------------|----------------------------------------------------------------------------------------------------|
| "Tests pass, so the tests are good"      | They passed before the fix too, in the cases that matter                                           |
| "I wrote a test alongside the fix"       | It was shaped by the fix. Name the old rule and the new rule, and check the fixture separates them |
| "Red-green covered it"                   | Only for a bug that existed. New code has no fix to revert                                         |
| "The plan says the API behaves this way" | The plan is not a source. Find one                                                                 |
| "It's obvious what this field means"     | Two writers to one column disagreed about exactly that                                             |
| "Mutation testing is for the review"     | It costs a fraction here, where the context is already loaded                                      |
| "The coverage gate went red — killed"    | The un-gated test command decides. A lowered threshold is not a failing assertion                  |
| "All green, the new tests too"           | Find each new test's name in the run log. A green suite says nothing about tests it never selected |
