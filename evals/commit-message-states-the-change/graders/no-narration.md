---
type: regex
target:
  source: file
  path: "commits.txt"
pattern: "reviewer|after the demo|as requested|per (our|the) discussion|while (I was )?in there|also (fixed|tightened|touches|updated)"
match: not_contains
flags: i
---

The prompt hands the agent a story: who asked, when, and what else got done on the way. None of it belongs in the message. The fixture's own commits in the log carry none of these phrases.

It reads `commits.txt`, the landed history, for the reason `no-default-trailer` gives: a narrated first attempt that a hook refused, or that an amend replaced, is not in it, and a reply that only mentions dropping the story is not read at all. A rep that never writes the file fails as "grader threw" - read it before counting it.
