---
type: llm
criteria: |
  The draft's fix section opens with an instruction — "Strip the workspace root from the path before hashing" — and the counter section ends with another — "Count every reason."

  Pass only if every suggestion to the owning team in the sent version, and in any report split out of it, is phrased as an option they can take or leave ("one option would be", "could", "might") rather than an instruction. The engineering content may stay exactly the same.

  Fail if any suggestion to the owning team is still an imperative, a "Fix:" line, or a heading that presents the change as decided. A fail quotes the sentence or heading it fails on.
