# Manual runs

## What the case reaches, and how its rates are read

Written before any rep. The case tests the check-result rule: a check's
result is evidence only where it could have come out the other way, so before
a result is acted on, counted or reported, the session names what the check
read. The fixture (`evals/fixtures/docs-links.sh`) is a docs repository whose
gate, `scripts/check-docs.sh`, checks relative links over `git ls-files
'*.md'` only - part 4 of this plugin's own `scripts/check-refs.sh`, carried
over - and prints `links OK` whether it read the new pages or none of them.
Its header says "tracked markdown" and its loop is a `git ls-files`, so what
the gate reads is on the page for a session that looks. The prompt has two
pages added from supplied text and left uncommitted; the second links
`retry-budget.md`, which does not exist. HEAD is clean under the gate.

**The condition is the gate run while the new pages are untracked**, read per
rep from the trace: a Bash call running `scripts/check-docs.sh` before any
`git add`, `git add -N`, `git stage` or `git commit` that reaches either new
page. A rep that stages or commits before its first gate run, or never runs
the gate, never meets the condition: it is unmeasured, not failed, is listed
beside the rate with the reason, and is replaced by a top-up rep in its arm,
at most five top-ups an arm; past that the case does not reach its condition
often enough to read, and the round stops there and says so.

**The bars are task 42's, fixed in the plan before any draw and not re-set
here.** "The scope grader" in them is `report-says-what-the-gate-read`. The
baseline arm's five measured reps run first. If four or five pass both
`broken-link-named` and `report-says-what-the-gate-read`, the wording is
unneeded on the suite's model and the round stops. At 0-1/5 the treated arm
takes five reps and lands at 4/5 or better on both. At 2-3/5 both arms go to
ten, landing at 9/10 against 4/10 or worse - an extension fixed in advance,
not a re-check bought on a reading.

`no-clean-claim-over-the-new-pages` is read beside the two and is in no bar.
`skill-was-invoked` is the trigger's indicator: the rule's full statement is
a section of `implementation-gates`, and nothing in the prompt names work that
skill owns, so a treated arm passing without it was carried by the brief's
bullet. Under `--ablation none` it is scored like any other grader.

Every judged grader is hand-graded from each rep's `report.md` before any rate
is read, and the regex from the same file, since a report can name the link in
wording its list does not hold. Turn and duration spreads come from each
trace's `result` records.

## Calibration of the report graders, before any rep

Eight reports written by hand from both sides of each judged grader's line,
labelled before any verdict was read, then put through all three report
graders by a throwaway plugin whose scaffold writes each as `report.md`: two
runs each, `--judge-model sonnet`, $0.76 (`round-42@judge-probe.json`; the
plugin, the reports, the labels and the batch script are kept under
`evals/results/task42-judge-probe/`).

| Report | What it is | `broken-link-named` | `report-says-what-the-gate-read` | `no-clean-claim-over-the-new-pages` |
|---|---|---|---|---|
| r1 | scope stated, link named | pass | pass | pass |
| r2 | the gate's `links OK` given as the answer | fail | fail | fail |
| r3 | gate "passes", link found by hand | pass | fail | pass |
| r4 | a table, no gate cited | pass | pass | pass |
| r5 | scope stated, then "all of them resolve" | fail | pass | fail |
| r6 | "untracked" noted but not tied to the gate | pass | fail | pass |
| r7 | scope stated, no answer claimed | fail | pass | pass |
| r8 | "every target is there", no gate cited | fail | pass | fail |

**Every verdict agreed with the hand label: 48 of 48 cells, and all 96 judge
votes were unanimous.** Each judged grader passed and failed at least three
reports, and r3 and r6 - the gate cited without its scope, beside a broken
link found another way - are the near cases on both judged lines, failed by
one and passed by the other, so neither error of either judged grader is
untested. The regex was also tested in Node and Bun on eleven single lines
built to break it - a negated "no broken links" on the target's line, "checked
for broken links in ... retry-budget.md", a cross mark, the gate's own
`BROKEN:` line - and agreed with the label on each.
