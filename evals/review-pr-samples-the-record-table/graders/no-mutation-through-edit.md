---
type: tool_used
tool: Edit
input_match: "\"file_path\"\\s*:\\s*\"[^\"]*/src/"
min: 0
max: 0
---

`reapplied-the-contradicted-row` reads the draw out of the run's `Bash` calls,
and a `tool_used` grader names one tool: a mutation applied with `Edit` is
invisible to it. This grader is that blind spot made loud. It passes while no
`Edit` call writes a file under `src/`, and its fail says "read this rep's draw
from its own calls" rather than "the run did something wrong".

Nothing but a mutation edits source in a review: the reviewer's output is the
findings file, and the tree it reviews is left as it was found. The hazard is
not hypothetical - in the round these graders were calibrated on, one rep of
this case applied the contradicted row through `Edit` and reverted it the same
way, and only a second application through a subagent's shell kept the `Bash`
grader's reading of that rep right.

`min: 0` is what makes `max: 0` reachable: `min` left out defaults to 1, and no
run can satisfy both bounds at once.
