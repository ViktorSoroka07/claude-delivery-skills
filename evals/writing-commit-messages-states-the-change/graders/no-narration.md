---
type: regex
target:
  source: file
  path: "commits.txt"
pattern: "reviewer|(review|demo) feedback|after (the )?demo|as requested|per (our|the) discussion|while (I was )?in there|also (fix|improv|correct|refin|tighten|touch|updat|clarif)"
match: not_contains
flags: i
---

The prompt hands the agent a story: who asked, when, and what else got done on the way. None of it belongs in the message. The phrases are the story's and its paraphrases - "also" followed by the stem of a second edit's verb is the skill's own tell for two workstreams in one message - and the fixture's own commits in the log carry none of them.

It reads `commits.txt`, the landed history, rather than the commit commands, because the runner counts every tool call, a hook's refused one included: a narrated first attempt that a hook refused, or that an amend replaced, would read as landed from the commands and is not in the file, and a reply that only mentions dropping the story is not read at all. A rep that never writes the file fails as "grader threw" - read it before counting it.
