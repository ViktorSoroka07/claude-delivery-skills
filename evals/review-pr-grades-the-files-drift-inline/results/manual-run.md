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
