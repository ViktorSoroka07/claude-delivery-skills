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

## The draft, and the two verification passes before any draw

The treated arm carries task 49's draft - A, four tests appended to "A
memory write is a promotion"; A2, a boundary on "Promotion into a skill"'s
pointer bullet; one red-flag row; and B, the brief's bullet 3 restated -
after two verification passes, each finding re-checked at source before
anything was adopted. The blind pass (ten claims, pinned at `eec58d3`,
barred from the plan's reasoning) corrected four of the draft's examples
against their records: the prohibition example (all five treated reps of
the drift case stashed, and the rule fired as an audit after the act rather
than being "recognised and broken in one step"), the skill gate (it stops an
act once, not "until the document is open"), the short form the fourth
landing left behind (the repository's instruction file, not the brief) and
the trigger example's second failure. It also showed that B's trigger had
dropped the current bullet's "one copy onto another" and that B's last
clause, "every other place that lists it", read with "it" as the rule
exempts exactly the stale copies. The delta check on the changed sentences,
the second pass and the one where the protocol stops, confirmed the figures
and their dates, and moved B's search to "its subject, not the new wording"
and its copies to every place that "states or lists" it. Two of its
suggestions were declined: "in the same commit" for "before calling it
landed", which a session told not to commit reads as not applying, and an
example list for the short form naming "an instruction file", which names
this case's own short form. B came to 178 words, against 71 today and the
longest bullet's 162; the skill to 2,523 words from 1,807. The full diff is
kept as `evals/results/task49r-treated-traces/treated-wording.diff`, with
each finding's disposition beside it.

## The baseline arm: five reps, all measured, none pass

Five reps of the plugin at `6216416` (the case's commit, no draft),
`--ablation none --model sonnet --judge-model sonnet -j 3 --keep-temp` on
CLI 2.1.280: $0.77 and 34 seconds wall, kept as `round-49r@baseline.json`,
each rep's trace and final tree under `evals/results/task49r-baseline-traces/`.
Nothing curtailed: one `result` record per trace, all `success`, 5-6 turns
against a 40-turn cap and 13-17 seconds against 600. The brief reached every
rep, and every rep's first call loaded `tracking-open-asks`.

**The condition, read from each tree before any grader: met in all five.**
Every rep read `skills/handoff/SKILL.md`, and only that file, and added the
rollback as a fourth (or second) item of what a note carries. No top-up was
needed. The runner's per-rep score was printed beside the run summary before
the hand grades were taken; the hand grades below were taken from the trees'
diffs against a fresh build of the fixture.

| Grader | Runner | Hand |
|---|---|---|
| `checklist-carries-it` | 4/5 | 4/5 |
| `readme-carries-it` | 0/5 | 0/5 |
| `short-form-carries-it` | 0/5 | 0/5 |
| `skill-was-invoked` | 0/5 | 0/5 |
| **all three copies** | **0/5** | **0/5** |

Four reps brought the checklist in the same file into line - the one copy
in front of them - and none opened `README.md` or `CLAUDE.md`; rep 1 edited
the owner section alone. Every closing reply reports the work as complete:
"Nothing else changed; no open items remain" (rep 1), "a matching checklist
line" (reps 2-5). Runner and hand agree on all twenty cells. Whether the
fixture's `CLAUDE.md` was in each rep's context is not readable from the
trace, which carries no system prompt.

**By the bar fixed before the draw, 0/5 buys the treated arm's five reps,
landing at 4/5 or better.**

## The treated arm: five reps, all measured, three pass - below the bar

Five reps of the plugin from a detached worktree at `6216416` carrying the
draft, the same flags: $0.90 and 76 seconds wall, kept as
`round-49r@treated.json`, traces and trees under
`evals/results/task49r-treated-traces/`. Nothing curtailed: one `result`
record per trace, all `success`, 6-15 turns and 13-46 seconds - the sweep
roughly doubles a rep's turns. Arm membership read from every trace: the
start hook's output carries B's phrase "states or lists that subject into
line", which only the treated text has, in five of five.

**The condition: met in all five.**

| Rep | Searched for other copies | checklist | README | short form | all three | skill loaded |
|---|---|---|---|---|---|---|
| 1 | `hand-over\|handoff\|rollback\|roll back`, case-insensitive: 3 files | pass | pass | pass | **pass** | no |
| 2 | `hand-over note\|handoff`, case-sensitive: 3 files | pass | pass | pass | **pass** | yes |
| 3 | no search | pass | fail | fail | fail | no |
| 4 | `hand-over\|handoff`, case-sensitive: 3 files | pass | pass | pass | **pass** | yes |
| 5 | `hand-over note\|handoff note`, case-sensitive: 1 file | pass | fail | fail | fail | yes |

| Grader | Runner | Hand |
|---|---|---|
| `checklist-carries-it` | 5/5 | 5/5 |
| `readme-carries-it` | 3/5 | 3/5 |
| `short-form-carries-it` | 3/5 | 3/5 |
| `skill-was-invoked` | 3/5 | 3/5 |
| **all three copies** | **3/5** | **3/5** |

Runner and hand agree on all twenty cells. Rep 4's short form names the
item as "the step that undoes it"; the pattern's undo alternation carries
it, and so does the hand read.

**Reading, by the bar fixed before any draw: the wording does not land.**
Three of five against a bar of four. The clause moved the act it names - a
search for other copies in four treated reps against none in the baseline,
and each rep that searched and found them rewrote them, one quoting B's own
clause back ("per the 'bring every other place that states or lists that
subject into line' rule") - but three in five against none in five is a
gap five reps an arm cannot separate, and the section reads a treated arm
below its bar as the brief clause unbound, which is 49b's question.

What the two failures are, since they are different mechanisms:

- **Rep 3 never searched.** B reached it and it acted as the baseline did:
  the owner section, the checklist in view, done. The clause did not bind.
- **Rep 5 searched, and its search could not have found the copies.** It
  loaded the skill, grepped the workspace for `hand-over note|handoff note`
  case-sensitively, found only the file it had edited, and closed "No other
  copies to sync. Done." `CLAUDE.md` says "Hand-over notes" and the README
  says "**handoff**", so neither matches. The clause bound; the search it
  asked for came back empty for a reason having nothing to do with whether
  copies existed - the check-result family's mechanism, a result that could
  not have come out the other way, met here inside the sweep.

**The passes rest partly on the fixture's own pointer.** Reps 2 and 4
searched case-sensitively as well, and found `CLAUDE.md` only because its
bullet ends in the path `skills/handoff/SKILL.md`, whose "handoff" matched;
"Hand-over notes" did not. Only rep 1's case-insensitive search would have
found a short form carrying no path. So the sweep's weak point, after
whether it runs at all, is what it searches for: a subject's words in the
reader's own spelling and case, not in the owner's.

**Skill loading did not decide the rep.** It loaded in three treated reps
and none of the baseline's; two of the three passed, and rep 1 passed
without it. The skill's fourth test was in front of rep 5 when it ran the
narrow search.

Nothing else was bought. The extension belonged to a 2-3/5 baseline, and the
neighbours only to a treated arm that lands. Spent on the round: $0.77 and
$0.90, **$1.67** of the approved ~$3.50 for the case (up to ~$17 in all).

## A second treated arm: the search step restated, and a stop at the write

The round after this one restated the sweep's search step and added a
stop at the write: the same text with the section's fourth test, the brief's
last clause and two red-flag rows asking for a search in any letter case,
once by the subject's name in every spelling and once by a word a shortened
copy would keep from each thing the owning text said before the change; and
a fifth act for the plugin's skill gate, stopping a write into a `SKILL.md`,
an instruction file or an agent contract once until
`maintaining-project-memory` is loaded. That text, the verifier pass it had
before any draw and the live check of the stop are recorded in
`maintaining-project-memory-sweeps-the-unnamed-copy`, the sibling built for
the round, whose short form names its subject only by a paraphrase.

**The stop reaches this case**: every rep edits `skills/handoff/SKILL.md`,
so a rep that has not loaded the skill is stopped at that edit, and
`skill-was-invoked` reads the stop rather than the trigger in this arm. The
case's lower-case `handoff` - in the README's lead and in the short form's
path - also lets any case-insensitive name search reach every copy, so this
arm reads the letter-case half of the step and not the second search, which
the sibling reads. Its baseline is this record's 0/5; the bar, fixed before
any draw, is 4/5.

Five reps from a detached worktree at the sibling's commit, the same flags:
$1.15, kept as `round-49c@copies-treated.json`, traces and trees under
`evals/results/task49c-copies-treated-traces/`. Nothing curtailed: one
`result` record per trace, all `success`, 15-17 turns and 35-43 seconds.
Arm membership and the stop, read from every trace before any grader: the
start hook carries the treated bullet's words in five of five; reps 1, 2 and
3 loaded the skill before their first write into the handoff skill, and reps
4 and 5 were stopped at that write and loaded it with their next call.
**The condition: met in all five.** Every rep searched, and every search was
in any letter case:

| Rep | How the skill loaded | Search | checklist | README | short form | all three |
|---|---|---|---|---|---|---|
| 1 | before its first write | `hand-over\|handoff\|hand over` | pass | pass | pass | **pass** |
| 2 | before its first write | `hand-over\|handoff` with the items' headlines, before any edit | pass | pass | pass | **pass** |
| 3 | before its first write | `hand-over note\|hand over note\|handoff`, then the new item's words | pass | pass | pass | **pass** |
| 4 | the gate's stop | `hand-over\|handoff`; after its edits, the old and new items' words | pass | pass | pass | **pass** |
| 5 | the gate's stop | `hand-over\|handoff\|hand over`, then a shell `grep -i` of both copies | pass | pass | pass | **pass** |

| Grader | Runner | Hand |
|---|---|---|
| `checklist-carries-it` | 5/5 | 5/5 |
| `readme-carries-it` | 5/5 | 5/5 |
| `short-form-carries-it` | 5/5 | 5/5 |
| `skill-was-invoked` | 5/5 | 5/5 |
| **all three copies** | **5/5** | **5/5** |

Runner and hand agree on all twenty cells; rep 3's copies name the item as
"how to undo", which the undo alternation carries. **This arm clears its bar,
five of five against four** - but the round lands only when every treated arm
that decides clears its bar, and the sibling's, on a 0/5 baseline, came to
1/5: its misses ran the name search and never the second, and there the
name search cannot reach the short form. So on this case the letter-case
clause bound in five of five (one of four searching reps under this record's
first treated text), and the second search's worth is read on the sibling,
not here.
