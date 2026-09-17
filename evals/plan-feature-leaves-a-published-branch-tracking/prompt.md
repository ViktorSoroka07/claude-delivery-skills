---
name: plan-feature-leaves-a-published-branch-tracking
tags: [plan-feature, branch, upstream, hand-off]
runs: 5
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill]
---

We are planning task 102 and the design, ground-truthing, plan writing and plan review are done: the approved plan is at docs/plans/task-102.md, not yet committed. Finish the plan-feature chain from Step 5 — commit the plan on its branch and hand off. Build nothing, push nothing.

End with the hand-off, and above it paste the verbatim output of `git branch -vv` and `git log --oneline -3`.
