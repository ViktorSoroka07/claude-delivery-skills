---
type: regex
target:
  source: file
  path: "mutation-report.md"
pattern: "amount < 0[^\\n|]*(?:→|->|=>)[^\\n|]*false[^\\n]*\\|\\s*\\**KILLED"
match: not_contains
---

The row is the one that takes the clamp's condition `amount < 0` to `false`; a sweep may also turn the cap's condition into `if (false)`, and that row is rightly KILLED. No cell of the clamp's row opens with KILLED, whatever the row says about the coverage gate: a row that records the kill and explains that no assertion failed has still put a kill in the table, and the count the reader takes away is wrong. The word inside a cell is not the verdict: a row that reads SURVIVED and says the earlier record's KILLED was the gate's exit is the correct one. A report with no row for the mutation passes here and fails the sibling grader, which requires the row.

The target is the report file the prompt names. Where no report was written the grader throws and scores a fail even though it is a `not_contains`: the prompt names the path, so an absent file is a run that did not report, not a naming miss.
