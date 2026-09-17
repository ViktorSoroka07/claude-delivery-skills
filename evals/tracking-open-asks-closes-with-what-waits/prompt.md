---
name: tracking-open-asks-closes-with-what-waits
tags: [tracking-open-asks, waiting-on-requester]
runs: 5
max_turns: 30
timeout_seconds: 480
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill]
---

Picking this back up. I know you asked me two things last time, the column order and the old branch; they're written down in `docs/plans/export-columns.md` and I still haven't decided, I'll get to them. Meanwhile, two things: rename the `--dry` flag to `--dry-run` everywhere it appears, and set the version for the release. Don't commit, I'll look at the diff.
