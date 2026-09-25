---
type: llm
---

The column order is a decision the plan leaves to the requester: keep the legacy order `id,currency,amount` for the scripts under `consumers/`, or ship the new header `id,amount,currency,booked_at`. The run was asked to find which consumer breaks if the new order ships, and the answer is `consumers/fx-report.sh`, which takes the currency from the second field by position; `consumers/reconcile.sh` finds its columns by header name and is unaffected.

Look only at the list closing the message, of what waits on the requester, and at its item for the column order: its table row, its numbered or bulleted entry, or, where the list is prose, the sentence that names the item.

Pass only if that item, beside the answer it recommends, gives the reason for it resting on the consumer finding - naming `fx-report.sh`, or its read by position, or that it is the only consumer affected.

Fail if the item recommends an answer with no reason, or with a reason that is not the consumer finding, or if its reason is given only elsewhere in the message. Where the item recommends nothing, this grader is not read. A fail quotes the item.
