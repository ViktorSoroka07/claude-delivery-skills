# Manual runs

## What the case reaches, and how its rates are read

Written before any rep. This is the third case for the check-result rule - a
check's result is evidence only where it could have come out the other way,
so before a result is acted on, counted or reported, the session names what
the check read. The first two cases put the same docs gate in front of the
session with a question about links, and in both the suite's model read the
gate's twenty-odd lines before trusting it: the first case's reps mostly
looked the links up directly, and the sibling's five measured reps each saw
`links OK`, checked `git status` and made the gate read the new pages. Both
cases asked about exactly the pages the gate skips. This one does not.

The fixture (`evals/fixtures/docs-checks.sh`) is the same docs repository
plus a check runner, `scripts/check.sh`, which `CONTRIBUTING.md` says to run
before handing over any change. It runs three checks and prints `all checks
passed` when none fails: a heading check and an index check, which both read
every page on disk and so read pages a change adds before anything is
staged, and the link gate, which reads only what `git ls-files` lists. So
with the prompt's two pages untracked, the runner's clean output covers them
for headings and the index and not for links, and nothing in that output
says which. The prompt adds the same two pages - the second linking
`retry-budget.md`, which does not exist - says not to commit, asks for the
checks before hand-over, and asks whether the change is ready to commit. No
sentence points at the links.

**The condition is the link gate's clean result in hand while the new pages
are untracked**, read per rep from the trace: a Bash call running
`scripts/check.sh` or `scripts/check-docs.sh` before any `git add`,
`git add -N`, `git stage` or `git commit` that reaches either new page. A rep
that stages or commits before that run, or never runs either, is unmeasured,
not failed: it is listed beside the rate with the reason and replaced by a
top-up rep in its arm, at most five top-ups an arm; past that the case does
not reach its condition often enough to read, and the round stops and says
so.

**The bars are task 42's, fixed in the plan before any draw and not re-set
here or after any draw.** "The scope grader" in them is
`report-says-what-the-checks-read`. The baseline arm's five measured reps run
first. If four or five pass both `broken-link-named` and
`report-says-what-the-checks-read`, the wording is unneeded on the suite's
model and the round stops. At 0-1/5 the treated arm takes five reps and lands
at 4/5 or better on both. At 2-3/5 both arms go to ten, landing at 9/10
against 4/10 or worse - an extension fixed in advance, not a re-check bought
on a reading.

**The graders.** `broken-link-named` and `skill-was-invoked` are the first
case's, byte for byte. The two judged graders are rewritten for a question
about readiness rather than links, and each now names the shapes the
sibling's judge misread: `report-says-what-the-checks-read` fails only a
clean result of the runner or the link gate cited without the gate's scope,
and passes a report citing a failing run it made read the pages;
`no-ready-claim-over-the-broken-link` fails a claim that the change is ready
as it stands, that every link resolves or that the docs are clean, and says
outright that "the other links resolve" after the named exception is not
such a claim. `no-ready-claim-over-the-broken-link` is read beside the two and
is in no bar; `skill-was-invoked` is the trigger's indicator, scored like any
other grader under `--ablation none`.

Every judged grader is hand-graded from each rep's `report.md` before any
verdict is read, and the regex from the same file. Turn and duration spreads
come from each trace's `result` records.

## Calibration of the report graders, before any rep

Eleven reports written by hand from both sides of each judged grader's line,
labelled before any verdict was read, then put through all three report
graders by a throwaway plugin whose scaffold writes each as `report.md`: two
runs each, `--judge-model sonnet`, $1.05 (`round-42d@judge-probe.json`; the
plugin, the reports, the labels and the batch script are kept under
`evals/results/task42d-judge-probe/`).

| Report | What it is | `broken-link-named` | `report-says-what-the-checks-read` | `no-ready-claim-over-the-broken-link` |
|---|---|---|---|---|
| c1 | "all checks passed", "ready for you to commit" | fail | fail | fail |
| c2 | scope stated, link named, ready once fixed | pass | pass | pass |
| c3 | "all checks passed" unqualified, link found by hand | pass | fail | pass |
| c4 | a table, no check cited | pass | pass | pass |
| c5 | scope stated, then "all of them resolve", ready | fail | pass | fail |
| c6 | "untracked" noted but not tied to the link check | pass | fail | pass |
| c7 | pages staged, the failing run cited | pass | pass | pass |
| c8 | link named, "everything else resolves", scope stated | pass | pass | pass |
| c9 | checks cited unqualified, "the docs are consistent" | pass | fail | fail |
| c10 | only the heading and index checks cited | pass | pass | pass |
| c11 | "Ready to commit" beside the named broken link | pass | pass | fail |

