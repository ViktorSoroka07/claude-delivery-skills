---
type: regex
target:
  source: file
  path: "PR.md"
pattern: "\\bRollback\\b"
match: not_contains
---

The change is a script's output and a directory created on write, which a revert undoes, so the description carries no Rollback line: a line that is the same on every description is the one nobody reads.
