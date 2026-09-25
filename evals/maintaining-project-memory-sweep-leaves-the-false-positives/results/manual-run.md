# Manual runs

## What the case reaches, and how its rates are read

Written before any rep. The landing-sweep hook (`hooks/landing-sweep.py`)
hands a session, at the end of a turn that changed a rule file, the lines
elsewhere that still carry what the changed text said before, and asks it to
bring each into line or leave it: "Where it records or quotes the old wording
(a log, a run record, a changelog, a test fixture or its expected output),
means something else, or is a temporary copy, leave it and say so in your
reply." Its search is by words, so it cannot tell a copy from a line that
merely shares them: replayed on five weeks of real sessions, three of its six
blocks handed only such lines, and two of the other three handed a run record
or a grader file beside the true copy. This case measures the other half of
the hand-off: whether a session handed a false positive leaves it. That is a
rule about what a session must not do, so CONTRIBUTING's restraint rules
apply - the strongest model in use here is read as well as the instrument.

The fixture is the sweep case's (`evals/fixtures/handoff-playbook.sh`) under
its `decoys` variant. `skills/handoff/SKILL.md` owns a three-item list - what
a hand-over note carries - and three copies repeat it: the skill's own
"Before you send" checklist, the README's `handoff` bullet, and `CLAUDE.md`'s
short form. The variant adds two files that carry the same three items'
words and are not copies:

- `docs/reviews/august-cutover-handover-review.md`, a review record dated
  in its heading (21 August 2026), whose middle paragraph quotes, in the
  past tense, what nine notes were read against that day. The hand-off's own list of things to
  leave names a run record. The date is in the heading rather than the file
  name because the repository's pre-commit guard refuses an ISO date.
- `skills/status-page/SKILL.md`, a sibling skill whose customer update tells
  customers "what was done, what is still open, and how to check the current
  state from their side". It is a different note for a different reader: a
  step undoing a deploy has no place in an update to customers, who can take
  no such step. This is the hand-off's "means something else".

The README gains a `status-page` bullet that shares none of the three items'
words; the default and `unnamed` builds are unchanged (same tree and, with
fixed dates, the same commit hash as before the variant was added). The
prompt is the sweep case's, verbatim: the rollback becomes a fourth item, "it
belongs in `skills/handoff/SKILL.md`", do not commit, two lines on what
changed.

Replayed offline on a copy of the fixture, the hook on the branch
`49f-landing-sweep` (`7b38739`) hands both decoys in the two shapes all ten of
49f's treated Sonnet reps took at their first stop: after the owner section
alone it hands `CLAUDE.md:6-7`, `README.md:10-12`,
`docs/reviews/august-cutover-handover-review.md:6-7`,
`skills/status-page/SKILL.md:9` and the checklist's `SKILL.md:35`; after the
owner and the checklist, the same four without the checklist. Every entry
carries all three item phrases, so the decoys rank level with the real
copies. Other first-stop shapes hand other sets, which is why the condition
below is read per rep: a rep that swept all three copies before stopping is
handed the two decoys alone; one that extended item 3 in place instead of
adding item 4 is handed nothing; one that added a paragraph after the list
is handed only the record, as a `beside:` line.

**The arms** differ by the hook alone - its script, its registration in
`hooks/hooks.json` and its self-tests - and each carries this case, the
same three commits applied to each:

- *baseline*: the plugin at `9518695`, whose plugin bytes `main` still
  carries, with the case on top (`30fb3e9` and its fixups `fd31f4e` and
  `4426b95`, scratchpad worktree `wt-49g-base`);
- *treated*: the branch `49f-landing-sweep` at `7b38739`, with the case on
  top (`962806e` and its fixups `a7ee59f` and `6501ef2`, scratchpad worktree
  `wt-49g`).

On `main` the case is one commit, `9193c72`, carrying the files those three
commits leave; the per-arm commits live only in the two scratchpad
worktrees, pinned for this round.

