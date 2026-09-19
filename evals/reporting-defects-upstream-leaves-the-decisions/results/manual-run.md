# Manual runs

Historical scores: each table below is from the fixture as it stood when that
table was taken. `evals/fixtures/notify-report.sh` has changed since the first
of them, in 58d8ceb, 8efd0ea, a2797d0 and 2b592bf; a table is a baseline for
the current fixture only where none of those commits is later than it.

`claude plugin eval` is still gated at run time, so the case was run by the
hand procedure in CONTRIBUTING's "Testing a wording change": ten fixtures
from `evals/fixtures/notify-report.sh`, verified identical by hash, fresh
subagents on sonnet, the eval prompt verbatim. The baseline arm was told not
to use the Skill tool. The other arm was told nothing about skills: the
skill was installed and never named, so the run had to find it, which is
the shape the plugin command runs. Graded on the files under
`docs/reports/` as written to disk. The trigger grader was read from each
run's transcript by script: the line of the first Skill call naming the
skill against the line of the first write under `docs/reports/`.

This is the second round. The first ran an earlier draft whose effort
estimate and safety claim were blunt enough that the baseline dropped them
unprompted; the draft now sizes the fix by its shape and predicts the
change's effect by analogy, and both graders discriminate.

## Results

| Grader | base | skill unnamed |
|---|---|---|
| states-the-true-proportion | 1/5 | 5/5 |
| no-price-on-their-work | 1/5 | 5/5 |
| no-ranking-of-their-priorities | 0/5 | 4/5 |
| suggestion-is-an-option | 0/5 | 5/5 |
| no-safety-assertion | 0/5 | 5/5 |
| title-carries-no-verdict | 5/5 | 5/5 |
| split-moves-the-evidence | 3/5 | 5/5 |
| no-disposal-imagery | 3/5 | 5/5 |
| skill-was-invoked | 0/5 (forbidden) | 5/5 |

Every run in the unnamed arm loaded the skill before its first edit, with
the load between transcript lines 10 and 17 and the first write between 29
and 37. Every tree was written; no run reported a rewrite it had not made.

The baseline keeps the standing almost entirely: every run argues that the
fix belongs in the service, every run keeps the fix as an instruction, four
of five keep the shape-sized estimate ("more a re-keying than new logic")
and every one keeps the analogy ("the other channels would carry on as they
do now") — one run defended keeping it as "grounded in evidence". What the
baseline does unprompted is trim the fix's shape out of the title and split
the report where the fixture's own convention says one file is one item.

The unnamed-arm miss on ranking: one run kept the "why a workaround on our
side isn't the answer" heading with "we think this belongs in the service",
then added "where it fits against your other priorities is for you to
weigh". The hand-back does not undo the sentence before it.

Two graders need a note. The title grader no longer separates the arms:
every baseline trimmed "a re-keying in enqueue" and "doesn't survive
retries" reads as the observation, so a future fixture round should put a
verdict word back. The suggestion grader met an imperative under an "An
option" heading in three runs across both arms; the grader now states that
the frame makes it an option, and those runs are graded that way.

## Not tested

The "never price their work" rule against a hedged estimate that names no
shape at all ("probably small on your side"); the fixture's is shaped.

## The dependent-requirement rule

The fixture's draft gained an options section listing one risk per option,
and the notes gained the two things the caller's invoice-reminder flow
relies on (retry stays enabled; no recipient gets a reminder twice), graded
by `states-the-dependent-requirement`. Five fresh Sonnet reps on the current
skill text, the prompt verbatim: every rep pulled both requirements from the
notes and set them beside the options, in a section of their own or under
the consequence, and left the choice with the owner. The baseline does not
fail, so the bullet proposed for "Decisions that belong to the owner" was
declined; `BACKLOG.md` carries the line. The grader stays as a regression
guard.

## The graders moved onto the report, and the retake that followed

Every rubric in this case is about the report that gets filed, and until
`7b59f4d` eight of the nine `llm` graders carried no `focus`, so each was shown
the run's closing message — a summary of what changed — and nothing else. The
verdicts in the release baseline are votes on a text that cannot hold the
evidence, and none of them is a reading of this case's behaviour. Only
`states-the-dependent-requirement` had a focus, and in one baseline run of three
it threw: that run replaced the draft with two reports of its own naming and
deleted the path the grader reads, which the prompt as it stood permitted.

The prompt now says the version to send goes into `docs/reports/draft-notify-dedupe.md`
itself, and the eight graders focus that file. `split-moves-the-evidence` could
not follow them as written, because the report it asks to exist is one the run
names: it now reads the parent — the locale evidence gone from it, and the
pointer the skill asks a split parent to keep standing in for the child.

One runner pass at the head that carries those edits, three runs per arm,
`--judge-model sonnet`, $4.77 for this case and its sibling together:

| Grader | No plugin | Plugin |
|---|---|---|
| no-disposal-imagery | 1/3 | 3/3 |
| no-price-on-their-work | 2/3 | 3/3 |
| no-ranking-of-their-priorities | 0/3 | 2/3 |
| no-safety-assertion | 0/3 | 0/3 |
| split-moves-the-evidence | 0/3 | 2/3 |
| states-the-dependent-requirement | 0/3 | 0/3 |
| states-the-true-proportion | 0/3 | 1/3 |
| suggestion-is-an-option | 0/3 | 2/3 |
| title-carries-no-verdict | 0/3 | 2/3 |
| skill-was-invoked | — | 3/3 (indicator, scored in neither arm) |

No grader threw and no run was curtailed, which is the first thing this table
says: every row is a reading of the filed report in both arms. The second is
that the arms separate on every row — the unaided arm keeps the draft's
standing almost entirely, as the hand rounds above found.

The third is that the judge is harsher than the rubrics' own text on this
family, and the two zero rows are where that shows. Hand-graded from the kept
`evidence`:

- **`no-safety-assertion`, judge 0/3, hand 2/3.** Run 1 genuinely fails: "Single
  sends already key on message id, so we'd expect this to change batch behavior
  only" is the prediction-by-analogy the rubric names. Run 3 states the opposite
  — "we don't have visibility into what else on your side depends on batch-level
  idempotency" — and was failed anyway; run 2's "For reference, single sends
  already key on message id today" reports the path and draws no conclusion,
  which the rubric expressly allows.
- **`states-the-dependent-requirement`, judge 0/3, hand 2/3.** Runs 1 and 3 both
  carry a section of their own — "Our invoice-reminder flow depends on two things
  from the service: retry on timeout stays enabled… and no recipient gets the
  same reminder twice" — directly above the options, with the choice left open.
  Run 2 states both at the end, after the options rather than beside them, which
  is the one reading on which "beside the options" bites.
- **`split-moves-the-evidence`, judge 2/3, hand 3/3.** The run it failed carries
  "## Separately: locale fallback", a pointer to the file it wrote, and no locale
  evidence at all — a pass under the rewritten clause.

So the retaken rows are readable as the difference between the arms and not as
absolute rates. That is a property of the family, not of the retake: nine tone
rubrics over a three-kilobyte document is the shape the judge was already known
to be harsh on, and the earlier tables in this file were graded by hand, which is
why their rates are higher and not comparable with these.
