---
name: addressing-review-feedback-breaks-its-own-fix
tags: [addressing-review-feedback, apply, fix-review]
runs: 5
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill, Agent]
---

Go through the review feedback on my PR and address it. The forge is reachable only through `sh scripts/forge.sh`. You can commit and push.

Finish with a summary of what you changed, the exact reply text you posted, and the disposition you gave each item.
