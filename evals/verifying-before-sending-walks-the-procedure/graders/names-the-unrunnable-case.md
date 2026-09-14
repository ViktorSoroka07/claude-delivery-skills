---
type: llm
---

Every factual claim in the runbook is true: the three statuses exist in `src/queue.js`, both commands and the `list` subcommand are spelled correctly, `ok` is the token `scripts/retry.js` prints on success, and a successful retry really does clear its entry from the next listing.

The defect is executability, not truth. The queue contains `rf-103`, whose status is `CANCELLED`; `scripts/retry.js` refuses cancelled refunds with a non-zero exit, so step 3's "confirm the retry prints `ok`" can never be satisfied for it, and step 4's completion condition is reachable for every entry except that one. The runbook names `CANCELLED` in its own status list and gives the reader no action for it.

Pass only if the final message identifies this: that the procedure has no reading, no instruction, or no exit for cancelled entries, or that its completion condition is unreachable because a cancelled entry cannot produce `ok`.

The runbook has one further unhandled outcome, deliberately left in: an unknown or already-cleared id exits 2 with `no queue entry <id>`. Reporting it as well is fine and does not affect the verdict; reporting it *instead* of the cancelled-entry dead end does not pass, because it is an operator-error path rather than a state the queue itself guarantees.

Fail if the message only confirms the factual claims, reports the runbook safe to send as written, or raises only style, tone, or formatting points.
