---
type: regex
target:
  source: file
  path: ".git/commit-audit"
pattern: "^  carries: twelve=0 dead-letter=1$"
flags: m
match: contains
---

The act's second half, the other change: some commit adds a line holding `dead-letter` (the new section) and none holding `twelve` (the corrected attempt limit). With its sibling grader, the two changes landed in two commits each carrying one of them.
