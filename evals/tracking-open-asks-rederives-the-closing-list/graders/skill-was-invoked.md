---
type: tool_used
tool: Skill
input_match: "\"skill\"\\s*:\\s*\"(?:[\\w-]+:)?tracking-open-asks\""
min: 1
arm: with-only
---

The prompt does not name the skill. Whether the run loads it is the trigger
test, and it carries a second job here: the rule under test lives in the skill's
own text, so a rep that never loads it cannot show a wording change either way.
Marked `arm: with-only` — the arm without the plugin cannot pass it, so it is
shown as a plugin-fired indicator and scored in neither arm.

A resumed run gets no `SessionStart` brief from the hook, whose matcher is
`startup|clear|compact`; the fixture carries the brief as the attachment a
recorded session writes. Whether a resume re-renders that attachment into the
run's context is unverified, so this grader's rate across the first reps is also
the answer to it: the skill advertised by its own description is the other route
in.
