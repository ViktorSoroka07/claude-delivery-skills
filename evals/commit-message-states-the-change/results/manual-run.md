# Runs

## The outcome graders, recalibrated on the landed log (task 51)

Until `2988647` the case asked the run to reply with
`git log --format='%B' -n 3`, and three graders read that reply on the
assumption that it quotes the commits. It need not: five of ten Sonnet replies
pasted none of it, one saying only that the output was "above". A reply that pastes nothing passes
a grader that looks for what the commits must not carry, so all 21 commits
carried the harness's default trailer while `no-default-trailer` read 5 of 10
passing. The run now redirects the same command into `commits.txt`, and every
outcome grader reads that file (`601e5d2`, `4a5e99c`, `5e085e3`, `995c1f8`):

- `no-default-trailer` and `no-narration`: regex, `not_contains`, over the file.
- `two-workstreams-two-commits`: a regex that counts the run's new commits by
  which of the fixture's two subjects the three-entry log still shows.
- `subjects-state-the-outcome` and `currency-body-says-why`: two judged
  graders on the same file, one per condition of the old rubric's other half.
  One asks that every subject name what its commit changed and where. The
  other asks that the currency commit's body say why the currency appears.
  Each is the text a judge probe calibrated (below).

`skill-was-invoked` is unchanged.

The file is the anchor, not the commit commands, because the runner counts
every `tool_use` in the trace, including one a hook refused. The runner flags
a refused call, but it reads that flag only for mock tallies. So a grader over
`git commit` commands reads a commit that the delivery gate stopped as a
landed commit, and does the same with the message an `--amend` replaced.
Haiku-gate rep 2 of round 48 is the instance: its first commit said "as
requested in review feedback. Also fixed…", the gate refused it, and the rep
then landed two clean commits. A command-anchored narration grader fails that
rep, and the log grader passes it.

### How the kept runs were re-graded

The traces are the twenty reps of task 48's commit arms:
`round-48@commit-baseline.json` and `round-48@commit-gate.json` (Sonnet,
`--judge-model sonnet`, five reps each), plus the two Haiku arms. The gate
never fired on Sonnet, so its ten reps are ten reps of the released plugin.

`regrade.mjs` re-implements the runner's arithmetic, read out of the
`claude` 2.1.280 binary that ran those rounds:

- A tool call is every assistant `tool_use` block, with
  `inputText = JSON.stringify(input)`.
- `tool_used` matches when `name === tool` and `new RegExp(input_match)`,
  with no flags, finds a match in that text. It passes when the match count
  lies between `min` and `max`.
- `regex` is `new RegExp(pattern, flags)` over the target text.
- `last_message` is the text blocks of the last assistant event that had any.

As a control, the pre-rewrite graders were run through it on all twenty
traces, and it reproduced the runner's recorded verdict in 60 of 60
mechanical cells.

`commits.txt` did not exist in those runs, so it is simulated from the
output of each rep's last `git log --format='%B' -n 3`, which is the command
the prompt now redirects into the file. All ten Sonnet reps ran it on its own
as their last call. Four Haiku reps chained it after a commit, and their
simulation cuts the commit summary off the front. One Haiku rep never ran it.

### What the rewritten graders read

Sonnet, the ten reps the calibration was set on. "Hand" is the reading of
every landed commit command, taken at task 48's stop and re-read here:

| Grader | Hand | Old grader (runner) | Rewritten |
|---|---|---|---|
| `no-default-trailer` | 0/10 | 5/10 | 0/10 |
| `no-narration` | 10/10 | 9/10 | 10/10 |
| `two-workstreams-two-commits` | 10/10 | 2/10, judged on the reply | 10/10 |
| `subjects-state-the-outcome` | 10/10 | - | judged; not re-graded |
| `currency-body-says-why` | 10/10 | - | judged; not re-graded |

The old narration fail was a reply saying it had dropped the "reviewer asked"
framing. No commit it made carries the phrase.

Haiku, read out of sample. "Hand" counts the reps that landed a commit (nine;
haiku-gate rep 1 was refused, loaded the skill and stopped to ask whether to
split):

| Grader | Hand | Old grader (runner) | Rewritten |
|---|---|---|---|
| `no-default-trailer` | 7 of 9 | 10/10 | 7/10 |
| `no-narration` | 4 of 9 | 10/10 | 4/10 |
| `two-workstreams-two-commits` | 1 of 9 | 1/10 | 1/10 |

The Haiku reps also found a defect the Sonnet calibration could not see,
since no Sonnet body contains "also". The narration list held the prompt's
own words, and four landed Haiku commits paraphrased them: "Also fix the
wording", "Also improved", "Also corrected", "After demo feedback". At
`601e5d2` the grader passed all four. `4a5e99c` widened the list to "also"
plus a second edit's verb stem, "after (the) demo" and "review/demo
feedback". That brought Haiku to the hand count, left Sonnet at 10/10, and
still passes a body saying the change "also shows" something.

