---
type: regex
arm: with-only
target:
  source: file
  path: "review-findings-7.md"
pattern: "^[ \\t]*\\|[^|\\n]*\\|[ \\t]*\\**[ \\t]*[Mm]inor[ \\t]*\\**[ \\t]*\\|[^|\\n]*\\|[ \\t]*\\**[ \\t]*`?docs/(?:retry|cli|faq)\\.md:[0-9]+"
flags: m
match: contains
---

D1 to D4 are minors of one defect class - user docs that misdescribe the code -
over three files. Compact merges findings of one class across files, so they
become one thread, and its anchor is one of its members'.

The pattern reads one row of the packing table in the column order the skill
prescribes (thread title, grade, members, anchor): any title, a grade cell
holding `Minor` alone, any members, and an anchor cell opening on a line of
`docs/retry.md`, `docs/cli.md` or `docs/faq.md`. Which member gives the row its
anchor is the run's choice and is not read - runs anchor it at
`docs/retry.md:3` and at `docs/retry.md:5`, and a run that listed the
command-line guide first would anchor it there. The grade cell is the strict
one: it holds the grade alone, since a cell naming two grades is the mixed row
compact forbids. The anchor cell has to open with the anchor and may carry
anything after it, a parenthetical or the other members' anchors listed behind
it.

The members cell is deliberately unread. The merge renumbers the findings in
every run and some runs fold the two minors on `docs/retry.md` into one grouped
finding, so the same correct packing writes `F3 (items 1-2), F4, F5`,
`N1 (D1, D2), N2 (D3), N3 (D4)` or `3, 4, 5, 6` there. That this row holds all
four is carried by the family instead: the three sibling rows take the other
three survivors out of it, and `packing-docs-minors-not-spread` refuses a
second Minor docs row.

The file the run leaves behind also holds the fixture's Pass 1 and Pass 2
sections, which this pattern is not scoped past. Neither carries a table, so a
row of this shape is the run's own.
