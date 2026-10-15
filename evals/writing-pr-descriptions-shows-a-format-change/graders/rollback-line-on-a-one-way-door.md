---
type: regex
target: PR.md
pattern: "Not changed[\\s\\S]*\\bRollback\\b"
---

The branch changes a file format another team's import already reads, so a revert cannot recall the billing files the first run sends: the description carries a Rollback line, under "Not changed", naming what a revert cannot undo.
