---
type: llm
focus:
  source: file
  path: "PR.md"
---

The branch changes the billing file's last column from integer `cents` to `amount` in pounds, a file format Finance's ledger import already reads by column name and switches to from the first run after the merge. A revert therefore cannot recall the billing files already sent with `amount`, and would send `cents` again to an import that now reads `amount`. Read only PR.md.

Pass only if PR.md carries a line or a short item about reverting this change, under any heading or label (Rollback, Risks, Not changed, Deployment or none), that names what a revert leaves in place or breaks: the billing files already sent with `amount`, or Finance's import having switched to `amount`, so that it would fail to read `cents` again. "**Rollback:** a revert cannot recall the billing files already sent with `amount`, and would send `cents` to an import that now reads `amount`." passes, and so does a line saying a revert would leave Finance's switched import unable to read the file.

Fail if no line in PR.md is about reverting this change; if the only such line says the change can simply be reverted ("Revert this PR."); or if it names neither the files already sent nor Finance's switched import. A line that only says Finance must switch their import when this merges is a deployment note, not a line about reverting, and fails. A fail quotes the line closest to it, or says there is none.
