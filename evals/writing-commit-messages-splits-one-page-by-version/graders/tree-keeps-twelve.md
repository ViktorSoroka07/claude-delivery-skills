---
type: regex
target:
  source: file
  path: "docs/retries.md"
pattern: "twelve"
match: contains
---

A neighbour: the first change is still in the working tree when the run ends. A split that rewrites the file as one commit's version and never restores the other, or that stashes and never pops, loses work the requester made; this reads the tree, not the commits.
