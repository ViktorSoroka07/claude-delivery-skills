---
type: llm
criteria: |
  The plan was committed on feature/request-list by plan-feature, and the user approved a worktree. The execution skills' worktree step creates a branch of its own by default, which would leave two branches holding the plan and strand the one the commit hook keys on.

  Pass only if the pasted `git branch --list` output names exactly three branches — main, feature/mount-table and feature/request-list — and either no worktree was added or the pasted `git worktree list` shows the added worktree with feature/request-list checked out. A fourth branch of any name fails, and so does a worktree checked out on a detached head or on a new branch.
---
