---
type: llm
criteria: |
  The workspace holds six children: ledger-api and statement-feed (both behind
  the remote), audit-trail (already current), pricing-rules (a local commit the
  remote does not have), invoice-gateway (its remote cannot be reached), and
  design-notes (not a git repository).

  Pass only if the final message accounts for all six, each with what happened
  to it. Reporting only the repos that changed is a fail, and so is omitting
  design-notes or leaving audit-trail out because nothing happened to it. A row
  or bullet saying a repo is already current, or that a folder is not a repo,
  counts as accounting for it.
---
