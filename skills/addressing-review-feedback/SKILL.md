---
name: addressing-review-feedback
description: Use when review feedback has arrived on your own pull request or merge request — from a person, a review bot, or a scanner — and it needs working through — "address the comments", "go through the review", "check the bot threads", "reply to the reviewers", "resolve the threads"; and when a thread already marked resolved needs re-checking before merge.
compatibility: Requires git and an authenticated platform CLI - gh (GitHub), az / a PAT in AZURE_DEVOPS_EXT_PAT (Azure DevOps), or glab (GitLab). Platform mechanics (reading threads, replying, resolving) are review-pr's references; this skill owns the author's seat.
---

# Addressing Review Feedback

Review feedback on your own change arrives from three kinds of author on three kinds of surface, and the work is done only when every item has a verdict, every verdict has a reply, and every reply points at something the reviewer can see. Four failures recur (learned from real review rounds): an item nobody listed because it sat in a collapsed section or a review body; a suggestion applied because the reviewer was usually right; a reply citing a commit that existed only locally; and a thread marked resolved over code that never changed.

**Inventory → verify → apply → reply and resolve.** The order matters because each step's output is the next step's checklist, and the inventory is what the closing gate is measured against.

## 1. Inventory: every surface, every author, before anything else

Pull every surface before forming a single verdict. A forge splits feedback across places that do not link to each other, and a bot's own summary line ("N actionable comments") counts only what it chose to post inline:

- **Inline review threads**, with their resolved state and every reply.
- **Review submission bodies** — a bot folds nitpicks and out-of-diff observations into collapsed sections there, and they never appear as threads.
- **Request-level comments** — a teammate's question, a scanner's list, a status bot.
- **Comments on files the change does not touch** — a doc the change invalidated, raised at request level because the platform cannot anchor it.

Write the inventory as a table with these columns, one row per item, before verifying any of them:

| id | surface | author | state | the claim, in one line | verdict | action |
|---|---|---|---|---|---|---|

**Resolved threads are in scope.** A thread's state records that someone pressed a button; only the code records whether the request landed. Re-read the line each resolved thread anchors on at the current head — a request still visible in the code is an open item wearing a closed label, and one whose request did land needs no row and no reply.

Nothing gets a reply, a commit, or a resolve without a row. The table is also the closing gate: the run ends when every row's action is done, not when the visible threads look quiet.

## 2. Verify: a reviewer's finding is a claim, and so is a suggestion

Evaluate each row with the receiving-code-review stance where the superpowers skill set is installed — verify against the codebase before implementing, push back with reasoning, no performative agreement — and grade it with `review-pr`'s finding rules, two of which do most of the work here:

- **An absence claim names its authority.** "This accepts an empty value", "nothing validates X": go and find the layer that would supply the constraint — the caller, the reader the value passes through, the type — before accepting that it is missing. A guard that already exists one layer down makes the finding unreachable, and adding a second copy of it gives the rule two owners that will drift. *"The function itself is unguarded even if the caller is safe"* is the rationalization to watch for: it argues for duplicating a rule instead of naming who owns it.
- **A documented-deliberate decision is acknowledged before it is questioned.** If the plan, the spec, or a code comment records why the code is the way it is, the reply cites that record; the finding is not re-litigated from scratch.

**A suggestion is a behavior change, and the way to check one is to construct the input where the old rule and the new rule disagree.** State what each returns for it. A stricter check that falls through to a laxer branch on rejection is the common trap: tightening a parser so a previously accepted value now reaches a lenient fallback turns a harmless tolerance into a wrong answer. If no input separates the two rules, the suggestion changes nothing and is declined as a no-op; if one does, that input decides the verdict.

"The bots are usually right" is a prior, not a verdict. It sets how much effort verification deserves, never whether it happens.

Four verdicts, and every row gets exactly one:

| Verdict | Meaning |
|---|---|
| **apply** | The claim held against the code; the fix lands on this branch |
| **reject** | The claim did not hold; the reply carries the evidence |
| **out of scope** | A real condition that predates the change or lives outside it |
| **answer** | A question; the reply is the whole action |

**Where an out-of-scope item goes depends on whose debt it is.** A gap in this change's own work belongs in this change's plan document. A pre-existing repository condition a bot surfaced only because the diff touched a nearby file does not: recording it in the plan makes twenty untouched instances read as this change's debt, and the next bot run comments on the note itself (learned from a real review round). It gets its own tracker item, or nothing.

## 3. Apply: one commit per workstream, every fix's test red first

Fixes from one review round are still separate workstreams — a log-line fix and a doc correction would be reverted separately, so they are separate commits (`writing-commit-messages` owns the split and the message; the message describes the change, never the reviewer or the round). Every fix that changes behavior gets a test that fails against the pre-fix code, with the finding's own mechanism as the expected failure — a fix-shaped test that never went red proves nothing. Run the repo's gates after the last change.

Where the repo's convention is that pushing needs the author's OK, stop there and say what is committed and what is waiting; the reply step below is keyed to the push, not to the commit.

## 4. Reply and resolve: timing is keyed to the remote

Every row gets a reply, in the author's own voice, stating the disposition and its reasoning — rejections and out-of-scope verdicts included, because the reply is where the reasoning lives for the next reader. A reply states what was done or why not; "good catch" and "thanks" are not dispositions and go under the author's name.

**When a reply may post is decided by where the commit is, not by whether it exists:**

- **Rejections, answers, and out-of-scope verdicts post immediately.** They depend on no commit, and posting early lets the reviewer push back before more work stacks on top.
- **A fix reply posts only once its commit is on the remote** — the check is that the remote branch contains the SHA (`git branch -r --contains <sha>`), not that `git log` shows it. A "fixed in <sha>" citing a local commit points at nothing the reviewer can open; if the push is waiting on someone's OK, the fix reply waits with it. Cite SHAs the way the platform links them (review-pr's platform reference: bare on GitHub, never in code formatting).

**Resolve every thread you dispositioned**, rejections and deferrals included — a thread left open as a reminder reads as unaddressed to every other reviewer and can gate the merge. A thread found resolved over unchanged code stays resolved once the fix lands; it gets a reply naming the commit so the state and the code agree again. Request-level comments have no resolve state; the reply is the whole disposition.

**Closing gate: zero unresolved threads by the platform's own query, and every inventory row actioned.** Then look for what the replies provoked: a bot marks a rejection as addressed or withdrawn, or raises a new point in its reply, and a scanner needs its rescan trigger where the repo has one. A new point is a new inventory row.

## Red flags

| Thought | Reality |
|---|---|
| "The bot said N actionable comments, so N items" | The count is what it posted inline. The collapsed section and the review body are not in it |
| "The thread is resolved, skip it" | The button was pressed; the code decides whether the request landed |
| "The bots are usually right — apply it" | A prior sets the effort, not the verdict. Find the layer that owns the constraint |
| "The function isn't safe on its own, harden it anyway" | That duplicates a rule the layer below owns. Two owners drift |
| "It's stricter, so it's safer" | Construct the input the old and new rule disagree on. Stricter checks fall through to laxer branches |
| "I'll cite the SHA now and push in a minute" | The reviewer opens the link now. The remote must contain the commit first |
| "Leave the thread open so we remember" | An open thread reads as unaddressed and can block the merge. Reply with the plan, then resolve |
| "One commit: address review feedback" | Separate workstreams, separate commits. The message describes the change, not the round |
| "Note the scanner's finding in the plan's follow-ups" | It predates the change. Its own item, or nothing — the plan is this change's debt only |
| "Threads are quiet, we're done" | The inventory is the gate, and so is the platform's unresolved count |
