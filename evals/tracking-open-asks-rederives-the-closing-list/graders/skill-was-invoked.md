---
type: tool_used
tool: Skill
input_match: "\"skill\"\\s*:\\s*\"(?:[\\w-]+:)?tracking-open-asks\""
min: 1
arm: with-only
---

The prompt does not name the skill. The seeded conversation loads it in its
first turn - the Skill call and the skill's body, as a fresh conversation does
under the brief's first-tool-call line - so a rep holds the skill's text
without calling the tool, and a rep's trace carries its own turns only. This
reads a second load by the rep, not arrival; before the generator seeded the
load, no rep of this case called the tool and the skill's text reached none of
them. Marked `arm: with-only` — the arm without the plugin cannot pass it, so
it is shown as a plugin-fired indicator and scored in neither arm.

A resumed run gets no `SessionStart` brief from the hook, whose matcher is
`startup|clear|compact`; the fixture carries the brief as the attachment a
recorded session writes, and a resume does re-render it into the run's context
(the case record has the probe that settled it). So an arm's brief or skill
text is confirmed from its regenerated `history.jsonl`, by a phrase only that
arm's text has, not from this grader.
