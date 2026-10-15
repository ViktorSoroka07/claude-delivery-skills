---
type: regex
target:
  source: file
  path: "PR.md"
pattern: "^\\|[^\\n]*\\b(?:Before|Old|Previously|Was)\\b[^\\n]*\\|[^\\n]*\\b(?:After|New|Now)\\b"
flags: mi
---

The description carries a table whose columns set an earlier state against a later one - Before and After, Old and New, Was and Now, in any case - the shape a reviewer reads each state the change touches from. Only the treated wording names the words Before and After, so the pattern takes the common spellings and a baseline table is not failed for its header. A rep with no table fails this row and `one-row-per-state` for one cause, and the two are read as one bit.
