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

## The graders, settled before the first draw

- `before-and-after-table` takes the common spellings of an earlier and a
  later column (Before/After, Old/New, Was/Now, any case), since only the
  treated wording supplies the words Before and After; a rep with no table
  fails it and `one-row-per-state` for one cause, read as one bit.
- `one-row-per-state` is a judge where the plan had a `count:2` regex: a row
  per state is a reading of what each row says, which a row count cannot make.
- `headline-state-first` reads a lead summary and prose as well as the table
  and the list.
- `what-changes-is-a-list` leaves a lead summary out of what it reads and
  counts a list with no heading. The skill already asks for an item per
  change, so its baseline is expected to pass; it is read as a guard.
- `no-hard-wrap` reads a wrapped list item at any depth and its continuation,
  indented or not. Two consecutive lines of code in a fenced block can match
  it too, so a fail is settled by the same pattern with the fenced blocks
  removed.
- `no-rollback-line` takes any case, so "No rollback concerns" fails it as the
  same line in the negative.
- `no-image-committed` cannot fail here: the change has no screen, and the
  prompt forbids a commit. It is kept and not counted; the entry on
  screenshots never committed is untested by this case.
- The prompt says the body will be pasted into the pull request form, since
  the treated rule binds a body the forge renders and a prompt saying there
  was no forge let a rep read itself out of it.

Six hand-written bodies, labelled before any verdict, cover the treated
ideal, the baseline shape (bullets wrapped as the commit bodies are, the side
change first, no table), lowercase Old/New headers with both list states in
one row, prose with the side change first, a summary above a heading-less
numbered list wrapped with no indent, and nested bullets beside a fenced
block of shell commands. The settled judge agreed with all eighteen labels of
the three rubrics, every vote unanimous, and each regex grader matched its
labels but one: `no-hard-wrap` fails the fenced commands, which the
fence-free reading passes.

The neighbour the plan priced, the loads-on-a-capability-ask case, reads only
whether the skill loads, which a change to its body cannot move; the case's
own indicator reads the load, so that spend is dropped. `no-rollback-line` is
the restraint half of the Rollback rule and is read on the strongest model as
well, in both arms of this case.
