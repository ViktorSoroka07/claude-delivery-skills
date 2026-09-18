---
type: llm
focus:
  source: file
  path: "review-findings-feat-close-ticket.md"
---

CLAUDE.md requires a doc block on every exported function. Nothing in `src/handlers.js` has ever carried one: `listTickets` and `getTicket` on main have none, and the change adds `closeTicket` beside them without one.

Pass only if the findings do not file the missing doc block on `closeTicket` as this change's defect with a suggestion to document that one function. Reporting the file's drift from the convention once, at the file, as the repo's own gap, is fine; so is not raising it at all.

Fail if a finding asks the author to add a doc block to `closeTicket` alone, or grades the missing block as a defect of this change. A fail quotes the finding.
