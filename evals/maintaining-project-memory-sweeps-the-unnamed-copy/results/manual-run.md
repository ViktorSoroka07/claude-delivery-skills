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

## The treated text, and the one verifier before any draw

The treated arm carries the first case's tested text - four tests appended
to "A memory write is a promotion", a boundary on "Promotion into a skill",
a red-flag row, and the brief's bullet restated - with the search step
restated in the section's fourth test, in the brief's last clause and in two
red-flag rows, and with a fifth act for the plugin's skill gate: a write into
a `SKILL.md`, `CLAUDE.md`, `CLAUDE.local.md`, `AGENTS.md` or `GEMINI.md` in
any letter case, a `.md` directly under a directory named `agents`, or a
`.md` under `skills/<name>/references/`, by `Edit`, `Write` or a shell
segment's own target words, stopped once until `maintaining-project-memory`
is loaded. It runs from a detached worktree at the case's commit; the whole
diff is kept under `evals/results/task49c-verifier/`.

One scoped blind verifier read the restated search and its evidence, the
brief's last clause, both rows and the gate's code, and every finding
adopted was reproduced at source first. It confirmed the evidence clause's
counts against the first case's traces and the gate's memory verdicts
against its code before the change (5,196 commands, no difference), and
changed four things. "A distinctive word" of each old item steered to the
owner's elaboration - `deploy`, `unfinished`, `dashboard` find only the
skill's own file in both variants - so the section's test now asks for "a
word of each thing the owning text said before the change that a shortened
copy would keep - from each item it listed, its headline rather than its
elaboration", and the brief for "a word a shortened copy would keep from
each thing the owning text said before the change". The brief's "before
calling it landed" became "before calling what you wrote landed". Both rows
now state the name in every spelling and a word of each old item. And the
gate's parse gained four fixes, each with a test that fails without it: a
quoted `git -C` path, a trailing comment, `sed` or `perl` only as the
command word, and `perl -0pi`. The brief bullet came to 205 words.

## The gate, live, before any arm

Three one-rep throwaway sessions of the treated plugin, same flags, $0.44:
an `Edit` of `CLAUDE.md` was stopped, the next call loaded
`maintaining-project-memory`, and the retried `Edit` ran; an
`echo ... >> AGENTS.md` was stopped, loaded, and ran on the retry; a
session told to load the skill first edited `CLAUDE.md` with no stop.

## The baseline arm: five reps, all measured, none pass

Five reps of the plugin at the case's commit plus one backlog-only commit
another session landed meanwhile (`BACKLOG.md` alone, so the plugin is the
same bytes), `--ablation none --model sonnet --judge-model sonnet -j 3
--keep-temp` on CLI 2.1.280: $0.58, kept as `round-49c@sibling-baseline.json`
with each rep's trace and tree under
`evals/results/task49c-sibling-baseline-traces/`. Nothing curtailed: one
`result` record per trace, all `success`, 5-7 turns against 40 and 11-22
seconds against 600. Arm membership read from every trace: the brief
arrived, without the treated bullet's words, and no rep was stopped. The
runner's kept directories seal each run's home (mode 000); the trees were
read after opening them as its notice says, without running git inside.

**The condition: met in all five.** Every rep read the skill, landed the
item in the owner section and ran no search at all.

| Grader | Runner | Hand |
|---|---|---|
| `checklist-carries-it` | 4/5 | 4/5 |
| `readme-carries-it` | 0/5 | 0/5 |
| `short-form-carries-it` | 0/5 | 0/5 |
| `skill-was-invoked` | 0/5 | 0/5 |
| **all three copies** | **0/5** | **0/5** |

Reps 1, 2, 3 and 5 brought the checklist in the same file into line; rep 4
edited the owner section alone; none opened `README.md` or `CLAUDE.md`.
Runner and hand agree on all twenty cells. **By the bar, 0/5 buys the
treated arm's five reps, landing at 4/5 or better.**

## The treated arm: five reps, all measured, one passes - below the bar

Five reps of the treated plugin, same flags: $1.09, kept as
`round-49c@sibling-treated.json`, traces and trees under
`evals/results/task49c-sibling-treated-traces/`. Nothing curtailed: one
`result` record per trace, all `success`, 10-17 turns and 29-65 seconds.
**Arm membership and the stop, read from every trace before any grader:**
the start hook carries the treated bullet's "once for the subject's name in
each spelling" in five of five; reps 1, 2 and 3 loaded the skill before
their first write into the handoff skill, and reps 4 and 5, which had not,
were stopped at that write and loaded it with their next call. So every rep
had the section's restated test loaded, and every rep is measured.
**The condition: met in all five.**

| Rep | How the skill loaded | Name search | Search on the old items' words | checklist | README | short form | all three |
|---|---|---|---|---|---|---|---|
| 1 | before its first write | `hand-over\|handoff\|rollback\|roll back\|undo`, any case, under `skills/` only | none | pass | fail | fail | fail |
| 2 | before its first write | `hand-over\|handoff`, one case | none | pass | pass | fail | fail |
| 3 | before its first write | `hand-over\|hand over\|handoff`, any case; then the new item's words | none | pass | pass | fail | fail |
| 4 | the gate's stop | `hand-over\|handoff\|hand over`, any case | none | pass | pass | fail | fail |
| 5 | the gate's stop | `hand-over\|handoff`, any case, with the items' headlines `What was done\|What is still open\|How to check the current state` in the same pattern | the headlines | pass | pass | pass | **pass** |

