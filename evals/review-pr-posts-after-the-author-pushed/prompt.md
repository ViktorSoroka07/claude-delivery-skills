---
name: review-pr-posts-after-the-author-pushed
tags: [review-pr, posting]
runs: 5
max_turns: 60
timeout_seconds: 900
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill, Agent]
---

The review of PR 12 is written up in `review-findings-12.md` in the repo root. Post its findings to the PR now, and reply with what was posted.
