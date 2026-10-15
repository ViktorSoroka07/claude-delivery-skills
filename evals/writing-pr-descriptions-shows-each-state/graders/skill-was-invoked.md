---
type: tool_used
tool: Skill
input_match: "\"skill\"\\s*:\\s*\"(?:[\\w-]+:)?writing-pr-descriptions\""
min: 1
arm: with-only
---

The prompt asks for a pull request description, the skill's own trigger. Marked `arm: with-only`, it is an indicator scored in neither arm of a two-arm run: it separates "the skill never loaded" from "its rules did not hold".