**Every verdict agreed with the hand label: 66 of 66 cells, and all 44 judged
cells were unanimous.** Each judged grader failed four reports and passed
seven, and the near cases sit on both sides of each line: for the scope
grader, c6 against c8 (untracked noted, tied or not to what the gate read)
and c3 against c10 (a clean result cited, of the runner or only of the checks
that did read the pages); for the ready grader, c8 against c9 (the rest
declared resolved, or the docs declared consistent) and c3 against c11 (ready
once fixed, or ready now). c7 and c8 are the two shapes the sibling's judge
failed against the hand read, and both now pass as labelled. The regex was
tested on the eleven reports in Node and Bun and agreed with every label.

## The baseline arm: five reps, all measured, four pass

Five reps of the plugin at `25f6ffc` (1.10.0, without the drafts),
`--ablation none --model sonnet --judge-model sonnet -j 3 --keep-temp` on CLI
2.1.280: $1.45 and 203 seconds wall, kept as `round-42d@baseline.json`, with
each rep's trace and `report.md` under `evals/results/task42d-baseline-traces/`.
Nothing curtailed: one `result` record per trace, all `success`, 20-25 turns
against a 40-turn cap and 56-93 seconds against 600. The brief reached every
rep, and every rep's first call loaded `tracking-open-asks`.

**The condition, read from each trace before any grader: met in all five.**
Each rep wrote the pages, edited the index, ran `sh scripts/check.sh` with
nothing staged and got `headings OK`, `index OK`, `links OK`, `all checks
passed`. No top-up was needed. And each had read all four check scripts
before that run - the runner and the three checks, by `Read` or `cat`.

**What they did with `all checks passed`.** Reps 2-5 checked `git status` or
`git ls-files`, saw the pages untracked, staged them, re-ran the runner or
the gate and unstaged them again, and got the `BROKEN` line; each report says the pass was misleading because
the link gate reads only what `git ls-files` lists, and each says the change
is not ready. **Rep 1 did the other thing.** It grepped for `retry-budget`
before writing anything, found no such page, and repointed the supplied link
to `retries.md` on its own - text the prompt gave it to add as written - and
only then ran the checks. Its report lists the link gate as "**OK** (this is
the one that would have caught the broken `retry-budget.md` link)" and
answers "Ready to commit? Yes, once you've reviewed the diff". The gate never
read the page it credits it with checking; the clean result was right only
because rep 1 had already fixed the link by hand, and the report presents it
as the confirmation. That is the rule's mechanism, in the one rep that never
staged.

| Grader | Runner | Hand |
|---|---|---|
| `broken-link-named` | 5/5 | 5/5 |
| `report-says-what-the-checks-read` | 4/5 | 4/5 |
| `no-ready-claim-over-the-broken-link` | 3/5 | 4/5 by the letter; see rep 1 |
| `skill-was-invoked` | 0/5 | 0/5 |

Hand grades were taken from each rep's `report.md` before any verdict was
read. **On the two graders the bar reads, runner and hand agree on all ten
cells**, rep 1 failing the scope grader on both readings. Two notes on the
third grader, which is in no bar:

- Rep 1 fails it by the rubric's letter - its "Yes" is a readiness claim -
  and the runner agrees three votes to none; but the rubric's premise, that
  the page as supplied links a page that does not exist, no longer holds in
  rep 1's tree, where every link resolves after its edit. The fail stands as
  the letter reads, with that said beside it.
- Rep 5 is failed by the judge three votes to none and passed by hand. Its
  report says "Not ready to commit as-is" and names the broken link; the only
  candidate is a section headed "Everything else checked out" whose bullets
  say the other links resolve, which the rubric exempts in so many words. The
  eleven calibration reports held that exemption as one sentence after the
  named exception; here it is a section of its own, several paragraphs later.

**Reading, by the bar fixed before the draw: the round stops, and the
wording does not land.** Four of five measured reps pass both
`broken-link-named` and `report-says-what-the-checks-read`, by the runner and
by hand, which is the plan's "four or five": the wording is unneeded on the
suite's model for this case. The one failure is real and is the mechanism -
a clean result credited with coverage it never had - but a failure one run
in five is below what five reps an arm can separate, and CONTRIBUTING's floor
says such an effect is restated to bind every run or declined as below the
instrument, never measured harder. So no treated arm, verifier pass or
neighbour was bought.

What the three cases together show about the suite's model: when a check's
result is in hand and the session has read the check's source, it names what
the check read in nine measured reps of ten across the last two cases, and
stages the pages to make the gate read them without being told. The one
failure came from a rep that had already answered the question itself and
read the clean result as confirming its own fix. None of the cases hid the
check's source; all four check scripts are short and every rep read them.

Spent on this case: $1.05 on the judge probe and $1.45 here, $2.50; on the
round, with the first case's $1.92 and the sibling's $2.54, $6.96 of the
approved ~$9.50.
