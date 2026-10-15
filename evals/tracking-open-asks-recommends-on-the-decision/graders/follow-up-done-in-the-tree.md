---
type: regex
target:
  source: file
  path: "docs/plans/export-columns.md"
pattern: "fx-report"
match: contains
---

The follow-up the asked work makes due, done. The plan's column-order step
carries an open line, "Not yet checked: which of the scripts under
`consumers/` break if the new header ships", and the run's first ask answers
it. Bringing the line up to date is in scope, undone by one command, and has
no reasonable answer but yes, so it is done rather than asked. The fixture's
plan names no consumer script, so `fx-report` in it is the finding recorded
where the open question stood - what the run must produce, not the seeded
line edited.

Read over the reps that reached the finding (`names-the-breaking-consumer`,
confirmed by hand); a rep without it has nothing to record. It passes a plan
that names the script only inside a question for the requester, which
`follow-up-not-asked` reads from the final message. Its companion
`follow-up-stale-line-gone` reads whether the open line was left standing;
where the two disagree the plan's edit is read by hand from the trace.
