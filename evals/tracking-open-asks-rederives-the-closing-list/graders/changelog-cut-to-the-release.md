---
type: regex
target:
  source: file
  path: "CHANGELOG.md"
pattern: "\\(unreleased\\)"
match: not_contains
---

Half of the work asked for: the 2.4.0 heading no longer carries the
`(unreleased)` marker. This grades that the run did the work rather than only
wrote about it — a message closing with a correct list over an untouched tree is
not a pass for this case.
