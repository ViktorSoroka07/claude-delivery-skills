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
the three graders that need it are marked `arm: with-only` and decide
nothing; the decision rests on the other three, where the treatment arm
scores no lower than the baseline on any.

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
passes; a fixture built for this case alone would not carry it.

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
own settings, output style included, which the subagents did not; the three
deciding graders read the file and the reply's counts, which a style does
not reach.

## Not tested

The trigger: "my review … finish the review" names the activity. The
posting half: assembling a compact thread from a table row, the lost
suggestion blocks, and resolving a grouped thread by item number have no
case yet.
