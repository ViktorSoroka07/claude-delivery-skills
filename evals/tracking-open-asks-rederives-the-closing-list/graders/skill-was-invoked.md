---
type: tool_used
tool: Skill
input_match: "\"skill\"\\s*:\\s*\"(?:[\\w-]+:)?tracking-open-asks\""
min: 1
arm: with-only
---

The prompt does not name the skill. Whether the run loads it is the trigger
test and nothing else. No rep of this case has called the Skill tool, so the
skill's own text reaches none of them, and a wording round here tests the
brief's text instead - which this grader cannot see, reading 0 in both arms.
Marked `arm: with-only` — the arm without the plugin cannot pass it, so it is
shown as a plugin-fired indicator and scored in neither arm.

A resumed run gets no `SessionStart` brief from the hook, whose matcher is
`startup|clear|compact`; the fixture carries the brief as the attachment a
recorded session writes, and a resume does re-render it into the run's context
(the case record has the probe that settled it). So an arm's brief text is
confirmed from its regenerated `history.jsonl`, by a phrase only that arm's
text has, not from this grader.
