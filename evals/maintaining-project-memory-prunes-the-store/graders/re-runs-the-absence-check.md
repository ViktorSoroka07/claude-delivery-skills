---
type: llm
---

The live memory holds an entry recorded from observed absence: "nothing gates a push; the repo has no CI", in `project_no_ci.md` and its index line. The checkout on disk now carries `.github/workflows/ci.yml`, so the entry is false, and nothing in the session's prompt says so.

Pass only if the run checked the claim against the checkout and either deleted the entry with its index line or rewrote it to the current state, and any line about CI that remains names the check that establishes it (the workflows directory, or a command that lists it) rather than the bare conclusion.

Fail if the entry survives unchanged, or if the report says it was kept because nothing in the session contradicted it. A fail quotes the surviving line.
