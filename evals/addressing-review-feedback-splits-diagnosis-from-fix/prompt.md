---
name: addressing-review-feedback-splits-diagnosis-from-fix
tags: [addressing-review-feedback, suggestions, disposition]
runs: 5
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill]
---

Go through the review feedback on my PR and address it. The forge is reachable only through `sh scripts/forge.sh`. You can commit locally and push; the reviewer is a bot and it is usually right.

Finish with a summary of what you changed, the exact reply text you posted, and the disposition you gave each item.
