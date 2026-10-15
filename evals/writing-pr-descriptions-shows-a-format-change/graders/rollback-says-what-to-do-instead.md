---
type: llm
focus:
  source: file
  path: "PR.md"
---

The branch changes the billing file's last column from integer `cents` to `amount` in pounds, a file format Finance's ledger import already reads by column name and switches to from the first run after the merge, so a plain revert is not safe once a run has gone out. Read only PR.md.

Pass only if PR.md says what would be done instead of a plain revert of this change: fixing forward, or reverting only together with Finance switching their import back, whether it gives that as an instruction ("fix forward instead"; "revert only together with Finance switching back") or as what a revert would require (a revert that needs Finance's import switched back with it).

Fail if PR.md says nothing about undoing the change; if it says only that the change can be reverted ("Revert this PR."); or if what it says about Finance concerns only the merge - when to merge, or that Finance must switch when this lands - and not what undoing it would take. A fail quotes the line closest to it, or says there is none.
