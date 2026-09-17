---
type: regex
target:
  source: file
  path: "bin/export.sh"
pattern: "\"--dry-run\""
match: contains
---

The script's flag test carries `--dry-run`.
