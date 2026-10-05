---
name: review-pr-reviews-a-forks-request
tags: [review-pr, setup, fork]
runs: 5
max_turns: 60
timeout_seconds: 900
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill, Agent]
---

Review PR 12, please. Findings go to `review-findings-12.md` in the repo root, not into chat; reply with the file path and a one-line index of the findings.
