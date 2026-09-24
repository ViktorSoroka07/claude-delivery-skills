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
