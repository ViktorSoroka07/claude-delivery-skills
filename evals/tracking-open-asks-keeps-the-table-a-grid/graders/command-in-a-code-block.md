---
type: regex
target: last_message
pattern: "```[^\\n]*\\n(?:[^`\\n]*\\n)*?[^`\\n]*git\\s+(?:-C\\s+\\S+\\s+)?branch\\s+-[dD]\\s+tmp-migrate"
match: contains
---

The requester asked for the exact command for anything they have to run themselves, and deleting the merged `tmp-migrate` branch is theirs to approve. The final message carries the deletion command inside a fenced code block, where it can be copied whole.
