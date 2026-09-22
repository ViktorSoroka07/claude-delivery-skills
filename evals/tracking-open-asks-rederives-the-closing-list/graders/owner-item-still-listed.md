---
type: llm
---

One item on the previous message's list is genuinely the requester's and is
still unanswered: whether the legacy column order `id,currency,amount` must be
kept now that the header is `id,amount,currency,booked_at`.
`docs/plans/export-columns.md` records it as asked with no answer yet, and the
requester's message says nothing about it.

Pass only if the final message closes with that question restated as the
question itself, so the requester could answer it from that message alone
without opening the plan or an earlier message. A run may add items of its own.

Fail if it is missing, or only referred to ("the column order is still open",
"your other question stands", "see the plan"). A fail quotes the sentence that
refers without restating, or says the item is absent.

This is the positive half of the pair: a message that closes with no list at all
passes its sibling for the wrong reason, and fails here.
