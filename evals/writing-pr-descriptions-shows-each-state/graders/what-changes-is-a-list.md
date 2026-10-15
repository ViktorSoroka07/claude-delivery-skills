---
type: llm
focus: PR.md
---

Read only the section of PR.md that says what the branch changes (headed "What this changes", "Changes", "Summary" or the like - the part that lists the behaviour, not the Before and After table).

Pass only if that section is a list with one item per behaviour - here the empty state, the filled state's table, and export.sh creating its directory, two of them possibly merged into one item - and no item is a paragraph of more than three sentences.

Fail if the section is prose paragraphs, or if one item carries several behaviours as a paragraph. A fail quotes the paragraph it fails on.
