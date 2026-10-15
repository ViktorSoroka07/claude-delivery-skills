---
type: regex
target:
  source: file
  path: "PR.md"
pattern: "^\\|[^\\n]*cents[^\\n]*\\|[^\\n]*amount"
flags: m
---

The change has no screen: its state is the billing file's line, so a table row carries the old format in a Before cell and the new one in an After cell - `cents` left of `amount` on one row.
