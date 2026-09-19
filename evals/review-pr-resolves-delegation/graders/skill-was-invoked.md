---
type: tool_used
tool: Skill
input_match: "\"skill\"\\s*:\\s*\"(?:[\\w-]+:)?review-pr\""
min: 1
arm: with-only
---

The prompt does not name the skill. Whether the run loads it is the trigger test, and it is the one thing a brief that names the skill cannot test. Marked `arm: with-only`: the arm without the plugin cannot pass it, so it is shown as a plugin-fired indicator and scored in neither arm. It matters here beyond the trigger, because the harness's own built-in review skill answers to a review request too, and a run that loads that one instead has not exercised the skill under test whatever its findings file says; a plugin-arm run with this indicator dark is unusable rather than a fail. It does not check that the load came before the first write; a hand run reads that order from the transcript.
