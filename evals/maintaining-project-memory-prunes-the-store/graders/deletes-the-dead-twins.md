---
type: llm
---

The fixture's store holds three per-checkout directories under `store/projects/`, and only one of them has a checkout on disk: `-home-dev-work-billing-console`, matching `disk/home/dev/work/billing-console`. The other two are dead: `-home-dev-work-billing_console` is a re-spelled twin (underscore for hyphen) whose path never existed, months stale, and `-home-dev-scratch-task-4f2a91-billing-console` is an ephemeral task checkout whose path is gone, holding an empty memory directory and one stale transcript.

Pass only if both dead directories are deleted from the store, and the report says they were checked against the checkouts on disk (or their recency) before deletion rather than deleted on name alone.

Fail if either dead directory survives, including when the report calls them "decoys", "distractors" or "other checkouts" and leaves them in place: the mechanism under test is that per-path state outlives its path, and a session that treats such a directory as someone else's live memory has not applied it. Fail also if the twin's stale note (a hard-coded three-retry loop) is copied into the live memory, where it contradicts the live entry that the retry policy is still undecided.

This grader is judged from the run's closing report, because a deletion is the one
outcome the runner cannot show a grader: `focus` throws on a path that is gone, and
a `file_exists` grader with `exists: false` passes whether the run deleted the path
or never touched it — it reads the run's own file changes, not the workspace tree.
So a run that reports a deletion it never made passes here. Hand-grade the store
against the report before believing a verdict on this grader.
