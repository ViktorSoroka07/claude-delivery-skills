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

## Conventions axis, second round

The contract said of the file's own drift both "reported once at the file"
and, in the never-raise list, never raise; the first round's reps split three
to two on it. The never-raise entry is gone, the rule now says to file it
once as a minor addressed to the repo, and a file the change creates is
graded against the convention as written. Run as fresh headless sessions
started as the agent (`claude -p --agent`), five per wording, since a
dispatched subagent gets the contract its parent session loaded at start.

| | Drift filed once at the file | Git write commands in the read tree |
|---|---|---|
| First round's text (its record above) | 3/5 | 1/5 seen |
| Contradiction removed | 4/5 | 4/5 |
| The same, plus a clause that notes are not findings | 4/5 | 5/5 |
| Clause dropped; boundary names the scratch export | 5/5 | 0/5 |

The clause moved nothing and was dropped. The second column was not what the
round set out to measure: nine sessions in ten stashed the tree and checked
the base branch out over it, then restored it, to learn whether the red lint
gate was already red on the base. The boundary forbade the write and offered
no other way to answer a question the axis has to ask. It now names one,
exporting the base into a scratch directory and running the gate there; with
it no session wrote to the tree and four of five used the export. Trees were
clean at the end of every run in every row, which is why a grader that reads
only the final tree never saw this.

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
