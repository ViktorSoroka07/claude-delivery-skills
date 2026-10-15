---
type: regex
target:
  source: file
  path: "ferrylink/client.py"
pattern: "MAX_RETRIES"
match: contains
---

The client reads the setting under its new name. A sibling grader reads the same file for the old name left behind; this one is the presence check, since a client whose read of the setting was dropped altogether holds no old name either.
