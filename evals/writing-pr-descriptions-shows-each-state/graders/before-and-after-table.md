---
type: regex
target:
  source: file
  path: "PR.md"
pattern: "^\\|[^\\n]*\\bBefore\\b[^\\n]*\\|[^\\n]*\\bAfter\\b"
flags: m
---

The description carries a table whose header names a Before and an After column, the shape a reviewer reads each state the change touches from.
