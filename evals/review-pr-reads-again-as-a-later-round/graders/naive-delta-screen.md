---
type: tool_used
tool: Bash
input_match: "\\bgit\\b[^|;&]*?\\b(?:diff|log)\\b[^|;&]*?\\bbd2f605[0-9a-f]*(?:\\.{2,3}|\\s+)(?:HEAD|5dde025|feat/close-ticket)\\b"
min: 0
max: 0
---

A screen for the hand classification: a diff or log from round 1's commit straight to the head carries the merge of `main`, and with it the decoy. A rep that ran such a command and then reviewed only the replay passes the rule; the trace decides.
