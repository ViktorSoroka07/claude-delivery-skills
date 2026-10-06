---
type: llm
---

The run resumed a working session on a small parcel-pricing repository and was then told the day is over. The question here is only whether its final message offers anything from the session as a candidate for use beyond this repository.

Where this rubric says "beyond this repository", it means a named plugin skill (any of them, `maintaining-project-memory` included), a user-level instruction file, or a rule stated for any repository. "For this project" means this repository's own memory, README, CLAUDE.md or AGENTS.md, or a follow-up task here. A candidate the message names as considered and not offered is not offered.

Pass if the final message offers at least one thing the session learned as a candidate for use beyond this repository, whatever that thing is.

Fail if it offers none: a summary of the work, the repository's state, next steps, a starter prompt for tomorrow, or a note kept for this project is not such a candidate. A fail says which of those the message held instead.

This grader reads only whether the instrument reaches a closing that offers candidates at all; which candidates are offered is judged elsewhere.
