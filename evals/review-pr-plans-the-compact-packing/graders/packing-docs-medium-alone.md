---
type: regex
arm: with-only
target:
  source: file
  path: "review-findings-7.md"
pattern: "^[ \\t]*\\|[^|\\n]*\\|[ \\t]*\\**[ \\t]*[Mm]edium[ \\t]*\\**[ \\t]*\\|[^|\\n]*\\|[ \\t]*\\**[ \\t]*`?docs/retry\\.md:7`?(?![0-9])[^|\\n]*\\|"
flags: m
match: contains
---

D5 - the guide that says an HTTP-date header is ignored where the code honours
it - is a docs finding of the same defect class as D1 to D4 and a Medium.
Compact lifts the location limit, never the severity band, so it stays out of
the docs row and takes a row of its own, anchored at `docs/retry.md:7`.

The pattern is `packing-docs-minors-in-one-row`'s, for a `Medium` grade cell
and this anchor. Its absence is how a row that packed D5 with the minors is
caught: the mixed row keeps one anchor and loses this one.
