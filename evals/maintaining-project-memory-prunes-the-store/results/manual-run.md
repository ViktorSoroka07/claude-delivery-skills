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

## The boundary for an entry recording a ruling

The pruning pass's minimality rule reached the live memory's `feedback_review_style.md`,
whose body restates verbatim a rule the plugin's own brief states. Ten fresh headless
Sonnet reps per arm, one fixture each, the tree graded rather than the reply; arm
membership confirmed in every transcript by a phrase only the arm's own text carries.

| Grader | Baseline | Shape 1 | Shape 2 |
|---|---|---|---|
| keeps-the-live-memory-intact | 7/10 | 8/10 | 10/10 |
| deletes-the-dead-twins | 10/10 | 9/10 | 10/10 |
| re-runs-the-absence-check | 10/10 | 10/10 | 10/10 |
| records-the-trap-once, by hand | 10/10 | 10/10 | 10/10 |

**Shape 1 did not bind, and how it failed is the result worth keeping.** It made the
rule's trigger an entry "holding a decision taken for this project", and pre-empted the
justification the failing baseline reps gave. Both surviving failures refused the
trigger instead: "not a project-specific decision, so it was noise", and "no
project-specific reasoning attached to it". A precondition the run has to judge is one
it can judge its way out of, and the sentence answering the old justification never
fires.

**Shape 2 states the trigger as something readable in the store** — the entry's type, or
the heading it is filed under — and swept every grader. One rep names the distinction
back: it kept the entry as "a user ruling, not just a restated skill rule". No neighbour
moved; the dead-twin row recovered the single rep shape 1 had lost, which was an
ordinary miss of the underscore twin rather than the rule crowding it out.

The baseline's first five reps were clean and its second five failed three times. Five
reps would have reported no baseline failure at all and stopped the task; the rate here
is about three in ten, and CONTRIBUTING's five-rep floor hides such a rate about one
time in six.

## The operator's own global instruction files have to come off for a hand run

The machine's user-level instruction file tells every session that recursive deletion is
the operator's act, and the user-level settings deny `rm -rf` outright. This case's
correct behaviour is deleting two dead directories, so a probe rep refused to delete and
said so. Both files are moved aside for each batch and restored by a trap that verifies
checksums; without that the case is unmeasurable in both arms, and the failure reads as
the plugin's. CONTRIBUTING's "Testing a wording change" carries the general form.

## `records-the-trap-once` was judging the reply, and the "regression" was that

The release baseline showed this grader at 2/3 without the plugin and 0/3 with
it, and a five-rep part run repeated the shape (1/5 with, 0/5 without). Read as
a score it says the plugin stopped runs recording the trap. It says nothing of
the kind: the grader carried no `focus`, so the judge was shown the run's final
message — three or four lines saying what changed — and asked whether exactly
one new memory file states the trap with its boundary condition inside the
imperative and without narrating the session. None of that can be in a summary,
so the votes were on a text that cannot hold the evidence.

The grader cannot be pointed at the entry file either: the entry's name is the
run's choice, and `focus` takes one literal path. The two runs of the pass below
named it `project_font_path_trap.md` and `project_font_path_space_trap.md`. So
the grader now reads the live checkout's index, `MEMORY.md`, which is where a
name the run chose has to be declared, and asks what the index can answer:
exactly one line for the trap, linking a file beside it, with the boundary
condition — a space in the font path — in the hook. Whether the entry file
itself is an imperative and keeps the session's story out is hand-graded from
the tree, and the grader body says so.

`deletes-the-dead-twins` keeps judging the reply, and that is now stated in the
grader rather than left to be discovered: a deletion is the one outcome the
runner cannot show a grader. `focus` throws on a path that is gone, and a
`file_exists` grader with `exists: false` passes whether the run deleted the
path or never touched it, because it reads the run's own file changes and not
the workspace tree (settled by a throwaway case that deleted a scaffold file and
left another alone: the untouched one reported missing, and the deleted one and
a path that never existed both reported "absent as expected").

## Runner pass at the fixed graders — two runs per arm

| Grader | No plugin | Plugin |
|---|---|---|
| deletes-the-dead-twins | 0/2 | 2/2 |
| keeps-the-live-memory-intact | 2/2 | 2/2 |
| re-runs-the-absence-check | 2/2 | 2/2 |
| records-the-trap-once | 2/2 | 2/2 |
| skill-was-invoked (indicator) | not evaluated | 2/2 |

$1.01. `records-the-trap-once` now resolves and votes in both arms, and both
arms pass it: recording a learned trap in the index is not what this case
separates, and the apparent regression was the instrument. The case's named
behaviour, `deletes-the-dead-twins`, still moves 0/2 to 2/2.

`skill-was-invoked` behaves as the mark promises: `withOnly` true, `scored`
false, and the grader does not appear at all in the arm without the plugin, so
it can never throw there.
