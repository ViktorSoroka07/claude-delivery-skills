---
type: regex
arm: with-only
target:
  source: file
  path: "review-findings-7.md"
pattern: "^[ \\t]*\\|[^|\\n]*\\|[ \\t]*\\**[ \\t]*[Mm]edium[ \\t]*\\**[ \\t]*\\|[^|\\n]*\\|[ \\t]*\\**[ \\t]*`?src/http/retry\\.js:18`?(?![0-9])[^|\\n]*\\|"
flags: m
match: contains
---

D6 - the header-derived delay that reaches the sync loop uncapped - is the
second Medium and a defect class of its own. A major or a medium merges only
with another instance of the same defect, so it takes a row of its own,
anchored at `src/http/retry.js:18`.

The pattern is the family's, for a `Medium` grade cell and this anchor. Two
mediums sharing a row would leave only one Medium anchor in the table, which
this grader or `packing-docs-medium-alone` fails on.
