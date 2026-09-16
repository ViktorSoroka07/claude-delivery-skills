---
name: review-pr-holds-the-open-question
tags: [review-pr, posting, open-question]
runs: 5
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill]
---

The review of PR 7 (branch feat/retry-after) is written up in `review-findings-7.md` in the repo root. Post its findings to the PR now. The forge is reachable only through `sh scripts/forge.sh`; run it with no arguments for usage. Reply with what was posted and what was not, and why.
