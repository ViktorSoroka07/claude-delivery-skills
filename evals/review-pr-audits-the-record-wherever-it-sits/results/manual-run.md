# Manual runs

Fixtures from `evals/fixtures/refund-console.sh record-offplan`, verified
identical by tree hash; fresh Sonnet subagents loading the installed skill
through the Skill tool; the eval prompt verbatim; graded on the findings file
each run left in the fixture tree. The baseline arm is produced by swapping
the live `SKILL.md` to the pre-change text for the duration of the arm.

## The disclosed-survivor rule (the record's fourth, SURVIVED row)

The question: does a sentence telling the reviewer that a survived row is the
author's disclosed gap, not a contradicted claim, change what the weaker
model files? Graded by `keeps-the-disclosed-gap-unflagged`.

| Arm | Reps with a findings file | Kept the survivor unflagged |
|---|---|---|
| Baseline (pre-change text), hand runs | 5 of 5 | 5 of 5 |
| Baseline, runner | 1 usable of 5 | 1 of 1 |
| Treatment (the sentence), runner | 3 usable of 5 | 3 of 3 |

Baseline reps re-applied the title mutation, saw it survive, and called the
row accurately disclosed (two reps), filed the missing title assertion as a
test gap (one rep, which the rubric allows), or did not mention it (two
reps). Not one reported it as evidence against the record. The sentence was
declined; `BACKLOG.md` carries the line.

Runner reps that wrote no findings file died on git inside the eval sandbox
(Apple's git shim cannot write its cache file there); the hand procedure is
the instrument on this machine until a non-Apple git is first on the path.

One runner baseline rep flagged the fourth finding on a real fixture defect
that has since been fixed: the base file already built the title from the
batch id, so the branch made no fix the record could claim. The record's
header was likewise corrected to match its body. Both defects handed the
runner's judge a genuine "contradicted" hook unrelated to the rule, which is
why every runner verdict on this grader was read against the findings file
by hand.

## The other three graders

| Grader | Treatment |
|---|---|
| findings-file-written | 5/5 |
| flags-the-contradicted-claim | 5/5 |
| keeps-the-true-rows-unflagged | 5/5 |

From the five hand runs on the earlier fixture (three killed rows, no
survivor): every run wrote the findings file, re-applied the record's
mutations against the pinned head, and reported the catch-arm claim as not
holding — the suite stays green with the arm removed because the only test
resolves its fetch — as a Major or Medium finding. Every run dispatched the
fresh-eyes verifier for Pass 2 because Pass 1 held a major finding.

Observed in the baseline hand runs, not graded: one rep sampled two of the
four rows and missed the contradicted one, since the text asks for a sample
of two or three rows without saying how to draw it.

## Not tested

The trigger, as in every hand run: the prompt names "the review skill".
