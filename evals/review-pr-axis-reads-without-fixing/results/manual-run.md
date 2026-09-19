# Manual runs

Historical scores: each table below is from the fixture as it stood when that
table was taken. `evals/fixtures/ticket-gateway.sh` has changed since the
first of them, in f0373c9, a2797d0, b88af3c, 2b592bf and 5b6249c; a table is a
baseline for the current fixture only where none of those commits is later
than it. The last of them removed the untracked `.githooks/` the default
variant carried, which every table below was taken with: no grader's evidence
moved - the audit files keep their paths and contents - but the tree the runs
read had a directory in it that the tree they would read now does not.

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

## The inline path

review-pr reviews a diff this small itself and dispatches no axis agent, so
a rule that lives in the agent's contract alone never reaches it. Five fresh
headless sessions per arm with an ordinary review prompt ("review this branch
against main", not the deep form the committed prompt asks for); no session
dispatched an agent. The baseline arm is review-pr without the
compliance-first rule in its grading rules; the treatment arm has it. That
prompt was kept nowhere; `review-pr-grades-the-files-drift-inline` now holds
the ordinary form on the same fixture with the two graders below, so the
inline rule has a case a runner can repeat, and this case keeps the deep
form for the dispatched path.

| | Baseline | Treatment |
|---|---|---|
| drift-graded-as-the-repos | 0/5 | 5/5 |
| of those, filed once at the file, addressed to the repo | | 4/5 |
| read-worktree-unmodified (no `fix` line in the lint log) | 3/5 | 4/5 |

Every baseline review filed the missing doc block on the new export as the
change's defect, one of them as a medium, and one confirmed in its own Pass 2
that the neighbours lack it too and kept the finding. Four treatment reviews
filed the file's drift once at the file; the fifth filed nothing and said why
in its verification section, which the grader allows and the rule does not
ask for.

The lint log shows what a judge over the reply never could: on the inline
path three reviews in ten ran the fixing form of the linter in the tree, in
both arms alike, and one baseline run's log was gone at the end. Whether
the hand count took that run as clean was not written down; the runner does
not, since a grader whose target file is gone throws and is scored a fail.
The
non-fixing-form rule is stated for the conventions axis and does not bind an
inline review as it stands; `BACKLOG.md` carries the entry.

## The committed prompt through the runner

One run of `claude plugin eval` on this case, three runs per arm, the
runner's own arms and its default judge, on the deep-review prompt as
committed:

| Grader | No plugin | Plugin |
|---|---|---|
| findings-file-written | 0/3 | 3/3 |
| drift-graded-as-the-repos | 0/3 | 3/3 |
| platform-header-seen | 0/3 | 2/3 |
| read-worktree-unmodified | 3/3 | 3/3 |

Every plugin review graded the doc block as the file's drift and left the
lint log without a `fix` line; two of three found the vendored header. The
no-plugin arm wrote no findings file under the name the two file graders
read, so their 0/3 there is six thrown graders, not a reading of what an
unaided review does with the doc block or the header. The inline form of
the same prompt has its own case and record
(`review-pr-grades-the-files-drift-inline`), where two plugin runs of
three ended with the lint log gone.

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

## Report delivery: the file the dispatch names

The dispatch named the report file — what `delegating-to-subagents`' delivery
instruction now asks an orchestrator to do — and said nothing about the reply's
form, which is what the contract owns; that split is the test. Five fresh
headless sessions per arm started as the agent (`claude -p --agent`, Sonnet),
one fixture per session, the conventions axis named in the brief. The baseline
arm ran while the contract still ended "Deliver the complete report as your
final message"; the treatment arm carries the delivery paragraph that names the
file and defines the reply.

| Grader | Baseline | Treatment |
|---|---|---|
| the reply is the path and nothing else | 0/5 | 5/5 |
| the file holds the complete report | 5/5 | 5/5 |
| drift-graded-as-the-repos | 5/5 | 5/5 |
| read-worktree-unmodified (no `fix` line in the lint log) | 2/5 | 5/5 |

Every baseline rep wrote the file the brief named and then pasted a summary or
the findings themselves into the reply as well — 1,156 to 1,599 characters of
it, which is the report a transport cuts. Every treatment reply was the path
and nothing else, 173 characters. Both arms filed the doc-block gap as the
file's own drift, so the grader this case is named for did not move.

The lint-log row is not a result of the rule. Two baseline reps ran the fixing
form of the gate in the read tree and reverted it, and a third deleted the log
that records the mode of every run, straight after running the fixer, leaving
that grader no file — which is scored a fail. The transcript's own Bash calls
are what show this; the tree and the log at the end cannot.

Not tested: a dispatch that names no file (the contract's fallback path), the
same sentence in `refute-verifier` and `mutation-tester`, and the full review
path where the skill dispatches the agent rather than a hand-written brief.

Two mechanics for the next hand run here. A headless rep inherits the machine's
configured output style, and an explanatory one wraps every reply in a block
that makes "the reply is the path alone" ungradable, so each rep passes
`--settings '{"outputStyle":"default"}'`. And the agent has no Write tool: all
ten reps wrote the report with a shell heredoc, so the file handoff needs no
tool grant.

## The prompt names the findings file, and the retake that followed

The prompt asked for "the findings file the review skill writes", which left the
file's name to the run and answers to the harness's own built-in review skill
besides. Both focus graders therefore threw wherever a run named its file
anything else: three of six plugin runs and six of six unaided runs across the
release baseline and its rerun, each scored a fail. Half this case's plugin arm
was unmeasurable rather than failing, and its unaided arm entirely so. The
prompt now names `review-findings-feat-close-ticket.md`, the branch's own name,
which both focus graders already read, and `findings-file-written` pins that
path instead of a glob.

One runner pass at the head, three runs per arm, `--judge-model sonnet`, $7.33:

| Grader | No plugin | Plugin | Same rows in the 1.9.0 rerun |
|---|---|---|---|
| drift-graded-as-the-repos | 0/3 | 3/3 | 0/3 (three throws) / 3/3 |
| platform-header-seen | 3/3 | 3/3 | 0/3 (three throws) / 2/3 |
| findings-file-written | 3/3 | 3/3 | 0/3 / 3/3 |
| read-worktree-unmodified | 3/3 | 3/3 | 3/3 / 3/3 |
| skill-was-invoked | — | 3/3 (indicator) | 3/3 |

No grader threw in either arm. The drift row is the one this case is named for,
and it separates cleanly: three unaided reviews filed the missing doc block on
the new export as this change's defect, three plugin reviews graded it as the
file's own drift.

**The platform row does not separate at all now that the unaided arm can be
read.** Three of three unaided reviews found that the vendored platform already
sets `cache-control: no-store` and called the handler's line redundant — which
is what the five-rep hand baseline in this file found, and why the sentence
about absence claims reaching beneath the framework was declined rather than
landed. Its 0/3 in the release baseline was three thrown graders and said
nothing. A row that scores as well without the plugin as with it is the
retirement signal the plan's rule-retirement task is about; this one has never
had a rule behind it to retire, so what it is now is a regression guard on a
behaviour the model has unaided.
