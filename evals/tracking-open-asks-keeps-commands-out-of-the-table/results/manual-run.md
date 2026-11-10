# Runner runs

Sonnet, five reps an arm, `--ablation none` on two worktrees, judge Sonnet,
`--keep-temp`. The baseline arm is the plugin at the commit that added this
case; the treatment arm is the same tree with the wording below in
`skills/tracking-open-asks/SKILL.md` and the brief's core. Kept as
`evals/results/round-grid@*.json`.

## The cause, isolated before any wording

A live interactive session rendered tables that differ in one property at a
time, read back from the screen. The terminal draws a table as a grid only
while every row fits in four wrapped lines; one row needing five turns the
whole table into stacked label-value records.

| Pair (one property changed) | Pane | Result |
|---|---|---|
| short cells | 86 cols | grid |
| short cells plus one 82-character path | 86 and 163 cols | grid (the path hard-broken at 86) |
| five columns of plain sentences, no path | 86 cols | stacked |
| the same | 163 cols | grid, rows of 3 lines |
| the same plus one path in a sentence cell | 163 cols | stacked |
| the same with a 70-character inline-code command in that cell | 163 cols | grid |
| one prose cell grown to 3 / 4 / 5 / 8 wrapped lines, others short | 163 cols | grid / grid / stacked / stacked |

The unbreakable token is not the cause on its own: it matters only by the
width it takes, which pushes its neighbours' sentences past four lines.

## Wording under test (landed second; the third, below, replaced its command clause)

> One item is a sentence. Two or more are walked through first, each under its number in a paragraph of its own: the question itself; what it blocks; the answer you recommend and why; and what happens if no answer comes, and where acting on the answer means a command the requester runs, that command in full in a fenced code block of its own beneath the paragraph, never inline or in the table. A numbered table then indexes them, one row per item, each cell a few words: the item's name, what it blocks, the recommended answer, what happens without one. A terminal draws a table as a grid only while every row fits in a few wrapped lines, so one cell of sentences, or a path or command whose unbroken length takes the width from its neighbours, turns the whole table into stacked records, and a command in a cell wraps where it cannot be copied whole.

with "The last cell opens with **Taken:** … and the item's paragraph says what
holds instead and which of those three keeps the recommendation from being
taken", and the brief's core: "(one item a sentence; two or more each walked
through under its number, any command the requester runs in a fenced code
block of its own, then indexed in a numbered table of few-word cells, since a
row of sentences or a long path or command stops a terminal drawing the table
as a grid)".

## The landed prompt (the requester does branch cleanup)

| Grader | Baseline | Treatment |
|---|---|---|
| table-cells-stay-short | 0/5 | 4/5 |
| no-command-in-a-table-cell | 1/5 | 5/5 |
| command-in-a-code-block | 3/5 | 5/5 |
| each-waiting-item-explained-above-the-table | 0/5 | 1/5 |
| closes-with-every-waiting-item | 5/5 | 5/5 |
| says-what-each-blocks-and-the-default | 5/5 | 5/5 |
| no-answer-cell-opens-taken-or-waits | 5/5 | 5/5 |
| rename-done-in-the-script | 5/5 | 5/5 |
| skill-was-invoked (with-only) | 5/5 | 5/5 |

Every baseline closing table carried whole sentences, about 150 characters a
cell, and four of five put the deletion command inside a row. The treatment's
one short-cell fail is a 46-character last cell. Read by hand, the
explained-above row is one or two of five, as the judge says: the item that
carries the command block tends to drop its recommendation's reason or its
default from the paragraph, the block standing in for them, while the table's
last cell still states the default in every rep. That is the gap a further
wording would aim at; it is not a loss against the baseline, which scores 0/5.

## Earlier draws (first prompt, which asked for any command the requester runs)

| Grader | Baseline | First wording | Landed wording |
|---|---|---|---|
| table-cells-stay-short | 0/5 | 5/5 | 5/5 |
| no-command-in-a-table-cell | 1/5 | 5/5 | 5/5 |
| command-in-a-code-block | 0/5 | 0/5 | 0/5 |
| each-waiting-item-explained-above-the-table | 0/5 | 3/5 | 5/5 |
| closes-with-every-waiting-item | 5/5 | 0/5 (5/5 by hand) | 5/5 |

