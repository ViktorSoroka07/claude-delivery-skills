---
type: regex
target:
  source: file
  path: ".forge-log"
pattern: "^\\S+ pr\\n(?:.*\\n)*?\\S+ post "
flags: m
match: contains
---

Posting re-verifies the PR's current head against the SHA in the findings header before anything is posted, so the log shows a `pr` call before the first `post`.
