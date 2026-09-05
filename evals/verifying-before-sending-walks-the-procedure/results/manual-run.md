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
