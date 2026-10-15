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

## The graders, settled before the first draw

- `before-and-after-table` takes the common spellings of an earlier and a
  later column (Before/After, Old/New, Was/Now, any case), since only the
  treated wording supplies the words Before and After; a rep with no table
  fails it and `record-sketch` for one cause, read as one bit.
- `record-sketch` takes a data line as well as a column name: a whole-number
  last field or `cents` on the left of a row, a two-decimal field or `amount`
  on its right.
- The Rollback line is read by two judges where it was one regex: the regex
  passed "Rollback: Revert this PR." under Not changed and failed a correct
  line placed above it. `rollback-names-what-a-revert-cannot-undo` passes a
  line under any heading that names what a revert leaves in place or breaks
  here - the billing files already sent, Finance's import having switched -
  and fails a deployment note that only says Finance must switch;
  `rollback-says-what-to-do-instead` passes a line saying what would be done
  in place of a plain revert, fixing forward or reverting only together with
  Finance switching back, given as an instruction or as what a revert would
  need. They were one two-condition rubric through the Sonnet round below,
  and are split because that rubric failed two of the treated arm's five
  correct lines.
- `what-changes-is-a-list` leaves a lead summary out of what it reads and
  counts a list with no heading; the skill already asks for an item per
  change, so it is read as a guard.
- `no-hard-wrap` reads a wrapped list item at any depth and its continuation,
  indented or not; a fail inside a fenced block is settled by the same pattern
  with the fenced blocks removed.
- `no-image-committed` cannot fail here: the change has no screen, and the
  prompt forbids a commit. It is kept and not counted.
- The prompt says the body will be pasted into the pull request form, since
  the treated rule binds a body the forge renders.

Five hand-written bodies, labelled before any verdict, cover the treated
ideal, the baseline shape (a summary wrapped like the commit body, file-led
bullets, a deployment note, no table), an Old/New table of data lines with
"Rollback: Revert this PR.", the changes as one paragraph with a correct
Rollback section above Not changed, and a wrapped heading-less list with an
After-only table. The settled judge agreed with all ten labels of the two
rubrics, every vote unanimous, and each regex grader matched all its labels.

`no-hard-wrap` is a restraint row too: its sighting was a strong model's own
wrapping, which the eval model may never show. Its strongest-model arms are
not bought for this case, so a clean baseline here says nothing about them.

## The Sonnet round

Two arms of five on Sonnet with the settled judge, from worktrees of one
commit: the baseline at `6777548` and the treated arm on that commit plus the
drafted contract, applied by the round's `apply.py`. The Rollback line was
then one rubric, `rollback-line-on-a-one-way-door`. Bars set before the first
draw: a row the wording targets moves only from 0/5 or 1/5 to at least four
more; a guard holds at 4/5 or better. Every judged cell was graded by hand
from the run JSON's `evidence`.

| Row | Baseline | Treated | Reading |
|---|---|---|---|
| `before-and-after-table` | 0/5 | 5/5 | moved; one bit with the next row |
| `record-sketch` | 0/5 | 5/5 | moved; every treated table sets the header and a data line before against after |
| Rollback line | 0/5 | 5/5 by hand, 3/5 judged | moved by hand; the two graders it is now split into read 0/5 and 5/5 on the same ten bodies |
| `what-changes-is-a-list` | 0/5 | 5/5 | moved; every baseline rep led with an item of four or five sentences, or bold paragraphs |
| `no-hard-wrap` | 5/5 | 5/5 | guard held; no rep wrapped |
| `no-image-committed` | 5/5 | 5/5 | not counted |
| `skill-was-invoked` | 5/5 | 5/5 | indicator |

Every baseline rep wrote a "Before merging" or "Rollout" note on timing the
merge with Finance and none said what a revert cannot undo; every treated
rep wrote a Rollback line naming Finance's switched import or the files
already sent and a revert made only together with Finance. The judge failed
two of those five, each giving the alternative as a condition ("Revert
together with their import, not alone"; what a revert would need) where the
three it passed gave an instruction; it agreed with the hand grade on the
other eighteen judged cells. Seven rows were read. Reps ran 8-10 turns in
about 40 seconds, $0.80 the baseline and $0.84 the treated arm. Kept as
`round-80@baseline-fmt.json` and `round-80@shows-each-state-fmt.json` with
their traces in `round80-traces/`.

The case is the second domain for the two Strong-tier entries, a screenshot
of each state and one bullet per behaviour: a change with no screen fills the
same slot with a sketch of its record, which no baseline rep wrote.

## Landed

The wording both arms' treated reps ran landed on `main` at `faa5ab6`, byte
for byte the text the round measured, with the README paraphrase; three of
the four entries left the queue and the hard-wrap entry kept its half for a
filed defect's body. The no-hard-wrap paragraph and the never-committed
screenshot landed on the maintainer's word, their failures unreached by
either fixture.
