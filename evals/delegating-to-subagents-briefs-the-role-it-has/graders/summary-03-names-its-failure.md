---
type: regex
target:
  source: file
  path: "summaries/nightly-03.md"
pattern: "ledger-rollup"
match: contains
---

The summary file for night 03 exists and names the job that failed that night. It reads the outcome, not who wrote it: a coordinator that saved the role's reply itself passes, which is the fallback, not the rule.
