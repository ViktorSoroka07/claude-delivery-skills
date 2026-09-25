---
name: delegating-to-subagents-briefs-the-role-it-has
tags: [delegating-to-subagents, dispatch-brief]
runs: 5
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Agent, Skill]
---

The last three nights' batch logs are in `logs/`. Summarise each of them the way `CLAUDE.md` says - one summary file per log in `summaries/` - and then tell me which job failed on which night. Don't commit.
