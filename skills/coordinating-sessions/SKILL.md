---
name: coordinating-sessions
description: Use when one session runs other long-lived sessions that each own a deliverable — a branch, a pull request, a measurement — forwarding the requester's rulings to them, taking their reports, pacing their context windows and handing their work to successors; and whenever such a session reports done, asks to hand off, or asks a question only the requester can answer.
argument-hint: "[sessions to coordinate]"
license: MIT
---

# Coordinating Sessions

A session you start is not a subagent. A subagent's result lands in your own turn and the agent is gone; a session outlives your turn, holds its own context window, talks to the requester in a chat of its own, and owns a branch for hours. `delegating-to-subagents` owns what the two share — a report is a claim about work, not the work — and `budgeting-agentic-work` owns the money. This skill owns what only a long-lived peer has: a design that can drift from the one the requester settled, two channels a ruling can arrive on, a window that fills while nobody watches, and a hand-over to a successor that has read none of it.

**Untested.** This skill landed without the baseline eval CONTRIBUTING asks of a new skill; its entry in `BACKLOG.md` holds the test still owed. Treat its wording as a first draft until that run exists.

Every rule below was paid for in real coordination work: a child about to build the requester's first words rather than the design refined after them; two sessions writing one branch; a build that ran on a larger model than the one named for it because no model was passed; a child that stopped and asked for a successor at a third of its window; a child's "ready to open the pull request" over a head that had not moved.

## Children build the settled design, never the opening ask

The requester's first message names a problem; the design is what the conversation makes of it afterwards. A child started from the opening ask builds the wrong thing with great care. Its brief is the design as last settled, in your own words, with the paths not taken and why, and the figures a judgement rests on. When the design changes after the child has started, the change reaches the child before it is next asked for anything, and the brief it would hand a successor changes with it.

## Rulings travel in the requester's words, and both channels hear them

A ruling forwarded as a paraphrase is a ruling re-decided by the forwarder. Send the requester's sentence, in order with the other rulings that bear on the same work, and say which question each answered. Then confirm it arrived by reading the child's transcript for the sentence; do not wait for an acknowledgement that may never come.

The requester can also speak to the child directly, so a ruling can arrive on either channel. What the child was told in its own chat reaches you only in its reports, and what you were told reaches the child only when you send it. A decision made on one channel is stated to the other before anyone acts on it, or the two sessions build to different rulings and each believes it holds the requester's word.

## A report is a claim; the branch is the fact

A child's "pushed", "resolved", "merged" or "ready" is checked where the state lives — the branch tip, the thread list, the check run, the merge state — before it is relayed, and the relay says what was checked. The one that is not checked is the one that is wrong: a round reported pushed over a head that had not moved, a finding reported fixed that the gate still counted. This is `delegating-to-subagents`' rule applied to a peer that keeps going on its own belief if nobody checks; the check costs one read, and the unchecked version costs a round.

The same holds for your own briefs. A child that corrects a claim in its brief is doing its job; the correction goes into the brief its successor gets.

## One writer per branch; ownership changes at a boundary

Two sessions alive on one branch produce two heads, and one of them loses. A branch has one session that writes it. When it must change hands — to a successor, or to a different owner for a review round — the first lands what it holds and says so, and the second starts from that state. A session that only reads may share a checkout; one that writes has the branch to itself.

## Start a session with what it cannot infer

A new session inherits whatever you do not set: your model, your effort, your permission mode. Pass the model named for the work every time; a build meant for the smaller model runs on the larger one silently, and only the bill says so. Pass the folder when the work lives in one particular checkout, such as the one holding a finished session's uncommitted diff. Name the session the child reports to, and ask every report for the head commit, what is verified, and the window figure.

## Pace the window from the harness's measure

