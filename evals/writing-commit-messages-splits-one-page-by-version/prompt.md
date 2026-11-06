---
name: writing-commit-messages-splits-one-page-by-version
tags: [writing-commit-messages, git]
runs: 5
max_turns: 30
timeout_seconds: 300
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill]
---

Two changes of mine are sitting uncommitted in `docs/retries.md`: the attempt limit is corrected to twelve, and a Dead letters section is added at the end. Commit them as two commits, one per change.
