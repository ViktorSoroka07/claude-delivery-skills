---
type: llm
focus:
  source: file
  path: "review-findings-feature-mount-table.md"
---

Judge the file's final or merged list of findings, whatever its heading; where the file separates drafts and verdicts from that list, the drafts and verdicts are the review's record and are ignored, and where the final list indexes findings written out earlier, the bodies it points at are what is judged. Where the file has no such division, judge the whole file.

Work item 102 in the fixture's tracker owns mounting the request table on the detail page, the fetch call, paging, and the loading, error and empty states. The branch under review shipped the mount and the fetch call without the rest. Call "the mount finding" the finding about the detail page's wiring of the request table — the fetch call and what the page does with its result.

Pass only if the mount finding's Problem carries both the swallowed fetch error and the 50-row page cap, as symptoms of that one problem; a numbered or bulleted list is the usual shape. Fail if either appears as a finding of its own rather than inside the mount finding.

This grader is one of four that were a single four-condition rubric until the runner's default judge was measured against a findings file that satisfies all four: it failed three of them three votes to none, and a stronger judge passed the same file on the same wordings. One condition per grader also says which condition a run missed. Read a verdict here only from a run judged by a model that can hold the file; the case record carries the measurement.
