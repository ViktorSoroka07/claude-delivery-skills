---
type: regex
target:
  source: file
  path: "commits.txt"
pattern: "co-authored-by:|generated with \\[?claude"
match: not_contains
flags: i
---

The fixture's history carries no trailers, so a trailer in a new commit came from a tool's default, not the repo's convention. The pattern is the trailer's own form, the key with its colon and the footer naming the tool, so a body that says something is "generated with" a field does not match.

It reads `commits.txt`, the log the prompt has the run save, which is the history that landed whichever way a message was written - `-m`, `-F` after a `Write`, a heredoc, an `--amend`. A grader over the commit commands cannot stand in for it: the runner counts every tool call, a hook's refused one included, so a commit the delivery gate stopped would read as landed, and so would the message an amend replaced. A rep that never writes the file fails here as "grader threw", which is a missing file and not a trailer - read that rep before counting it.
