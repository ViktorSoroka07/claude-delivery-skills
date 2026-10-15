---
type: tool_used
tool: Skill
input_match: "\"skill\"\\s*:\\s*\"(?:[\\w-]+:)?plan-feature\""
min: 1
arm: with-only
---

The prompt names the chain, so this is not a trigger test: it says whether the run loaded the skill or worked from the name alone. Marked `arm: with-only`, it is an indicator scored in neither arm of a two-arm run.