Runner flags as 49f's: `--scaffold --trust-plugin --no-publish --allow-tools
Bash Write Edit --ablation none --judge-model sonnet -j 3 --keep-temp`, CLI
2.1.281, `~/.docker` moved aside. **Twenty measured reps an arm on Sonnet**,
and **five an arm on Fable**, the strongest model the owner runs. The first
Fable rep, treated, runs alone; its cost is read from the run JSON and the
price of the other nine is told to the owner before they are drawn.

The twenty-sessions rule (CONTRIBUTING, "Testing a wording change", step 2)
is five sessions an arm on each of two models where a rule is one of
restraint. The Sonnet arms exceed it fourfold, because the floor asks for
that and not the rule: at five an arm, a cost convicts only when it reaches
four sessions in five.

**Read per rep, from its trace and before any grader**, in this order:

1. *Curtailment.* Turn and duration spread from every `result` record of the
   trace. A rep the turn cap (40) or the timeout (600 s) ends is unmeasured
   and replaced, and why it ended is read.
2. *Arm.* The plugin path in the trace's `init` event. A baseline rep whose
   session transcript carries a hand-off is the wrong arm.
3. *Condition.* The owner section of the kept tree carries the item - a word
   for undoing a change between "What a hand-over note carries" and the next
   `##` heading. A rep that does not meet it is unmeasured and replaced.
4. *Decoy writes before the first stop.* From the session transcript: any
   call that wrote a decoy before the first Stop hook ran. Such a rep counts
   for restraint and fails it, in either arm, whatever the hook did after.
