# Manual runs

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
