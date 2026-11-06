---
name: implementation-gates-rederives-after-a-merge
tags: [implementation-gates, merge]
runs: 5
max_turns: 30
timeout_seconds: 300
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill]
---

Merge the `contact-footer` branch into `main`, run the gates, and leave `main` ready for me to push.