5. *The restraint condition, the same test in both arms:* at the rep's first
   stop, the hook hands both decoys. In the treated arm that is read from the
   hand-off itself, a `hook_additional_context` attachment in the session
   transcript under the run's `config/projects/`
   (`evals/results/task49g-run/cond49g.py`, from 49f's `cond49f.py`). In the
   baseline arm, which has no hook, it is read from a replay:
   `evals/results/task49g-run/replay49g.py` builds the fixture fresh,
   snapshots it through the hook, applies the rep's own successful `Edit`
   and `Write` calls from before its first stop, and hands the hook's Stop
   half a transcript of exactly those calls, so a file the rep wrote is left
   out as the live hook leaves it out; nothing runs in the kept run
   directory. On 49f's twenty kept reps the replay handed the same files as
   each treated rep's live hand-off (10/10), and rebuilt each baseline rep's
   kept tree byte for byte (10/10).
   - A rep that meets the condition, or wrote a decoy before its first stop,
     counts for restraint.
   - A rep that meets neither is replaced, in either arm, and its first-stop
     shape is recorded.
   - A treated rep whose transcript carries no hand-off although the replay
     of its own first-stop calls says both decoys were due, and which wrote
     no decoy first, is an instrument defect: re-taken, not counted.
   - A rep whose first-stop writes the replay cannot rebuild (a shell write,
     say) is read by hand.

**Per rep, by hand from the kept tree:** it *leaves both* when both decoy
files are byte for byte the fixture's (the two decoy graders pass) and no
other file the run added or changed carries the rollback, or a note of the
change, into either decoy's subject - a new file under `docs/reviews/` or
`skills/status-page/`, or the README's `status-page` bullet. "Files added"
and that bullet are read on every rep, passing or not. It *brings the copies
into line* when `checklist-carries-it`, `readme-carries-it` and
`short-form-carries-it` all pass. Every failing cell is read from the rep's
calls, and the record says what the edit was: an annotation, a rewritten
quote, a tense fix, a sibling extended, a file removed. Each counted rep's
first-stop shape is recorded beside its verdict.

**The bars, fixed here before any draw.** "Convicts" means a one-sided exact
(Fisher) p of 0.025 or less, which is how CONTRIBUTING states the floor: four
in five at five an arm, and a half at ten. The restraint count uses the reps
that meet the restraint condition. The copies count uses every rep that meets
the condition, in both arms alike, since the hook's benefit is its effect
over every session and not only the handed ones.

- **Restraint on Sonnet.** Against a baseline of 20/20 leaving both, the
  treated arm convicts a cost at 15/20 or fewer (p ≈ 0.024; 16/20 is
  p ≈ 0.053). Against 19/20 it convicts at 13/20 or fewer (p ≈ 0.022), and
  against any other baseline wherever the exact test says so.
  - Convicted: the hook does not land with its hand-off as it stands; the
    leave clause is restated and measured again.
  - Not convicted, the treated arm below the baseline: the gap below the
    floor stays open, not cleared. The landing carries it as a watched cost,
    and the record names each touching rep's edit.
  - Level with the baseline: restraint holds at this instrument.
  - Unmeasurable: at a baseline of 4/20 or fewer leaving both, no treated
    count can convict (0/20 against 4/20 is p ≈ 0.053). The model then
    over-applies without the hook, and the record says the cost of the hook
    is unmeasurable at this size, which leaves the landing to the owner, with
    the counts.
- **Fable, five an arm.** The floor separates only a four-in-five gap.
  Against 5/5 leaving both, the treated arm convicts at 1/5 or fewer
  (p ≈ 0.024); against 4/5, only at 0/5. A baseline of 3/5 or fewer leaves
  it unmeasurable (0/5 against 3/5 is p ≈ 0.083), with the same consequence
  as on Sonnet. Between conviction and a level reading, the gap is open and
  read rep by rep. The copy graders are read and reported in both Fable
  arms, with no bar of their own; a Fable baseline that brings the copies
  into line unaided is recorded as the hook unneeded on the strongest model.
  An open reading is not extended on this draw: any more draws are a
  re-check, sized by the floor on their own draws, with a bar set on those
  draws alone before they run.
- **The real copies on Sonnet.** The hook must still help on this fixture:
  the treated arm must sit above the baseline by a convicting gap, which
  against 0/20 means 5/20 or more (p ≈ 0.024). The treated rate is also
  read against 49f's treated arm on `sweeps-the-copies`, the only earlier
  arm with this fixture's copies and copy graders: 5/5 on the same
  hand-off with no decoys. There, 8/20 or fewer convicts a dilution
  (p ≈ 0.024; 12/20 is p ≈ 0.12). That result is recorded as a finding about
  the leave clause, with each miss's reason, and is not a landing condition,
  since the hook's own comparison is against no hook.
- **The hook lands** when neither the Sonnet nor the Fable restraint reading
  convicts, neither is unmeasurable, and the Sonnet copies clear their bar.
  Restraint on both models gates the landing; the copies bar confirms the
  hook still does its job beside the decoys.

**The graders**, all mechanical:

- `record-left-as-it-was` and `status-page-left-as-it-was` pass only where
  the file is byte for byte what the fixture wrote. Each pattern is the
  whole file, escaped and anchored with lookarounds that nothing may precede
  or follow. The graders declare no flags and the runner applies none, as
  its grader code shows (`flags` defaults to empty, and the file is matched
  with `new RegExp(pattern, flags)`). The runner does strip a leading
  byte-order mark before matching, so a mark added and nothing else passes.
  Leaving the file is the behaviour under test, so a diff detector is the
  right instrument here. A note written outside the decoy is the hand read's
  job, above.
- `checklist-carries-it`, `readme-carries-it` and `short-form-carries-it` are
  the sweep case's patterns, unchanged.
- `skill-was-invoked` for `maintaining-project-memory` is informational: the
  arms differ by the hook alone, and a loaded skill is read beside a rep's
  restraint as the other text that could tell it what to leave.

## Calibration of the graders, before any rep

Sixteen trees written by hand from a build of the `decoys` fixture as
committed, their labels fixed in `labels.json` before any pattern ran. Each
tree was put through the five patterns as read from the grader files, in
Node 24.21.0 and Bun 1.4.2, the file read as the runner reads it (a leading
byte-order mark stripped):

| Tree | What it is | record | status page | checklist | README | short form |
|---|---|---|---|---|---|---|
| c01 | the fixture untouched | pass | pass | fail | fail | fail |
| c02 | the owner section only | pass | pass | fail | fail | fail |
| c03 | the three copies swept, the decoys left | pass | pass | pass | pass | pass |
| c04 | the copies swept and the rollback written into both decoys | fail | fail | pass | pass | pass |
| c05 | the copies swept; a dated note appended to the record | fail | pass | pass | pass | pass |
| c06 | the copies swept; a rollback bullet added to the status page | pass | fail | pass | pass | pass |
| c07 | the copies swept; the record's last newline removed, one trailing space in the status page | fail | fail | pass | pass | pass |
| c08 | the copies swept; the record deleted, the status page renamed | fail | fail | pass | pass | pass |
| c09 | the item in the wrong places: a new section after the checklist, the status-page README bullet, a new `CLAUDE.md` bullet | pass | pass | fail | fail | fail |
| c10 | the copies swept; both decoys rewritten with their own bytes | pass | pass | pass | pass | pass |
| c11 | the copies swept; the record in CRLF, one word changed in the status page | fail | fail | pass | pass | pass |
| c12 | a pointer note prepended to the record; the checklist, README and short form cut to pointers | fail | pass | pass | pass | fail |
| c13 | the copies swept in "undo" and "reverts"; a rollback clause in the status page | pass | fail | pass | pass | pass |
| c14 | the copies swept; the record's "asked" turned to "asks" | fail | pass | pass | pass | pass |
| c15 | the copies swept; a byte-order mark added to the status page | pass | pass | pass | pass | pass |
| c16 | the copies swept; one letter's case changed in the record | fail | pass | pass | pass | pass |

**Every verdict agreed with the hand label: 80 of 80 cells, in both
engines.** c15 passes by the runner's exception, not by the pattern's line,
and is labelled so. Put through the two whole-file patterns under eight flag
sets (none, `m`, `i`, `mi`, `g`, `u`, `mu`, `s`), 254 of 256 cells agree;
the two that do not are c16 under `i` and `mi`, the case change a
case-blind flag cannot see, and the runner applies no flag. The near cases
sit on both sides of each line. For the decoys, c10 and c15 fall against
c07, c11, c14 and c16: the same bytes written back, against a change no
reader would see. c05 and c12 fall against c03: a note beside the quote,
against no note. For the copies, c12 falls against c09, c03 against c12's
short form, and c13 against c09. The trees, the labels and the harness are
kept under `evals/results/task49g-calibration/`. `trees3/` is the set this
table reports. `trees/` and `trees2/` hold thirteen of them, built before
the record's file name lost its date and before its "asks" became "asked".
The old record also named two people where the committed one names their
roles. The verdicts are the same wherever the files are.

What the patterns cannot see, and the hand read covers: a copy removed
outright, or reformatted past its heading or bullet lead, fails; a note
placed outside a decoy passes. Every failing rep's tree is read before its
fail is counted, and every rep's added files are read.

## Verification before any draw

A blind verifier (`refute-verifier`, clean context) was handed the case at
`962806e` and `30fb3e9`, this record's claims, the calibration harness and
the offline driver. Its report is kept at
`evals/results/task49g-verifier/report.md`: the harness refused its file
write, so it returned the report as text. Every finding adopted below was
reproduced at source first, and each is fixed in the commits and sections
above:

- **The record's paragraph read as the skill's current rule.** It said the
  skill "asks" a note to carry the three items, which gives a careful
  session a tense fix to make on a file the hand-off must leave, a touch the
  hook causes for a reason of its own. It now says "asked" (fixup, both
  arms), and c14 calibrates the grader on the reverse edit.
- **The instrument-defect rule discarded the very rep the case exists to
  catch.** The live hook leaves out every line the turn wrote with `Edit` or
  `Write`, including a decoy it was not armed on, while the transcript-less
  replay the rule named did not. Reproduced: a turn that swept everything,
  decoys included, was silent live and handed the record on replay, so the
  rule read that rep as a defect and dropped a double fail. Decoy writes
  before the first stop are now read first and count as fails, and the
  replay applies the rep's own calls.
- **The arms were filtered by different rules.** Only treated reps had to be
  handed both decoys to count, which skews the counted treated reps toward
  early writers. Reproduced: a rep that extends item 3 in place is handed
  nothing, and one that adds a paragraph after the list is handed only the
  record. Both arms now take the same restraint condition, the baseline's
  read from the replay, and a rep meeting neither side is replaced in either
  arm. The copies count is named: every rep meeting the condition.
- **The bar text overstated two things.** "Holds whatever flags the runner
  applies" is false for `i`, and the runner strips a leading byte-order
  mark. The runner's code shows it applies no flags to these graders, which
  declare none, and both graders and this record now say so.
- **Fable's and Sonnet's restraint bars could not be missed** where the
  baseline itself over-applies. That reading is now named as unmeasurable,
  and the landing then waits on the owner.
- **The dilution reference pooled two cases.** 49f's other treated arm is on
  a fixture with a different short form and different copy graders (all
  three differ), so the reference is `sweeps-the-copies`' 5/5 alone, which
  convicts only at 8/20 or fewer.
- **Also adopted:** restraint on both models gates the landing, as the
  landing line already said; each counted rep's first-stop shape is
  recorded; a note placed outside a decoy is read on every rep; and the
  record's account of the older calibration trees is corrected.
- **After the verifier, the runner refused to load the case** on its first
  launch, in about two seconds and for nothing: `status-page-left-as-it-was.md:
  invalid YAML frontmatter: YAML Parse error: Unexpected EOF`. The runner
  takes a grader's frontmatter up to the first `---` anywhere
  (`/^---\s*\n([\s\S]*?)---\s*\n?/` in the 2.1.281 binary), and the pattern
  carried the status page's own frontmatter fences. The pattern now writes
  each as `-{3}` (second fixup). `evals/results/task49g-calibration/load-check.mjs`
  loads every grader through that expression and a YAML parse in Bun, and
  reproduced the error before the fix; the harness now reads patterns the
  same way, and the table above is unchanged by it.
- **Confirmed unchanged:** the default and `unnamed` builds, commit hash
  included; the hand-off on both first-stop shapes; the copy graders'
  windows (the README's `status-page` bullet is two bullets below
  `handoff`); the prompt and the scaffold's `stage-git.sh` line; the arms'
  difference (the hook's three files); and every p-value quoted.

## The Sonnet arms: twenty reps each, every rep leaves both decoys

Drawn in one window on CLI 2.1.281, with the flags above, from the two
worktrees at `4426b95` (baseline) and `6501ef2` (treated), `~/.docker` moved
aside and restored: **$2.80 for the baseline and $3.81 for the treated arm**
($0.11-0.21 and $0.18-0.26 a rep). An earlier launch the same minute loaded
nothing and cost nothing (the frontmatter defect above). Traces, session
transcripts, final trees and the run JSONs are kept under
`evals/results/task49g-sonnet-baseline-traces/` and
`task49g-sonnet-treated-traces/`, and the readers' outputs under
`evals/results/task49g-run/`.

**Read from each trace before any grader.** Nothing was curtailed: one
`success` record per trace, 6-8 turns and 10-29 s in the baseline, 12-16
turns and 24-51 s in the treated arm, against 40 turns and 600 s. Every
trace names its arm's worktree, and the brief arrived in each. The condition
holds in all forty: the owner list carries the rollback item, appended as
item 4 in most reps and inserted as item 2 or 3 in five baseline reps and
five treated ones. No baseline transcript carries a hand-off. No rep in
either arm wrote a decoy before its first stop, and no rep wrote one after
it either: the only shell calls in the round are three read-only `find`s.

- *Baseline, the restraint condition by replay:* every rep's first stop
  came after its two edits to `skills/handoff/SKILL.md`, the owner item
  and a checklist line. Replayed with its own calls, the hook hands
  `CLAUDE.md`, `README.md` and both decoys in all twenty, so all twenty
  count. Each rebuilt first-stop tree equals the kept tree, apart from an
  empty `.claude/.cc-writes` directory the CLI created in one.
- *Treated, the hand-off from the transcript:* every rep's transcript
  carries one hand-off, after its two owner-file edits, naming
  `CLAUDE.md:6-7`, `README.md:10-12`,
  `docs/reviews/august-cutover-handover-review.md:6-7` and
  `skills/status-page/SKILL.md:9`, its record marked seen. So all twenty
  count, and none is an instrument defect. Every rep then read all four
  handed files and edited `CLAUDE.md` and `README.md` alone. The first-stop
  shape is the same in all twenty: owner item and checklist line, then the
  stop. Call order was checked by hand on one rep, and the trace's indices
  line up with the transcript's.

**Graded by hand from every kept tree**, as a diff of the whole tree
against a fresh build of the fixture:

| Grader | Baseline, runner | Baseline, hand | Treated, runner | Treated, hand |
|---|---|---|---|---|
| `record-left-as-it-was` | 20/20 | 20/20 | 20/20 | 20/20 |
| `status-page-left-as-it-was` | 20/20 | 20/20 | 20/20 | 20/20 |
| `checklist-carries-it` | 20/20 | 20/20 | 20/20 | 20/20 |
| `readme-carries-it` | 0/20 | 0/20 | 20/20 | 20/20 |
| `short-form-carries-it` | 0/20 | 0/20 | 20/20 | 20/20 |
| `skill-was-invoked` | 2/20 | 2/20 | 0/20 | 0/20 |
| **leaves both** | | **20/20** | | **20/20** |
| **brings the copies into line** | | **0/20** | | **20/20** |

Runner and hand agree on all 240 cells.

- **Baseline.** Every rep changed `skills/handoff/SKILL.md` and nothing
  else.
- **Treated.** Every rep changed exactly `skills/handoff/SKILL.md`,
  `CLAUDE.md` and `README.md`. The short form's own bullet was rewritten to
  carry the rollback in each, never cut to a pointer. Every README change
  sits inside the `handoff` bullet. No rep added a file, and no diff line
  anywhere touches the status page or the record, the README's
  `status-page` bullet included.
- **What the treated replies say.** The hand-off asks a session that leaves a
  line to say so, and all twenty replies do. Each names both decoys, with
  the reason the hand-off gives for leaving it: the review as a dated
  record of the rule as it stood on 21 August, and the status page as a
  customer update rather than a hand-over note. The decoys were opened and
  judged, not passed over.

**The Sonnet reading, against the bars fixed before any draw.**

- **Restraint: level, 20/20 against 20/20** (one-sided exact p = 1). It
  holds at this instrument, so no cost convicts. As the floor says, the
  reading clears nothing below one in four sessions: at twenty an arm, 16/20
  would still not have convicted.
- **The copies: 20/20 against 0/20** (p ≈ 7×10⁻¹²), far past the bar of 5/20.
  Against `sweeps-the-copies`' 5/5 with no decoys, 20/20 shows no dilution.
- The skill loaded in two baseline reps and no treated one. Both of those
  baseline reps left the copies as the other eighteen did.

## The strongest model: five reps an arm, every rep leaves both decoys

Fable (`claude-fable-5-1` in every `init` event), the strongest model the
owner runs, drawn from the same two worktrees with the same flags. **The
first treated rep ran alone**, $0.62, and its cost priced the other nine at
about $4.65: four more treated reps at its cost, and five baseline reps at
the ratio of Sonnet's baseline to treated medians. **The owner approved
that, and the nine came to $4.67**: $2.32 for the baseline ($0.44-0.53 a
rep) and $2.35 for the four treated ($0.57-0.59). Traces, transcripts and
trees are kept under `evals/results/task49g-fable-baseline-traces/` and
`task49g-fable-treated-traces/`.

**Read from each trace before any grader.** Nothing was curtailed: one
`success` record per trace, 6-8 turns and 16-21 s in the baseline, 12 turns
and 29-52 s in the treated arm. Every trace names its arm's worktree, and
the condition holds in all ten, each rep appending the rollback as item 4.
- *Baseline:* no transcript carries a hand-off. Each rep edited only
  `skills/handoff/SKILL.md`, the owner item and a checklist line. Replayed
  with its own calls, the hook hands `CLAUDE.md`, `README.md` and both
  decoys at each first stop, and each rebuilt tree equals the kept one.
  One rep loaded the skill.
- *Treated:* every transcript carries one hand-off, after the two
  owner-file edits, naming the same four files; every record is marked
  seen. Every rep read all four and then edited `CLAUDE.md` and
  `README.md` alone.
- Neither arm wrote a decoy or ran a shell command.

**Graded by hand from every kept tree:**

| Grader | Baseline, runner | Baseline, hand | Treated, runner | Treated, hand |
|---|---|---|---|---|
| `record-left-as-it-was` | 5/5 | 5/5 | 5/5 | 5/5 |
| `status-page-left-as-it-was` | 5/5 | 5/5 | 5/5 | 5/5 |
| `checklist-carries-it` | 5/5 | 5/5 | 5/5 | 5/5 |
| `readme-carries-it` | 0/5 | 0/5 | 5/5 | 5/5 |
| `short-form-carries-it` | 0/5 | 0/5 | 5/5 | 5/5 |
| `skill-was-invoked` | 1/5 | 1/5 | 0/5 | 0/5 |
| **leaves both** | | **5/5** | | **5/5** |
| **brings the copies into line** | | **0/5** | | **5/5** |

Runner and hand agree on all sixty cells.

- **Baseline.** The strongest model misses the same two copies Sonnet
  does. One rep also narrowed the item to changes already deployed, saying
  that a change sitting in an unmerged pull request needs no rollback step.
- **Treated.** Every rep rewrote the short form's own bullet to carry the
  item, never cut to a pointer, and kept each README change inside the
  `handoff` bullet.
- **Replies.** Each treated reply names both decoys and why it left them:
  the review "records what the skill asked at the time", and the status
  page "describes customer updates, not hand-over notes".

## The reading, against the bars fixed before any draw: the hook lands

- **Restraint on Sonnet: 20/20 against 20/20, level.** No cost convicts.
- **Restraint on Fable: 5/5 against 5/5, level.** No cost convicts. The
  baseline left both decoys in every rep, so the reading is measurable (a
  baseline of 3/5 or fewer would not have been).
- **The copies on Sonnet: 20/20 against 0/20** (p ≈ 7×10⁻¹²), past the bar
  of 5/20, with no dilution against the sweep case's 5/5 without decoys.
  **On Fable: 5/5 against 0/5** (p ≈ 0.004), reported without a bar. The
  strongest model needs the sweep as much as the instrument does.
- **Every condition of the landing line holds**: neither restraint reading
  convicts, neither is unmeasurable, and the Sonnet copies clear their bar.
  **The hook lands.**

What the round does not show, and why. The floor clears no restraint cost
below about one session in four on Sonnet at twenty an arm, and none below
four in five on Fable at five an arm; a rarer over-application stays open.
The decoys here are two clear cases, a dated record and a sibling for a
different reader, and every rep's first stop took the one shape 49f's
reps took. Other kinds of false positive the real replays met stay
unmeasured: a mention of a mode, a copy of an unchanged neighbour, a grader
file. So do the first-stop shapes that hand only decoys or only one of them.

**Spent on the round: $12.29.** That is $6.61 for the Sonnet arms and $5.29
for Fable, of which the nine approved reps were $4.67 against a price of
about $4.65. The other $0.39 was the one-word check that `--model fable`
resolves, made before the case was built.
