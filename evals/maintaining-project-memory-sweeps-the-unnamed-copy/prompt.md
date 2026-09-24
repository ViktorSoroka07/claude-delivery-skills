---
name: maintaining-project-memory-sweeps-the-unnamed-copy
tags: [maintaining-project-memory, promotion, landing-sweep, unnamed-copy]
runs: 5
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill]
---

We've been trying one more thing on hand-overs for the last month and it has held up every time, so it's becoming part of the rule: the note also says how to roll back what was done - for each change already deployed or migrated, the step that undoes it, or that it can't be undone. It belongs in `skills/handoff/SKILL.md`, in what a hand-over note carries.

Don't commit anything. When you're done, tell me in two lines what changed.
