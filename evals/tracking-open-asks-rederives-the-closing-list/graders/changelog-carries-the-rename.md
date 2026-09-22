---
type: regex
target:
  source: file
  path: "CHANGELOG.md"
pattern: "--dry-run"
match: contains
---

The other half of the work: a line under the release heading for the flag
rename. The fixture's changelog names neither flag, so this reads what the run
wrote rather than what the scaffold seeded.
