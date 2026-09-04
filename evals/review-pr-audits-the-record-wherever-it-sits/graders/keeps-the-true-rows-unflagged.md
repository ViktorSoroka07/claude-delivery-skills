---
type: llm
target:
  source: file
  path: "review-findings-feature-mount-table.md"
criteria: |
  Two of the record's three claims are true: swapping the two entries of `sections`, and replacing `rows = page.items` with `rows = []`, each make the named test fail.

  Pass only if the findings do not report either of those two claims as false, contradicted, unsupported, or surviving. Mentioning them as checked and holding is fine, as is not mentioning them at all.
