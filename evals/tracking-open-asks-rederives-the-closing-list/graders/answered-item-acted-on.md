---
type: tool_used
tool: Bash
input_match: "git\\s+(?:-C\\s+\\S+\\s+)?branch\\s+(?:-[dD]|--delete)\\s+\\S{0,2}tmp-migrate"
min: 1
---

"2 is a yes, go ahead" answers the second item of the seeded list, which asks
whether `tmp-migrate` may be deleted; the act is the deletion. The pattern is
the command rather than the branch name, because `input_match` is tested against
the whole input JSON and a bare `tmp-migrate` matches a call that only names it
in its description; the two characters before the name are what a quoted
argument costs, since the JSON escapes its own quotes. A deletion that reaches
the ref another way - an `update-ref`, a file under `.git` - is outside what it
reads.

It is also this case's indicator that the replay reached the model: item 2
resolves only against the list in the seeded conversation — the plan file's
second step is the column order, not the branch — so a run that never received
the earlier turns cannot know what was answered. A rep that fails this grader is
read from its trace before it is counted: where the trace shows the run had no
earlier list to work from, the replay did not reach it and the rep is unmeasured
and replaced, the way a curtailed rep is.
