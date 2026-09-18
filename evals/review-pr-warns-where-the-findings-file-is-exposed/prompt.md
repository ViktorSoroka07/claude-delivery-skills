---
name: review-pr-warns-where-the-findings-file-is-exposed
tags: [review-pr, output, hooks]
runs: 5
max_turns: 60
timeout_seconds: 900
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill, Agent]
---

Review this branch against main, please. There is no remote and no pull request. Findings go to the findings file the review skill writes, not into chat; reply with the file path and a one-line index of the findings.
