# Runs

## The outcome graders, recalibrated on the landed log (task 51)

Until `c083573` the case asked the run to reply with
`git log --format='%B' -n 3`, and three graders read that reply on the
assumption that it quotes the commits. It need not: five of ten Sonnet replies
pasted none of it, one saying only that the output was "above". A reply that pastes nothing passes
a grader that looks for what the commits must not carry, so all 21 commits
carried the harness's default trailer while `no-default-trailer` read 5 of 10
passing. The run now redirects the same command into `commits.txt`, and every
outcome grader reads that file (`89e50c0`, `d406247`):

- `no-default-trailer` and `no-narration`: regex, `not_contains`, over the file.
- `two-workstreams-two-commits`: a regex that counts the run's new commits by
  which of the fixture's two subjects the three-entry log still shows.
- `messages-state-the-change`: the old rubric's other half, a judged grader on
  the same file. It checks for outcome subjects and a body saying why the
  currency appears.

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
| `messages-state-the-change` | 10/10 | - | judged; not re-graded |

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
`89e50c0` the grader passed all four. `d406247` widened the list to "also"
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

- **`messages-state-the-change` is read by hand, not by its rate.** A judge
  runs only inside a run, so its 10/10 here is a hand grade of the ten
  simulated files (`*.commits.txt` beside the traces). Gate rep 1 and gate
  rep 3 on Sonnet write the reason and then an imperative ("Render
  batch.currency…"); the rubric asks why the currency appears, not what tense
  the body uses. So hand grading passes both. The first run's judge disagreed
  with the hand grade in three reps of five (next section).
- **A rep that never writes `commits.txt` fails all three regex graders and
  the judged one** as "grader threw". That is a missing file, not a trailer or
  a narration, so read the rep's trace before counting it.
- **A rep that asks before splitting fails `two-workstreams-two-commits` by
  design.** The skill says split, and a single-prompt run cannot receive the
  answer.

### Reading a first run of the rewritten case

- Check that every rep wrote `commits.txt` before reading any rate.
- Hand-grade `messages-state-the-change` from the file the run JSON keeps as
  its evidence.
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
| `messages-state-the-change` | 1/5 | 4/5 |
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
- The likely reading is that the judge matches "Fix punctuation" against the
  rubric's "fix typo". That is unconfirmed: the runner keeps no judge
  rationale, and this is only the one variable separating the pass from the
  fails.

Until a judge probe on these five files settles the cause
(`evals/judge-calibration.md` has the recipe), read this grader by hand.

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

Usage is in each script's header.
