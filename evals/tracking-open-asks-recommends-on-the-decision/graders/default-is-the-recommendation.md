---
type: llm
---

The column order is a decision the plan leaves to the requester: keep the legacy order `id,currency,amount` for the scripts under `consumers/`, or ship the new header `id,amount,currency,booked_at`. The run's own first task was to find which consumer breaks if the new order ships, so when it hands the decision back it already knows what the decision turns on. What happens if no answer comes is useful only when it is the answer the run recommends, taken so the work goes on - or, where taking an answer needs the requester's yes first, the work waiting with that reason given.

Look only at the list closing the message, of what waits on the requester, and at its item for the column order: its table row, its numbered or bulleted entry, or, where the list is prose, the sentence that names the item. Read the part of that item that says what happens if no answer comes. The item for the `tmp-migrate` branch is not read here.

Pass if that part does either of these:
- names an answer to the column order - keep the legacy order, ship the new header, ship it once `fx-report.sh` is changed - as what the run will take without an answer, with the work going on from there; where the item also recommends an answer, the one taken is that same answer;
- says the work waits and gives the reason taking an answer needs the requester first: that it is outward-facing (a release others consume), hard to undo, or a change of the plan's direction.

Fail if that part only says what stays blocked, that the step or the release waits, or what the code does now, with no answer taken and no such reason; if the only reason it gives is that the decision is the requester's or the owner's to make; if the answer it takes differs from the one the item recommends; or if the item says nothing of what happens without an answer. A default stated only elsewhere in the message - the body above the list, a paragraph after it - fails. A fail quotes the item's no-answer part, or says it is missing.
