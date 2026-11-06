---
type: tool_used
tool: Skill
input_match: "\"skill\"\\s*:\\s*\"(?:[\\w-]+:)?verifying-before-sending\""
min: 1
arm: with-only
---

The prompt does not name the skill; an answer the requester forwards to their lead is the skill's trigger. Marked `arm: with-only`, so it is the trigger's indicator and scored in neither arm of a two-arm run. Whether the load came before the answer was written is read from the trace.
