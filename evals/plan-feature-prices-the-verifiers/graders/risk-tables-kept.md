---
type: regex
target:
  source: file
  path: "docs/plans/anchor-check.md"
pattern: "(?:\\|\\s*Risks?\\s*\\|[\\s\\S]*?){2}\\|\\s*Risks?\\s*\\|"
---

A guard on what the repository's plan process asks the plan itself to carry: a risk table per task, read as at least three table headers opening with a `Risk` column, one for each design part. The sentence under test holds back dispatches the process prescribes per task; a plan that loses the tables is the sentence read past dispatches onto the plan's content, which the repository's writing-plans governs. The baseline is expected to pass; a fall in the treated arm is a cost of the wording.
