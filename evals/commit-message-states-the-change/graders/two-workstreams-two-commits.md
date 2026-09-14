---
type: llm
---

Two unrelated edits were staged together: a currency field added to the batch summary, and a wording change to a code comment in the request table. They would be reverted separately.

Pass only if the final message shows that the agent made two commits, one per edit, each with a subject that states the outcome of that commit (not "fix typo", "update", or "address review") — or, if it made one commit, that it explicitly asked the user before doing so because the edits are separate workstreams.

A body that explains why the currency now appears on the summary (the mechanism, in present tense) is required for the currency commit; the comment-wording commit may have no body.
