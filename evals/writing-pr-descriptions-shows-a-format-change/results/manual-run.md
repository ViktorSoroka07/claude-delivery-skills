# Manual runs

Not run. Built for the writing-pr-descriptions contract that adds a Before and
after table, one item per behaviour, no hard-wrapped body and a Rollback line
only on a one-way door, on `meter-ingest.sh format-change`. The builder's other variants
(default and record-table) build the same tree from the builder before and after the variant
was added, compared by `git rev-parse HEAD^{tree}`.

A blind verifier read the case before any draw; its report is kept with the
round's notes. Two of its findings stop a launch: every grader that reads
`PR.md` names it as a bare path, which the runner refuses at load - the form is
`focus` or `target` `{source: file, path: "PR.md"}` - and the hard-wrap pattern
does not read a wrapped list item. The rest are listed there, with the
strongest-model arms a restraint row needs.

The variant's branch sits on `harden/ingest-guards`, which is not merged into
`main`, so a description written against `main` describes the hardening too;
the fix fast-forwards `main` to that tip inside the variant, where the other
variants' trees stay as they are.
