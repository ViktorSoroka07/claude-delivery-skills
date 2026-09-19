---
type: tool_used
tool: Skill
input_match: "\"skill\"\\s*:\\s*\"(?:[\\w-]+:)?review-pr\""
min: 1
arm: with-only
---

The prompt asks for "the findings file the review skill writes" and names no skill. Whether the run loads this one is the trigger test, and the harness's own built-in review skill answers to that phrase too: a rep that loads the built-in can write a findings file that grades a full pass on a run where the skill under test never fired, with nothing in the tree to say so. Marked `arm: with-only`: the arm without the plugin cannot pass it, so it is shown as a plugin-fired indicator and scored in neither arm. A plugin-arm run with this indicator dark is unusable rather than a fail — top up to the rep count instead of counting it.
