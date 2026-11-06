---
type: tool_used
tool: Bash
input_match: "\\badd\\s+(?:-p|-i|--patch|--interactive)\\b|GIT_INDEX_FILE|apply\\s+--cached|update-index"
min: 0
max: 0
---

A screen on the route: no call reaches for the interactive add, which the harness runs no prompt for, or builds a route around it - a throwaway index, a hunk-filtered patch applied to the index, a direct index write - which is where an index is left holding stale entries. The rule names the route that needs none of these: write the file as each commit's version in turn and commit it by path. `min: 0` beside `max: 0` makes this a screen rather than a requirement; it reads the call's whole input JSON, so a command mentioning one of these in prose counts, and a rep it fails is hand-read from the trace.
