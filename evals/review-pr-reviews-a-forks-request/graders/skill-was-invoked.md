---
type: tool_used
tool: Skill
input_match: "\"skill\"\\s*:\\s*\"(?:[\\w-]+:)?review-pr\""
min: 1
arm: with-only
---

The prompt does not name the skill, and the harness's own built-in review skill answers to a review request too. A rep with this indicator dark is unusable rather than a fail: top up to the rep count instead of counting it.
