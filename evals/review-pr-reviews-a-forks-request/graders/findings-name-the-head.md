---
type: regex
target:
  source: file
  path: "review-findings-12.md"
pattern: "bd2f605"
match: contains
---

The findings file records the commit it reviewed, which is the request's head. A rep can copy the SHA from the forge without ever fetching it, so this passes beside `head-commit-fetched`, never alone.