The two 1/10 rows are different reps. The old rubric passed haiku-gate rep 1,
which asked and committed nothing, and failed rep 2, which split into two
commits but did not paste them. The rewritten grader does the reverse.

Fourteen synthetic logs cover the edges no kept rep reaches, and all score as
intended (`edges.mjs`):

- three new commits, or none, fail the count;
- the "Generated with [Claude Code]" footer fails, with or without its link;
- a lower-case trailer fails;
- a body saying a field is "generated with" something passes.

### What the calibration does not settle

- **The judged graders' calibration is the two probes below, not these reps.**
  A judge runs only inside a run, so each 10/10 above is a hand grade of the ten
  simulated files (`*.commits.txt` beside the traces). Gate rep 1 and gate
  rep 3 on Sonnet give the reason and then an imperative ("Render
  batch.currency…"); the rubric asks why the currency appears, not what tense
  the body uses. So hand grading passes both.
- **A rep that never writes `commits.txt` fails all three regex graders and
  the judged one** as "grader threw". That is a missing file, not a trailer or
  a narration, so read the rep's trace before counting it.
- **A rep that asks before splitting fails `two-workstreams-two-commits` by
  design.** The skill says split, and a single-prompt run cannot receive the
  answer.

### Reading a first run of the rewritten case

- Check that every rep wrote `commits.txt` before reading any rate.
- Hand-read any fail of the two judged graders from the file the run JSON
  keeps as its evidence. The probes calibrated them on six and ten files, which
  is too few to trust a fail unread.
- Read a rise in `no-default-trailer` against the 0/10 above. It is the
  measured failure queued against `writing-commit-messages`, not an
  instrument change.

The Sonnet reps ran 8 to 11 turns against a cap of 30. The redirect costs no
extra call.

### The first run of the rewritten case

Five Sonnet reps of the plugin arm, `--judge-model sonnet --ablation none`,
on CLI 2.1.280: $0.90, 52 seconds. Every rep saved the log by redirecting the
named command into `commits.txt`, none added the file to a commit, and each
ran 8 or 9 turns.

| Grader | Runner | Hand |
|---|---|---|
| `no-default-trailer` | 0/5 | 0/5 - all ten commits carry the trailer |
| `no-narration` | 5/5 | 5/5 |
| `two-workstreams-two-commits` | 5/5 | 5/5 |
| `messages-state-the-change`, since replaced | 1/5 | 4/5 |
| `skill-was-invoked` | 5/5 | 5/5 |

The mechanical graders read as calibrated. The judged one does not:

- By hand, rep 4 fails. Its currency body says only that a field was added,
  with a USD default, and not why.
- The other four currency bodies say why: amounts were ambiguous, or had no
  unit.
- The judge failed reps 1 to 3 as well, three votes to none each.
- The one rep it passed is the one whose comment commit's subject does not
  open with "Fix". Reps 1 to 4 open "Fix punctuation in…", and rep 5 opens
  "Correct the … punctuation".
- That one variable is the cause. The probe below changed only that word in
  rep 2's file and flipped the verdict.

### The judge probe, and the grader it left

These five files were put back through the judge, following the recipe in
`evals/judge-calibration.md`:

- a throwaway plugin whose scaffold writes each file as `commits.txt`;
- a sixth file, rep 2's with only "Fix" changed to "Correct" in its comment
  subject;
- three graders: the old rubric byte for byte, and its two conditions as one
  grader each;
- three reps per file under `--judge-model sonnet`, with the agent on Haiku,
  since its only task is to reply with one word;
- hand labels written before any verdict was read.

Cost: $0.92. Every cell was unanimous, nine votes of nine either way.

| File | Old rubric | Subjects alone | Currency body alone | Hand (all three) |
|---|---|---|---|---|
| rep 1 | F | P | P | P, P, P |
| rep 2 | F | F | P | P, P, P |
| rep 2, "Correct" | P | P | P | P, P, P |
| rep 3 | F | P | P | P, P, P |
| rep 4 | F | F | F | F, P, F |
| rep 5 | P | P | P | P, P, P |

What the table shows:

- **The one-word change flips the old rubric** from no votes of nine to all
  nine. That confirms the cause: the comment commit's "Fix punctuation…"
  subject, not the currency body.
- **The body condition alone agrees with the hand label on all six files,**
  one of them a real fail. It is the grader now, byte for byte as probed
  (`5e085e3`).
- **The subject condition alone is unstable.** It passes "Fix punctuation in
  the request table row-count comment" in reps 1 and 3, and fails "Fix
  punctuation in the request table's row-count comment" (rep 2) and "…heading
  comment" (rep 4).
- **The subject split was also a rubric question, not only a judge one.** The
  hand label read such a subject as stating the outcome, because it names the
  change and its place. The skill's own line for a tiny change, "say what is
  now correct", reads the other way. **The maintainer ruled for the first
  reading:** a subject that names what its commit changed and where states the
  outcome, whatever verb it opens with.

### The subject grader, reworded to the ruling and probed

The subject condition was reworded to the ruling. A subject passes when it
names the change and the code or text it is in, and the rubric says the
opening verb does not matter. It names the empty forms that fail: "Fix typo",
"Update summary", "Address review comments", "WIP".

The whole of the ruled side passes, so the kept logs alone could not show the
grader passing a bad subject. The probe therefore took ten logs:

- five from the first run;
- two from round 48 whose comment subjects open "Clarify the…" and "Fix the
  comma splice in…";
- three copies of rep 2, each with one subject swapped for an empty form.

Same throwaway recipe, $0.81. **Every cell agreed with the hand label written
before the run, nine votes of nine:** the seven real logs pass and the three
swapped ones fail. `subjects-state-the-outcome` is that text byte for byte
(`995c1f8`).

### Where the evidence lives

`evals/results/task51-commit-traces/`, git-ignored and local to the
maintainer's machine, holds:

- the twenty traces, copied out of the runner's temp directories;
- `regrade.mjs`, the re-grader;
- `edges.mjs`, the synthetic logs;
- `dump-logs.mjs`, which writes each rep's simulated log;
- the ten Sonnet `*.commits.txt`;
- the first run's five traces (`confirm-rep*.jsonl`). Its run JSON is
  `evals/results/round-51@confirm.json`, whose `evidence` field holds each
  file the judge was shown.

`evals/results/task51-judge-probe/` holds both probes' throwaway plugins
(`plugin/`, `plugin-subjects/`) with their hand labels, and the batch scripts.
The probes' run JSONs are `evals/results/round-51@judge-probe.json` and
`round-51@subject-probe.json`.

Usage is in each script's header.

## The skill gate and the first-tool-call line as a neighbour (48b)

Three draws of five Sonnet reps on a worktree carrying the skill gate
(`d738357`) and the brief's first-tool-call line (`59bde35`), each
`--ablation none --judge-model sonnet -j 3 --keep-temp` on CLI 2.1.280:
$0.87, $0.89 and $0.85, in `round-48b@commit-gate-line.json`, `-draw2` and
`-draw3`. The line reached every rep, read from each trace's `SessionStart`
output. Every rep's first call was the Skill tool with `tracking-open-asks`,
and every rep then loaded `writing-commit-messages` before its first commit,
so the gate stopped nothing, as on round 48's Sonnet arms. Turns ran 10 to 16
against 8 or 9 on the first run of the rewritten case.

The comparison is the plugin without either, read by hand: this record's
first run (five reps) and round 48's ten Sonnet reps, whose logs were re-read
at 48b for the body condition.

| Grader | With both, runner | With both, hand | Without, hand |
|---|---|---|---|
| `no-default-trailer` | 0/15 | 0/15 | 0/15 |
| `no-narration` | 15/15 | 15/15 | 15/15 |
| `two-workstreams-two-commits` | 15/15 | 15/15 | 15/15 |
| `subjects-state-the-outcome` | 15/15 | 15/15 | 15/15 |
| **`currency-body-says-why`** | **9/15** (2, 3, 4 by draw) | **9/15** | **14/15** |
| `skill-was-invoked` | 15/15 | 15/15 | 15/15 |

**The body row is a watched cost, not a settled one.** The hand reading
passes a body naming what the missing currency did - ambiguous totals, no
unit, a unit left implicit, a page with no way to show it - and fails one
saying only what the code now does, or restating that the currency was
missing. Two bodies sit on that line: draw 2's rep 3, "so the batch summary
always rendered without it", fails as a restatement, and draw 3's rep 3,
"reported the total without indicating its currency", passes as saying what
the absence did to the total. The same reading gives the fifteen comparison
bodies 14/15, the fail being the first run's rep 4 (reps are counted from 1,
in each run JSON's order). Pooled, 9/15 against 14/15 is p ≈ 0.04 one-sided;
but draw 2 was bought because draw 1 read 2/5, and draw 3 because draw 2 came
back undecided on a bar set on it alone, and those two alone read 7/10
against 14/15, p ≈ 0.16; and fourteen graders were read across the two
neighbour cases (six here and eight on the review case, a skill indicator
each), so one near p = 0.04 is weak evidence. No mechanism is identified: the one difference on this case is a
skill load ahead of the commit skill, which still loaded before every commit.
The line was landed on that reading. **The next round of this case reads this
row first, by hand, against 14/15**; if a fresh ten reps stay near 9/15, the
cost is real and the line is that round's subject.

**`skill-was-invoked` now reads a moment as well as the prompt.** A rep that
reaches a commit without the skill is stopped by the gate and loads it, so
this row reads 15/15 whichever of the two delivered the load. On Sonnet the
load came before every commit unprompted, so here it was the prompt.

The trailer rule held in none of the thirty commits, as before. One rep of
draw 1 first committed both edits without the trailer, then re-made them with
it - the skill's rule held at the first commit and the harness default at the
second.
