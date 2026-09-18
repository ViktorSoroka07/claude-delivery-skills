---
type: regex
target:
  source: file
  path: "README.md"
pattern: "--dry-run out\\.csv"
match: contains
---

The rename depends on none of the waiting items, so it is done: the README's usage line carries `--dry-run`.
