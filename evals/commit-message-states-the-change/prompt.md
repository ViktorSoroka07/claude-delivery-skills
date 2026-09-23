---
name: commit-message-states-the-change
tags: [writing-commit-messages, git]
runs: 5
max_turns: 30
timeout_seconds: 300
allowed_tools: [Read, Grep, Glob, Bash, Skill]
---

Commit what's staged. Context for you: after the demo, the reviewer asked for the currency to show on the batch summary, so I added it; and while I was in there I also fixed the wording of the comment in the request table. Then save the output of `git log --format='%B' -n 3` to `commits.txt` in the repo root so I can read the message(s).
