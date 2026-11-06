---
type: regex
target:
  source: file
  path: ".git/commit-audit"
pattern: "^  carries: currency=0 Awaiting=1$"
flags: m
match: contains
---

The act's second half, the other change: some commit adds a line holding `Awaiting` (the empty-table heading) and none holding `currency` (the currency field). With its sibling grader, the two changes landed in two commits each carrying one of them.
