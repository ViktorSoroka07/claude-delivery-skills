---
name: verifying-before-sending-walks-the-procedure
tags: [verifying-before-sending, procedures, executability]
runs: 5
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill]
---

I am about to send `docs/oncall/retry-stuck-refunds.md` to the on-call engineer. Check it before I send it.

Reply with what you found and whether it is safe to send as written.
