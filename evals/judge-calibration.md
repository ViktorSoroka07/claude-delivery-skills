# Judge calibration

Every `llm` grader in this suite is scored by a judge model, and the judge is
chosen once per invocation — `--judge-model <model>` on the `claude plugin eval`
line. A grader file cannot name its own judge: `model`, `judge_model`,
`judge-model` and `judgeModel` are all rejected at load. So "which judge" is a
single decision taken before a baseline is bought, and this file is the evidence
it is taken from.

A row here answers one question: **on an artifact a person has graded by hand,
does this judge return the same verdict?** Agreement is the only thing that makes
a judge's vote worth reading. Unanimity is not: a judge that votes the same way
three times can be consistently wrong, and in the rows below one of them is.

## How a row is made, for the next instalment

A row costs cents, not the price of a run, because the artifact already exists.
Every `llm` grader keeps the exact text it judged in the run JSON under
`evals/results/`, as its `evidence` — so a kept run is a corpus of judged inputs,
and a hand grade written beside one turns it into labelled data.

1. Pull the `evidence` string of the grader whose verdict is in question out of
   the run JSON, and write it to a file.
2. Build a throwaway plugin outside the repo: a `.claude-plugin/plugin.json`, one
   case per file, the case's `fixture.sh` copying that file into the run
   workspace under the path the real case's graders `focus` on, and a
   `prompt.md` whose whole task is to reply with one word. Copy the graders in
   **verbatim** from the case being calibrated; a reworded rubric calibrates
   nothing that is running.
3. Run it once per candidate judge with `--ablation none` (no plugin is under
   test) and `--runs 3`.
4. Write the hand label first, from the grader text alone, before reading the
   verdicts.

Step 4 is the one that decays if skipped. A label written after seeing the votes
is not a label.

## Reading the table

Each row is one grader against one file — a cell of the calibration, not a run.

- **Hand label** — what the grader's own text says the verdict should be, read by
  hand. `contested` means two careful readings of the same text disagreed; such a
  row measures the rubric, not the judge, and is left out of the agreement counts.
- **Reps** — three repetitions of the same case. Each rep is an independent judge
  evaluation of the same file, and each evaluation is itself three votes, so a
  cell holds nine votes. `P`/`F` is the rep's verdict; the vote count behind it is
  given where it was not unanimous.
- **Agrees** — ✓ where the judge's verdict matches the hand label in all three
  reps.

## Rows: the delegation case's rubric, two files

The four graders of `review-pr-resolves-delegation` are one condition each, split
out of what was a single four-condition rubric. Both files judged here are real
review output kept from that case's own runner pass (`task11-18-resolves-deleg`):
one written by a run with the plugin loaded, 6.3 KB, and one by a run without it,
1.7 KB. The graders were copied byte-for-byte from the case as it stands at
`eccf6a2`; the files byte-for-byte from that run's `evidence`.

**File A — the plugin arm's findings file (6.3 KB).**

| Grader | Hand label | Default judge (haiku) | Agrees | `--judge-model sonnet` | Agrees |
|---|---|---|---|---|---|
| one-mount-finding | pass | P P P (8/9 votes) | ✓ | P P P (9/9) | ✓ |
| symptoms-under-one-finding | pass | F F F (1/9) | ✗ | P P P (9/9) | ✓ |
| no-error-state-suggested | pass | F F F (0/9) | ✗ | P P P (9/9) | ✓ |
| held-the-mount-back | contested | F F F (0/9) | — | F F F (0/9) | — |

**File B — the unaided arm's findings file (1.7 KB).**

| Grader | Hand label | Default judge (haiku) | Agrees | `--judge-model sonnet` | Agrees |
|---|---|---|---|---|---|
| one-mount-finding | fail | F F F (0/9) | ✓ | F F F (0/9) | ✓ |
| symptoms-under-one-finding | fail | F F F (0/9) | ✓ | F F F (0/9) | ✓ |
| no-error-state-suggested | pass | F F F (0/9) | ✗ | P P P (9/9) | ✓ |
| held-the-mount-back | fail | F F F (0/9) | ✓ | F F F (0/9) | ✓ |

