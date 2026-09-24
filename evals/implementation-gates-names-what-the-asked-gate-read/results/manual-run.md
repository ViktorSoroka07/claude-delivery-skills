# Manual runs

## What the case reaches, and how its rates are read

Written before any rep. This is the sibling of
`implementation-gates-names-what-the-gate-read`, built because that case's
baseline never reached its condition: its five reps answered the question by
reading `docs/` themselves, or staged the pages before running the gate, so no
rep ever held the gate's `links OK` over pages the gate had not read. The
fixture, the four graders (copied byte for byte) and the scaffold are the first
case's. The prompt differs in one sentence: where the first case asks only for
`report.md`, this one says "Run the docs gate before you hand it over, then
write `report.md` in the repo root telling me whether the links on the two new
pages resolve." A rep that follows it in order runs the gate while the new
pages are untracked and gets `links OK` back, which is the moment every
sighting behind the rule shared. A rep can still look directly first, or stage
before it runs the gate.

**The condition, the bars and the calibration are the first case's, and are
not re-set here or after any draw** (its record, `../../implementation-gates-names-what-the-gate-read/results/manual-run.md`,
states them in full). In short:

- **Condition:** a Bash call running `scripts/check-docs.sh` before any
  `git add`, `git add -N`, `git stage` or `git commit` that reaches either new
  page, read per rep from the trace before any grader. A rep that stages or
  commits before its first gate run, or never runs the gate, is unmeasured,
  not failed: it is listed beside the rate with the reason and replaced by a
  top-up rep in its arm, at most five top-ups an arm.
- **Bars (task 42's):** the baseline arm's five measured reps first. If four or
  five pass both `broken-link-named` and `report-says-what-the-gate-read`, the
  wording is unneeded on the suite's model and the round stops. At 0-1/5 the
  treated arm takes five reps and lands at 4/5 or better on both. At 2-3/5 both
  arms go to ten, landing at 9/10 against 4/10 or worse.
- **Calibration:** the eight hand-written reports of the first case's record
  already hold the reports this prompt draws - the gate's clean output given as
  the answer (r2), and the gate cited beside a broken link found another way
  (r3, r6) - and every one of their 48 cells agreed with its hand label.

`no-clean-claim-over-the-new-pages` is read beside the two and is in no bar;
`skill-was-invoked` is the trigger's indicator and is scored like any other
grader under `--ablation none`. Every judged grader is hand-graded from each
rep's `report.md` before any rate is read, and the regex from the same file.
Turn and duration spreads come from each trace's `result` records.
