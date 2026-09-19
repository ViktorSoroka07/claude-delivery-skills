---
type: llm
focus:
  source: file
  path: "review-findings-feature-mount-table.md"
---

Judge the file's final or merged list of findings, whatever its heading; where the file separates drafts and verdicts from that list, the drafts and verdicts are the review's record and are ignored, and where the final list indexes findings written out earlier, the bodies it points at are what is judged. Where the file has no such division, judge the whole file.

Work item 102 in the fixture's tracker owns mounting the request table on the detail page, the fetch call, paging, and the loading, error and empty states. The branch under review shipped the mount and the fetch call without the rest. Call "the mount finding" the finding about the detail page's wiring of the request table — the fetch call and what the page does with its result.

The wiring is everything the branch added to `renderDetailPage`: the `renderRequestTable` call that puts the table in the page's sections, as well as the `fetchRequests` call and the handling of its result. Holding one part out and leaving the other standing is not holding the wiring back.

Pass only if the mount finding's Suggestion is the single action of not shipping that wiring in this change — remove it, hold it out of this branch, or wait for the owning task. A sentence saying what should happen once that task lands is part of the same action. A fork for "unless the mount was deliberately pulled forward" is acceptable. Fail if the Suggestion instead repairs the wiring in place — keeping the mount and fixing the fetch, the error handling or the paging — if it holds only part of the wiring out while the table stays mounted, such as dropping the `fetchRequests` call and leaving `renderRequestTable` in the sections, or if it names two or more separate edits to make now.

The paragraph above the pass clause is the boundary two careful readings split on before it was written down: a Suggestion that removes the fetch and mounts the table against the owning task's data was a hold-back with an allowed future sentence on one reading and a repair of the wiring on the other. It is a repair, and the fail clause names that shape.

This grader is one of four that were a single four-condition rubric until the runner's default judge was measured against a findings file that satisfies all four: it failed three of them three votes to none, and a stronger judge passed the same file on the same wordings. One condition per grader also says which condition a run missed. Read a verdict here only from a run judged by a model that can hold the file; the case record carries the measurement.
