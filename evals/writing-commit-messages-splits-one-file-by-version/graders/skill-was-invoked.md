---
type: tool_used
tool: Skill
input_match: "\"skill\"\\s*:\\s*\"(?:[\\w-]+:)?writing-commit-messages\""
min: 1
arm: with-only
---

The skill gate stops the first commit until `writing-commit-messages` is loaded, so a lit indicator reads the gate firing. Whether the load came before the commit that ran is read from the trace.
