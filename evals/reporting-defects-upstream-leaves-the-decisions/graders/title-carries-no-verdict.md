---
type: llm
---

The draft's title is "Notification service: batch dedupe doesn't survive retries — a re-keying in enqueue". The fixture's CLAUDE.md says the first heading becomes the tracker item's title.

Pass only if the sent version's title describes the observation — retried batch calls delivered twice, or equivalent — with no verdict on the owner's code ("doesn't work", "broken", "wrong", "unusable") and no estimate of the fix's size or shape.

Fail if the title keeps either, or if the run rewrites the body and leaves the title untouched. A fail quotes the title.
