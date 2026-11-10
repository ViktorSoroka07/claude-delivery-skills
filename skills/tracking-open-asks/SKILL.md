---
name: tracking-open-asks
description: Use when a request contains more than one ask, when new asks arrive while work is already running, at any checkpoint or session end where status gets reported, and whenever a question, decision or action is handed to the requester.
license: MIT
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

## What waits on the requester is on the ledger too

The ledger runs in both directions. A question put to the requester, a decision handed to them, an action only they can take (a push, an approval, a login) is an open item from the moment it is asked. It is lost faster than their own asks are: the message that asked it is followed by messages of work, and a requester who comes back finds it only by re-reading the conversation.

- **What the asked work leaves due is done, not asked.** When a finding of yours answers a line a file still carries as open, or a change of yours leaves a comment, a usage line, a record or a second copy of the same edit stale, and putting it right is in scope and undone by one command, do it in the same turn — every instance at once, not only the one noticed — and report it in one line as done. A follow-up found and neither done nor reported is the failure, not the safe choice: the requester never learns it was there. The table is for what only the requester can decide or do; before a row is written, test the item — would an answer other than yes be reasonable, and would a wrong yes be hard to take back? What passes neither test is done as above. What is outward-facing, hard to undo, or a change of direction stays a row, whatever its size.
- **Every message that ends while such items are open closes with all of them**, not only the ones that message raised, and including ones asked in an earlier session and the ones the requester has said they know about and will get to: an acknowledgement is not an answer, and "your two questions are still open" is a reference to the list, not the list. Each item is restated as the question itself. In a closing message that carries a next-session starter prompt the table sits directly above the starter, which stays last (`maintaining-project-memory` owns that form). One item is a sentence. Two or more are walked through first, each under its number in a paragraph of its own: the question itself; what it blocks; the answer you recommend and why; and what happens if no answer comes, and where acting on the answer means a command the requester runs, that command in full in a fenced code block of its own beneath the paragraph, after all four parts and never in place of one, and never inline or in the table. A numbered table then indexes them, one row per item, each cell a few words: the item's name, what it blocks, the recommended answer, what happens without one. A terminal draws a table as a grid only while every row fits in a few wrapped lines, so one cell of sentences, or a path or command whose unbroken length takes the width from its neighbours, turns the whole table into stacked records, and a command in a cell wraps where it cannot be copied whole. The recommendation is your own answer wherever something you read, ran or traced this session bears on it, and it stays your answer where the plan or the requester calls the decision theirs: recommending takes nothing from the decision's owner, who overrules by answering. Only where nothing you did bears on the answer does the item say so, and then it names what would. Without an answer the recommended one is taken and the work goes on from it; the work waits only where taking it is outward-facing, hard to undo, or a change of direction. The last cell opens with **Taken:** where the recommended answer is what happens without one, and with **Waits:** where it is not, and the item's paragraph says what holds instead and which of those three keeps the recommendation from being taken; a cell naming a different act from the recommendation without that word leaves the requester unable to tell whether silence takes it. Where a stronger reviewer model is configured for the session, each judgement row is put to it before the message closes, and its recommendation is the row's recommendation and default. The numbers stay the same from message to message, gaps and all — an item that leaves keeps its number retired, a lone item keeps its number too, and the message after one leaves says in a line beside the list which numbers left and how — so the requester can answer "2: yes" without quoting anything, and an answer given by number reaches the question it was given to.
- **An item leaves the table in one of three ways, each stated:** the requester answered it, the work went ahead on the default the table named, or the work no longer needs it, with a sentence saying why. An item that simply stops being listed is the silent closure *Every ask closes visibly* forbids, pointed the other way.
- **Work that does not depend on an open item carries on.** The table is the closing of a message, never a reason to stop.

## Red flags

| Thought                                        | Reality                                                                    |
|------------------------------------------------|-----------------------------------------------------------------------------|
| "I'll handle the side-ask after the main one"  | Un-ledgered deferral is how it drops. Write it down, then defer it         |
| "That request was mostly one big task"         | The trailing "and also…" is an ask. Enumerate before starting              |
| "I reported what I finished"                   | The requester needs the whole ledger — open items are the report's point   |
| "The agent will deliver it eventually"         | A promised deliverable is an open ask until the report lands               |
| "That item became moot"                        | Moot is a closure to state, not a silence                                  |
| "I asked that two messages ago, they saw it" | They saw it before three screens of work. Repeat it in the closing table until it leaves the table |
| "Only the new question belongs in this message" | The table is the whole set. A partial one teaches the requester to go back and search |
