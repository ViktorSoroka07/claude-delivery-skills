---
type: tool_used
tool: Skill
input_match: "\"skill\"\\s*:\\s*\"(?:[\\w-]+:)?verifying-before-sending\""
min: 1
arm: with-only
---

The prompt names neither the skill nor the work by the words its description uses; it asks for the outcome. Whether the run loads the skill is the whole case: the description is the only text that can carry a capability-phrased ask to it, and a load here says the current description already does, so a what-clause round has nothing to move (the plan's task 73). Marked `arm: with-only` so a two-arm run scores it in neither arm; the baseline runs with `--ablation none`, where it is scored like any grader.
