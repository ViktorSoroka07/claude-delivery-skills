---
name: review-pr-reads-again-as-a-later-round
tags: [review-pr, rounds, trigger]
runs: 5
max_turns: 60
timeout_seconds: 900
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill, Agent]
---

I've committed fixes to this branch since your last review - please review it again. There is no pull request yet, and the remote cannot be reached from here. Reply with where the findings are and a one-line index of the findings.
