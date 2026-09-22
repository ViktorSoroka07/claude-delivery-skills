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

## Rebuilt as regex graders

`packing-obeys-its-limits` is retired. Five regex graders over the same file
replace it, one for each row a correct packing must have and one for the row it
must not:

| Grader | Reads |
|---|---|
| `packing-docs-minors-in-one-row` | a Minor row anchored in `docs/retry.md`, `docs/cli.md` or `docs/faq.md` |
| `packing-docs-medium-alone` | a Medium row anchored at `docs/retry.md:7` |
| `packing-uncapped-delay-alone` | a Medium row anchored at `src/http/retry.js:18` |
| `packing-final-wait-alone` | a Minor row anchored at `src/cli/sync.js:10` |
| `packing-docs-minors-not-spread` | no second Minor row anchored in a docs file |

Each reads the grade cell and the anchor cell of a row in the column order the
skill prescribes (thread title, grade, members, anchor) and leaves the members
cell alone, which is the cell the judge could not read: the merge renumbers the
findings in every run and some runs fold the two `docs/retry.md` minors into one
grouped finding, so one correct packing writes `F3 (items 1-2), F4, F5` there,
another `N1 (D1, D2), N2 (D3), N3 (D4)` and a third `3, 4, 5, 6`. The grades are
identical across every run, and the anchors are fixed wherever the row has one
member.

The four failure modes the retired rubric named each take away one of those five
checks, which is what makes the family sufficient without reading the members:
the docs medium packed with the minors takes away the Medium row at
`docs/retry.md:7`; the final-attempt wait riding in the docs row takes away the
Minor row at `src/cli/sync.js:10`; the two mediums sharing a row takes away one
of the two Medium rows; and the four docs minors spread over more than one row
adds a second Minor docs row.

### What the runner's first pass corrected

The family was first written with the docs row pinned to `docs/retry.md:3`, the
anchor all three kept baseline files use, and the spread read as a row anchored
in `docs/cli.md` or `docs/faq.md`. Three runs through the runner scored that
1/3: two of them packed the four docs minors correctly into one Minor row and
anchored it at `docs/retry.md:5`, one of the two naming the member it took the
anchor from. A row's anchor is one of its members' and which member is the run's
choice, so both the pinned line and the pinned file were the grader's assumption
rather than the rule's.

Both graders were rewritten around that: the docs row may be anchored at any
line of any of the three docs files, and the spread is read as *two* Minor rows
anchored in a docs file rather than as one row anchored in a particular file.
The new shape also catches a split the first one could not see at all - the four
minors in two rows both anchored inside `docs/retry.md`.

A regex grader keeps no `evidence` in the run JSON, only the pattern and
"pattern not found in file". The findings file of a failing run is reachable
anyway: the case's `llm` graders focus on the same file, and their evidence is
that file.

### Tested on every file kept, and on eleven written by hand

The three findings files the release baseline kept as the retired grader's
`evidence` - the three the judge failed three votes to none, and which pack
correctly by hand - score 5/5, as do the three from the runner pass above. The
hand-written files are built from one of them, one per case:

| Hand-written file | Result |
|---|---|
| the docs medium packed into the minors' row | fails `packing-docs-medium-alone`, and only that |
| the final-attempt wait in the docs row | fails `packing-final-wait-alone`, and only that |
| the two mediums sharing a row | fails `packing-uncapped-delay-alone`, and only that |
| the docs minors spread over three rows | fails `packing-docs-minors-not-spread`, and only that |
| the docs minors split into two rows inside `docs/retry.md` | fails `packing-docs-minors-not-spread`, and only that |
| no packing table at all | fails the four row graders; the spread grader passes |
| bold grades, anchors without backticks | passes 5/5 |
| an anchor cell reading `src/http/retry.js:18 (retryDelayFor)` | passes 5/5 |
| an anchor cell listing all four members' anchors behind its own | passes 5/5 |
| the docs row anchored at `docs/cli.md:5` | passes 5/5 |
| a single-member row anchored at `:30` where the finding is at `:3` | fails that row's grader |

The last four set the tolerance of the anchor cell. It has to open with the
anchor and may carry anything after it, so a parenthetical or a list of the
members' own anchors passes; and where a row has one member the line number has
to end where the anchor does, so `:30` is not `:3`. The grade cell is the strict
one: it holds the grade alone, since a cell naming two grades is the mixed row
compact forbids.

A file with no table fails the four row graders and passes the spread grader,
which is right and is why `packing-table-written` - not this family - carries
the question of whether a table was written at all. All five keep the
`with-only` mark the retired grader had, for the reason the first runner section
gives.

### The corrected family through the runner

Three runs per arm at the graders as they stand, the runner's own arms:

| Grader | No plugin | Plugin |
|---|---|---|
| packing-docs-minors-in-one-row (with-only) | | 3/3 |
| packing-docs-medium-alone (with-only) | | 3/3 |
| packing-uncapped-delay-alone (with-only) | | 3/3 |
| packing-final-wait-alone (with-only) | | 3/3 |
| packing-docs-minors-not-spread (with-only) | | 3/3 |
| packing-table-written | 1/3 | 3/3 |
| refuted-draft-dropped | 3/3 | 3/3 |
| default-list-kept-whole | 2/3 | 3/3 |
| report-counts-both-ways (with-only) | | 3/3 |
| report-keeps-the-bodies-out | 1/3 | 1/3 |

The five read the packing without a judge and without a hand grade, which is
what the rebuild was for. The two rows that move are the judge's own and are
older than this change: `default-list-kept-whole` and
`report-keeps-the-bodies-out` split their votes on a long file and on a reply's
tone, the same in both arms.


## Not tested

