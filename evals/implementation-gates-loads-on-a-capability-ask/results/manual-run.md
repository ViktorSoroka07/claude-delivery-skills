# Runs

Both arms by `claude plugin eval` on CLI 2.1.289, five reps each, `--ablation
none`, `--model sonnet` (resolved to `claude-sonnet-5-5` in every rep's
`init` event), from a worktree of the commit named, the run JSONs kept as
`evals/results/round-73@baseline.json` and `round-73@what-clause.json`.

## Round 73: does a what-clause reach a capability-phrased ask

| Grader | baseline (`c6dfe09`, the description as landed) | what-clause (`449f902` on `73-what-clause`) |
|---|---|---|
| skill-was-invoked | 0/5 | 0/5 |

The wording under test opened the description with one sentence of what the
skill does before its "Use when" clause. It moved nothing, and is declined for
this skill on this ask.

The instrument is read from the traces, not assumed: every rep in both arms
carried the plugin's eighteen skills in its `init` event, saw the brief, and
made the Skill tool its first call, loading `tracking-open-asks` (15/15 and
15/15 across the three cases of the round). The treated text reached the reps:
the session transcript under a treated rep's `config/projects/` carries the
new sentence and a baseline rep's does not.

Every rep in both arms did the capability unaided: ran the suite, read the
branch, and reported what blocks the merge, three of ten naming the weak test
the skill's Gate 1 exists to find; none loaded any skill but the first-call one.

## Not tested

Whether a description that names the ask's own nouns - the artefact asked for,
the outcome wanted - reaches it, which the writing-for-audiences loads in the
round suggest is what the model matches on. One wording was bought; a second is
the owner's call.
