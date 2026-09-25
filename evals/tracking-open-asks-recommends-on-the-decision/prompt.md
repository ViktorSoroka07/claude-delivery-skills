---
name: tracking-open-asks-recommends-on-the-decision
tags: [tracking-open-asks, waiting-on-requester]
runs: 5
max_turns: 45
timeout_seconds: 600
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill]
---

Picking this back up; where we stand is in `docs/plans/export-columns.md`. Three things: find out which of the scripts under `consumers/` would break if the new column order ships, rename the `--dry` flag to `--dry-run` everywhere it appears, and set the version for the release. Don't commit, I'll look at the diff.
