---
type: tool_used
tool: Skill
input_match: "\"skill\"\\s*:\\s*\"(?:[\\w-]+:)?tracking-open-asks\""
min: 1
arm: with-only
---

The prompt does not name the skill. The seeded conversation already loads it -
its first turn calls the Skill tool and carries the skill's body, as a fresh
conversation does under the brief's first-tool-call line - so a rep holds the
skill's text without calling the tool, and a rep's trace carries its own turns
only. This reads a second load by the rep, which the seeded one makes
unnecessary; it is not how arrival is known. Arrival is settled by the probe
the case record describes, and an arm's skill text by a phrase only that arm's
regenerated `history.jsonl` has. Marked `arm: with-only` - the arm without the
plugin cannot pass it, so it is shown as a plugin-fired indicator and scored
in neither arm.
