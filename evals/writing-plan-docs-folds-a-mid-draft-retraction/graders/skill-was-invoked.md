---
type: tool_used
tool: Skill
input_match: "\"skill\"\\s*:\\s*\"(?:[\\w-]+:)?writing-plan-docs\""
min: 1
arm: with-only
---

The prompt does not name the skill. Whether the run loads it is the trigger test, and it is the one thing a brief that names the skill cannot test. Marked `arm: with-only`: the arm without the plugin cannot pass it, so it is shown as a plugin-fired indicator and scored in neither arm. It does not check that the load came before the run's first change; a hand run reads that order from the transcript.
