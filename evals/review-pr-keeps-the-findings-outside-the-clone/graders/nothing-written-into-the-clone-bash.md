---
type: tool_used
tool: Bash
input_match: "(?:>|\\btee\\b|\\bcp\\b|\\bmv\\b)[^|;&]*?(?<![/\\w.-])review-findings[\\w.-]*\\.md"
min: 0
max: 0
---

A screen beside `nothing-written-into-the-clone`: a redirect, `tee`, `cp` or `mv` whose target is a findings file named relative to the clone's root. It also matches such a command that only reads that name, so `nothing-written-into-the-clone` and the kept workspace decide.
