---
type: regex
target: last_message
pattern: "^\\|[^\\n]*\\bgit\\s+(?:-C\\s+\\S+\\s+)?(?:branch|push|add|commit|tag|checkout|switch|worktree)\\b"
flags: m
match: not_contains
---

A command inside a table cell wraps wherever the column ends and cannot be copied whole, and its unbreakable length takes width from every other column. No table row in the final message carries a git command.
