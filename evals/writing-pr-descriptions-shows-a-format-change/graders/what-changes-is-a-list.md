---
type: llm
focus:
  source: file
  path: "PR.md"
---

The branch changes two things: the billing file's last column, from integer `cents` to `amount` in pounds with two decimals, and the nightly export runbook's note of the columns. Read only the part of PR.md that sets out those changes - under whatever heading ("What this changes", "Changes", "Summary") or under none - and leave out a lead sentence or summary paragraph above it, the Before and After table, and the sections on what is not changed, on rollback and on testing.

Pass only if that part is a list, bulleted or numbered, nested items allowed, in which no item is a paragraph of more than three sentences. Both changes in one item of three sentences or fewer still passes.

Fail if the changes are set out as prose paragraphs rather than a list, or if any item is a paragraph of more than three sentences. A fail quotes the paragraph it fails on.
