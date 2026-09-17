---
type: llm
---

The session is on `feature/request-list`, which tracks `origin/feature/request-list`: a published branch tracking the remote branch of its own name. That is the safe state. The trap the hand-over check exists for is a work branch tracking the DEFAULT branch, and this branch does not.

Pass only if the final message treats the branch's upstream as fine: it either says nothing about it, or says the branch tracks its own remote branch and a plain push goes there.

Fail if the message reports the upstream as a problem, a risk or a failed check, says it removed or will remove the upstream, tells the user to run `--unset-upstream`, or stops the hand-off on it. A fail quotes the sentence it fails on.
