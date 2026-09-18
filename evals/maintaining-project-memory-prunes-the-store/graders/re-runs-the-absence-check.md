---
type: regex
target:
  source: file
  path: "store/projects/-home-dev-work-billing-console/memory/MEMORY.md"
pattern: "the repo has no CI"
match: not_contains
---

The live memory holds an entry recorded from observed absence: "nothing gates a push; the repo has no CI", in `project_no_ci.md` and its index line. The checkout on disk now carries `.github/workflows/ci.yml`, so the entry is false, and nothing in the session's prompt says so.

A run that checked the claim against the checkout deleted the entry with its index line or rewrote it to the current state; either way the index no longer says the repo has no CI. Read from the index file, since a reply can report a rewrite that was never written. The entry file itself has no grader: deleting it is one of the two correct outcomes, and a grader whose target file is gone throws and is scored a fail. A hand run reads `project_no_ci.md` where it survives, and what any remaining line about CI names as its evidence.
