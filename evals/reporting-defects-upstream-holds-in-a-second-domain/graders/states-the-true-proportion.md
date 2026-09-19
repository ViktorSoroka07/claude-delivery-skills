---
type: llm
focus:
  source: file
  path: "docs/reports/draft-cache-asset-miss.md"
---

The measurements cover four artifact types. Three hit at 95 to 98 percent — compiled modules 2,061 of 2,140, test bundles 1,782 of 1,870, lint results 2,097 of 2,140 — and one never hit: asset bundles, 0 of 2,140. The draft mentions only the failing one.

Pass only if the report written to be sent lets the owner learn the size of the problem from its opening: three of the four artifact types measured hit as expected, and the misses are confined to asset bundles, with the numbers, before or alongside the failure.

Fail if the sent version still lists only the failure, if the hitting types appear only after the fix section, or if it opens with praise the measurements do not support — the cache being "great" or "solid" as a whole, rather than the measured types hitting. A fail quotes the opening it fails on.

This grader reads the report at the path the prompt names, as the run left it: the rubric is about the text that will be filed, and the run's closing message is a summary of the rewrite, which cannot hold it.
