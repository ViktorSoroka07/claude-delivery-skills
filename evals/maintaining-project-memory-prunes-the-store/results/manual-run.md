# Manual run

Historical scores: each table below is from the fixture as it stood when that table was taken. `evals/fixtures/memory-store.sh` has changed since the first of them, in 8efd0ea; a table is a baseline for the current fixture only where none of those commits is later than it.

Hand-run per CONTRIBUTING's "Testing a wording change", the plugin eval command being early-access-gated on the machine. Five fresh subagents per arm on the model of interest, each on its own fixture built by `evals/fixtures/memory-store.sh`, the skill named in the brief (so the trigger is untested), the tree graded rather than the reply.

| arm | records the trap | files it under its heading | deletes the twin | deletes the ephemeral dir | live memory intact |
|---|---|---|---|---|---|
| current skill text | 5/5 | 5/5 | 0/5 | 0/5 | 5/5 |
| with the store-wide pruning bullet | 5/5 | 5/5 | 5/5 | 5/5 | 5/5 |

Baseline reads: every rep named the two dead directories, called them decoys or other checkouts, and left them in place. Treatment reads: every rep listed the store against the disk, checked mtimes, deleted both, and declined to carry the twin's contradicting note into the live memory.

Declined from the same run: a sentence telling the writer to file a new index line under its heading rather than at the file's end. The baseline filed it under the matching heading in every rep, so the sentence adds nothing; it stands in BACKLOG's declined section.

## The absence-check rule

The fixture gained a "no CI" entry recorded from observed absence that the
checkout has since falsified (it carries a workflow file), graded by
`re-runs-the-absence-check`. Five fresh Sonnet reps on the current skill
text, the pruning-pass prompt verbatim: every rep read the checkout, found
the workflow file, and deleted the entry with its index line as answered by
the repo. The baseline does not fail, so the sentence proposed for the
pruning pass (re-check an entry recorded from absence rather than re-read
it) was declined; `BACKLOG.md` carries the line. The grader stays as a
regression guard on the behaviour the current text already produces.

## Through the runner, and why one of its graders says nothing

Two runs of `claude plugin eval` on this case, the runner's own arms and its
default judge: three runs per arm in the release baseline, then five per arm
with the traces kept, to settle what the first one seemed to show.

| Grader | No plugin | Plugin |
|---|---|---|
| deletes-the-dead-twins | 0/5 | 3/5 |
| re-runs-the-absence-check | 5/5 | 5/5 |
| keeps-the-live-memory-intact | 5/5 | 3/5 |
| records-the-trap-once, as judged | 0/5 | 1/5 |
| records-the-trap-once, by hand | not read | 5/5 |

**`records-the-trap-once` cannot be read from the runner at all.** It has no
`focus`, so the judge is shown the run's final message, while its rubric asks
whether exactly one new file states the trap with its boundary condition
inside the imperative and without narrating the session — none of which a
reply contains. Read from the traces, every plugin run wrote exactly one file
under the live memory directory, each stating that a space in the font path
triggers the silent fallback and each ending in the imperative to check the
path before rendering; the judge passed one of the five. The 2/3 → 0/3 that
looked like a regression in the release baseline is this grader failing runs
that did what it asks.

**The live-memory drop is real and repeats.** Two plugin runs of five
rewrote the index without its "conventions the user has ruled on" heading,
having deleted the review-style entry under it; one of them says why, in as
many words: the rule it records is already stated by a skill the plugin
ships, so the entry is a duplicate. That is the pruning pass's own
minimality rule reaching an entry recording the user's ruling — which no
repo, tracker or history answers, and which outlives any install. No
no-plugin run touched it, in either round. `BACKLOG.md` carries the
mechanism against this skill; the fix is a boundary inside the rule, not a
grader edit.

The dead-twin row is the rule working: three plugin runs of five deleted both
dead directories after checking them against the checkouts on disk, and no
unaided run deleted either, in ten runs across the two rounds.
