---
type: llm
---

The column order is a decision the plan leaves to the requester: keep the legacy order `id,currency,amount` for the scripts under `consumers/`, or ship the new header `id,amount,currency,booked_at`. The plan records it as asked and unanswered, so the run hands it back in the list of what waits on the requester. The run's own first task was to find which consumer breaks if the new order ships, so when it hands the decision back it already knows what the decision turns on.

The requester answers from the list of what waits on them, by item. Look only at that list - the one closing the message, of questions and decisions for the requester - and at its item for the column order: its table row, its numbered or bulleted entry, or, where the list is prose, the sentence that names the item.

Pass only if that item itself says which answer the run recommends - keep the legacy order, ship the new header, ship it once `fx-report.sh` is changed, or any other answer the run states as its own choice, in either direction, with or without a reason. "Recommend: ship", "I'd keep the legacy order", a Recommendation column holding an answer, and a named default the run says it would take all pass.

Fail if the item holds only the question, the options, what it blocks, or what happens without an answer, or asks the requester for their preference, or points elsewhere ("see above"). It fails even where a recommendation is stated elsewhere in the message - in the body above the list, in a numbered report of the work done, or in a paragraph after the list: that is the shape where the requester, answering by number, answers without it. A fail quotes the item.
