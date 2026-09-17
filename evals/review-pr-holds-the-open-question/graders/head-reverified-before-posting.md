---
type: regex
target:
  source: file
  path: ".forge-log"
pattern: "(?<![\\s\\S])(?:(?!\\S+ pr\\n).*\\n)*?\\S+ post "
match: not_contains
---

Posting re-verifies the PR's current head against the SHA in the findings header before anything is posted, so the log shows a `pr` call before the first `post`. The pattern is the violation: from the start of the log, a `post` line reached through lines none of which is a `pr` line. A run that posts nothing passes here and fails the grader that expects the settled findings posted.
