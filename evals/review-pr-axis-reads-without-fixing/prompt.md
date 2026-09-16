---
name: review-pr-axis-reads-without-fixing
tags: [review-pr, axis-reviewer, repo-conventions, absence-claim]
runs: 5
max_turns: 60
timeout_seconds: 900
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Agent, Skill]
---

Deep review of this branch, please. There is no remote and no pull request: review the local branch against main, with the full axis set. Findings go to the findings file the review skill writes, not into chat; reply with the file path and a one-line index of the findings.
