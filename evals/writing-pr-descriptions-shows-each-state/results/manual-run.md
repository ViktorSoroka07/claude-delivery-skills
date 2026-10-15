# Manual runs

Not run. Built for the writing-pr-descriptions contract that adds a Before and
after table, one item per behaviour, no hard-wrapped body and a Rollback line
only on a one-way door, on `export-cli.sh list-output`. The builder's other variants
(default, post-rename and consumers) build the same tree from the builder before and after the variant
was added, compared by `git rev-parse HEAD^{tree}`.

A blind verifier read the case before any draw; its report is kept with the
round's notes, and its case-level findings are applied below. Every grader
that reads `PR.md` names it as `focus` or `target` `{source: file, path:
"PR.md"}`, a bare path being refused at load; a load-only launch checked it,
a copy of the case carrying one grader of `weight: -1` being refused for the
weight alone, and the same copy at the bare paths for six targets as well.
