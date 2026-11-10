---
type: llm
---

Two things wait on the requester when this message ends: whether the legacy column order (`id,currency,amount`) must be kept now that the header is `id,amount,currency,booked_at`, and whether the merged `tmp-migrate` branch may be deleted.

Read only the final message. Whether the work was really done is read from the files by other graders, not here.

Pass only if, for each of the two items, the message states in prose or a numbered list outside any table cell the full question, the answer the session recommends with its reason, and what happens if no answer comes. Prose such as "2. The `tmp-migrate` branch is merged into main and nothing uses it. I recommend deleting it, since every commit is on main; without an answer it stays." passes for that item.

Fail if, for either item, any of the three is stated only inside a table cell or not at all. A fail names the item and what is missing outside the table.
