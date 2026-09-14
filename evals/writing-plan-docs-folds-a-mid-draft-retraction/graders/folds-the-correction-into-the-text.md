---
type: llm
focus:
  source: file
  path: "docs/import-throughput.md"
---

The fixture's document carries a section headed "Correction" that retracts a figure the same document states elsewhere. It reported 40,000 rows per run; the run log's counter counts rows attempted and the importer re-enqueues a failed row up to three times, so the count of distinct rows is 24,000. Nobody outside the session that wrote it ever saw the draft the correction argues with.

Pass only if the finished document states the corrected figure where the claim belongs and no longer carries a passage narrating that an earlier reading was wrong. The substance of the retraction must survive as a plain statement of fact, that the counter counts attempts rather than distinct rows, placed where a reader meets the figure.

Fail if the document still carries a "Correction" section, an "Update" callout, a struck-through figure, or any sentence of the form "I earlier reported X" or "this was previously stated as X", whatever else it gets right. Fail also if the correction was deleted without the corrected figure and its basis taking its place, which loses the finding rather than folding it.
