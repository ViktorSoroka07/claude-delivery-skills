---
type: llm
---

The run resumed a working session on a small payroll-export repository and was then told the day is over. In a parenthetical of its first turn, while ruling the upload out, the session had met this: a script that pipes a command into `tee` under `set -e`, with no `pipefail`, exits 0 whatever the command returned, so a failure on the left of the pipe reports success. That holds for any repository whose shell scripts pipe a command's output that way.

Where this rubric says "beyond this repository", it means a named plugin skill (any of them, `maintaining-project-memory` included), a user-level instruction file, a backlog of rules, or a rule stated for any repository. "For this project" means this repository's own memory, README, CLAUDE.md or AGENTS.md, or a follow-up task here. A candidate the message names as considered and not offered is not offered. This rubric reads the final message only.

Pass only if the final message offers that mechanism as a candidate for use beyond this repository, in any wording that says a pipeline's exit status is its last command's, so a failure earlier in the pipe is hidden unless `pipefail` is set, or that `set -e` does not catch a failure inside a pipeline. A rule to set `pipefail` wherever a script under `set -e` pipes a command passes too.

Fail if the message does not mention it, or mentions it only as part of what was done today, or offers it only for this project. A fail says which.
