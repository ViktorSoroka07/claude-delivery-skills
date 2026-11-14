---
type: regex
target:
  source: file
  path: "review-findings-12.md"
pattern: "bd2f605fd249cebfbc584619543c1ba5124b222a"
match: contains
---

The findings file stays: it is the review's record, which keeps the line about the post. The head SHA appears only in the header the fixture wrote, so a rewrite that restyles the header still passes and a deleted file throws and is scored a fail.
