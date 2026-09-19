# Manual runs

Historical scores: each table below is from the fixture as it stood when that
table was taken. `evals/fixtures/refund-console.sh` has changed since the
first of them, in 5ea7fb1, 2500ef5, 83cfc92, a2797d0 and 2b592bf; a table is a
baseline for the current fixture only where none of those commits is later
than it.

Fixtures from `evals/fixtures/refund-console.sh record-offplan`, verified
identical by tree hash; fresh Sonnet subagents loading the installed skill
through the Skill tool; the eval prompt verbatim; graded on the findings file
each run left in the fixture tree. The baseline arm is produced by swapping
the live `SKILL.md` to the pre-change text for the duration of the arm.

## The disclosed-survivor rule (the record's fourth, SURVIVED row)

The question: does a sentence telling the reviewer that a survived row is the
author's disclosed gap, not a contradicted claim, change what the weaker
model files? Graded by `keeps-the-disclosed-gap-unflagged`.

| Arm | Reps with a findings file | Kept the survivor unflagged |
|---|---|---|
| Baseline (pre-change text), hand runs | 5 of 5 | 5 of 5 |
| Baseline, runner | 1 usable of 5 | 1 of 1 |
| Treatment (the sentence), runner | 3 usable of 5 | 3 of 3 |

Baseline reps re-applied the title mutation, saw it survive, and called the
row accurately disclosed (two reps), filed the missing title assertion as a
test gap (one rep, which the rubric allows), or did not mention it (two
reps). Not one reported it as evidence against the record. The sentence was
declined; `BACKLOG.md` carries the line.

