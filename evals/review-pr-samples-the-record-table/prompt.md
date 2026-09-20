---
name: review-pr-samples-the-record-table
tags: [review-pr, mutation-record, grading-rules, second-domain]
runs: 5
max_turns: 60
timeout_seconds: 900
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Agent, Skill]
---

Review this branch. There is no remote and no pull request: review the local branch against main. Findings go to `review-findings-harden-ingest-guards.md` in the repo root, not into chat; reply with the file path and a one-line index of the findings.
