---
type: regex
pattern: "co-authored-by|generated with"
match: not_contains
flags: i
---

The fixture's history carries no trailers, so a trailer in the new commit came from a tool's default, not the repo's convention.
