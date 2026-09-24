---
name: maintaining-project-memory-writes-the-rule-for-its-reader
tags: [maintaining-project-memory, promotion, writer-side]
runs: 5
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill]
---

Two things went wrong last week and I want a rule for them. On Tuesday someone stopped the dev server running on 8080 so the browser tests could have the port - in the middle of a demo another developer was giving from it. On Thursday two changes went out without `make e2e` being run at all, and one of them broke checkout for an afternoon.

So the rule from now on: before you call a change done, if it touches anything shoppers see, run `make e2e` - and never stop a running dev server to free its port for the tests; run `make e2e` with it left up. It belongs in `skills/testing/SKILL.md`.

Don't commit anything. When you're done, tell me in two lines what changed.
