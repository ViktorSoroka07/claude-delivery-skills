# Runs

Both arms by `claude plugin eval` on CLI 2.1.289, five reps each, `--ablation
none`, `--model sonnet` (resolved to `claude-sonnet-5-5` in every rep's
`init` event), from a worktree of the commit named, the run JSONs kept as
`evals/results/round-73@baseline.json` and `round-73@what-clause.json`. The
trend fold excludes both as "judged by the default judge": the case has no
judged grader, so the run's judge field is unset and the fold cannot tell that
from an unsettled judge. Read the rates from the JSON itself.

## Round 73: does a what-clause reach a capability-phrased ask

| Grader | baseline (`c6dfe09`, the description as landed) | what-clause (`449f902`, branch deleted) | nouns of the ask (`cf1a589`, branch deleted) |
|---|---|---|---|
| skill-was-invoked | 0/5 | 0/5 | 5/5 |

The wording under test opened the description with one sentence of what the
skill does before its "Use when" clause, verbatim (the branch SHA above is a
pointer only; the branch is spent):

> Writes and keeps current a pull request's title and description as the net change a reviewer or later reader needs, never the branch's history, and the author's reviewer-facing summary comment.

It moved nothing, and is declined for this skill on this ask.

The instrument is read from the traces, not assumed: every rep in both arms
carried the plugin's eighteen skills in its `init` event, saw the brief, and
made the Skill tool its first call, loading `tracking-open-asks` (15/15 and
15/15 across the three cases of the round). The treated text reached the reps:
the session transcript under a treated rep's `config/projects/` carries the
new sentence and a baseline rep's does not.

Three baseline reps and four treated reps loaded `writing-for-audiences`
instead, whose description names what the ask produces ("a report ... an
explanation" a person will read) rather than the task that produces it. That is
a capability match on a neighbour's description, caught in the act, and the
one lead the round leaves.

### The second wording: the nouns of the ask

The owner bought a second wording on the lead above. It rewrote the "Use when"
clause to name the nouns a capability-phrased ask carries, verbatim:

> Use when a branch is ready for the team and reviewers need to know what to read first - a pull request, its title and description, review notes or a reviewer-facing summary for a branch - when creating a pull request, writing or editing a PR title or description, when commits have landed on a branch whose PR description may no longer match - including "sync the PR description" and "update the PR body" asks - and when maintaining a living status comment on a PR or issue. GitHub and Azure DevOps.

Four reps of the batch loaded the skill with their second call and none loaded `writing-for-audiences`; the batch's fifth rep was curtailed at its scaffold (the worktree was being removed under it, so `stage-git.sh` was gone) and is unmeasured, replaced by a one-rep re-take from a fresh worktree at the same commit (`round-73@nouns-retake.json`), which loaded the skill too. Instrument as before: eighteen plugin skills in every `init`,
`tracking-open-asks` loaded first in every rep, the new clause present in a
treated rep's session transcript (`round-73@nouns.json`).

This wording moved the indicator from 0/5 to 5/5 and is the candidate to
land. It has not landed: the skill's named-trigger cases are its neighbours and
have not been run under it on this model, and CLAUDE.md declines a wording
that costs one.

## Not tested

The neighbours above, and whether the same clause shape reaches the other
thirteen named-task skills, whose descriptions this round did not touch.
