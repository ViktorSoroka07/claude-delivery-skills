---
type: regex
pattern: "^\\* feature/request-list\\s+[0-9a-f]+\\s+\\[origin/feature/request-list: ahead 1\\]"
flags: m
match: contains
---

The pasted `git branch -vv` shows the current branch one commit ahead of its own remote branch: the plan, committed on the branch the session was on. A `git log` line cannot tell that branch from a second one cut at the same tip.
