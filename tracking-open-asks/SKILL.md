---
name: tracking-open-asks
description: Use when a request contains more than one ask, when new asks arrive while work is already running, and at any checkpoint or session end where status gets reported.
---

# Tracking Open Asks

In a long session, asks drop silently — and the failure is only visible when the requester has to re-ask: "did you create the issue?", "what's the status of everything I asked for?" By then they have paid twice: once waiting, once auditing. The mechanism below exists because a working set of tasks in the head demonstrably loses items that an explicit ledger does not.

## The ledger starts when the asks arrive

- **Enumerate every ask in a multi-part request immediately** — including the small trailing ones ("…and also create an issue for it"), which are precisely the ones that drop while attention is on the big item.
- **Mid-session additions go on the ledger at arrival**, not reconstructed later from memory. A new ask landing while other work runs is the highest-risk arrival there is.
- **A dispatched agent's promised deliverable is an open ask too** — the ledger holds it until the report actually lands (`delegating-to-subagents` owns pulling it).

## Every ask closes visibly

An ask leaves the ledger in exactly one of four states, each stated to the requester: **done** (with the evidence), **answered**, **declined with the reason**, or **explicitly deferred with an owner and a where**. Silent closure is not a state — an ask that was overtaken by events still gets a sentence saying so.

## Reports run against the full ledger

At any checkpoint, and always at session end, status covers the **whole ledger**, not the items that happened to finish: done items with their evidence, open items with their state, and nothing omitted because it is embarrassing or stale. The closing message answers every still-open item before the next-session starter prompt; an item whose closure was already stated to the requester needs no restating, so a fully-closed ledger's closing is the starter prompt alone (`maintaining-project-memory` owns the closing's form).

## Red flags

| Thought                                        | Reality                                                                    |
|------------------------------------------------|-----------------------------------------------------------------------------|
| "I'll handle the side-ask after the main one"  | Un-ledgered deferral is how it drops. Write it down, then defer it         |
| "That request was mostly one big task"         | The trailing "and also…" is an ask. Enumerate before starting              |
| "I reported what I finished"                   | The requester needs the whole ledger — open items are the report's point   |
| "The agent will deliver it eventually"         | A promised deliverable is an open ask until the report lands               |
| "That item became moot"                        | Moot is a closure to state, not a silence                                  |
