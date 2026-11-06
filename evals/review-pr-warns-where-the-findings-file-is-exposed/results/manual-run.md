# Manual runs

Historical scores: every table below was taken before 5b6249c, which stopped
the fixture's own audit hooks from standing untracked inside `.githooks/`.
Until then the pre-commit hook stashed them away with the run's findings file,
so after the author's aborted commit the hooks were gone and the tree held two
untracked files that were not the run's. Nothing these tables grade reads
those hooks, but the tree the runs saw is not the tree a run sees now.

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

## Through the runner

One run of `claude plugin eval` on this case, three runs per arm, the
runner's own arms (no plugin, the plugin) and its default judge, on the
fixture with the stash hook seeded and the lint red. It was run from a
worktree checked out at the released tag the rest of the baseline was taken
at, not at the branch head, which by then carried two hooks that did not
exist when the other cases ran.

| Grader | No plugin | Plugin |
|---|---|---|
| findings-file-written | 0/3 | 3/3 |
| exposure-named-beside-the-path | 0/3 | 3/3 |

Every plugin run wrote the findings file and named the exposure beside its
path; the judge was unanimous in all six verdicts. No no-plugin run wrote a
file at all, so its arm fails the exposure grader for want of the artifact as
much as for want of the warning: the prompt asks for the findings in a file
and for the path in the reply, and an unaided review answers in chat.

This is the two-arm form of the hand table above, where both arms wrote the
file because both were told to follow the skill and only the exposure
sentence differed. The hand table is what says the sentence earns its place;
this one says the behaviour is absent without the plugin.

## The prompt names the findings file, and the retake that followed

The prompt asked for "the findings file the review skill writes", which left the
name to the run and reaches the harness's own built-in review skill besides. It
now names `review-findings-feat-close-ticket.md`, and `findings-file-written`
pins that path instead of a glob. `exposure-named-beside-the-path` keeps no
`focus` on purpose: what it grades is the final message, which is where the
warning has to reach the author, and the findings file cannot hold it.

One runner pass at the head that carries the edit, three runs per arm,
`--judge-model sonnet`, $3.67:

| Grader | No plugin | Plugin | Same rows before the edit |
|---|---|---|---|
| exposure-named-beside-the-path | 0/3 | 2/3 | 0/3 / 3/3 |
| findings-file-written | 3/3 | 3/3 | 0/3 / 3/3 |
| skill-was-invoked | — | 3/3 (indicator) | not present |

The file row moving to 3/3 in both arms is the edit working, not a loss: the
unaided arm used to fail it by naming its file something else, and where that
row sits in the sibling cases it took every file-reading grader down with it.
Here it is a precondition — findings on disk rather than in chat — and the case's
own behaviour is the exposure row, which still separates the arms.

The plugin-arm miss is a real one. That run wrote a long and accurate paragraph
about the hook and then undid it: "this checkout currently has it disabled …
so it's usually safe, but a lint failure between the stash and pop would leave
it sitting in the stash". The rubric fails a message that calls the file safe
from the hook, and it asks for an action the author can take, which that message
never gives. The claim is also wrong: built from the fixture, this variant sets
`core.hooksPath` to `.githooks` and tracks that directory, so the hook resolves
both in the checkout and in a linked read worktree — checked by hand after the
run, because a review that mis-reads the setup and hedges is a different failure
from one that never looked.

## As a neighbour of the findings-storage round (69a), five reps an arm

Model `claude-sonnet-5-5` in every rep's `init` event; CLI 2.1.289; both arms with the plugin and the state-folder grant (`--allow-tools ... 'Write(~/.local/state/**)' 'Edit(~/.local/state/**)'`), `--judge-model sonnet`; baseline = `main` at `4014fa1`, treated = branch `69a-storage` at `009d9d5` (the findings-storage wording). Compared across these two arms only. Kept as `evals/results/round-69a@baseline-warns.json` and `round-69a@storage-warns.json`. The case's turn cap was raised from 60 to 80 before the draw; reps used 9-14.

| Grader | Baseline | Treated |
|---|---|---|
| exposure-named-beside-the-path | 5/5 | 5/5 |
| findings-file-written | 5/5 | 5/5 |
| skill-was-invoked | 5/5 | 5/5 |

The treated wording keeps the exposure warning for a findings file inside the clone, and this prompt names a root path, so every treated rep wrote the file where the prompt said and named the stash hook beside it. The case stays a valid test of the narrowed warning.

## What a runner rep sees of the hook

No git hook runs in a runner rep: from CLI 2.1.312 every command a rep runs
carries `GIT_CONFIG_KEY_n` pairs that set `core.hooksPath` to `/dev/null` and
disable each hook by name (CONTRIBUTING, "Nor does a fixture's git hook run in
a rep"). This case's graders need no record of a hook run, unlike the drift
case's audit: they read the final message and whether the findings file
exists, and the hook only has to be there for the rep to read, which it is.

The same pairs answer a rep that asks. Built from this fixture and run under
the pairs copied from the kept probe traces, `git config core.hooksPath` prints
`/dev/null`; without them it prints `.githooks`. So a rep that checks whether
the hook is wired, as the plugin-arm miss in the retake above did when it
wrote "this checkout currently has it disabled", is told it is off. That
retake ran before any kept run recorded the sandbox's environment, so whether
the pairs reached it is unknown and its verdict stands as read; but on a CLI
that sets them, a miss of that shape is read from the trace first: a
`core.hooksPath` query answered `/dev/null` makes it the instrument's, not
the rep's misreading of the setup.
