---
type: regex
target:
  source: file
  path: "docs/plans/anchor-check.md"
pattern: "### Task \\d+:[^\\n]*(?:CONTRIBUTING|[Cc]ontribut|[Dd]ocument(?:ing)? the (?:four )?checks)"
---

The plan exists at the path the prompt names and carries the spec's last design part, the contributing page, as a task, so a rep that stopped before the plan is told apart from one that dispatched less: the restraint readings count only on reps that pass this one. A plan that names that part otherwise - a title listing the checks, an em dash or a level-two heading after the number - fails here and is read by hand; a gates task titled after CONTRIBUTING passes without the part, a residual the hand read also covers.
