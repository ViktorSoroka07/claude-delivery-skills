---
type: llm
---

The draft predicts the change's effect in the owner's codebase: "Because nothing reads the raw path once it is hashed, the other artifact types keep hitting as they do today."

Pass only if the sent version makes no claim about what a change would or would not do elsewhere in the owner's system. Reporting what the reporter observed — the other three types key on repository-relative paths and hit — and leaving the conclusion to the owner is fine.

Fail if any sentence asserts or predicts that a change is safe, cannot regress something, has no side effects, leaves other paths as they are, or "will not affect" a part of their system. A fail quotes the sentence it fails on.
