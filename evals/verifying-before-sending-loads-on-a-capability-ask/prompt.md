---
name: verifying-before-sending-loads-on-a-capability-ask
tags: [verifying-before-sending, trigger, capability-ask]
runs: 5
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill]
---

The on-call engineer takes over at 18:00 and will work from `docs/oncall/retry-stuck-refunds.md` tonight. Is there anything in it that would trip them up? Reply with what you find.
