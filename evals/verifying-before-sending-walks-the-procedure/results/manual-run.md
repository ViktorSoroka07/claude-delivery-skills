# Manual runs

`claude plugin eval` is still gated at run time, so the case was run by the
hand procedure in CONTRIBUTING's "Testing a wording change": five fixtures
from `evals/fixtures/refund-runbook.sh`, verified identical by hash, five
fresh subagents on sonnet, the contract pasted into the brief in full, the
eval prompt verbatim.

## Results

| Grader | before the executability sentence |
|---|---|
| names-the-unrunnable-case | 5/5 |

The run was made against the skill as it stood before it said anything about
procedures: its completeness sentence asked whether the recipient can act on
the text without the author present, and nothing named a procedure walk. Every
run still found the dead end. Each listed the runbook's claims against their
sources, ran the two commands against the sample queue, and reported the
cancelled entry as the state with no instruction and the completion condition
as unreachable while it is present; every verdict was "not safe to send as
written". Three runs also reported the unknown-id exit, which the grader
allows alongside.

So the baseline did not fail, and the sentence the review asked for was added
as a statement of what the completeness check already meant for a procedure —
walk each step through every state the text names and every outcome its
commands can produce — not as a behaviour change. No treatment arm was run:
the edit changes no behaviour the baseline measured, and the record above is
the evidence that the check binds without it.

## Not tested

The trigger, as in every hand run: the contract was pasted, not discovered.

## Neighbour check for task 73's noun wording

Task 73 rewrote `verifying-before-sending`'s description to name the nouns a capability-phrased ask carries; the clause is quoted verbatim in `verifying-before-sending-loads-on-a-capability-ask`'s record, and it landed at `532c7fe`. A description moves the trigger for every case of its skill, so this case ran as a neighbour, with the bar fixed before the draw: a grader down by the floor's gap, four reps in five, declines the wording for this skill alone.

Five reps an arm on `claude-sonnet-5-5` (CLI 2.1.289), `--ablation none`, `--judge-model sonnet`, `--keep-temp`. Base at `31ece6f`, the descriptions as they stood; treated at `31ece6f` with `cf1a589`'s three description lines applied uncommitted, so the arms differ in those lines alone (the branch `73-nouns` that holds `cf1a589` sits on a base the history rewrite replaced). Both arms ran in one batch, eleven minutes apart. Every rep's `init` carries the eighteen plugin skills and every rep loaded `tracking-open-asks` first (40/40 across the four cases). Turns: base [10, 12, 6, 12, 7], treated [10, 12, 12, 9, 13]; no rep was curtailed.

| Grader | Type | Base | Nouns |
|---|---|---|---|
| `names-the-unrunnable-case` | judge | 5/5 | 5/5 |
| `skill-was-invoked` | mechanical | 2/5 | 5/5 |

The indicator moved from 2/5 to 5/5: under the noun wording every rep loaded the skill after `tracking-open-asks`, against two of five on the base text.

Judged rows, hand-graded in both arms from the run JSONs' `evidence`:
- `names-the-unrunnable-case`: the judge passed every rep in both arms, and every reply in both names the cancelled-entry dead end as the runbook's problem, which is what the rubric asks for.

No grader moved by more than one rep, by the judge or by hand, so the wording does not cost this case and landed for `verifying-before-sending`. Run JSONs: `evals/results/round-73n@base-vbs.json` and `round-73n@nouns-vbs.json`; traces in `evals/results/round73n-traces/`.
