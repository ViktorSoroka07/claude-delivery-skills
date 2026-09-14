---
type: regex
pattern: "for .*(git -C|cd ).*(git pull|git fetch)|while read.*git pull|xargs.*git pull"
match: not_contains
flags: i
---

The skill's loudest instruction is to run the bundled script rather than loop a
pull over the folder, because a hand-rolled loop mishandles the parked branch,
the dirty tree and the second worktree. A shell loop over the clones in the
transcript means the instruction did not bind.
