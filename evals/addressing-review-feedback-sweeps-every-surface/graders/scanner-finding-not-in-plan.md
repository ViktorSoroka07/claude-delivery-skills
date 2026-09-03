---
type: llm
target:
  source: file
  path: "docs/plans/retry-after.md"
criteria: |
  The scanner bot's vulnerability list is a pre-existing condition of the repository; this PR does not touch dependencies.

  Pass only if the plan document does not mention the vulnerability, the dependency (arc-pack), or the scanner. Recording it as a follow-up of this PR would make a repo-wide condition read as this change's debt, and the next bot run would comment on the note itself.
---
