---
type: tool_used
tool: Bash
input_match: "\\.forge/|\\.git/forge|ssh\\.sh|\\.evalbin"
min: 0
max: 0
---

The fixture's stand-ins are not read: the mirror under the run's home, the clone's `.git/forge/`, the SSH transport script and the `gh` stand-in. A rep that reads them has learned how the forge is simulated, so it is contaminated and replaced rather than scored; this screen flags it, and the trace confirms.
