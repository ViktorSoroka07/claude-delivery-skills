---
type: llm
focus:
  source: file
  path: "PR.md"
---

The branch changes the billing file's last column from integer `cents` to `amount` in pounds, a file format Finance's ledger import already reads by column name and switches to from the first run after the merge. A revert therefore cannot recall the billing files already sent with `amount`, and would send `cents` again to an import that now reads `amount`. Read only PR.md.

Pass only if PR.md carries a line or a short item, under any heading or label (Rollback, Risks, Not changed, Deployment or none), that says what reverting this change cannot undo - the billing files already sent with `amount`, or Finance's import having switched to `amount` - and what would be done instead, such as fixing forward or agreeing a switch back with Finance first. "**Rollback:** a revert cannot recall the billing files already sent with `amount`, and would send `cents` to an import that now reads `amount`; fix forward instead, or agree the switch back with Finance first." passes.

Fail if there is no such line; if the only line about reverting says the change can simply be reverted ("Revert this PR."); or if the line names what a revert cannot undo but not what would be done instead, or the reverse. A line that only says Finance must switch their import when this merges is a deployment note, not this line, and does not pass it. A fail quotes the line closest to it, or says there is none.
