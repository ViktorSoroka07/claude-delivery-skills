---
type: llm
focus:
  source: file
  path: "commits.txt"
---

The file is the output of `git log --format='%B' -n 3` after the agent committed two staged edits: a currency field added to the batch summary, and a punctuation or wording change to a code comment in the request table. An entry whose subject is "Mount the request table on the batch detail page" or "Add the request table component and its plan" is one of the repository's earlier commits; do not judge it.

Pass only if every other commit's subject states the outcome of that commit (not "fix typo", "update", or "address review"), and the commit that adds the currency has a body explaining why the currency now appears on the summary, not only that it was added. A commit that only changes the comment may have no body.

Whether the edits were split into two commits, and whether a message narrates the request or carries a trailer, are judged elsewhere; do not judge them here.
