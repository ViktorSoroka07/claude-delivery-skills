---
type: regex
target:
  source: file
  path: "commits.txt"
pattern: "^(?![\\s\\S]*Add the request table component and its plan)[\\s\\S]*Mount the request table on the batch detail page"
match: contains
---

Two unrelated edits were staged together: a currency field added to the batch summary, and a wording change to a code comment in the request table. They would be reverted separately, so they are two commits; the skill says split, and a single-prompt run cannot receive an answer to a question about it.

The count is read off the fixture's history. After exactly two new commits, `git log -n 3` shows them and the fixture's head, "Mount the request table on the batch detail page", but not the commit before it, "Add the request table component and its plan"; one new commit shows both, three or more show neither. The two subjects are landmarks the run has no reason to rewrite, not wording it is asked to change, so the pattern counts commits rather than detecting an edit. What the new subjects and bodies say is `messages-state-the-change`'s to judge.
