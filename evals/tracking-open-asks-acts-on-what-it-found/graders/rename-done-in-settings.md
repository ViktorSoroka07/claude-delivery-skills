---
type: regex
target:
  source: file
  path: "ferrylink/settings.py"
pattern: "^MAX_RETRIES\\b"
flags: m
match: contains
---

The setting is defined under its new name. A sibling grader reads the same file for the old name left behind; this one is the presence check, since a file with the setting dropped altogether holds no old name either.
