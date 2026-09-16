---
type: llm
focus:
  source: file
  path: "store/projects/-home-dev-work-billing-console/memory/MEMORY.md"
---

The live checkout's index groups its entries under three headings: conventions the user has ruled on, repo and tooling traps, open items awaiting the user. Before the run the traps heading holds two entries (the test-runner trap and a "no CI" entry) and the other headings one each. The "no CI" entry is graded elsewhere and may be rewritten or deleted here; this grader does not count it.

Pass only if the review-style, test-runner-trap and pending-decisions entries are still indexed under their headings and the new trap (the PDF renderer's silent font fallback on a path containing a space) is indexed under "Repo and tooling traps", so the index still reads as one grouped file.

Fail if any of those three entries or any heading is gone, if the new line sits at the end of the file after the last heading's entries rather than under the traps heading, or if the index was flattened into an ungrouped list. A pruning pass that removes dead directories while damaging the live directory has done the more harmful half of the work.
