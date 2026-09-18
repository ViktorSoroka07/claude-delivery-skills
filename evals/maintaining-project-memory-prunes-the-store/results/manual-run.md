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
