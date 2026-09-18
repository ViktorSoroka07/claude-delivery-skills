# Runs

The case holds the ordinary review prompt on the axis case's fixture, so the
compliance-first rule has a committed prompt on the inline path; the hand
result that landed the rule (0/5 → 5/5 on `drift-graded-as-the-repos`, with
a prompt no case kept) is in
`evals/review-pr-axis-reads-without-fixing/results/manual-run.md` under
"The inline path". No hand run has been made on this prompt as committed.

## Through the runner

One run of `claude plugin eval` on this case, three runs per arm, the
runner's own arms (no plugin, the plugin) and its default judge, on the
fixture with the lint log seeded.

| Grader | No plugin | Plugin |
|---|---|---|
| findings-file-written | 0/3 | 3/3 |
| drift-graded-as-the-repos | 0/3 | 3/3 |
| read-worktree-unmodified | 3/3 | 1/3 |

Every plugin review wrote the findings file and graded the missing doc block
as the file's own drift, none as the change's defect. The no-plugin arm's
0/3 on the drift grader is not a reading of the behaviour: no run there
wrote a file under the name the grader reads, so the grader threw on the
missing file three times and was scored a fail each time; what an unaided
review makes of the doc block is in the axis record's hand table (0/5).

The lint-log row runs the other way. Without the plugin every log was there
and held no `fix` line. With it, one run's log was clean and two runs' logs
were gone at the end, which the runner scores as a fail (a grader whose
target is missing throws). The runner keeps no transcript, so what removed
the log is not known from this run; the axis record notes one such run
before, and `BACKLOG.md` holds the entry for the inline path's gate rule,
which this grader is the test for.

## The inline path's gate rule: one wording, not landed

Five fresh headless Sonnet reps per arm, one fixture each, the tree and each
transcript's own Bash calls graded rather than the reply; arm membership confirmed
in every transcript. $5.83 for the round, $0.56 a rep.

| Grader | Baseline | With the wording |
|---|---|---|
| read-worktree-unmodified | 3/5 | 4/5 |
| findings-file-written | 5/5 | 5/5 |
| drift-graded-as-the-repos | 5/5 | 5/5 |

The wording tried, appended to section 3's inline/dispatch fork sentence, where the
inline path reads it:

> **Reviewing inline moves every axis's boundary onto you, the gate rule included:**
> run each of the repo's own gates in its non-fixing form, because a lint or format
> script that chains a fixer rewrites the tree you are reading, and the diff you
> report after it is the fixer's rather than the author's. Reverting the fixer
> afterwards does not repair that - it leaves a clean tree that shows nothing.

**Not landed: 3/5 to 4/5 is one rep, and two of the ten rows do not measure the rule.**
One treatment rep ran the fixing form and scored a pass because the invocation never
reached the script, so the log holds no `fix` line - the grader scores a failed
violation exactly as it scores compliance. One rep in each arm lost the `.lint-log`
entirely, which a `not_contains` grader scores as a fail without voting on behaviour.
Between them the graded row moves on two reps that the rule did not touch.

**What the round did establish is that the defect is wider than the row.** The rule
the entry names - the gate's non-fixing form - is one instance of the read-only
boundary, and the boundary as a whole does not bind the orchestrator: every treatment
rep, and three of five baseline reps, reached the base with `git stash -u`,
`git checkout main -- .` or `git reset --hard` inside the tree it was reading. The
`axis-reviewer` contract forbids exactly that and sends a dispatched agent to export
the base into a scratch directory instead. The wording's opening clause was meant to
carry that class and moved it not at all, so a shape that names the class is not
enough; the instances have to be where the inline path reads them, and nothing here
grades the git-write half.

A next shape is the owner's call. What this round rules out is the class-naming
sentence, and what it asks for first is a grader that can tell a failed violation
from compliance.
