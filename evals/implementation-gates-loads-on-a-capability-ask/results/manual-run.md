# Runs

Both arms by `claude plugin eval` on CLI 2.1.289, five reps each, `--ablation
none`, `--model sonnet` (resolved to `claude-sonnet-5-5` in every rep's
`init` event), from a worktree of the commit named, the run JSONs kept as
`evals/results/round-73@baseline.json` and `round-73@what-clause.json`. The
trend fold excludes both as "judged by the default judge": the case has no
judged grader, so the run's judge field is unset and the fold cannot tell that
from an unsettled judge. Read the rates from the JSON itself.

## Round 73: does a what-clause reach a capability-phrased ask

| Grader | baseline (`31ece6f`, the description as landed) | what-clause (`449f902`, branch deleted) | nouns of the ask (`cf1a589`, branch deleted) |
|---|---|---|---|
| skill-was-invoked | 0/5 | 0/5 | 5/5 |

The wording under test opened the description with one sentence of what the
skill does before its "Use when" clause, verbatim (the branch SHA above is a
pointer only; the branch is spent):

> Proves that a suite which passes would also catch the defect the change could carry, settles a plan's claims about outside systems against evidence, and holds a written verification record to what actually ran.

It moved nothing, and is declined for this skill on this ask.

The instrument is read from the traces, not assumed: every rep in both arms
carried the plugin's eighteen skills in its `init` event, saw the brief, and
made the Skill tool its first call, loading `tracking-open-asks` (15/15 and
15/15 across the three cases of the round). The treated text reached the reps:
the session transcript under a treated rep's `config/projects/` carries the
new sentence and a baseline rep's does not.

Every rep in both arms did the capability unaided: ran the suite, read the
branch, and reported what blocks the merge, three of ten naming the weak test
the skill's Gate 1 exists to find; none loaded any skill but the first-call one.

### The second wording: the nouns of the ask

The owner bought a second wording on the lead above. It rewrote the "Use when"
clause to name the nouns a capability-phrased ask carries, verbatim:

> Use when a change is about to be merged, called done or complete, or handed over on a green suite - a branch ready for its target, passing tests, a written record of what was verified, the question of what is left before a merge - after the repo's own gates have passed; and while writing a plan or spec, to settle its claims about outside systems (APIs, data, libraries) against evidence before they become design decisions.

Every rep loaded the skill with its second call, before touching the repo, then ran the suite and reported against Gate 1. Instrument as before: eighteen plugin skills in every `init`,
`tracking-open-asks` loaded first in every rep, the new clause present in a
treated rep's session transcript (`round-73@nouns.json`).

This wording moved the indicator from 0/5 to 5/5 and is the candidate to
land. It has not landed: the skill's named-trigger cases are its neighbours and
have not been run under it on this model, and CLAUDE.md declines a wording
that costs one.

## Not tested

The neighbours above, and whether the same clause shape reaches the other
thirteen named-task skills, whose descriptions this round did not touch.
