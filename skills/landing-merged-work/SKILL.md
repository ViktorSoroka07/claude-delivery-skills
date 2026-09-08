---
name: landing-merged-work
description: Use when work has landed on its target branch — a merged PR or MR, a completed local merge — and the branch, worktree, memory entries and tracker item it leaves behind need closing out; and, as a separate ask, when deciding which existing local branches and worktrees are safe to delete.
compatibility: Requires git; the tracker step requires an authenticated platform CLI. The forward path of integrating a branch you just finished belongs to the superpowers skill set (finishing-a-development-branch) or a repo's own fork — this skill owns the moment after that one ends.
---

# Landing Merged Work

The merge is where ownership lapses. A finishing skill hands the branch off at "PR open, the worktree stays until the work lands" — and then it lands in a different session, a browser tab, or on someone else's approval, and nothing fires. What is left behind is a local branch that ancestry commands call unmerged, a worktree nobody claims, memory entries describing finished work, and a tracker item closed in fact and open on the board. The board is what gets re-asked.

Close it out as one operation: **establish it landed → sweep → re-point what named it → close the item.** Half of it done looks exactly like none of it done, because the only part anyone sees later is the part that was skipped.

**The scope is the work that landed** — its branch, its worktree, the memory entries and the tracker item that name it — not every local branch. Judging every other local branch and worktree is the second trigger above: a separate ask, priced before it runs (`budgeting-agentic-work`), because each candidate costs a fetch, a containment test and a report line, and the operator who asked about one branch did not buy the rest.

## Establish it landed — ancestry tests lie about squash-merges

**`git branch --merged` and `git merge-base --is-ancestor` report *unmerged* for every squash-merged branch.** The squash commit carries no ancestry link back to the branch it collapsed, so those commands answer a question about graph reachability, not about whether the work shipped. "Unmerged" from either is not evidence that anything would be lost — and `git branch -d` consults the same reachability, so it refuses the deletion for the same wrong reason.

**The evidence is the request's recorded head.** Ask the forge which head SHA it merged (`gh pr view`, `glab mr view`, `az repos pr show`), then test containment:

    git merge-base --is-ancestor <local-tip> <recorded-head>

Contained means everything local went into the merge — including the case where the forge pushed commits the local copy never saw. Not contained means local commits the merge did not carry: that is a finding, and it stops the deletion.

Before reporting a not-contained tip as lost work, test whether it is an earlier round the merge superseded — the usual shape after review fixes were pushed from another checkout. Per-commit patch ids cannot answer that across a squash. Two diffs can: `git diff <local-tip> <recorded-head>` reading as the merged side correcting the local one, and `git diff <base> <recorded-head> -- <paths the branch touched>` coming back empty. Any residue is attributed with `git log <recorded-head>..<base> -- <path>`.

**A failed command returns the same empty output as a passing one.** Once the remote branch is pruned the recorded head is no longer a local object, so the comparison errors — and with stderr suppressed, the empty result reads exactly like a clean pass. Fetch the request's published head ref first, then prove the object is local before believing any answer about it:

    git cat-file -e <recorded-head>^{commit}   # non-zero here means the verdict below is invalid, not clean

Never accept an empty result from a command whose exit status went unchecked. **When this checklist gets trimmed, this is the item to keep:** the others fail loudly and get rediscovered, while this one issues confident false clearance.

**File existence is not content equality.** That every changed file exists on the base branch says nothing about what is in it. The comparison is between contents, at the paths the branch touched.

## A branch with no request at all is the dangerous case

Nothing exists to compare against, so the question changes from "did it merge" to "does this content exist anywhere else":

    git diff <base-tip> <branch-tip> -- $(git diff --name-only $(git merge-base <base-tip> <branch-tip>) <branch-tip>)

Report the count of paths that still differ — those hold content that exists only there. **Report it; do not decide it.** Such a branch is either abandoned or unfinished, and which one it is exists only in the author's head.

## Deletion is reversible only if the SHA is printed with it

Deleting a branch deletes its reflog too, so its commits become unreachable and the recovery window ends at the next garbage collection — after which the work is gone, not archived. **Announce every deletion with the tip SHA and the command that restores it** (`git branch <name> <sha>`), in the same message. A SHA recoverable only by searching a transcript is not a safety net.

