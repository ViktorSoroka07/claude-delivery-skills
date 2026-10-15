# Manual runs

Not run. Built for the writing-pr-descriptions contract that adds a Before and
after table, one item per behaviour, no hard-wrapped body and a Rollback line
only on a one-way door, on `meter-ingest.sh format-change`.

A blind verifier read the case before any draw; its report is kept with the
round's notes, and its case-level findings are applied below. Every grader
that reads `PR.md` names it as `focus` or `target` `{source: file, path:
"PR.md"}`, a bare path being refused at load; a load-only launch checked it,
a copy of the case carrying one grader of `weight: -1` being refused for the
weight alone, and the same copy at the bare paths for six targets as well.

The variant fast-forwards `main` to `harden/ingest-guards` before branching,
as its merge would have: the branch first sat on that unmerged tip, so a
description written against `main` described the hardening too, nine files
where the change is three, and `main`'s export had no header to set the
`cents` column against. `main...feature/billing-amounts` is now the runbook
note, `src/export.py` and its test, and `main`'s header reads
`meter,units,tariff,cents`. The builder's other two variants, default and
record-table, build every branch to the same tree from the builder before
and after the change, compared by `git rev-parse <branch>^{tree}`.
