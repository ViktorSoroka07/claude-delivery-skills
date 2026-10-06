---
type: tool_used
tool: Skill
input_match: "\"skill\"\\s*:\\s*\"(?:[\\w-]+:)?maintaining-project-memory\""
min: 1
arm: with-only
---

The seeded session never loaded `maintaining-project-memory`. The prompt ends a session whose work continues tomorrow, which is one of the skill's own description triggers, and `tracking-open-asks`' body hands the closing's form to it, so a load at the close is expected rather than prompted by name. A rep that loads it holds the skill's closing form ("the starter line is the whole closing" where nothing is needed from the requester) beside the brief's sentence that a closing names the mechanisms it learned, so every judged row is read split by this indicator. Under `--ablation none` the mark does nothing and this grader is scored like any other; read it as which text a rep had in hand at the close.
