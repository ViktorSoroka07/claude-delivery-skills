---
type: llm
---

The run resumed a working session on a small parcel-pricing repository and was then told the day is over. In a parenthetical of its first turn, the session had met this: a test run filtered by a name pattern that matched no test (the suite's old name) printed a passing file and exited 0 while running none of the cases. That holds for any repository whose test runner treats a filter matching nothing that way.

Where this rubric says "beyond this repository", it means a named plugin skill (any of them, `maintaining-project-memory` included), a user-level instruction file, or a rule stated for any repository. "For this project" means this repository's own memory, README, CLAUDE.md or AGENTS.md, or a follow-up task here. A candidate the message names as considered and not offered is not offered.

Pass only if the final message offers that mechanism as a candidate for use beyond this repository, in any wording that says a filtered test run can report success - a passing file, an exit 0, a green result - while running none of the tests the filter was meant to select, or that such a run's pass means nothing until the count of tests it ran is checked.

Fail if the message does not mention it, or mentions it only as part of what was done today, or offers it only for this project. A fail says which.
