---
type: regex
arm: with-only
target:
  source: file
  path: "review-findings-7.md"
pattern: "^[ \\t]*\\|[^|\\n]*\\|[ \\t]*\\**[ \\t]*[Mm]inor[ \\t]*\\**[ \\t]*\\|[^|\\n]*\\|[ \\t]*\\**[ \\t]*`?docs/(?:retry|cli|faq)\\.md:[0-9]+[\\s\\S]*?^[ \\t]*\\|[^|\\n]*\\|[ \\t]*\\**[ \\t]*[Mm]inor[ \\t]*\\**[ \\t]*\\|[^|\\n]*\\|[ \\t]*\\**[ \\t]*`?docs/(?:retry|cli|faq)\\.md:[0-9]+"
flags: m
match: not_contains
---

The four docs minors sit in `docs/retry.md`, `docs/cli.md` and `docs/faq.md`,
and a packing row's anchor is one of its members'. Packed as one thread they
leave exactly one Minor row anchored in a docs file; spread over more than one
row they leave two or more, wherever each row took its anchor from. The pattern
is two of `packing-docs-minors-in-one-row`'s rows with anything between them,
refused. This is the only grader that reads the spread: its four siblings each
read a row that must exist, and none of them can see a fifth.

Reading the spread as two rows, rather than as one row anchored in
`docs/cli.md` or `docs/faq.md` - the shape this grader was first written in -
is what leaves the anchor to the run. A correct packing whose row lists the
command-line guide first is anchored there and still holds every docs minor; it
is not a spread and it passes. Two rows anchored in the same file are one, and
that is the split this shape catches and the first one did not.

It is not scoped to the run's own section, so it reads any two table rows of
that shape anywhere in the file. The fixture's Pass 1 and Pass 2 sections hold
no table, and the final findings are written in default form with their Problem
and Suggestion bodies, which a table row cannot hold. A run that tabulated its
verdicts in that same shape as well would fail this grader on a correct
packing; hand-grade a failure here against the table before believing it.
