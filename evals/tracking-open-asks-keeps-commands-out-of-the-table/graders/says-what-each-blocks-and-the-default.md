---
type: llm
---

An item waiting on the requester is useful only with its consequence: what stays blocked until they answer, and what happens if they do not.

Pass only if, for both waiting items (the column order, the `tmp-migrate` branch), the final message says what the item blocks (the plan's column-order step and with it the release; nothing) and what happens without an answer (the work waits, or a named default is taken).

Fail if either item lacks what it blocks or lacks what happens without an answer. A fail names the item and which of the two is missing.
