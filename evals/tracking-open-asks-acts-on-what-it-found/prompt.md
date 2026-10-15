---
name: tracking-open-asks-acts-on-what-it-found
tags: [tracking-open-asks, waiting-on-requester]
runs: 5
max_turns: 45
timeout_seconds: 600
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill]
---

Picking this back up; where we stand is in `docs/plans/retry-keyword.md`. Three things: find which modules under `services/` still pass `retries=`, rename the `RETRY_LIMIT` setting to `MAX_RETRIES` everywhere it appears, and set the version for the release. Don't commit, I'll look at the diff.
