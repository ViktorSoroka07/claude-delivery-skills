# Manual runs

`claude plugin eval` is still gated at run time, so the case was run by the
hand procedure in CONTRIBUTING's "Testing a wording change": five fixtures per
arm from `evals/fixtures/refund-console.sh plan-drafted`, verified identical by
hash, five fresh subagents per arm on sonnet, the contract pasted into the
brief in full, the eval prompt verbatim.

## Results

| Grader | baseline | treatment |
|---|---|---|
| no-second-branch | 2/5 | 5/5 |
| hand-off-names-the-branch | 5/5 | 5/5 |
| nothing-pushed | 5/5 | 5/5 |

Baseline is Step 5 as it stood: "Create the work's branch", unconditional.
Three runs in five created a fourth branch from the one the session was on
and committed the plan there; two used the branch they were on. Treatment
states the boundary inside the imperative — create only when on the default
branch; on a non-default branch, that branch is the work's branch — and every
run committed on the existing branch and said so in the hand-off.

## A first baseline that did not fail

The prompt's first draft told the agent the branch had been created before
the session started, and all five baseline runs used it. The hint handed over
the answer the rule exists to supply, so the prompt was rewritten to say
nothing about branches and the baseline re-run; the table above is that run.
A prompt that names the state the rule decides on is not a test of the rule.

## Not tested

The trigger, as in every hand run.
