---
type: regex
target:
  source: file
  path: "tracker/outbox/CL-212-comment.md"
pattern: "(?:PR|[Pp]ull [Rr]equest)[ -]?#?48\\b|#48\\b"
match: contains
---

Neighbour: the comment names the change its readers can open - the client's PR 48, written as "PR 48", "PR-48", "PR #48", "pull request 48" or "#48" - so an empty or evasive file fails here, not on the act.
