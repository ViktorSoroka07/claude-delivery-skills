---
type: regex
target:
  source: file
  path: ".git/commit-audit"
pattern: "^  carries: twelve=1 dead-letter=0$"
flags: m
match: contains
---

The act's second half, one change: some commit adds a line holding `twelve` (the corrected attempt limit) and no line holding `dead-letter` (the new section). The wrapper writes the line from each commit's own added lines, so a commit taking the whole file carries both and fails here, and so does a split that put a hunk of one change into the other's commit.
