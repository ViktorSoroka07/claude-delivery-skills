---
name: implement-plan-keeps-the-plans-branch
tags: [implement-plan, branch, worktree]
runs: 5
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill]
---

Implement the plan at docs/plans/task-102.md; it was committed on this branch by plan-feature. This is a dry run: read the plan, settle its premises, then set up the workspace for Step 3 exactly as the execution skill directs — I approve a git worktree for this work, do not ask again — and stop before writing any code.

End with a report that pastes the verbatim output of `git worktree list` and `git branch --list`, and names the branch the implementation will commit on.
