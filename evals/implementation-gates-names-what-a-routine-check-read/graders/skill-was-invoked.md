---
type: tool_used
tool: Skill
input_match: "\"skill\"\\s*:\\s*\"(?:[\\w-]+:)?implementation-gates\""
min: 1
arm: with-only
---

The prompt does not name the skill, and nothing in it asks for work the skill names: the rule under test fires on reading a check's result, which no tool call identifies. Whether the run loads the skill is therefore the trigger's own indicator - a treated arm that passes without it was carried by the brief's bullet, not by the skill's section. Under `--ablation none` the mark does nothing and this grader is scored like any other; read it as the indicator, not as a behaviour either arm is asked for.
