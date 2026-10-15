---
type: regex
target:
  source: file
  path: "PR.md"
pattern: "^\\|[^\\n]*(?:cents|,\\d+\\b(?!\\.))[^\\n]*\\|[^\\n]*(?:amount|\\b\\d+\\.\\d\\d\\b)"
flags: mi
---

The change has no screen: its state is the billing file's line, so a table row carries the old format left of the new one - the `cents` column or a whole-number last field such as `m-1,10.0,standard,120` on the left, the `amount` column or a two-decimal one such as `1.20` on the right, on one row. A row with only the new format, or the two formats on separate rows, fails.
