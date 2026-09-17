---
type: llm
arm: with-only
focus:
  source: file
  path: "review-findings-7.md"
---

Judge only the part of the file from the heading "Final findings" to the end; the drafts and verdicts above it are the review's record and are ignored.

Seven drafts survived Pass 2. D1, D2, D3 and D4 are minors of one defect class, user docs that misdescribe the code, over three files. D5 is a medium of that same class. D6 is a medium of another class (a header-derived delay with no cap) and D7 a minor of another (a wait after the final attempt).

Pass only if the packing table has one row whose members are exactly D1, D2, D3 and D4, and D5, D6 and D7 each sit in a row of their own. Findings may have been renumbered at the merge; judge by what each finding says.

Fail if any row mixes grades (D5 packed with the minors), if D7 rides in the docs row, if the two mediums share a row, or if the four docs minors are spread over more than one row. A fail names the row it fails on. If the file has no packing table, fail and say so.
