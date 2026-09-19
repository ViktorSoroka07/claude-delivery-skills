---
type: tool_used
tool: Agent
input_match: "\"subagent_type\"\\s*:\\s*\"(?:[\\w-]+:)?mutation-tester\""
min: 1
arm: with-only
---

The prompt asks for the plugin's mutation-tester agent by name, and only the arm with the plugin has one; the arm without it dispatches a general agent against the same brief, which is the comparison the case makes. Marked `arm: with-only`: shown as a plugin-fired indicator, scored in neither arm. A plugin-arm run with this indicator dark did not reach the contract under test, whatever its report says.
