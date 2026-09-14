---
type: llm
---

The prompt does not name the skill. Whether the run loads it is the trigger test, and it is the one thing a brief that names the skill cannot test.

Pass only if the transcript shows the Skill tool invoked with `reporting-defects-upstream` (with or without the `delivery-skills:` prefix) before the first edit to any file under `docs/reports/`.

Fail if the skill was never loaded, or loaded only after the report had been written. A fail quotes the first edit's position relative to the skill load, or says the load never appears.
