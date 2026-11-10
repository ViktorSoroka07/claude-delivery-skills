---
type: regex
target:
  source: file
  path: "bin/export.sh"
pattern: "--dry-run"
match: contains
---

The script carries `--dry-run`, however its flag test quotes it. A sibling grader reads the same file for the old flag left behind; this one is the presence check, since a script with the flag dropped altogether holds no old flag either.
