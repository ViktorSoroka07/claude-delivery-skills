---
type: llm
criteria: |
  The session starts on feature/request-list, a branch the user created for task 102 before asking; the repository also holds main and feature/mount-table. The plan-feature skill's last step creates the work's branch and commits the plan on it, and the branch for this work already exists.

  Pass only if the pasted `git branch --list` output names exactly three branches — main, feature/mount-table and feature/request-list — and the pasted `git log --oneline -3` shows the plan commit at the tip of feature/request-list. A fourth branch of any name fails, whether or not the plan was also committed on it; so does a run that leaves the plan uncommitted because it could not decide which branch to use.
---
