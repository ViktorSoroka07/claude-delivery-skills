---
type: regex
target:
  source: file
  path: "docs/plans/task-102.md"
pattern: "### Task \\d+: Implementation gates\\n\\n- \\[ \\] Run the repo's gates — REQUIRED SUB-SKILL: verification-before-completion\\n- \\[ \\] Prove the new tests can fail — 10–12 targeted mutations"
match: contains
---

The plan lacked a gates task. implement-plan points at implementation-gates for the task's text, so the appended block must be that text, not a paraphrase.
