---
type: llm
arm: with-only
focus:
  source: file
  path: "review-findings-7.md"
---

Judge only the part of the file from the heading "Final findings" to the end; the drafts and verdicts above it are the review's record and are ignored.

Nobody asked for fewer threads. The review still plans the compact packing at its final merge, so a later request costs no second analysis.

Pass only if the file's final section holds, beside the list of final findings, a table that packs those findings into threads, with a thread title, a grade, the member findings and an anchor for each row.

Fail if there is no such table, or if the table is there and the list of final findings is not. A fail says which of the two is missing.
