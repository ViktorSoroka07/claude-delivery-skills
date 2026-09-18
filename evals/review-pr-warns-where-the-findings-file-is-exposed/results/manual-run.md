# Manual runs

Fixtures from `evals/fixtures/ticket-gateway.sh stash-hook`, five fresh
headless Sonnet sessions per arm with the case's prompt, an ordinary review
that runs inline. Graded on the reply beside the findings file's path. The
baseline arm is review-pr's exposure sentence as it stood ("a pre-commit hook
that stashes and restores the tree can delete it"); the treatment arm states
the mechanism and the verdict: the restore is the step that gets skipped, and
a hook that stashes is never reported as safe because it also restores.

| Reply, beside the path | Baseline | Treatment |
|---|---|---|
| says the file is exposed to the hook | 2/5 | 5/5 |
| calls the file safe from the hook | 2/5 | 0/5 |
| tells the author what to do about it | 2/5 | 3/5 |
| findings-file-written | 5/5 | 5/5 |

Every session in both arms found and read the hook: the check itself is not
what fails. Two baseline sessions read "stash, lint, pop" and reported the
file safe; one pointed at a note inside the findings file. The treatment
sessions all followed the failure path, and four named the red lint on the
branch as the reason the next commit will abort with the file in the stash.
The action clause is the weaker half: two treatment replies state the
exposure and stop.

## A first fixture the rule could not fail on

The variant's first hook always popped the stash, so "safe" was the correct
answer, and all ten sessions gave it, five on each text. The hook now pops
only when the lint passes, which is what the hooks the rule was written from
do, and the lint is red on the branch. A fixture has to make the wrong answer
wrong before a wording can be seen to matter.

The same first round also settled a finding against the sentence's
parenthetical ("the repo-conventions axis has read them"): every baseline
session on the inline path read the hook directory with no axis dispatched,
so the parenthetical was left alone.

## Not tested

A formatting gate that blocks the push on the untracked file; a hook whose
pop conflicts. The trigger: the prompt names the review.
