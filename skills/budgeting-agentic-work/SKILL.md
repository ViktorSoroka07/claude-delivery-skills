---
name: budgeting-agentic-work
description: Use when launching work that will spend real money or context at scale — multi-agent passes, multi-phase implementations, long-running pipelines — when a session approaches a budget or context ceiling, and when unplanned rework cost has appeared.
---

# Budgeting Agentic Work

Agentic work spends the operator's money, and the bill arrives after the decisions that ran it up. Three failure shapes, each from real spend: a budget wall hit mid-phase, losing paid work in interrupted agents; a rework round silently doubling a pass's cost; and compute left running after its purpose was served. Neighbors own adjacent ground — `delegating-to-subagents` owns mid-run rescue budgets for silent agents, `maintaining-project-memory` owns the session-end starter prompt — this skill owns how the spend is structured and disclosed.

## Phase the work to survive interruption

Money and context are both meters that can hit their ceiling mid-run; structure expensive work so that:

- **Each phase ends durable.** Results committed or written to disk, in a state a fresh session can resume from, before the next phase spends anything. An interruption then costs at most the current phase — never the run.
- **The split is planned before the wall forces it.** Watch the context meter the way the operator watches the money meter; a session past roughly three-quarters of its window plans its ending at a phase boundary instead of discovering it mid-agent. The boundary ends with the literal next-session starter prompt — `maintaining-project-memory` owns its form.

## Price the pass before running it

Before an expensive fan-out or long pass, state in one line what will run and what it is expected to cost — scale, agent count, or a money estimate where the harness shows one — so the operator can redirect before the spending starts, not after. `review-pr`'s axis triage is this rule applied to reviews; the rule holds for any expensive pass. Proportionality is the test: verification and enrichment spend scales to what it protects, and a pass expected to cost more than the work it checks runs only on the operator's explicit yes.

## Rework cost is a process defect

When a pass's bill balloons — one real implementation round's cost more than doubled after a post-hoc review forced rework — the extra spend has a cause, and the cause is usually a check that ran after the expensive pass instead of before it. When rework cost appears: name the cause, move the check earlier in the process so the next run doesn't pay it, and report the incident plainly. Never present unplanned spend as routine — an unexplained cost spike is the operator's failure signal, and "that's just what it cost" converts a process defect into a recurring bill.

## Stop what you started

A server, watcher, agent, or scheduled job whose purpose is served gets stopped — proactively, not on request. Anything left running needs an articulated reason the operator has seen. Two costs, not one: idle compute is spend without a consumer, and a forgotten process corrupts later work — a stale server answering probes fakes verification results long after everyone forgot it was there. (`delegating-to-subagents` owns deciding whether a *silent* agent is dead or working; this rule is for after the work is done.)

## Red flags

| Thought                                            | Reality                                                                      |
|----------------------------------------------------|-------------------------------------------------------------------------------|
| "Run it all in one go, it's simpler"               | One ceiling hit mid-run loses everything unfinished. Phase it, durable ends  |
| "The context will probably last"                   | Plan the split before the wall picks the boundary for you                    |
| "The operator will see the cost in the bill"       | The bill arrives after the decisions. Price the pass before it runs          |
| "A deep verification pass is always worth it"      | Spend scales to stakes. Costlier than the work it checks → operator's call   |
| "The rework is done, no need to dwell on it"       | Unexplained spend recurs. Name the cause, move the check earlier, report it  |
| "I'll leave the server up in case we need it"      | An articulated reason or it stops — idle compute spends and fakes results    |
