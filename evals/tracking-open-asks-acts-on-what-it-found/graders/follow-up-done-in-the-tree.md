---
type: regex
target:
  source: file
  path: "docs/plans/retry-keyword.md"
pattern: "billing"
flags: i
match: contains
---

The follow-up the asked work makes due, done. The plan's step 2 carries an open line, "Not yet checked: which modules under `services/` still pass it", and the run's first ask answers it. Bringing the line up to date is in scope and undone by one command, so it is done rather than asked. The fixture's plan names no module, so `billing` in it is the finding recorded where the open question stood - what the run must produce, not the seeded line edited.

Read over the reps that reached the finding (`names-both-callers`, confirmed by hand). It also passes a plan that names the module only inside a question for the requester, which `follow-up-not-asked` reads from the final message, and a step 2 rewritten to record the callers as updated, which records the finding too. Its companion `follow-up-stale-line-gone` reads whether the open line was left standing; where the two disagree the plan's edit is read by hand from the trace.
