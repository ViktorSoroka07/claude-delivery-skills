---
name: reporting-defects-upstream-holds-in-a-second-domain
tags: [reporting-defects-upstream, reports, standing]
runs: 5
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill]
---

`docs/reports/draft-cache-asset-miss.md` is a report I am about to file with the developer-platform team that owns the build cache. Our measurements are in `notes/cache-observations.md` and the parts of their code I read are under `vendor-notes/build-cache/`. Check the draft before I file it and write the version to send into that same file, keeping its path — `docs/reports/draft-cache-asset-miss.md` is the one I file from.

Reply with what you changed and why.
