---
name: delegating-to-subagents
description: Use when handing work to subagents — writing dispatch briefs, partitioning parallel edits across agents, deciding whether a silent agent is stuck — and whenever anything a subagent produced is about to be used — an identifier wired into code, a diff committed, a finding acted on, a "done" accepted.
compatibility: Claude Code-native — assumes the Agent tool and subagent machinery. The decision to fan out belongs to the superpowers dispatch skills or a repo's own; this skill owns collision-safe partitioning and everything around and after the dispatch.
---

# Delegating to Subagents

**This skill does not decide when to delegate** — the superpowers dispatch skills own that decision and the shape of a good brief; call the Skill tool with them rather than restating them here.

What it adds is what dispatch skills lack: collision-safe partitioning, and the discipline that a subagent's output is a **claim about work, not the work**. Every rule below is one where treating the output as fact shipped a defect or lost a session's worth of results — briefs that were followed into a bug, diffs committed with the agent's monologue in them, identifiers pasted from a report straight into runtime code, and reports that never arrived at all.

## Before dispatch

**Know the agent type's isolation before giving it edits.** A repo's custom agent types may run in a fresh git worktree by default — even when isolation was not requested — and a worktree can be branched from a stale base commit where the target files do not yet exist. Edits made there never land on the current branch. Two agents once produced correct designs that could not be applied for exactly this reason, costing the whole parallel round. When edits must land on the current working tree, use an agent type known not to isolate; if an agent reports "edit the worktree copy instead" or that target files are missing, it is isolated on a stale base — re-delegate or apply the hunks yourself.

**Partition parallel edits by file ownership, never by finding.** Several findings usually live in one file; handing agents findings means concurrent writes and lost edits, handing them files makes collisions structurally impossible. A finding that spans a boundary gets split at the boundary. Three boundaries file ownership does not protect:

- **Git.** No agent sharing a tree — the working tree, or a worktree other agents read — runs a git write command (commit, restore, stash, reset, add): repo-wide operations respect no file boundary. The sole occupant of its own dedicated worktree may restore or reset files there; commits stay the orchestrator's everywhere, one per workstream, after verifying that workstream alone.
- **Verification.** Typecheck and tests are repo-wide, so one agent mid-edit reddens everyone else's run. Serialize the workstream that changes types everyone reads.
- **The file itself.** While agents share a tree, `git show <sha>:<path>` at the pinned commit is the only fixed point — the copy in the tree may be mid-edit by someone else, so re-read from the object before asserting anything about a file. An agent that must transform a shared file works on a scratch copy and writes the result back in one step: an in-place, unbounded rewrite once left the file wrong for minutes and hung the suite every other agent runs. To preserve a dying agent's uncommitted work, `git stash create` followed by `git update-ref` records it as a commit object without touching the tree; a plain `git stash` reverts the tree under everyone.

Specify cross-boundary contracts yourself, upfront (the exact shape, the exact name), so two agents cannot disagree about a seam neither owns.

**Make the brief falsifiable.** The dispatch skills own brief structure; what they miss is falsifiability — state mechanisms and expected behavior precisely enough that the agent can prove you wrong. In one large remediation, three agents corrected the orchestrator's own instructions: a wrong rule, an overstated finding, an upstream reference implementation that was itself broken. A vague brief would have been followed, and the bug shipped.

**Put the delivery instruction in the spawn prompt, and make long work recoverable from disk.** Background agents can finish without their final text ever reaching you — completion arrives as a bare idle signal. End the spawn prompt by naming exactly how the report must be delivered. Tell any long-running agent to *script* its work and write its running results to a file as it goes: when one vanished at a session boundary — unreachable, results gone — its scripts survived, and re-running them cost minutes instead of a fresh dispatch from zero.

## While it runs

**Idle is not done, and silence is not death.** Agents routinely go idle without delivering — pull the report explicitly, restating the exact output format wanted. But before concluding a quiet agent is stuck, sample its workspace two or three times, a minute apart: a build or mutation agent's tree oscillates between dirty and clean, so one clean sample proves nothing. An orchestrator once "took over" for an agent that was mid-run, overwriting its driver script under it. If you do take over, use a different worktree — never the agent's own.

**Address agents unambiguously.** Names can collide across sessions, and a message by name can reach a stale agent that worked on something else entirely — use the id, or the name with the disambiguating ref the harness lists when two rows share it.

**Budget the rescue.** Two status pings with nothing back: stop the agent and do the work yourself. The findings are the deliverable, not the delegation. When a dead agent left scripts behind, re-run those in its now-free workspace rather than re-dispatching from zero.

## When results come back

**Verify every identifier before wiring it into shipped code.** A research agent hands you a function name, tool name, file path, endpoint, flag: grep the actual source or fetch the real file yourself before it enters runtime code. Citations in the report — file, line, a code quote — are necessary but not sufficient; agents have fabricated those too, under the phrase "confirmed from source". One startup check was built on a tool name the agent invented: it rejected every input, valid or invalid — strictly worse than no check at all. Spot-check the two or three highest-stakes identifiers per research run; where a wrong identifier would reject or destroy rather than merely miss, also add a runtime check that degrades gracefully when the identifier turns out not to exist.

**Audit the diff before committing it.** Discipline stated in the brief does not survive delegation: an agent treats an explanatory comment as evidence it understood the problem, so the brief's "no narrating comments" yields three-to-five-line monologues anyway. Before committing any subagent's work, read the diff — every added comment against the repo's bar (`writing-code-comments` where the repo states none), every hunk against the brief. This is still write-time; nothing is committed yet. Tell the agent upfront that the sweep is coming and that its reasoning belongs in its report, where the insight is actually wanted.

**Treat findings and "done" as claims.** This skill owns that rule for every delegation; review-pr applies it with review-specific mechanics. A reply that does not name the exact commit or object it read is unverified. Verify a delegated agent's findings at source before acting — repeated real rounds each contained one finding whose fix would have been mis-scoped without that check. And when delegation fails and you do the work yourself, say so where the summary is read, not buried in a file: the loss is independence — a second reader who never saw your framing — and the reader deserves to know it is gone.

## Red flags

| Thought                                       | Reality                                                                          |
|-----------------------------------------------|----------------------------------------------------------------------------------|
| "The brief said no comments, so there are none" | The brief is not the enforcement point. The diff is                              |
| "The report cites file and line"              | Agents fabricate citations. Grep it yourself                                     |
| "The agent went idle, so it's finished"       | Idle means available. Pull the report explicitly                                 |
| "Its tree is clean, so it's stuck"            | One sample proves nothing — it may be between operations. Sample again, then ask |
| "I'll just fix it in the agent's worktree"    | You are overwriting a live agent's work. Use a different worktree                |
| "Re-dispatch a fresh agent"                   | If the dead agent left scripts, re-running them is minutes, not a fresh run      |
| "The reviewer confirmed it, apply the fix"    | A finding is a claim. Verify at source; note which commit the reviewer read      |
