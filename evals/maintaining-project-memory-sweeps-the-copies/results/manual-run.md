# Manual runs

## What the case reaches, and how its rates are read

Written before any rep. The rule under test is the landing sweep drafted for
`maintaining-project-memory`'s promotion section: a landing is done when
every other place listing its subject agrees, because landing a rule in the
text that owns it leaves each other enumeration of that subject reading as
complete while wrong, and whoever writes from one never reaches the owner.
It is the one clause of the draft that asks for a search nothing else in the
work calls for, so it is the clause least likely to bind from a line in the
always-on brief, which is where the draft carries it.

The fixture (`evals/fixtures/handoff-playbook.sh`) is a small team-playbook
repository whose `skills/handoff/SKILL.md` owns a list - what a hand-over
note carries, three items - and whose three other files each enumerate the
same three: the skill's own "Before you send" checklist further down the same
file, the README's bullet on the skill, and `CLAUDE.md`'s one-bullet short
form, the copy every session in that repository loads first. Those are the
shapes the queued entry's four sightings left behind: further lists in the
same file, a paraphrase elsewhere, and the short form. The prompt is the
requester's shape at the fourth sighting - a rule that has held up in use,
"it belongs in `skills/handoff/SKILL.md`, in what a hand-over note carries",
do not commit, say in two lines what changed - and names none of the copies.
The new item is the rollback; no copy in the fixture uses a word for undoing
a change, so the graders read those words as the item landed.

**The condition is the item landed in the owner section**, read per rep from
the kept tree before any grader: a word for undoing a change between the
"What a hand-over note carries" heading and the next `##` heading. A rep that
does not land it there has not landed the rule, so it cannot have swept it,
and is unmeasured rather than failed: listed beside the rate with the reason
and replaced by a top-up rep in its arm.

**The bars are task 49's, fixed in the plan before any draw and not re-set
here or after any draw.** A rep passes when all three copy graders pass. The
baseline arm's five measured reps run first. At 4-5/5 the sweep is unneeded
on the suite's model where the copies are this close, and the round stops.
At 0-1/5 the treated arm takes five reps and lands at 4/5 or better. At
2-3/5 both arms go to ten, landing at 9/10 against 4/10 or worse - an
extension fixed in advance, not a re-check bought on a reading. A treated
arm below its bar reads the brief clause unbound.

**The graders**, all mechanical:

- `checklist-carries-it` passes where the "Before you send" section names
  the new item, or has been cut to a pointer at the owner - none of the three
  old items left and a pointer "above" or at the owner section by name.
- `readme-carries-it` passes where the README's `handoff` bullet names the
  new item, or has been cut to a pointer - still linking the skill, none of
  the old items left.
- `short-form-carries-it` passes only where a `CLAUDE.md` bullet names both a
  hand-over and the new item. A short form cut to a pointer fails: its
  readers rely on it without opening the owner, which the draft says in so
  many words.
- `skill-was-invoked` for `maintaining-project-memory` is the trigger's
  indicator, informational: the prompt names the work only by its category,
  and in the treated arm the brief carries the rule to every rep.

Every grader is hand-graded from each rep's kept tree before any verdict is
read. Turn and duration spreads come from each trace's `result` records.

## Calibration of the copy graders, before any rep

Nine trees written by hand from both sides of each grader's line, each a
copy of the fixture with the owner section and the copies edited as a rep
might leave them, labelled before any pattern was run, then put through the
three patterns as read from the grader files, in Node 24.21.0 and Bun 1.4.2:

| Tree | What it is | checklist | README | short form |
|---|---|---|---|---|
| t1 | the owner section only | fail | fail | fail |
| t2 | every copy gains "roll back" | pass | pass | pass |
| t3 | every copy cut to a pointer | pass | pass | fail |
| t4 | a pointer above the kept old items; the README reworded to three items in new words; "rollback" added to the dates bullet | fail | fail | fail |
| t5 | a new "Rolling back" section after the checklist; "rollback" in the incident-notes bullet; a new bullet on shipping changes that can be rolled back | fail | fail | fail |
| t6 | "undo" and "undone", "reverts", and the short form's rollback ahead of the hand-over | pass | pass | pass |
| t7 | the fixture untouched | fail | fail | fail |
| t8 | "back it out" in the checklist, the README untouched, "roll each change back" in the short form | pass | fail | pass |
| t9 | "reversal" and "irreversible", "back each change out", "roll it back" | pass | pass | pass |

**Every verdict agreed with the hand label: 27 of 27 cells, in both
engines.** The near cases sit on both sides of each line: for the checklist,
t3 against t4 (a pointer that replaces the items, or one left above them) and
t8 against t5 (the item in the section, or in a section of its own after
it); for the README, t3 against t4 (cut to the link, or reworded and still
enumerating) and t2 against t5 (the item in the handoff bullet, or in its
neighbour's); for the short form, t2 against t3 (the item added, or the bullet
cut to a pointer) and t6 against t4 and t5 (the item in the hand-over bullet
in either order, or in another bullet). The trees and the harness are kept
under `evals/results/task49r-calibration/`.

What the patterns cannot see and the hand read covers: a copy removed
outright or reformatted past its heading or bullet lead fails the pattern;
every failing rep's tree is read before its fail is counted.
