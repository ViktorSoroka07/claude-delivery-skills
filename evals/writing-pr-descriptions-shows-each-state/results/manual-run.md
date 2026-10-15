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

## The Sonnet round

Two arms of five on Sonnet with the settled judge, from worktrees of one
commit: the baseline at `6777548`, where the graders above were settled, and
the treated arm on that commit plus the drafted contract (item 2 one bullet
per behaviour, a new item 3 Before and after, the Rollback sentence in Not
changed, the no-hard-wrap paragraph after the list), applied by the round's
`apply.py`. Bars set before the first draw: a row the wording targets moves
only from 0/5 or 1/5 to at least four more; a guard holds at 4/5 or better.
Every judged cell was graded by hand from the run JSON's `evidence`.

| Row | Baseline | Treated | Reading |
|---|---|---|---|
| `before-and-after-table` | 0/5 | 5/5 | moved; one bit with the next row |
| `one-row-per-state` | 0/5 | 5/5 | moved; every treated table has a row per list state and one for the side change |
| `headline-state-first` | 5/5 | 5/5 | guard held; every rep put the list states first in both arms |
| `what-changes-is-a-list` | 2/5 | 3/5 | unmeasurable at five reps from a 2/5 baseline |
| `no-hard-wrap` | 5/5 | 5/5 | guard held; no rep wrapped, the fence-free reading agreeing |
| `no-rollback-line` | 5/5 | 5/5 | restraint held on Sonnet |
| `no-image-committed` | 5/5 | 5/5 | not counted |
| `skill-was-invoked` | 5/5 | 5/5 | indicator |

The judge and the hand grade agreed on all thirty judged cells. Four of the
five list fails are the `bin/export.sh` item running to four sentences, its
scope note and the dry-run note added to the problem and the fix; the fifth,
a baseline rep, merged both list states into one item of five sentences.
Eight rows were read. Reps ran 9-12 turns in about 50 seconds in both arms,
$1.00 the baseline and $1.05 the treated arm. Kept as
`round-80@baseline-cli.json` and `round-80@shows-each-state-cli.json` with
their traces in `round80-traces/`.

## The Fable read

The same two arms on Fable, five reps each, from the same commits, the
strongest model the maintainer runs, for the restraint half: a Rollback line
on a change a revert undoes, and the hard wrapping whose sighting was a
strong model's own.

| Row | Baseline | Treated | Reading |
|---|---|---|---|
| `before-and-after-table` | 0/5 | 5/5 | moved |
| `one-row-per-state` | 0/5 | 5/5 | moved |
| `headline-state-first` | 5/5 | 4/5 by hand, 3/5 judged | guard held at the bar, a watched cost |
| `what-changes-is-a-list` | 1/5 | 4/5 | a gap of three, below the floor |
| `no-hard-wrap` | 5/5 | 5/5 | no rep wrapped on either model |
| `no-rollback-line` | 5/5 | 5/5 | restraint held: no Rollback line on the revertable change |
| `no-image-committed` | 5/5 | 5/5 | not counted |
| `skill-was-invoked` | 5/5 | 5/5 | indicator |

The judge agreed with the hand grade on 29 of 30 judged cells. The one miss
is a treated rep whose table puts the side change below both list states,
which the judge failed unanimously. The order guard's real fail is a treated
rep whose table follows a user's path - the empty listing, then the export
into a missing directory, then the listing after it - so the side change's
row sits between the two list states; its list of changes keeps the order.
The hard-wrap entry's failure reproduced on neither model: every rep on both
wrote its paragraphs as single lines through the Write tool, so the
paragraph against it rides on the guard alone. Reps ran 12-18 turns in two
to four minutes; $5.46 the baseline and $6.32 the treated arm, about 5.5
times Sonnet's per rep. Kept as `round-80@baseline-cli-fable.json` and
`round-80@shows-each-state-cli-fable.json` with their traces.

## Landed

The wording both arms' treated reps ran landed on `main` at `faa5ab6`, byte
for byte the text the round measured, with the README paraphrase; three of
the four entries left the queue and the hard-wrap entry kept its half for a
filed defect's body. The no-hard-wrap paragraph and the never-committed
screenshot landed on the maintainer's word, their failures unreached by
either fixture.
