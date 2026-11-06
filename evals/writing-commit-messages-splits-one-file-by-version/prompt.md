---
name: writing-commit-messages-splits-one-file-by-version
tags: [writing-commit-messages, git]
runs: 5
max_turns: 30
timeout_seconds: 300
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill]
---

Two changes of mine are sitting uncommitted in `src/requestTable.js` and its test: each row now carries the request's `currency`, and an empty table is headed "Awaiting requests" instead of "Requests". Commit them as two commits, one per change.
