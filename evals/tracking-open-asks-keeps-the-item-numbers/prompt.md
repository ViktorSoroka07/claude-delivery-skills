---
name: tracking-open-asks-keeps-the-item-numbers
tags: [tracking-open-asks, waiting-on-requester, replay]
runs: 5
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill]
---

Answering your list: 1 - the new order is fine, nothing reads the old one any more. Then the changelog — drop the `(unreleased)` marker from the 2.4.0 heading and put a line under it for the flag rename. Still don't commit; I'll read the diff.