The first wording ended its command clause "with any command the requester
would run in a code block of its own beneath it"; it gave the command inline
in three reps. Under that prompt no rep of the landed wording gave a command
at all, reading the deletion as the owner's approval to give and the
session's act to perform, so the code-block row there measured nothing; the
prompt was changed so the requester does branch cleanup themselves.

`closes-with-every-waiting-item` asked for "one list or table" stating both
questions; on the first wording the judge read the short-celled table as that
list and failed all five, though each rep restated both questions in full in
the numbered walk-through directly above it. The rubric, in this case and its
two copies, now names the walk-through followed by its index table as one
place.

## Third wording: the command block after the paragraph, never in its place

The landed wording's command clause now reads "that command in full in a
fenced code block of its own beneath the paragraph, after all four parts and
never in place of one, and never inline or in the table." Same prompt as the
landed table above; the comparison is that table's treatment column.

| Grader | Second wording | Third wording |
|---|---|---|
| each-waiting-item-explained-above-the-table | 1/5 | 4/5 |
| table-cells-stay-short | 4/5 | 5/5 |
| no-command-in-a-table-cell | 5/5 | 5/5 |
| command-in-a-code-block | 5/5 | 5/5 |
| closes-with-every-waiting-item | 5/5 | 5/5 |
| says-what-each-blocks-and-the-default | 5/5 | 5/5 |
| no-answer-cell-opens-taken-or-waits | 5/5 | 5/5 |
| rename-done-in-the-script | 5/5 | 5/5 |

The one fail, read by hand, recommends deleting the branch with no reason.
A gap of three in five is under the five-rep floor, so the third wording
lands as the better reading with no neighbour moving, not as a measured
win. Three of the five reps replace three the runner curtailed at launch,
when the CLI was upgraded under it: two reps ran on 2.1.319, three on
2.1.322, which every earlier arm of this case did not mix.

## Reverted: the sentence-celled table back, commands kept out of cells

The operator declined the few-word index: it emptied the table in every
display to fix one, the terminal, where a stacked table still shows every
word; the desktop app draws the sentence-celled table as a grid at any
length. Two further measurements settled it. The renderer's switch point (a
row of four wrapped lines draws a grid, five stacks the table) is the same in
CLI 2.1.284 and 2.1.322 on the same pair in the same 86-column pane; and one
real sentence-celled closing table stacked at 86 columns and drew as a grid
at 163, its tallest row exactly four lines. Whether such a table stacks is
the pane's width at that moment.

The case is renamed from `keeps-the-table-a-grid` and keeps the graders for
the rule that stays; `table-cells-stay-short` and
`each-waiting-item-explained-above-the-table` are dropped with the shape they
measured, and the closing-list rubric is back to "one list or table".
`no-command-in-a-table-cell` now matches only the whole deletion command in a
row: the first pattern counted any git word, which failed rows that point at
the block above (`the git branch -d command above`) or cite a command as
evidence (`git branch --merged main`) while the whole command sat in a
fenced block.

Wording under test, added to the October four-cell sentence:

> A command the requester runs is never put in a cell: a cell wraps it where it cannot be copied whole, and its unbroken length takes the width the other cells need; it goes whole in a fenced code block above the table, under the item's number, and the cell points to it.

Same prompt; the baseline is the landed-prompt baseline above, re-scored
with the narrowed grader from its kept evidence.

| Grader | Baseline | Reverted + command rule |
|---|---|---|
| command-in-a-code-block | 3/5 | 5/5 |
| no-command-in-a-table-cell (whole command) | 3/5 | 4/5 |
| closes-with-every-waiting-item | 5/5 | 4/5 |
| says-what-each-blocks-and-the-default | 5/5 | 5/5 |
| no-answer-cell-opens-taken-or-waits | 5/5 | 5/5 |
| waiting-items-in-a-numbered-table | 5/5 | 5/5 |
| rename-done-in-the-script | 5/5 | 5/5 |

Both moves are under the five-rep floor. The one row failure repeats the
whole command in a cell that also points at its fenced copy, so nothing is
lost to the requester; the one closing-list fail turned the deletion into a
row reading "Run the command above" instead of the question. The rule lands
as what the operator asked for, not as a measured win.
