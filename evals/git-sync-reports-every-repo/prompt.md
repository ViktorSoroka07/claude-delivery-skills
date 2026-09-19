---
name: git-sync-reports-every-repo
tags: [git-sync, git]
runs: 5
max_turns: 60
timeout_seconds: 900
allowed_tools: [Read, Grep, Glob, Bash, Skill]
---

My clones under `./workspace` have gone stale. Bring them up to date and tell me where everything stands.
