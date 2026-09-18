---
type: llm
focus:
  source: file
  path: "review-findings-7.md"
---

Judge only what follows the "Pass 2 — verification" section, which is the final merge whatever heading the run gave it. Everything above that point is the review's drafts and verdicts, where the refuted draft and ungrouped findings rightly appear; ignore it.

The final findings are written once, in default form, organised by severity. A packing plan sits beside that list and never replaces it.

Pass only if the final section lists all seven surviving findings (the 60-second cap, the milliseconds claim, the stdout claim, the 3-retries claim, the ignored HTTP-date claim, the uncapped header delay, the wait after the final attempt) with the two mediums ahead of the minors, and no group in that list holds both a medium and a minor. Two findings on the same file merged into one grouped finding is fine, as long as each member keeps its own `file:line`.

Fail if a surviving finding is missing from the list, if a medium and a minor were merged, or if the list was reduced to the rows of a packing table. A fail names the finding or group it fails on.
