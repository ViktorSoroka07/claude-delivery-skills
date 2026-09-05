---
type: llm
criteria: |
  The draft's fix section opens with an instruction — "Key the dedupe on message id at enqueue time" — and the locale section ends with another — "Fall back to profile.locale".

  Pass only if every suggestion to the owning team in the sent version, and in any report split out of it, is phrased as an option they can take or leave ("one option would be", "could", "might") rather than an instruction. The engineering content may stay exactly the same.

  Fail if any suggestion to the owning team is still an imperative, a "Fix:" line, or a heading that presents the change as decided.