Prune only worktrees your own tooling created; a workspace the host manages stays where it is — `finishing-a-development-branch`'s cleanup step owns that boundary, including what to do when removal is refused because files exist nowhere else.

## Deleting a thing and re-pointing what named it are one operation

Notes, memory entries, plan docs and tracker comments that name a deleted branch become false the moment it goes, and a later session reads a stale pointer with full authority — never as a guess. Prune in the same pass: `maintaining-project-memory` owns the memory write discipline (including deleting branch state outright once the work merges), `writing-plan-docs` owns the plan document's rewrite into the spec of what shipped.

## Close the tracker item

**Only items you own change state.** Where the work landed on someone else's item, say so in a comment; the state change is theirs to make.

- **Effort and estimate fields are operator-only inputs — ask, never infer.** Elapsed session time and commit timestamps are not hours worked, and a guessed number is indistinguishable from a measured one the moment it reaches a report someone runs. Ask for them at the *start* of the close-out, so the run does not stall at the end waiting on a human.
- **A value that is legal while the item is open can be rejected on closure.** Workflow validation fires on the transition, so a number written for tidiness — a zero into a remaining-effort field — fails the whole update. Omit the field rather than zeroing it.
- **Read the parent from the tracker before rolling it up.** Close a parent only when every child is closed there, not when every child this session touched is closed.
- **A tracker's rich-text fields can carry a per-field format, and a write in the wrong one fails silently.** Where fields are HTML or Markdown per field and new items default to HTML, Markdown sent into an HTML field is stored and read back unchanged and renders as literal asterisks — the content read-back that guards every other send passes over it. Read the field's format back before writing a comment or description, and set format and value in the same write. On Azure DevOps, `references/ado.md` carries the mechanics.
- **The closing comment names the merge commit and what now behaves differently** — never the session, the model, or the round count. (`writing-commit-messages` owns the same boundary for commit messages.)
- **An item the merge closed for you still needs that comment.** Where the forge honours a closing keyword in the request body it changes the state itself, so the close-out arrives to find the item already closed and reads the board as done; where it does not, the state is still yours to change. It is not: the state changed and the record did not, leaving an item closed with no trace of where the work went — the same "re-asked later" failure as leaving it open, and harder to notice because the board looks right. Enumerate every item the request named, not the ones you expected to close by hand.
- **One request usually settles several items, and one comment does not serve them all.** Each item asked something specific, and its comment answers *that* ask in its own terms — what a reader of that item would go and check. The same text pasted across all of them reads as an announcement rather than an answer, and buries the one detail each reader came for.
- **Items the request referenced but deliberately did not close need a comment too.** A follow-up split out on purpose reads as forgotten unless something on it says which half landed and which is still open. Where the split turned on a measurement, record the measurement there — the next person decides with it, and it is the thing least likely to survive in anyone's head.

## Red flags

| Thought | Reality |
|---|---|
| "`--merged` doesn't list it, so it isn't merged" | A squash-merge breaks ancestry. Check the request's recorded head |
| "`branch -d` refused, so unmerged work exists" | It consults the same reachability the squash broke |
| "The check came back empty — clean" | An errored command is empty too. Check the status; prove the object is local |
| "Every changed file is on main already" | Existence is not equality. Compare contents at the paths the branch touched |
| "No request, no activity — safe to delete" | No request means no evidence. Report what exists only there; the author decides |
| "The SHA is in the scrollback if they want it" | Deletion drops the reflog. Print the SHA and the restore command with it |
| "I'll prune the memory entries next session" | The stale pointer is authoritative the moment the branch is gone |
| "Zero the remaining work so it closes clean" | Validation fires on the transition. Omit the field |
| "It was about a day — I'll put eight hours" | A guessed number becomes a reported fact. Ask; it is an operator-only input |
| "The branch is gone, so the item is obviously done" | Closed in fact and open on the board is the state that gets re-asked |
| "The merge closed the items — nothing left to do" | The state changed; the record did not. Every item the request named still needs its comment |
| "One close-out note, posted to each item" | Each asked something specific. Answer it in that item's own terms |
