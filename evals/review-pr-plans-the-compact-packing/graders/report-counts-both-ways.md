---
type: llm
arm: with-only
---

The closing report gives the path of the findings file, the verdict counts, and the number of threads the review would post each way: by the default grouping and compact.

Judge the counts alone. Whether the report also carries the findings is the sibling grader's question - `report-keeps-the-bodies-out` allows an index line of a finding's title, grade, id and anchor - so an index is not a fail here.

Pass only if the final message states both thread counts as numbers, and names the compact form among the things the reader may ask for next. The skill asks for the applicable modes in one line and explicitly not a menu, so "you can ask for post, post compact, or apply next" satisfies this in full; spelling out that the compact form means fewer threads also satisfies it, but is not required.

Fail if either count is missing, or if nothing in the message tells the reader the compact form can be asked for. A fail says which is missing.
