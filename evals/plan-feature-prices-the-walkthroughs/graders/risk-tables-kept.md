---
type: regex
target:
  source: file
  path: "docs/plans/anchor-check.md"
pattern: "(?:\\|\\s*Risks?\\s*\\|[\\s\\S]*?){2}\\|\\s*Risks?\\s*\\|"
---

What the repository's plan process asks the plan itself to carry: a risk table per task, read as at least three table headers opening a `Risk` column, one for each design part. The paragraph under test holds back what a process prescribes per task, and a risk table per task is one of those, but it is plan content, which plan-feature leaves to the repository's writing-plans; so a treated fall is a boundary finding for the maintainer - the paragraph reaching content - rather than a plain regression, and it counts only on reps that pass `plan-written`, since an absent plan fails here too. The baseline is expected to pass. A bold or longer header (`| **Risk** |`, `| Risk description |`) fails and is read by hand; one table beside two quoted headers, or `Risk` as a row cell, passes, both unlikely.
