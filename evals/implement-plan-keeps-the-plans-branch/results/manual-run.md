# Manual runs

`claude plugin eval` is still gated at run time, so the case was run by the
hand procedure in CONTRIBUTING's "Testing a wording change": five fixtures per
arm from `evals/fixtures/refund-console.sh plan-on-branch`, verified identical
by hash, five fresh subagents per arm on sonnet, the contract pasted into the
brief in full, the eval prompt verbatim; the execution skills the contract
names were loaded through the Skill tool from the installed superpowers set.

## Results

| Grader | baseline | treatment |
|---|---|---|
| worktree-holds-the-existing-branch | 0/5 | 4/4 |
| names-the-plans-branch | 0/5 | 4/4 |

Baseline is Step 3 without a word about the branch: every run reached the
worktree skill's git fallback and ran `git worktree add <path> -b <new>`,
five different new names, each reported as the branch the implementation
would commit on. Treatment adds that the work's branch already exists and
that a worktree checks it out rather than creating one.

Four treatment runs completed; the fifth was killed by the account's usage
limit after its worktree was created, and its repository shows the same
end state as the other four — three branches, the worktree on the plan's
branch — with no report to grade. The column is four of four completed, not
five.

## What every completed run did on the way

The fixture leaves the main checkout on the plan's branch, and git checks a
branch out in one worktree at a time, so the first `git worktree add` was
refused in every run. All four moved the main checkout to the default branch
and retried; none forced it and none fell back to a new branch. The rule now
states that step, since it is the shape every run converged on.

## Not tested

A fifth completed treatment run. The trigger, as in every hand run.