The trigger: "my review … finish the review" names the activity. The
posting half: assembling a compact thread from a table row, the lost
suggestion blocks, and resolving a grouped thread by item number have no
case yet.

## The re-take under the staged git, and what it found instead (task 44)

Three reps an arm, `--ablation with-without --model sonnet --judge-model sonnet
--runs 3 -j 2 --keep-temp`, plugin 1.10.0 on CLI 2.1.278, kept as
`round-44@packing.json`. $3.17 and 382 seconds. Bought because kept traces of
this case showed the sandbox's broken git, and any rate a git act touches was a
floor until that was staged.

**It changed nothing here, and the judge change that rode with it changed three
rows to zero.** The nearest kept arm, `task9-packing-regex-graders-2.json`, ran
on the default judge, so these rows differ in two things at once and the hand
grade is the arbiter:

| Grader | Old, default judge | New, sonnet judge | Hand, new |
|---|---|---|---|
| `packing-table-written` | 3/3 | **0/3** | **3/3** |
| `report-counts-both-ways` | 3/3 | **0/3** | **3/3** |
| `report-keeps-the-bodies-out` | 1/3 | **0/3** | **2/3** |
| `packing-docs-minors-in-one-row` | 3/3 | 2/3 | 2/3, mechanical |
| the other six | unchanged | unchanged | - |

All three reps wrote the packing table the case is named for - thread title,
grade, members, anchor, the four docs minors in one row - and all three gave
both thread counts and named the compact form as an ask. No trace shows the git
stub. So the behaviour is where it was and **three of this case's four judged
graders now fail work that satisfies their own pass clauses.**

**Two causes, one of them a defect in the graders.** `packing-table-written`
focuses a file of 6.8-9.2k characters, and the runner itself prints "long file;
llm judges are noisy on long inputs, prefer a regex grader for large artifacts"
on two of the three reps. `report-counts-both-ways` is worse than noisy: its
preamble says the report "does not restate the findings", while its sibling
`report-keeps-the-bodies-out` says in as many words that an index line **may**
carry a finding's title, grade, id and anchor. Every rep writes such an index.
A judge reading the preamble as a condition fails all three, and the pass
clause below it - both counts as numbers, and the reader told they can ask for
the compact form - is met by all three. Two graders of one case contradict each
other, and the weaker judge hid it.

**Nothing here is landed on that reading.** The rows above are the record; the
graders are unchanged, and repairing them is an instrument change that belongs
to whoever takes it, with the kept evidence in `round-44@packing.json` enough
to re-score by judging the same files again for cents.

### The repair, and what it did not fix

The contradiction is gone from `report-counts-both-ways`: its preamble no
longer forbids what `report-keeps-the-bodies-out` allows, and its fail clause
now names both of the conditions its pass clause states, which it did not.

**Tested before landing, on the kept messages rather than on fresh reps.** A
throwaway plugin outside the repo, both wordings as twelve `llm` graders over
the same six files - the three plugin-arm messages this round kept, which a
hand read passes, and the three no-plugin messages, which give no compact
thread count at all and a hand read fails. Both rubrics judged in one run,
`--judge-model sonnet`, three reps, $0.49. The hand labels were written before
the run.

| File | Hand | Old rubric | Repaired |
|---|---|---|---|
| w1 | pass | 0/3 | 0/3 |
| w2 | pass | 0/3 | 0/3 |
| w3 | pass | 0/3 | **3/3** |
| n1, n2, n3 | fail | 0/3 each | 0/3 each |

**So the contradiction was real and was not the whole cause.** One of the three
passes recovers; two do not, and the negative control holds under both
wordings, so the repair is not a rubric that accepts everything.

**What separated w3 from w1 and w2 was the second condition, and the skill
settled it.** `skills/review-pr/SKILL.md` asks to "name the applicable modes in
the closing message, in one line - not a menu, and only what the user could
sensibly want next. After a review that is post, post compact, apply, or a
deeper pass." Naming `post compact` among the modes is therefore the behaviour
the case exists to measure, and w1 and w2 do exactly that; w3's extra "if you
want fewer threads later" is more than the skill asks for. A rubric on the
strict reading would have failed runs for following the skill correctly.

A third wording says so in as many words, and was tested the same way over the
same six files, alongside both earlier ones:

| File | Hand | Original | First repair | Landed wording |
|---|---|---|---|---|
| w1 | pass | 0/3 | 0/3 | **3/3** |
| w2 | pass | 0/3 | 0/3 | **3/3** |
| w3 | pass | 0/3 | 1/3 | **3/3** |
| n1, n2, n3 | fail | 0/3 | 0/3 | 0/3 |

Agreement with the hand labels: 3/6, 3/6, **6/6**. The negative control holds
under all three, so the landed wording is not one that accepts anything. Note
also that the first repair scored w3 3/3 in one invocation and 1/3 in the next,
on the same file and judge - judge variance between invocations, which is a
reason to read a cell of three reps as a cell rather than a number.

**What was contested, for the record.** All three name `post compact` among the modes the reader may ask
for; only w3 also says a compact table is recorded "if you want fewer threads
later". One reading of "tells the reader they can ask for the compact form" is
satisfied by naming the mode - that is the hand label above - and the other
wants the option offered in so many words. Two careful readings differed, which by
`evals/judge-calibration.md` measures the rubric rather than the judge - and
the rubric is owed a wording, not the judge a verdict. The owner, asked which
reading the case means, said they did not know and to take the costlier one.
The skill answers it the other way, and the skill is what a grader must
measure: the strict reading would fail a run for naming the modes in one line
and not padding it, which is what the skill asks for in as many words. That is
why the landed wording is the lenient one, with the skill quoted beside it.
