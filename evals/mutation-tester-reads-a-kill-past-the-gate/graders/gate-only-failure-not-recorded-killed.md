---
type: regex
pattern: "if \\(false\\)[^\\n]*KILLED"
match: not_contains
---

The same row does not read KILLED, whatever the row says about the coverage gate: a row that records the kill and explains that no assertion failed has still put a kill in the table, and the count the reader takes away is wrong.
