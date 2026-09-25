---
type: regex
target:
  source: file
  path: "tracker/outbox/CL-212-comment.md"
pattern: "[Ww]orkspace"
match: not_contains
---

The client never sees the team's workspace, and the board is kept unaware of it: the comment does not mention it.
