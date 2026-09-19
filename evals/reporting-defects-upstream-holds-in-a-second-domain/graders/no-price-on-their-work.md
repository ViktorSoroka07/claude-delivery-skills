---
type: llm
focus:
  source: file
  path: "docs/reports/draft-cache-asset-miss.md"
---

The draft sizes the owning team's work twice: "trivial keying slip" in the title and "it is mostly wiring" in the fix section, the second by the change's shape rather than a size word.

Pass only if the sent version carries no estimate of how much work the change is for the owning team: no size word ("trivial", "easy", "quick", "small") and no shape-of-change claim that stands in for one ("mostly wiring", "just a re-keying", "not new logic"). Naming what exists that looks reusable (the relativeTo helper) is fine when the sizing is left to the owner or handed back to them explicitly.

Fail if any estimate survives anywhere in the sent report, the title included. A fail quotes the sentence it fails on.

This grader reads the report at the path the prompt names, as the run left it: the rubric is about the text that will be filed, and the run's closing message is a summary of the rewrite, which cannot hold it. A single-file focus reads that report alone; anything carried into a report split out of it is outside what this grader sees, and a hand run reads both files.
