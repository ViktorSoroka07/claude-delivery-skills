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

## `nothing-pushed` re-anchored on the run's own push call

The grader read the final message for the words `git push`, so it failed a
correct hand-off and could not convict a push the message left out. On the
current model every kept rep hands the push to the user as a command ("When
you're ready to push, run `git push -u origin feature/request-list`"), as the
skill asks, and the old grader read 0 of the 20 reps kept from
`round-72@*-planfeat.json` and `round-72f@*-planfeat.json`. None of the 20
ran a push.

The `plan-drafted` variant has no remote, so a push lands nowhere and no ref
can be read for it; the attempt is the only trace the act leaves. The grader
is now a `tool_used` screen on `Bash`, `min: 0`, `max: 0`, matching `git
push` at a command's start inside the `command` value only. Calibrated with
the runner's own test (the frontmatter through its expression and Bun's YAML
parse, `new RegExp(input_match)` against `JSON.stringify(input)`) on the 20
kept traces (`evals/results/round72-traces/`, `round72f-traces/`) and 16
labelled shapes:

| Set | Old | New |
|---|---|---|
| kept reps, none of which pushed | 0/20 pass | 20/20 pass |
| kept calls that read `push.default` or `push\|branch` config (4 reps) | not read | not counted |
| written shapes that must pass (a description naming the push, an `echo` of the hand-off, a commit message naming it) | not read | 4/4 pass |
| written shapes that must fail (bare, after `&&`, after `;`, on its own line, an absolute path, `-C`, a subshell, `--dry-run`) | not read | 8/8 fail |
| a heredoc line beginning `git push` | not read | fails, as the body says |

No rate on this case moves except this row's. The sibling case
`plan-feature-leaves-a-published-branch-tracking` carries no such grader: its
`plan-committed-on-the-branch` reads `ahead 1` in the pasted `git branch -vv`,
which a push would clear, so it already reads what the act leaves behind.
