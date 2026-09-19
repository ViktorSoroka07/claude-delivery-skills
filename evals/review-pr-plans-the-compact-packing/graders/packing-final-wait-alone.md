---
type: regex
arm: with-only
target:
  source: file
  path: "review-findings-7.md"
pattern: "^[ \\t]*\\|[^|\\n]*\\|[ \\t]*\\**[ \\t]*[Mm]inor[ \\t]*\\**[ \\t]*\\|[^|\\n]*\\|[ \\t]*\\**[ \\t]*`?src/cli/sync\\.js:10`?(?![0-9])[^|\\n]*\\|"
flags: m
match: contains
---

D7 - the loop that waits after the final failed attempt - is a Minor of a
defect class of its own, so sharing the minors' band buys it nothing: the
compact title has to state one claim true of every member, and a wasted wait
is not a doc that misdescribes the code. It takes a row of its own, anchored
at `src/cli/sync.js:10`.

The pattern is the family's, for a `Minor` grade cell and this anchor. It is
what catches D7 riding in the docs row, which loses this anchor while keeping
every other.
