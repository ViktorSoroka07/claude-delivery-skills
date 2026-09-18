# Manual runs

Fixtures from `evals/fixtures/ledger-sync.sh merge-findings`, five Sonnet
runs per arm, the eval prompt verbatim, graded on the `review-findings-7.md`
each run left behind and on the reply. The treatment arm is the compact
paragraph in review-pr's grouping section with its posting-reference half;
the baseline arm is both files as they stood before it.

| Grader | Baseline | Treatment |
|---|---|---|
| default-list-kept-whole | 5/5 | 5/5 |
| refuted-draft-dropped | 5/5 | 5/5 |
| report-keeps-the-bodies-out | 3/5 | 4/5 |
| packing-table-written (with-only) | 0/5 | 5/5 |
| packing-obeys-its-limits (with-only) | 0/5 | 5/5 |
| report-counts-both-ways (with-only) | 0/5 | 5/5 |

Nobody asked for fewer threads, and every treatment run wrote the packing
table beside the default list: the four docs minors in one row across three
files, the docs medium alone, the other medium and the other minor alone.
No row mixed grades. Every treatment reply gave both thread counts and
named "post compact" as an ask. The baseline cannot produce the table, so
the three graders that need it were marked `arm: with-only` and decided
nothing; the decision rested on the other three, where the treatment arm
scores no lower than the baseline on any. That left the runner's two-arm
score blind to the rule: with all three marked, deleting the compact
paragraph moved no scored number. `packing-table-written` is unmarked since,
so the behaviour the case is named for is scored in both arms and the
no-plugin arm failing it is the baseline; the two graders that presuppose
the table stay marked.

The misses on report-keeps-the-bodies-out are the same in both arms and
older than this rule: a reply that gives each finding a sentence of its
Problem where the skill asks for title and grade. One baseline reply also
miscounted the confirmed drafts. Both arms wrote a line saying the refuted
draft was dropped, some under a heading of its own; the grader's wording
was tightened after the run to say that such a line is a record, not a
finding.

One treatment run re-checked the fixture's resolved thread, found its rename
unmade, added it as a ninth finding and packed it in a row of its own. That
is the skill's dedupe step working on a defect the shared fixture carries
for another case, and the graders judge by what each finding says, so it
passes. The `merge-findings` variant has since made that rename, so the
resolved thread no longer hands a run a ninth finding.

## How the arms were produced

The treatment arm ran as subagents of the authoring session. The baseline
arm could not: a session's Skill tool serves the text it loaded when the
session started, so swapping the file on disk changes nothing for its
subagents. Five runs dispatched that way loaded the new text, wrote the
table, and were discarded as a baseline (as treatment runs they agree with
the five above on every grader but one reply that restated bodies). The
baseline that counts ran as five fresh headless sessions started while the
two files held the earlier text; each transcript shows the skill loaded and
the compact paragraph absent. The headless sessions ran under the author's
own settings, output style included, which the subagents did not. The two
deciding graders that read the file are out of a style's reach.
`report-keeps-the-bodies-out` is not: it fails a reply for retelling a
finding's Problem in prose, which is what an explanatory style adds, and the
style ran in the baseline arm only. Its 3/5 against 4/5 is therefore
confounded in the treatment's favour and carries no weight; "no lower than
the baseline" rests on the two file graders.

## The same case through the runner

One run of `claude plugin eval` on this case alone, five runs per arm, the
runner's own arms (the plugin, and no plugin at all), its default judge. All
ten runs completed and wrote the findings file.

| Grader | No plugin | Plugin |
|---|---|---|
| packing-table-written (with-only) | | 5/5 |
| packing-obeys-its-limits (with-only) | | 4/5 |
| report-counts-both-ways (with-only) | | 4/5 |
| refuted-draft-dropped | 5/5 | 5/5 |
| default-list-kept-whole | 3/5 | 3/5 |
| report-keeps-the-bodies-out | 0/5 | 1/5 |

Where the rubric names something a reader can point at, the judge agrees
with the hand grades. On the two rubrics that ask it to weigh a whole
findings file or the tone of a reply it is far stricter than the hand
grades, the same in both arms, and its three votes split on some runs; the
runner itself warns that a judge is unreliable on a file this long.

## Through the runner again, on the narrowed rubrics

The two rubrics were narrowed straight after that run: the file rubrics to
the part after the fixture's Pass 2 section, the reply rubric to what a
one-line index may carry (a title, a grade, an anchor) and what it may not.
`packing-table-written` lost its `with-only` mark, and the fixture's
resolved thread has its rename made. Three runs per arm on that state:

| Grader | No plugin | Plugin |
|---|---|---|
| packing-table-written | 0/3 | 3/3 |
| default-list-kept-whole | 3/3 | 3/3 |
| refuted-draft-dropped | 3/3 | 3/3 |
| report-keeps-the-bodies-out | 0/3 | 3/3 |
| report-counts-both-ways (with-only) | | 3/3 |
| packing-obeys-its-limits (with-only) | | 0/3 by the judge, 3/3 by hand |

The narrowing did what it was for: the two rubrics the judge had scored at
3/5 and at 0/5 and 1/5 now read 3/3 where a hand grade agrees, and the case
has a scored row that goes to 0/3 when the plugin is absent. No run raised a
ninth finding.

`packing-obeys-its-limits` is the exception. The runner keeps each run's
findings file as the grader's evidence, and all three plugin files pack
correctly: one Minor row anchored at `docs/retry.md:3` holding the four docs
minors, and the docs medium, the uncapped delay and the final-attempt wait
in a row each. The merge renumbered the findings in every run, and two runs
folded the two minors on `docs/retry.md` into one grouped finding, so the
row's members read "F3 (items 1–2), F4, F5" or "3, 4, 5, 6" where the rubric
names D1 to D4. The judge failed all three, three votes to none, on files of
about nine thousand characters, with the runner's long-file warning on each.
The rubric already says findings may be renumbered; that sentence does not
carry a small judge through it. The grader is marked `with-only`, so no
score moves on it, but its runner verdict means nothing as it stands: the
rows' grades and anchors are regular enough for regex graders, which is what
the runner's warning recommends.

## Not tested

The trigger: "my review … finish the review" names the activity. The
posting half: assembling a compact thread from a table row, the lost
suggestion blocks, and resolving a grouped thread by item number have no
case yet.
