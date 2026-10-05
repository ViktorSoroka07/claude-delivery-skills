---
name: review-pr-keys-a-percent-encoded-remote
tags: [review-pr, output, storage]
runs: 5
max_turns: 60
timeout_seconds: 900
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill, Agent]
---

Review this branch against main, please. There is no pull request yet, and the remote cannot be reached from here. Reply with where the findings are and a one-line index of the findings.
