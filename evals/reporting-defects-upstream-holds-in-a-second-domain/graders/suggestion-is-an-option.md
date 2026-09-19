---
type: llm
focus:
  source: file
  path: "docs/reports/draft-cache-asset-miss.md"
---

The draft's fix section opens with an instruction — "Strip the workspace root from the path before hashing" — and the counter section ends with another — "Count every reason."

Pass only if every suggestion to the owning team in the sent version, and in any report split out of it, is phrased as an option they can take or leave ("one option would be", "could", "might") rather than an instruction. The engineering content may stay exactly the same.

An imperative sentence under a heading or lead-in that names it an option ("One option", "An option:") is an option: the frame leaves the decision with the owner. An imperative under "Fix", "Suggested fix", or with no such frame is an instruction.

Fail if any suggestion to the owning team is still an imperative, a "Fix:" line, or a heading that presents the change as decided. A fail quotes the sentence or heading it fails on.

This grader reads the report at the path the prompt names, as the run left it: the rubric is about the text that will be filed, and the run's closing message is a summary of the rewrite, which cannot hold it. A single-file focus reads that report alone; anything carried into a report split out of it is outside what this grader sees, and a hand run reads both files.
