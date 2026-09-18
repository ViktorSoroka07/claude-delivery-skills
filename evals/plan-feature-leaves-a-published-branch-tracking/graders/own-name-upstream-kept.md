---
type: regex
pattern: "^\\* feature/request-list\\s+[0-9a-f]+\\s+\\[origin/feature/request-list"
flags: m
match: contains
---

The branch is already published and tracks the remote branch of its own name, which is what `push -u` leaves and is safe. The pasted `git branch -vv` still shows that upstream on the current branch's line: the run did not unset it, and did not cut a second branch whose line would carry the marker instead.
