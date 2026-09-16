# Manual runs

The axis-reviewer agent was dispatched directly, five fresh Sonnet agents
per arm, one fixture per agent built by `evals/fixtures/ticket-gateway.sh`,
each briefed with one axis, the checkout as its read worktree, and the
diff range; review-pr itself dispatches these agents only above its inline
threshold, which the fixture's diff does not reach. Graded on the agent's
report and on the tree it left.

## Conventions axis (repo-conventions-and-gates)

| Grader | Baseline (contract before) | First wording | Restated wording |
|---|---|---|---|
| drift-graded-as-the-repos | 0/5 | 0/5 | 5/5 |
| read-worktree-unmodified | 4/5 | 5/5 | 5/5 |

Baseline reps filed the missing doc block on the new export as this change's
defect in every rep, one of them while noting the neighbours lack it too.
The first wording ("a written convention is measured against the
surrounding file before it is cited") changed nothing: every rep read it and
argued the new code had a clean chance to comply. The restated wording names
the output — a finding that cites a convention states the file's compliance
first — and adds the case to the never-raise list; with it every rep graded
the gap as the file's own drift, three filing it once at the file as a minor
with a file-level suggestion and two filing nothing.

On the lint gate, one baseline rep ran the fixer in the read tree and
reverted it with a checkout; every other rep in every arm used the
non-fixing form or a scratch copy. One first-wording rep ran git write
commands in the read tree to compare against main and restored it. Trees
were clean at the end of every rep.

## Correctness axis

| Grader | Baseline |
|---|---|
| platform-header-seen | 5/5 |

Every baseline rep found that the vendored platform already sets the header
the change adds, called the handler's header redundant and the test's
assertion satisfied without it, and contradicted the commit message's claim.
The queued sentence about absence claims reaching beneath the framework was
declined; `BACKLOG.md` carries the line. One baseline rep edited the read
tree to re-run the tests without the header and restored it.

## Not tested

The full review path (review-pr dispatching the agent) and the trigger: the
agent was dispatched by hand with its axis named.
