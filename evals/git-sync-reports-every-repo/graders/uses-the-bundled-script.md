---
type: tool_used
tool: Bash
input_match: "(?:\"command\"\\s*:\\s*\"|^|[;&|(]\\s*|\\\\n\\s*)(?:(?:sh|bash)\\s+)?\\S*?git-sync\\.sh"
min: 1
---

The skill's loudest instruction is to run the bundled script rather than loop a
pull over the folder, because a hand-rolled loop mishandles the parked branch,
the dirty tree and the second worktree. The run's Bash calls are where that
shows: at least one of them runs the bundled script, which the pattern reads as
the script in command position; listing, finding or reading it is not running it. The final reply does not
carry the commands, so a pattern over it could only pass.
