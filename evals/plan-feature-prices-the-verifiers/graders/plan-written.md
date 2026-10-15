---
type: regex
target:
  source: file
  path: "docs/plans/anchor-check.md"
pattern: "### Task \\d+:[^\\n]*(?:CONTRIBUTING|[Cc]ontribut|[Dd]ocument)"
---

The plan exists at the path the prompt names and carries the spec's last design part, the contributing page, as a task, so a rep that stopped before the plan is told apart from one that dispatched less: the restraint readings count only on reps that pass this one. A plan that names that part otherwise fails here and is read by hand.
