---
type: tool_used
tool: Skill
input_match: "\"skill\"\\s*:\\s*\"(?:[\\w-]+:)?plan-feature\""
min: 1
arm: with-only
---

The prompt names the skill, so this is not a trigger test: it says whether the run loaded the skill or worked from the name alone, which a scored grader on the outcome cannot separate. Marked `arm: with-only`: the arm without the plugin cannot pass it, so it is shown as a plugin-fired indicator and scored in neither arm. It does not check that the load came before the run's first change; a hand run reads that order from the transcript.
