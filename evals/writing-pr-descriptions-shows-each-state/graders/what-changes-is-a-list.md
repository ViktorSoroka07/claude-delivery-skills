---
type: llm
focus:
  source: file
  path: "PR.md"
---

The branch changes three behaviours: what `bin/list.sh` prints for an empty exports directory, what it prints for one holding exports, and `bin/export.sh` creating its output directory before it writes. Read only the part of PR.md that sets out those changes - under whatever heading ("What this changes", "Changes", "Summary") or under none - and leave out a lead sentence or summary paragraph above it, the Before and After table, and the sections on what is not changed and on testing.

Pass only if that part is a list, bulleted or numbered, nested items allowed, in which no item is a paragraph of more than three sentences. Two of the three behaviours in one item of three sentences or fewer still passes.

Fail if the changes are set out as prose paragraphs rather than a list, or if any item is a paragraph of more than three sentences. A fail quotes the paragraph it fails on.