Runner reps that wrote no findings file died on git inside the eval sandbox
(Apple's git shim cannot write its cache file there); the hand procedure is
the instrument on this machine until a non-Apple git is first on the path.

One runner baseline rep flagged the fourth finding on a real fixture defect
that has since been fixed: the base file already built the title from the
batch id, so the branch made no fix the record could claim. The record's
header was likewise corrected to match its body. Both defects handed the
runner's judge a genuine "contradicted" hook unrelated to the rule, which is
why every runner verdict on this grader was read against the findings file
by hand.

## The other three graders

| Grader | Treatment |
|---|---|
| findings-file-written | 5/5 |
| flags-the-contradicted-claim | 5/5 |
| keeps-the-true-rows-unflagged | 5/5 |

From the five hand runs on the earlier fixture (three killed rows, no
survivor): every run wrote the findings file, re-applied the record's
mutations against the pinned head, and reported the catch-arm claim as not
holding — the suite stays green with the arm removed because the only test
resolves its fetch — as a Major or Medium finding. Every run dispatched the
fresh-eyes verifier for Pass 2 because Pass 1 held a major finding.

Observed in the baseline hand runs, not graded: one rep sampled two of the
four rows and missed the contradicted one, since the text asks for a sample
of two or three rows without saying how to draw it.

## The sampling rule: the mechanism is real and this case cannot measure it

The question: the record audit re-applies "2-3 of the recorded mutations"
without saying how to draw them, so does a sentence telling the reviewer how
to draw the sample change what a rep finds? Graded by
`flags-the-contradicted-claim`, with the case's other three graders watched.

Eleven fresh headless Sonnet sessions, one fixture each, the eval prompt
verbatim, graded on the findings file each left in the tree and on its own
tool calls. One rep is not in the arm (below); ten are.

| Grader | Baseline, ten usable reps |
|---|---|
| findings-file-written | 10/10 |
| flags-the-contradicted-claim | 9/10 |
| keeps-the-disclosed-gap-unflagged | 10/10 |
| keeps-the-true-rows-unflagged | 10/10 |

**No wording was written and the treatment arm was not run.** The one failure
is the entry's own mechanism, read from its Bash calls rather than its
findings file: it re-applied the record's first, second and fourth mutations -
the section swap, `rows = []`, the title constant - and not the third, the
catch arm, then spent its next mutation on a fresh one of its own
(`fetchRequests(batch.id)` to a hardcoded id). Its sample of three from four
skipped exactly the row the tree contradicts, and its findings file carries no
finding about the record at all. The draw is the defect the entry names.

The other nine all reported the third claim as false against a green suite.
Eight of them re-applied all four recorded mutations and the ninth three of
the four; seven state in the findings file that the other rows reproduce
exactly as recorded, and five had the Pass 2 verifier re-run the whole record
independently rather than trust the draft's citation. That comparison across
the record is what a sampling rule would have to produce, and they produce it
unaided.

**The rate is the problem, and its cause is the fixture.** The record holds
four rows, so "2-3 of the recorded mutations" is already nearly exhaustive and
the discretion the entry is about barely bites: re-applying all four costs
four suite runs on a suite of three tests. One rep in ten is below what this
instrument resolves - five reps are sized for a one-in-three defect, and ten
treatment reps could only have shown 9/10 against 10/10, the one-rep margin
the inline case already refused to call a result. Twenty reps an arm would
cost about forty dollars to settle a sentence.

So the entry is neither landed nor declined by this round. What it needs
first is a record long enough that a sample of two or three is a real sample -
eight to ten rows, the contradicted one not in the opening three - on a
fixture variant of its own, so the four-row record the other graders are
written against stays as it is. The wording drafted for this round, kept here
so the next attempt is not designed twice: re-apply the recorded mutations one
at a time, all of them where the record holds five or fewer and above that a
draw spread across the record rather than its opening entries, because nothing
in the record marks which of its claims the tree contradicts and a fresh
mutation elsewhere cannot contradict a claim it never applied.

Cost: $10.93 for eleven reps, $0.99 a rep, in three batches of 1, 5 and 5.

### The instrument, from this round

**The prompt's "the review skill" now reaches the harness's own built-in
review skill.** One rep of eleven loaded that instead of `review-pr`, then
searched the filesystem for where a findings file goes and read two ranges of
`skills/review-pr/SKILL.md` out of the plugin clone by hand - not the
record-audit paragraph. It wrote a findings file and would have graded 4/4,
which is the danger: nothing in the tree says the skill under test never
loaded. Such a rep is unusable rather than a fail, like a run the sandbox
kills, and this round topped up to ten graded reps instead of counting it.
Earlier hand rounds on this case ran as subagents, where the built-in does not
compete, which is why this is new. Confirm the Skill call in every transcript
before grading a rep of this case.

## Not tested

The trigger, as in every hand run: the prompt names "the review skill" -
and see the instrument note above for what else answers to that.

## The prompt names the findings file, and a grader records which skill fired

Two defects, one edit each.

**"The findings file the review skill writes" summoned the wrong skill.** The
harness's own built-in review skill answers to that phrase, and the rep above
that loaded it would have graded a full pass on a run where the skill under
test never fired. Naming the plugin's skill in the prompt would remove the
trigger from what the case measures, which is the one thing a named brief
cannot test. The phrase is gone instead — the prompt now names the output path
and says nothing about which skill writes it — and a `tool_used: Skill` grader
marked `arm: with-only` records whether the Skill call for the skill under test
happened. It scores in neither arm and is never evaluated in the arm without
the plugin, so it cannot throw there; it is read as a condition on the row
beside it, and a plugin-arm run with it dark is unusable rather than a fail.

**Three graders could not resolve in the unaided arm.** Their `focus` is the
literal `review-findings-feature-mount-table.md`, and across the release
baseline each threw in four unaided runs, which scores as a behaviour failure.
The prompt now names that path — the name the skill's own convention produces
for this branch, so the plugin arm is unchanged — and `findings-file-written`
is pinned to it rather than to a glob, so the file grader and the three focus
graders agree about where the findings are.

### Runner pass at the named path — one run per arm

| Grader | No plugin | Plugin |
|---|---|---|
| findings-file-written | 1/1 | 1/1 |
| flags-the-contradicted-claim | 1/1 | 1/1 |
| keeps-the-disclosed-gap-unflagged | 0/1 | 0/1 |
| keeps-the-true-rows-unflagged | 0/1 | 1/1 |
| skill-was-invoked (indicator) | not evaluated | 1/1 |

$1.30. Nothing threw: both arms wrote the findings file at the path the prompt
names, so the three focus graders that failed four unaided runs each in the
release baseline — on a file that did not exist — now return verdicts. The
indicator confirms the plugin arm loaded the skill under test rather than the
built-in that answers to the same request.

`keeps-the-disclosed-gap-unflagged` fails in both arms here. One run an arm
says nothing about whether that is behaviour or the judge; the case's own
verdicts are worth reading only from a run given a judge that can hold the
findings file, for the reason measured on the delegation case's rubric and
written into CONTRIBUTING.

## The fixture variant a sampling round needs (`record-offplan-long`)

Built and verified; no round has been run on it. The four-row record cannot
measure a sampling rule, for the reason the section above gives, so
`evals/fixtures/refund-console.sh record-offplan-long` carries a nine-row
record over a longer branch: the branch holds the whole results region the
tracker defers to task 102 - a status filter, a page label reconciled against
the server's `totalCount`, and the error path around the fetch - so every
finding names a file the branch changes rather than one it never touched,
which is what a record of this length costs.

Eight rows claim confirmation by mutation and the sixth of those is the row
the tree contradicts: the same catch-arm claim the four-row record ends on,
kept because ten reps have already shown it is reported when a reviewer
reaches it, now sitting outside the opening three. The ninth row is the
disclosed survivor. A draw of two or three from nine can miss the
contradiction; a draw from four cannot, which is the whole reason the entry
could not be measured here.

Each row was checked by applying its mutation to the built fixture and running
the suite: the seven true rows each fail exactly the test the record names,
the sixth leaves all nine tests green, and the ninth survives. The suite is
green at the branch tip with nine tests, which is what the record's header
claims - the header and the body agree, and no finding names a file outside
the branch's diff, so the fixture carries the one defect.

**The tables above are not stale.** The commit that added the variant touches
`evals/fixtures/refund-console.sh`, which the note at the top of this file
would otherwise read as a fixture change. The seven existing variants build to
identical trees before and after it, compared by `git rev-parse HEAD^{tree}`
on each build: only a new `$2` value was added. The rows above stand.

**What a round on it still needs.** A case of its own: this case's other three
graders are written against the four-row record, and its rows were re-taken
only after the prompt and grader fixes above. That is a prompt naming the
findings path, the four graders restated against the nine-row record, and the
wording drafted above as the treatment arm. At the $0.99 a rep this case
costs, five reps an arm is about $10; a case added to the suite also costs
about $2.50 in every later full baseline, which is why the case is the
owner's call rather than this session's.
