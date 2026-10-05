---
type: llm
focus:
  source: file
  path: "commits.txt"
---

The file is the output of `git log --format='%B' -n 3` after the agent committed two staged edits: a currency field added to the batch summary, and a punctuation or wording change to a code comment in the request table. An entry whose subject is "Mount the request table on the batch detail page" or "Add the request table component and its plan" is one of the repository's earlier commits; do not judge it.

Pass only if every other commit's subject tells a reader of the log what that commit changed and where: it names the change - a field added, a punctuation mark corrected, a wording clarified - and the code or text it is in. The verb it opens with does not matter: "Fix", "Correct", "Add" and "Clarify" all pass when the rest of the subject names what changed and where. Fail a subject that names neither, or only one of them, such as "Fix typo", "Update summary", "Address review comments" or "WIP".

Judge the subjects alone: bodies, trailers, and how many commits there are are judged elsewhere.
