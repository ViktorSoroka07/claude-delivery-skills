---
name: maintaining-project-memory
description: Use when writing, pruning, or restructuring project memory entries, when a merge or shipped milestone leaves memory describing finished work, when ending a session whose work continues in a later one — and whenever a statement is about to be copied from chat, a memory, or one document into another.
compatibility: Claude Code-native — assumes a per-project memory directory (entries plus a MEMORY.md index) that later sessions load.
---

# Maintaining Project Memory

A project memory is not a notebook — it is a **promotion tier**. A line written there executes with full authority in a later session that has no way to question it: a stale still-to-push note reads as a live obligation, and a rule whose scope was dropped at the write step fires as an absolute. Both failure directions below shipped in real work; both were invisible to the session that wrote them.

## What memory holds — and what it must not

Memory holds what the repository **structurally cannot** record. Git records what changed and when; a PR body records the net delta; a plan doc records the intended end state. None of them record the paths *not* taken — nobody commits a file explaining what they didn't build. This skill owns the memory-write discipline; `implement-plan`'s finish step applies it at end of task.

### Keep, because nothing else holds it

- **Approaches tried and rejected, with the reason** — "a size cap here would reintroduce the truncation bug the last fix removed" stops a future session from re-proposing the cap as obvious hygiene.
- **What live verification showed where no committed record holds it** — a mid-session observation that contradicted a green suite, in a repo whose plan docs carry no verification record. Where the shipped spec's record exists, memory keeps at most the pointer to it.
- **Environment and tooling traps** — the exact steps that reproduce a hang, a dev server serving stale code after a reload, git operations unsafe when two checkouts share one repository.
- **Decisions still genuinely open, and who owns them.**
- **User conventions confirmed in passing.**

### Delete what a better source already answers

**Delete branch state outright when the work merges.** Branch tips, unpushed-commit counts, divergence flags, open reminders to push or tidy the tracker — version control answers these correctly, forever, in milliseconds. Duplicating them into memory maintains a worse copy of a perfect source, and the stale copy outlives the branch.

**The test before writing a line:** is this in the code, a commit message, the PR body, the plan doc, an issue — or a skill? If yes, it is a duplicate that will drift from the authoritative copy. (A fact that *contradicts* the repo's obvious reading — the gate command that isn't what the scripts suggest — is a trap, not a duplicate.) **The issue tracker is the source everyone forgets** — one pruning pass "rescued" a decision as unrecorded when an issue was titled for that exact decision and even stated its open half. Search the tracker before concluding something lives nowhere; decisions relayed verbally are precisely what gets written into an issue rather than into code.

### Promotion into a skill

**Promotion into a skill triggers the same deletion.** When a memory's content graduates into a skill, the skill becomes the procedure's durable home, and the memory is condensed — in the same session, not later — to the three things the skill cannot hold:

- **a pointer naming the skill**, with the instruction to follow the skill's current text, never a paraphrase of it here — one retained paraphrase went stale while the skill moved on, and the stale copy is what the next session obeyed;
- **the private or project-specific facts** a published skill must not carry (incident identifiers, repo-local values);
- **a capture buffer**: a new correction lands in memory first, gets confirmed in practice, then promotes into the skill re-derived, per "A memory write is a promotion" below — and the memory line condenses again.

Leaving the full text in memory after promotion creates two authoritative copies, and the one that drifts is the one sessions load first.

### The pruning pass

Mechanics for the pruning pass itself:

