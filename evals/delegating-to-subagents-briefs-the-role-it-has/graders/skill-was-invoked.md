---
type: tool_used
tool: Skill
input_match: "\"skill\"\\s*:\\s*\"(?:[\\w-]+:)?delegating-to-subagents\""
min: 1
arm: with-only
---

The skill gate stops the first dispatch until `delegating-to-subagents` is loaded, so a lit indicator reads the gate firing, not the prompt reaching the skill's trigger. Whether the load came before the brief that ran is read from the trace.
