---
type: llm
criteria: |
  The draft asserts "Nothing else depends on the batch key, so this can't regress the other channels."

  Pass only if the sent version makes no claim about what a change would or would not break in the owner's codebase. Reporting what the reporter observed — 41 retried single sends, none duplicated — and leaving the conclusion to the owner is fine.

  Fail if any sentence asserts that a change is safe, cannot regress something, has no side effects, or "will not affect" a part of their system.
