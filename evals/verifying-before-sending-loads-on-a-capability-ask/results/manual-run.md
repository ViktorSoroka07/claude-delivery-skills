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
| skill-was-invoked | 0/5 | 0/5 | 4/5 |

The wording under test opened the description with one sentence of what the
skill does before its "Use when" clause, verbatim (the branch SHA above is a
pointer only; the branch is spent):

> Checks every factual claim in outbound prose against its source before the person who will act on it reads it, through a fact table, a blind pass by a fresh reader and a delta check.

It moved nothing, and is declined for this skill on this ask.

The instrument is read from the traces, not assumed: every rep in both arms
carried the plugin's eighteen skills in its `init` event, saw the brief, and
made the Skill tool its first call, loading `tracking-open-asks` (15/15 and
15/15 across the three cases of the round). The treated text reached the reps:
the session transcript under a treated rep's `config/projects/` carries the
new sentence and a baseline rep's does not.

Every rep in both arms read the runbook and its scripts and found the dead end
the fixture plants (the cancelled entry no step handles); none loaded any skill
but the first-call one. Treated reps ran the scripts more and read less
(six turns against ten), which the indicator does not read.

### The second wording: the nouns of the ask

The owner bought a second wording on the lead above. It rewrote the "Use when"
clause to name the nouns a capability-phrased ask carries, verbatim:

> Use when a runbook, hand-off, message, comment, instruction or spec that someone else will act on is about to reach them or already waits for them - the on-call engineer who works from a document tonight, a teammate who acts on a message, a reviewer reading a comment on their PR or work item, another engineer building against instructions, a future session obeying skill or agent text, another team reading a spec or wiki - and the question is whether anything in it is wrong or would trip its reader; and earlier, before drafting such text at all.

Four reps loaded the skill with their second call; the fifth read the runbook and ran the scripts unaided, as every baseline rep did. Instrument as before: eighteen plugin skills in every `init`,
`tracking-open-asks` loaded first in every rep, the new clause present in a
treated rep's session transcript (`round-73@nouns.json`).

This wording moved the indicator from 0/5 to 4/5 and is the candidate to
land. It landed at `532c7fe` (riding the unreleased 1.11.0),
after the skill's named-trigger case `verifying-before-sending-walks-the-procedure`
ran under it as a neighbour on this model: its behaviour grader held 5/5 in
both arms and its own indicator rose from 2/5 to 5/5; its record carries the
table.

## Not tested

Whether the same clause shape reaches the other thirteen named-task skills,
whose descriptions this round did not touch.
