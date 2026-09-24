# Manual runs

## What the case reaches, and how its rates are read

Written before any rep. This is the sibling of
`maintaining-project-memory-sweeps-the-copies`, built for the round that
tests a restated search step for the landing sweep drafted for
`maintaining-project-memory`'s promotion section: a landing is done when
every other place listing its subject agrees, searched for in any letter
case, once by the subject's name in every spelling and once by a distinctive
word of each thing the owning text said before the change. The first case's
treated reps showed two ways a search can come back short on that fixture -
one letter case, and only the owner's own two-word phrase - and the restated
step answers both. A rerun on the fixture that prompted it cannot tell a
wording that carries the mechanism from one that fits that fixture's two
traps, so this case changes the one copy those traps decided.

The fixture is the same builder, `evals/fixtures/handoff-playbook.sh`, in its
`unnamed` variant: the handoff skill, its checklist and the README are
byte-identical to the first case's, and `CLAUDE.md`'s short form names its
subject only as "the note you leave when work changes hands", in sentence
case, with no "hand-over", no "handoff" and no path to the skill. On the
built fixture, `hand-over|handoff`, `hand-?over|hand-?off|hand over` and
`hand-over note|handoff note` each find the README and the skill and miss
`CLAUDE.md` in either letter case, while `landed|owns|dashboard` and
`landed|owner|current state` find all three. So a name search in any
spelling misses this short form, and only a search for the old items' own
words reaches it. Adding the variant left the first case's build
unchanged: its tree hash is the same from the builder before and after.

**The condition is the item landed in the owner section**, read per rep from
the kept tree before any grader: a word for undoing a change between the
"What a hand-over note carries" heading and the next `##` heading. A rep that
does not land it is unmeasured, listed beside the rate and replaced by a
top-up rep in its arm. In a treated arm a rep is measured only when its start
hook carries the treated bullet's words and, where it had not loaded the
skill before its first write into the handoff skill, its trace carries the
gate's stop at that write; a treated rep missing either is an instrument
defect, re-taken and not counted.

**The bars were fixed in the maintainer's plan before any draw and are not
re-set here or after any draw.** A rep passes when all three copy graders
pass. The baseline, five reps at the head: at 0-1/5 the treated arm takes
five reps and lands at 4/5 or better; at 2-3/5 both arms go to ten, landing
at 9/10 against 4/10 or worse - an extension fixed in advance; at 4-5/5 this
case cannot show the sweep needed, and the first case decides alone. The
round lands when every treated arm that decides clears its bar.

**The graders**, all mechanical:

- `checklist-carries-it` and `readme-carries-it` read the two copies this
  fixture shares with the first case, with the same lines: the item named in
  the copy, or the copy cut to a pointer at the owner.
- `short-form-carries-it` passes only where one `CLAUDE.md` bullet names
  both the subject - hand-over, handoff, or work changing hands - and the new
  item, in either order. A short form cut to a pointer fails: its readers
  rely on it without opening the owner.
- `skill-was-invoked` for `maintaining-project-memory` is informational. In
  a treated arm under the gate, a load follows the stop rather than the
  trigger, and is read beside the trace's stop.

The three copy graders read the new item through one alternation of words
for undoing a change, and here it reads a phrase broken across a line and up
to three words inside "roll ... back" and "back ... out". The first case's
graders carry the same alternation with literal spaces and at most two words
inside "back ... out", so a copy whose item wraps inside such a phrase, or
reads "back each deployed change out", fails there: t10 below, a tree of
that shape, fails both of its copy graders. None of that case's ten reps
wrote such a copy - runner and hand agreed on all forty cells - and its
graders are left as they are, so its two arms stay comparable, with every
failing tree read by hand.

Every grader is hand-graded from each rep's kept tree before any verdict is
read. Turn and duration spreads come from each trace's `result` records.

## Calibration of the copy graders, before any rep

`checklist-carries-it` and `readme-carries-it` were run over the first
case's nine hand-written trees and one more, t10, whose checklist item wraps
("how to roll / it back") and whose README item reads "how to back each
deployed change / out" across a line; the hand labels are that case's, and
t10 passes both. **Every verdict agreed with the hand label: 20 of 20 cells,
in Node 24.21.0 and Bun 1.4.2.**

`short-form-carries-it` was run over fourteen trees written by hand on this
variant, labelled before any pattern was run:

| Tree | What it is | Hand | Pattern |
|---|---|---|---|
| s01 | the owner section only | fail | fail |
| s02 | the item added, the phrase kept | pass | pass |
| s03 | cut to a pointer at the skill | fail | fail |
| s04 | "rollback steps" added to the dates bullet | fail | fail |
| s05 | a new bullet on shipping behind flags so changes can be rolled back | fail | fail |
| s06 | reworded to "Hand-over notes carry ...", the item as "the step that undoes" each change | pass | pass |
| s07 | the fixture untouched | fail | fail |
| s08 | the item ahead of the phrase | pass | pass |
| s09 | an indented sub-bullet under the short form naming the item | pass | pass |
| s10 | a new top-level bullet naming the note by its phrase and the item | pass | pass |
| s11 | the rewrap breaks "changes / hands" and "back each change / out" across lines | pass | pass |
| s12 | "how to roll it back" added to the skills bullet, which says "change" but not the phrase | fail | fail |
| s13 | cut to "carries four things, the rollback among them: see the skill" | pass | pass |
| s14 | a new top-level bullet, "That note also says how to roll back each deployed change." | pass | **fail** |

**Thirteen of fourteen cells agree, in both engines.** The one disagreement
is the pattern's named blind spot: a bullet that refers back to the note
without naming it carries the item to a reader and fails here, so every
failing tree is read by hand before its fail is counted. The near cases sit
on both sides of the line: s02 against s03 (the item added, or the bullet cut
to a pointer), s10 against s05 and s12 (a new bullet that names the note, or
one that names another thing), and s11, whose phrase and item both break
across lines. The trees and the harness are kept with the round's results.