**Agreement, over the 7 cells whose label is not contested:** the default judge
4 of 7, the stronger judge 7 of 7.

### The contested cell, and why it is not a judge measurement

`held-the-mount-back` passes only where the mount finding's Suggestion is the
single action of not shipping the detail-page wiring in this change, and allows
"a sentence saying what should happen once that task lands". File A's Suggestion
is *"hold the `fetchRequests` call and its error/paging handling out of this
branch. Mount `renderRequestTable` against data supplied by task 102's container
once that lands…"*. Read against the pass clause that is a hold-back plus an
allowed sentence about the future; read against the fail clause it is a file that
keeps the table mounted and removes only the fetch, which is repairing the wiring
rather than not shipping it. The case record takes the second reading; the label
written for this table took the first.

Both judges vote fail on it, 0 of 9 each. Only the stronger judge's vote carries
information — it passes the other three conditions on the same file, so it is
discriminating rather than refusing — and it sides with the case record. What the
cell measures is a rubric two readers split on, which no judge can be scored
against. It is queued as its own task; until the wording says which reading is
meant, a verdict on this grader is worth nothing from any judge.

### What the two files together say that one file cannot

The default judge passed exactly one cell out of eight, on 9 of its 72 votes. On
File B that produced three agreements — the right verdict for the wrong reason,
since a judge that fails nearly everything is right whenever the answer is fail.
File A is what separates the two: three conditions that a hand read and the
stronger judge both pass, failed three votes to none.

**So a calibration set needs an artifact that should pass and one that should
fail.** Against only the failing file, the default judge scores 3 of 4 and looks
usable.

## What the judge line costs

Measured on the runs above, where a judge evaluation is one grader against one
file, three votes, with a rubric of about 2 KB:

| | Default judge (haiku) | `--judge-model sonnet` | Ratio |
|---|---|---|---|
| Per evaluation, 6.3 KB file | $0.0195 | $0.0508 | 2.6× |
| Per evaluation, 1.7 KB file | $0.0055 | $0.0207 | 3.8× |
| This probe: 24 evaluations plus 6 one-word runs | $0.52 | $1.08 | — |

The agent side of those runs is identical in both arms at $0.22, so the whole
difference is the judge.

Against a real baseline the judge is a small share of the bill. The 1.9.0
baseline and its part reruns together spent **$1.26 of $64.04 on the judge, 2.0%**,
over 257 judge evaluations in the main part alone — about $0.0026 each, far under
this probe's rate because most graders in the suite judge a short file or the
run's final message rather than a six-kilobyte one. Scaling that line by the
2.6–3.8× measured above puts a sonnet-judged baseline **$2.00–3.50 dearer**, on
a baseline that costs upwards of $55.

## What to do

**Run the next baseline with `--judge-model sonnet`.** It agreed with every hand
label that was not contested, where the default judge agreed with four of seven,
and it costs single-digit dollars more on a baseline of that size. The fallback
the plan names — keeping the default judge and hand-grading every
multi-condition rubric out of `evidence` — is the more expensive option in
everything but dollars.

Read these limits with it. The rows are one case's rubric family, two files, one
rep count; they say the default judge misreads this shape of grader, not that it
misreads all of them. Nothing here tests a judge on a rubric of a few hundred
bytes over a one-line output, which much of the suite is. And a judge and the
runs it grades come from one model family here, which no invocation can change;
it is a limitation to state in a result, not a defect to fix.

## The raw runs

`evals/results/judge-cal-deleg-haiku.json` and
`evals/results/judge-cal-deleg-sonnet.json`, both local only — `evals/results/`
is git-ignored. Each keeps the judged file as every grader's `evidence`, so a
disputed cell above can be re-read without re-running anything.
