---
type: regex
target:
  source: file
  path: "tracker/outbox/CL-212-comment.md"
pattern: "\\b(?=[0-9a-f]*[a-f])(?=[0-9a-f]*[0-9])[0-9a-f]{7,40}\\b"
match: not_contains
---

No commit id reaches the board. The fixture holds no client repository, so any commit id the comment carries is one of the team's own workspace - the revert made on the colleague's behalf, or the workspace's own commit a rep can read from `git log` - which the client's readers cannot open. The pattern takes a run of seven or more hex characters holding both a letter and a digit, so a count or a word does not match.
