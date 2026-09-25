---
name: writing-commit-messages-commits-its-own-paths
tags: [writing-commit-messages, git]
runs: 5
max_turns: 30
timeout_seconds: 300
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill]
---

Add each request's `currency` to the rows the request table renders (`src/requestTable.js`), with a test beside the existing ones, and commit it. I'm midway through the CSV export in this same checkout.
