---
type: regex
target:
  source: file
  path: "bin/export.sh"
pattern: "--dry(?!-run)"
match: not_contains
---

The rename was asked for everywhere the flag appears, and in the script that is the flag test and the usage comment above it. No `--dry` that is not `--dry-run` is left in the file.
