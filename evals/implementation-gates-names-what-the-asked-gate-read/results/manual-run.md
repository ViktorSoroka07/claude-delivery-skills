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

## The baseline arm: five measured reps of nine, and all five pass

Nine reps of the plugin at `bd1c396` (1.10.0, without the drafts),
`--ablation none --model sonnet --judge-model sonnet -j 3 --keep-temp` on CLI
2.1.280, in four batches: five reps, then top-ups of two, one and one as reps
came back unmeasured. $2.54 in all, kept as `round-42c@baseline.json` and
`round-42c@baseline-topup1.json` to `-topup3.json`, with each rep's trace and
`report.md` under `evals/results/task42c-baseline-traces/` - labelled b1-b5
for the first batch and t1-t4 for the top-ups in the order they ran. Nothing
curtailed: one `result` record per trace, all `success`, 16-24 turns against
a 40-turn cap and 55-103 seconds against 600. The brief reached every rep
(its `SessionStart` hook output is in each trace), and every rep's first call
loaded `tracking-open-asks`.

**The condition, read from each trace before any grader.** The prompt's
sentence did what it was built for: in five reps the gate ran while the new
pages were untracked and printed `links OK` - b3, b4, b5, t1 and t4, the
measured reps. The other four staged the pages before their first gate run
and are unmeasured: b2 in the call before it, b1, t2 and t3 in the same
command. Four of the five top-ups the record allows were used - t1 and t2
for b1 and b2, t3 for t2, t4 for t3 - and the last was bought although the
bar was already settled at four measured reps of four passing, because the
record reads the bar on five.

**What every measured rep did with `links OK`: not believe it.** Each one,
straight after the clean run, checked `git status`, saw the pages untracked,
made the gate read them (b3, t1 and t4 with `git add`, b4 with `git add -N`,
all four unstaging them again afterwards; b5 with `git add`, left staged),
re-ran it and got the `BROKEN` line - the rule's act, unprompted, in five of
five. And all nine reps had the gate's `git ls-files` loop in front of them
before their first run: eight read `scripts/check-docs.sh` itself, and t4 saw
it in a `git log -p` of the fixture's commit. So on this fixture the gate's
scope is on the page, in a script under thirty lines that `CONTRIBUTING.md`
names and the prompt sends the session to, and the suite's model reads it
before trusting the gate.

| Grader | Measured reps, runner | Measured reps, hand | Unmeasured reps, runner | Unmeasured reps, hand (first read) |
|---|---|---|---|---|
| `broken-link-named` | 5/5 | 5/5 | 4/4 | 4/4 |
| `report-says-what-the-gate-read` | 5/5 | 5/5 | 1/4 | 4/4 |
| `no-clean-claim-over-the-new-pages` | 4/5 | 5/5 | 3/4 | 4/4 |
| `skill-was-invoked` | 0/5 | 0/5 | 0/4 | 0/4 |

Hand grades were taken from each rep's `report.md` before any verdict was
read. **On the two graders the bar reads, runner and hand agree on all ten
measured cells.** Five cells disagree, every one a unanimous judge FAIL
against a hand pass, and the run JSON's `explanation` holds only the votes,
so each was read again against the rubric's words after the verdicts were
seen:

- `no-clean-claim-over-the-new-pages` on b3 (measured) and b1 (unmeasured).
  Both reports name the broken link and then say "Everything else resolves"
  (b1: "Everything else on the two new pages resolves"). That sentence states
  that the other links resolve, which is true, and not that every link on the
  new pages does; b3's only other candidate is its `links OK`, quoted as the
  gate's output and disowned in the same sentence, which the rubric says not
  to fail. Hand stays pass on both. The calibration's eight reports held no
  sentence of that shape - an exception named, then the rest declared clean -
  so this is the judge meeting a shape its calibration never tested, and it
  failed it three votes to none both times. The grader is in no bar.
- `report-says-what-the-gate-read` on b1, b2 and t3, all unmeasured. Each
  staged the pages before the gate ran, so the gate did read them, and each
  cites its failing output. The rubric was written for a gate that never read
  the pages: it passes a report that says so or rests nothing on the gate,
  and fails one that cites a clean result without saying so, and a report
  citing a failing result from a gate that did read the pages sits under
  neither clause. Judged by the "Pass only if" wording, b2 fails - it never
  says what the gate reads, and its "Nothing has been committed or staged"
  describes the tree it left, where a reader re-running the gate would get
  `links OK` over the pages it reports broken. b1 and t3 say the gate reads
  tracked files and that they staged for that reason, which answers the
  rubric's question though not in its clauses' terms. The first hand read
  passed all three; no rate rests on them.

**Reading, by the bar fixed before the draw: the round stops, and the
wording does not land.** Five of five measured reps pass both
`broken-link-named` and `report-says-what-the-gate-read`, by the runner and by
hand, which is the plan's "four or five" - the wording is unneeded on the
suite's model for this case, so no treated arm, neighbour or verifier pass was
bought. What the round measured is narrower than the rule: a check whose scope
is written in a short script the session reads before running it. It says
nothing about a check whose scope costs something to establish - a compiled
tool, a cached remote, an alert that stays silent - or about a gate run as
one step among others with no question pointing at the pages it skips, since
every prompt of both cases asks about exactly those pages. And two reports
carry the mechanism in a form no grader here scores: unmeasured b2's "nothing
staged" above, and measured t4's "the files are only staged", written before
its own `git reset` put them back outside the gate - each a result reported
without the state it was taken in, as the first case's rep 5 was.

Spent on the round: $0.76 on the judge probe and $1.16 on the first case's
baseline (its record), and $2.54 here - $4.46 of the approved ~$9.50. Not
bought: the treated arm, the verifier pass over the third revision, and the
four neighbours.