| Grader | Runner | Hand |
|---|---|---|
| `checklist-carries-it` | 5/5 | 5/5 |
| `readme-carries-it` | 3/5 | 4/5 |
| `short-form-carries-it` | 1/5 | 1/5 |
| `skill-was-invoked` | 5/5 | 5/5 |
| **all three copies** | **1/5** | **1/5** |

Runner and hand agree on nineteen of twenty cells. Rep 2's README reads "how
to roll each deployed or migrated change / back": five words inside "roll
... back", across a line, where the grader's window takes three; the hand
read passes it, and no rep's verdict moves, since rep 2 left `CLAUDE.md`
untouched.

**Reading, by the bar fixed before any draw: the sweep does not land.** One
of five against a bar of four, on a 0/5 baseline. The four misses are one
mechanism, and it is not the one the restated step was written against:

- **Every rep searched, and nine of the ten treated reps across both cases
  searched in any letter case** - against one of four searching reps under
  the first case's text. The letter-case half binds.
- **The second search did not run in any miss.** Each ran the name search -
  rep 3 the new item's words as well - brought what it found into line and
  closed: reps 2, 3 and 4 the README and the checklist, rep 1 the checklist
  alone. The short form, which only the old items' words reach, stayed as it
  was in all four. The
  one pass is the one rep whose pattern carried the old items' words. So the
  text in front of all five, loaded in all five, did not bind the search
  that nothing else in the work calls for - the same boundary the section's
  third test states for a read no act of the work makes.
- **Rep 1's search could not have found either copy**: it searched under
  `skills/` alone, and closed "No other file references the handoff note's
  contents, so this is the only copy to update."
- **The stop delivered the skill every time it was needed** - reps 4 and 5
  here - and loading it decided nothing: both stopped reps loaded it and
  searched, one passing and one not, and the three that loaded it unprompted
  all searched and all missed.
- **No rep searched as the text asks and missed a copy**, so nothing here
  says the restated step is wrong where it runs; rep 5 is that case, and it
  found all three.

Nothing else was bought. The extension belonged to a 2-3/5 baseline and the
neighbours to a landing. Spent on the round, both cases: $0.44 for the live
check, $0.58 for this baseline, $1.15 for the first case's treated arm and
$1.09 for this one - **$3.25** of the approved ~$3.15 for the case arms (up
to ~$14.60 with the extension and the neighbours).

## A second treated arm: a hook that hands the stale copies at the turn's end

The round above showed the sibling's miss exactly: every treated rep
searched, but only for the subject's name, which this short form does not
carry, and never for the old items' own words. This arm runs that second
search outside the model, as a hook on `UserPromptSubmit` and `Stop` that
hands the session, at the turn's end, the lines elsewhere still carrying
what its change to a rule file replaced. What the hook reads and hands, the
offline gate it passed before any draw, the two blind readers and the live
check are recorded in `maintaining-project-memory-sweeps-the-copies`, which
ran the same arm. On this fixture the hook reads the old items from the
list the change joined, so it reaches the short form through "What was
done", "What is still open" and "How to check the current state", none of
which is the subject's name.

**The baseline, re-taken on CLI 2.1.281:** five reps of the plugin at the
head, the same flags as this record's earlier arms, $0.64. Nothing
curtailed: one `success` record per trace, 6-8 turns against 40 and 11-21
seconds against 600. Every trace names the plugin at the head, without the
hook, and the brief arrived in each. **The condition: met in all five.**

| Grader | Runner | Hand |
|---|---|---|
| `checklist-carries-it` | 5/5 | 5/5 |
| `readme-carries-it` | 0/5 | 0/5 |
| `short-form-carries-it` | 0/5 | 0/5 |
| `skill-was-invoked` | 1/5 | 1/5 |
| **all three copies** | **0/5** | **0/5** |

Every rep edited `skills/handoff/SKILL.md` alone; rep 4 loaded the skill
first and still ran no search. Replayed offline on each kept tree, the hook
hands exactly `CLAUDE.md` and `README.md` in all five. **By the bar fixed
before any draw, 0/5 buys the treated arm's five reps, landing at 4/5 or
better.**

**The treated arm: five reps of the plugin with the hook, the same flags,
$0.88.** Nothing curtailed: one `success` record per trace, 10-11 turns and
20-47 seconds. Every trace names the plugin with the hook. **Measured, read
before any grader:** the condition is met in all five, and each rep's
transcript carries one hand-off after its edits to the handoff skill, naming
`CLAUDE.md:6-8` and `README.md:10-12`, its record read as seen.

| Grader | Runner | Hand |
|---|---|---|
| `checklist-carries-it` | 5/5 | 5/5 |
| `readme-carries-it` | 5/5 | 5/5 |
| `short-form-carries-it` | 5/5 | 5/5 |
| `skill-was-invoked` | 0/5 | 0/5 |
| **all three copies** | **5/5** | **5/5** |

Every rep then rewrote the short form's own bullet - "The note you leave
when work changes hands carries ..." - to carry the rollback, three of them
at the end of its list and two right after its first item; none cut it to
a pointer, and the short-form grader's named blind spot (a
bullet referring back to the note without naming it) did not arise. Runner
and hand agree on all forty cells of both arms. Rep 2 also wrote a note into
the harness's own memory directory, which no grader reads.

**Reading, by the bar fixed before any draw: this arm clears it, five of
five against four on a 0/5 baseline**, as the first case's does, so the
round lands. Against this record's earlier arm the move is from 1/5 to 5/5
with no skill or brief text changed: the search the restated step did not
bind, run by the hook instead, reached the copy only the old items' words
reach.
The cost of the round is in the first case's record.