- **Not every finished-work memory is branch state.** A decision record — architecture chosen, alternatives rejected, deployment constraints — keeps its reasoning even after the merge; only chronology dies. Read what a file actually contains before trimming it.
- **Commit hashes survive a merge commit and die on a squash.** Verify a cited SHA still resolves before treating it as dead — and prefer symbol anchors regardless (`writing-plan-docs`' reference rules own the anchoring discipline).
- **Rewrite in place to current state; never append a correction.** The same end-state discipline `writing-plan-docs` applies to plan documents. Update existing entries over creating near-duplicates, and keep the index line in step.
- **The pass covers the store, not one directory.** Per-checkout state is keyed by the checkout's path, so a renamed, re-spelled, or ephemeral checkout (a task worktree, a scratch clone) leaves a directory its path no longer reaches, and a session that opens one reads it as authoritative — one such twin produced a false "no memory exists" finding. List the store's directories against the checkouts that exist on disk and delete those whose path is gone, checking recency first so an oddly spelled live directory is not mistaken for a dead one. At any session's end, glance for a twin of the current checkout; the full sweep runs when a pass is asked for.

## A memory write is a promotion — re-derive, never copy the wording

When a statement crosses a tier — chat into a memory, a memory into a spec, a spec into someone's wiki — **re-derive it from its mechanism and keep its boundary condition inside the imperative itself**. The scope-strip happens at the *first* summarization step, within hours, not at some later document boundary: a reply scoped to one framework-owned surface was summarized the same day into an unscoped "never", and the absolute then survived every later review — each reader saw only a faithful paraphrase of the tier before. The conflict it created existed in no one's actual statements; the paraphrase manufactured it.

Test qualifiers in **both** directions:

- **A dropped qualifier is falsely broad.** For any always/never rule, ask "under what conditions is this false?" — if the answer is not in the sentence, the sentence is not ready to promote. It fails loudly somewhere, eventually.
- **An added qualifier is silently narrow — the worse direction.** Guidance once shipped scoped to work driven by one tool, when the mechanism worked for any producer; the first excluded case was the author's own workflow. An over-narrow rule just stops firing, with no error — and reviewers cannot save you: of four blind readers, the one who flagged the stray qualifier proposed *defining* it, not deleting it. For every qualifier present, ask "does the mechanism require this, or did it ride in from the circumstances of writing?"

**The care owed scales with how executable the destination is.** A wrong sentence in prose misleads a reader who may notice. In a test plan, runbook, CI config, or generated code, it becomes a failing artifact: a sentence claiming the platform links two settings it actually treats as independent was copied into a test-plan table minutes after being flagged as wrong in the very spec it came from; a test built from that row asserts behavior that does not exist and fails against a correctly configured system, reading as an implementation defect. Copying from the document you are correcting is the highest-risk hop, not the safest — familiarity with the sentence is what makes it feel already-verified.

This section owns the writer-side rule; `review-pr`'s doc-vs-code axis applies the same qualifier test from the reviewer's side.

## End a continuing session with the literal starter prompt

When work continues in a later session, finalize first — commit, and update the plan doc's next-steps section so it stands alone. Then **end the user-facing message with the verbatim prompt to paste into the next session**:

- It names the **concrete next unit of work** — never "continue".
- It lists every **operator-only input** — a cost figure only the user can read, an approval only they can give. A handoff that names the prompt but not those inputs silently drops them: one plan doc's own "start the next session with" line omitted the figure, and the plan's own tracking table would have gone another round with "pending" in it.
- The **same wording** goes in the plan doc's next-steps section, so a session that reads only the doc gets the same instruction.
- If nothing is needed from the user, the starter line is the whole closing — no summary tail after it. If something is needed (a push approval, a decision), state that first and put the starter last.

## Red flags

| Thought                                            | Reality                                                                             |
|----------------------------------------------------|--------------------------------------------------------------------------------------|
| "Record the branch state so nothing is lost"       | Version control already answers it, correctly, forever. The copy goes stale         |
| "This decision isn't written down anywhere"        | The issue tracker is the source everyone forgets. Search it first                   |
| "The PR merged — collapse its memory file"         | Decision records keep their reasoning; only chronology dies. Read before trimming   |
| "I'll summarize the rule for the memory"           | Summarizing is where the scope strips. Re-derive, boundary inside the imperative    |
| "This sentence is from the doc I'm fixing"         | The familiar copy is the highest-risk hop — it feels verified and is not            |
| "The qualifier makes it more precise"              | If the mechanism doesn't require it, it silently narrows the rule until it stops firing |
| "I'll append the correction below the old line"    | Rewrite in place to current state — the next session reads the file as one truth    |
| "The next session will figure out where to resume" | Print the literal starter prompt, with the operator-only inputs it needs            |
