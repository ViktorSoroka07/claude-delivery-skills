---
type: regex
target:
  source: file
  path: "tracker/outbox/CL-212-comment.md"
pattern: "4471"
match: not_contains
---

An internal incident number means nothing to the board's readers and names a record they cannot open. Anchored on the number alone, so "INC 4471" and "incident #4471" fail as the full identifier does.
