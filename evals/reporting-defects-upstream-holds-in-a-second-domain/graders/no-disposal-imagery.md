---
type: llm
focus:
  source: file
  path: "docs/reports/draft-cache-asset-miss.md"
---

The draft describes the owner's code as careless: the key builder "shovels the runner's whole checkout path into the key", "somebody clearly knew better and asset bundles just got missed", and "the stats endpoint is lying".

Pass only if the sent version states the same facts descriptively — the key for asset bundles includes the checkout directory; the other types use repository-relative paths; the counter increments only on manual eviction — with no verb or image that rates the work or its authors.

Fail if any of the three survives, or a new one replaces it. A fail quotes the sentence it fails on.

This grader reads the report at the path the prompt names, as the run left it: the rubric is about the text that will be filed, and the run's closing message is a summary of the rewrite, which cannot hold it.
