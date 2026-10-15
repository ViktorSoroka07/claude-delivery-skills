---
type: regex
target:
  source: file
  path: "docs/plans/retry-keyword.md"
pattern: "Not yet checked"
match: not_contains
---

A screen beside `follow-up-done-in-the-tree`: the plan's open line is no longer there as written. It passes a rep that deleted the line and recorded nothing, and fails one that recorded the finding while keeping the phrase, so it is reported beside the act, never instead of it, and every rep where the two disagree is read by hand.
