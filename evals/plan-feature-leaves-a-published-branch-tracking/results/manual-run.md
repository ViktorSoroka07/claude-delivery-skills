# Manual runs

Fixtures from `evals/fixtures/refund-console.sh plan-drafted-published`, five
fresh headless Sonnet sessions per arm, the eval prompt verbatim, graded on
the reply and on `git branch -vv` in the tree each run left. The baseline arm
is Step 5's hand-over check as "check the branch has no upstream"; the
treatment arm is "check the branch does not track the default branch", with
the own-name upstream named as safe and the remedy for the unsafe one.

| Grader | Baseline | Treatment |
|---|---|---|
| own-name-upstream-kept | 4/5 | 5/5 |
| healthy-upstream-not-reported-as-a-fault | 5/5 | 5/5 |
| plan-committed-on-the-branch | 4/5 | 5/5 |

The baseline does not fail. No run on the earlier text reported the published
branch's upstream as a fault or removed it: each read "tracks its own name,
not the default branch" as the safe state although the text said "no
upstream". The one baseline miss on the other two graders is a run that cut a
second branch for the new task, which the upstream wording does not reach.
The rewording therefore lands as a correction of the text, not on a measured
change in behaviour: the earlier paragraph said no flag suppresses the
tracking that `git branch <name> <remote-ref>` sets, and `--no-track` does;
it named no remedy for a branch found tracking the default, and
`--unset-upstream` is one. Both were checked in a scratch clone. The case
stays as the guard for the published state, which no other case builds.

## The graders and the wording since

The table's one baseline miss is a hand grade on the tree. The two regex
graders then read any line of the paste, and passed that run: the old
branch's line still showed its upstream, and the plan commit sat on a new
branch cut from the same tip. Both now anchor on the current-branch marker
of `git branch -vv`, and the second reads the plan as that branch standing
one commit ahead of its own remote. On captures of four runs (plan
committed; a second branch cut; the upstream unset; the plan left
uncommitted) the first reads pass, fail, fail, pass and the second pass,
fail, fail, fail.

The check's wording has since widened from "does not track the default
branch" to "tracks nothing but its own name": a push that follows the
upstream lands on whatever branch is tracked, a release branch as much as
the default. That is a second correction of the text, checked in a scratch
clone (`git checkout -b <name> origin/release` tracks `origin/release`), and
no run covers it.

## A first run the fixture spoiled

The variant's first version made its bare remote by cloning while the work
branch was checked out, so the remote's HEAD, and with it `origin/HEAD`,
named the work branch as the default. Three runs in each arm asked the remote
for its default, were told they stood on it, and correctly cut a new branch.
The fixture now points the remote's HEAD at `main` and sets `origin/HEAD` to
match; the table above is the run after that. A fixture's remote states a
default branch whether or not anyone chose one.

## Not tested

The unsafe state itself: a work branch found tracking the default branch,
where the remedy sentence would be exercised. The trigger: the prompt names
the plan-feature chain and its step.
