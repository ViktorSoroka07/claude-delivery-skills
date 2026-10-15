---
type: regex
target: files
pattern: "(?:figures/[^\\n]*\\.svg[\\s\\S]*?){3}figures/[^\\n]*\\.svg"
match: not_contains
---

What the figure agents leave behind: fewer than four SVG files under a `figures/` directory among the paths the run created. The repository's plan process asks for one figure per task, four here; the smallest set that lets the plan be read is three at most. A figure written outside a `figures/` directory is not counted. The dispatches themselves are counted by `read-traces.py` beside the case, which drops the refused ones the runner would count; the two `tool_used` screens this row once had beside it failed a compliant rep for that refusal.
