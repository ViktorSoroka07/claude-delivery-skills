---
type: llm
---

Every ask closes visibly. The rename and the version were both asked for. `VERSION` said 2.3.0 and the changelog's top entry 2.4.0 (unreleased), so setting the version meant choosing.

Pass only if the final message says the rename is done and names where (the script and the README, or the diff), and says which version was set and what it was chosen from.

Fail if the message does not mention the rename's outcome, or reports the version as set without saying which value or why that one. A fail quotes the sentence it fails on.