Each child's context fills while it works, and nobody watches it fill. Read every session's window from the harness's own measure at each boundary, your own included, and report the figures to the requester. A child's estimate of its own window has been wrong by half, so a child that asks to hand off is checked against the measure before a successor starts, and one past the threshold the operator set is told to stop at a boundary. A child cannot compact itself without the operator's act, so the plan for a full window is a hand-over, not a compaction.

A hand-over is a note in a folder both sessions can read: what landed with its commits, what is left in order, the traps met, and a starter prompt the successor can take verbatim. The coordinator sends that prompt, with the settled design and the rulings, as the successor's brief. The coordinator's own compaction happens at a boundary, with a line naming what the summary must keep: each session by its id and what it owns, the rulings not yet written anywhere else, and the open-items table.

## A child's denial is surfaced, not routed around

A child refused an action by its own permissions says so; it does not ask a sibling to do it, and a coordinator asked does not. The refusal goes to the requester with the command ready to run, and the requester decides. A denial that a pending decision may make moot waits on that decision.

## Questions only the requester can answer go up, with a recommendation

A child's question for the requester reaches them through the coordinator's open-items table (`tracking-open-asks` owns its shape), retold from the side of the person using the product with what each answer changes, and carrying the coordinator's recommendation; the child meanwhile proceeds on the default it named. The requester's answer goes back in their words, and the table says which items left and how.

## Close what you started

A child whose deliverable has landed, or whose work has moved to a successor, is finished, and a finished session left open costs twice: its process and checkout stay allocated, and its branch stays checked out where the next owner cannot take it. The coordinator closes them, not the requester: at every boundary it names each session it started with its state — working, idle with work left, finished — and archives the finished ones, asking first where the harness asks and taking a refusal to the requester with the session named. The sweep is the coordinator's own step at the end of each landed piece, not a list handed over; a requester who has to read the session list and archive by hand is doing the coordinator's job (learned from real coordination work, where the requester did exactly that). `budgeting-agentic-work`'s "stop what you started" is the same rule for compute; this is its form for sessions.

## Where the harness gives you less

The rules above name moves, not tools, because harnesses differ in what a session can do to another. Three moves depend on the harness, and each has a fallback that keeps the rule:

- **Starting a session with a model, a folder and a brief.** Where no tool starts one, the coordinator writes the starter prompt in full — the settled design, the rulings in the requester's words, the report format and the window threshold — into the shared folder, and the requester opens the session and pastes it; the brief is the same text either way, so a harness that cannot start a session loses only the click.
- **Reading another session's window.** Where no tool reads it, the child reports its own figure from its status in every report, and the coordinator treats that figure as a claim: a hand-off request is weighed against the child's recent output rather than accepted, and the threshold is set lower to cover the error.
- **Reading another session's transcript.** Where no tool reads it, the shared folder is the record: a ruling counts as arrived when the child's next report quotes it, and a child is asked to quote it rather than acknowledge it.

Messages between sessions on one machine exist in most harnesses, and a session in a stricter permission mode may hold them for its operator's approval, so a sent ruling is confirmed by the record above, never by the send's success.

## Red flags

| Thought                                                      | Reality                                                                       |
|--------------------------------------------------------------|-------------------------------------------------------------------------------|
| "The child has the issue link; it knows the design"          | It has the opening ask. Send the settled design                               |
| "I'll summarise the ruling for it"                           | A paraphrase re-decides. Send the sentence                                    |
| "It said pushed"                                             | Read the branch tip. The one you do not check is the wrong one                |
| "It says it is near the limit"                               | Read the harness's measure. Children misjudge their own window                |
| "The default model is fine"                                  | The default is yours. Pass the one named                                      |
| "I'll file it, since the child was denied"                   | That launders a denial. Surface it                                            |
| "The requester told the child; the child will tell me"       | Only in a report you may not read in time. Ask, and tell the child what you heard |
| "Both sessions can share the branch for a bit"               | Two heads, one loses. One writer at a time                                    |
| "The requester can archive the finished ones"               | Closing what you started is yours. Sweep at each boundary, and ask where the harness asks |
