---
name: writing-commit-messages
description: Use when a commit is about to be made — "commit this", staged changes waiting, a fix-up after review, a delegated diff the orchestrator is committing — and when a commit message is being edited or squashed before a push.
---

# Writing Commit Messages

A commit message is read after the branch is gone: in blame, in generated release notes, and by the PR description that curates its body. It is the durable record of **why the tree changed**, so it describes the change and its mechanism, never the session that produced it.

## The shape

1. **Subject: the outcome of applying the commit**, imperative, in the repo's own convention — read `git log --format=%s -20` before writing the first one. It states what is true after the commit, not the activity: "Address review comments", "Fix typo", "Update summary", "WIP" tell the reader nothing they can act on.
2. **Body: the mechanism**, whenever the subject cannot carry it — what was wrong or missing, and why this shape of change. Present tense for what now holds. This is the "why" the PR description curates and the release notes print; if it is not here, it is nowhere.
3. **Trailers: only the ones the repo's own history or contributing guide asks for** — an issue reference, a sign-off. A trailer a tool or harness offers by default is that tool's convention, not the repo's; the repo's log shows which trailers exist here.

Example of the shape (invented):

> **Retry the export upload once on a gateway timeout**
>
> The upstream gateway drops long uploads with a 504 a few times a day,
> and every one of them surfaced as a failed export the operator had to
> rerun by hand. A 504 now retries once after a short pause; any other
> failure still fails the export immediately.

## What the message never carries

- **Who asked, and when.** "As the reviewer requested", "after the demo", "per our discussion" — the request lives in the thread and the ticket; the commit records the change. A reference the repo's convention asks for ("Closes #12") is a trailer, not narration.
- **The session's route.** Attempts, reverts, "also while I was in there". The diff shows what changed; the message says why.
- **The file list.** `git show --stat` has it, with provenance.

## One commit per workstream

Staged changes that would be reverted separately are separate commits. The test: if one of them turns out wrong, can it be reverted without the other? "Also fixed X while there" in a draft body is the tell that two workstreams are staged as one — split them (`git add -p`) before writing either message.

The split follows what compiles, not the kind of file: an existing test that now specifies the changed behavior belongs in the commit that changes the behavior. Split into a separate tests commit, the source commit fails its own suite and breaks bisect across the range. Check each commit of a split at its own SHA in a detached worktree — the working tree that resembles the last commit says nothing about the first.

A fix to a mistake made on this same branch, before anyone reviewed it, is not a commit with a story: mark it for the commit it fixes (`git commit --fixup <sha>`). The squash that rewrites history is the author's decision — perform it only when the branch is unpushed and the user has asked for it; otherwise leave the fixup commit in place and say it is there. After review, the fix is its own commit whose message describes the delta, not the review.

## Delegated diffs

When an agent produced the diff, the orchestrator commits it (`delegating-to-subagents` owns that rule) and writes the message from the diff and the brief, never from the agent's report — the report narrates; the message states.

## Red flags

| Thought                                        | Reality                                                           |
|------------------------------------------------|--------------------------------------------------------------------|
| "The reviewer asked for this — say so"         | The thread holds the request. The message holds the change        |
| "It's tiny, 'fix typo' is enough"              | Say what is now correct. The subject is the outcome               |
| "I'll mention the other thing I fixed"         | Two workstreams, two commits. Split first, then write             |
| "The tool adds a trailer, leave it"            | The repo's log decides which trailers exist here                  |
| "The agent's summary is the message"           | The report narrates; the message states the mechanism             |
| "It's a fixup, I'll squash it now"              | History rewrites are the author's call. Mark it, say it is there  |
| "The PR description will explain it"           | It curates from bodies. An empty body leaves it nothing to curate |
