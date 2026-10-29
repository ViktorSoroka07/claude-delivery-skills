# Manual runs

Fixtures from `evals/fixtures/export-cli.sh`, fresh headless Sonnet sessions,
five per arm. The baseline arm is the skill and the session brief before the
rule; the treatment arm has the section in the skill and its pointer in the
brief. No run in either arm loaded the skill: the rule reached the sessions
through the brief alone, which is why it has a line there.

## Two turns: the situation the rule is for

Turn one asks for the plan's two blocked items and tells the session to ask
rather than guess; every session in both arms asked its two questions and
stopped. Turn two, in the same session: "I will come back to those", then an
unrelated rename. Graded on turn two's reply.

| Turn two's reply | Baseline | Treatment |
|---|---|---|
| closes with both questions restated | 0/5 | 5/5 |
| says what each blocks | 0/5 | 2/5 |
| says what happens without an answer | 0/5 | 0/5 |
| rename done in the script and the README | 5/5 | 5/5 |

Every baseline reply reported the rename and ended; the two questions asked
one message earlier are nowhere in it. Every treatment reply ended with both
questions, worded so they can be answered from that message alone. The
consequence columns did not carry over: sessions that gave them in turn one
dropped them in turn two. The rule binds on restating and not yet on the
consequence.

The runner has no second turn, so this table is a hand result only:
`claude -p` for turn one, `claude -p --resume <session id>` for turn two. The
two prompts were not kept word for word; the paragraph above is what they
said, and a repeat starts from it.

## One turn, with the requester's acknowledgement: the limit

The prompt first committed compressed the situation into one message and had
the requester say they know about the two questions and will get to them:
"Picking this back up. I know you asked me two things last time, the column
order and the old branch; they're written down in
`docs/plans/export-columns.md` and I still haven't decided, I'll get to them.
Meanwhile, two things: rename the `--dry` flag to `--dry-run` everywhere it
appears, and set the version for the release. Don't commit, I'll look at the
diff."

| Grader | Baseline | First wording | Restated wording |
|---|---|---|---|
| closes-with-every-waiting-item | 0/5 | 2/5 | 2/5 |
| says-what-each-blocks-and-the-default | 0/5 | 2/5 | 2/5 |
| rename-done-in-the-script | 5/5 | 5/5 | 5/5 |
| rename-done-in-both-places (the README; now rename-done-in-the-readme) | 5/5 | 5/5 | 5/5 |
| done-work-reported-with-evidence | 5/5 | 4/5 | 4/5 |

The restated wording says an acknowledgement is not an answer and that a
reference is not the list; it moved nothing. Where the requester has said in
the same message that they know, three sessions in five still close with
"still waiting on you: the column order and the old branch" and no
questions. Under that prompt the case fails in the treatment arm by design,
and the table measures the limit, not the rule: a case at 2/5 with the rule
in place cannot go red when the rule regresses.

The restated wording was measured in the brief, the only copy a session
read, and is cut from it: it moved nothing and every session start paid for
it. The skill keeps the same two clauses, since they state a boundary of its
own rule and no run loaded the skill to test them either way.

The done-work misses are in the two treatment columns alone, one session
each, which asked which version to set instead of setting it; the baseline
has none. A rule about asking can induce exactly that, and one run in five
is also within what five reps cannot tell from noise. No transcript line
was recorded that settles which; the grader is scored in every later run of
the case.

## One turn: the committed prompt since

The committed prompt no longer has the requester acknowledge the two
questions: it names the plan file, which records both as asked with no
answer yet, and asks for the rename and the version. The rubrics changed
with it: the second fails a reply that gives what an item blocks without
what happens if no answer comes, which the two-turn table shows is the
common shape, and the script's rename is read as the new flag present and
the old flag absent anywhere in the file, whatever the quoting. No hand run
has been made on this prompt. One run through the runner, three runs per
arm, the runner's own arms (no plugin, the plugin) and its default judge:

| Grader | No plugin | Plugin |
|---|---|---|
| closes-with-every-waiting-item | 0/3 | 2/3 |
| says-what-each-blocks-and-the-default | 0/3 | 0/3 |
| done-work-reported-with-evidence | 3/3 | 2/3 |
| rename-done-in-the-script | 3/3 | 3/3 |
| no-old-flag-left-in-the-script | 3/3 | 3/3 |
| rename-done-in-the-readme | 3/3 | 3/3 |

Without the acknowledgement the case separates the arms on restating: no
reply without the plugin carries the two questions, and two of three with it
close on both, worded to be answered from that message alone. The
consequence rubric fails every run in both arms. One plugin reply says what
each item blocks and none says what happens if no answer comes, which is
what the two-turn table found: the rule binds on restating and not on the
default.

The third plugin run is the done-work miss with its transcript line this
time. It did the rename, then wrote "I don't want to guess the target" and
made the version its first waiting item ("What version should `VERSION` be
set to? ... I won't guess a semver bump"), where the changelog names the
next version and every no-plugin run set it; it also dropped the
`tmp-migrate` question. Counted with the hand runs above that is three
plugin-side sessions in thirteen asking instead of doing, against none in
eight without the rule. That reads as a cost of the rule, a session told to
keep a list of questions finding one more to ask, more than as noise.

The fixture's first draft planted the release version as a third waiting
item. The changelog already names the next version, every baseline session
set it without asking, and the graders were rewritten around the two items
that do wait.

## A condition the requester only has to keep holding

Seen in use: a session that had started an hour-long run whose safe end
depended on the requester keeping an app closed put "keep it closed" into
the waiting table of every later message, and the requester could not tell
whether the list wanted an answer. Two turns on the same fixture with a soak
script added whose header says the metrics dashboard must stay closed while
it runs: turn one starts the soak and asks what to know about it; turn two
asks for the rename. Five fresh headless sessions per arm on two models,
graded on turn two's reply by hand. The baseline is the brief and skill as
they stand; three wordings were tried, each a bullet in the skill's section
on what waits and a sentence in the brief's core.

| Turn two | Sonnet, baseline | Sonnet, w1 | Sonnet, w2 | Sonnet, w3 | Strong, baseline | Strong, w1 | Strong, w2 | Strong, w3 |
|---|---|---|---|---|---|---|---|---|
| condition kept out of the waiting list | 5/5, 5/5 | 5/5 | 5/5 | 5/5 | 1/5, 1/5 | 5/5 | 5/5 | 5/5 |
| condition not repeated at all | 4/5, 4/5 | 5/5 | 1/5 | 0/5 | 0/5, 0/5 | 4/5 | 2/5 | 3/5 |
| both open questions restated | 4/5, 3/5 | 2/5 | 4/5 | 4/5 | 5/5, 5/5 | 3/5 | 3/5 | 5/5 |

Two baselines per model because the first fixture's soak slept four minutes
under a header that said an hour, and seven of ten sessions read the code
and said so; the second fixture sleeps the hour. The baseline fails on the
strong model alone: eight of ten of its sessions put the condition into the
numbered table as an item to answer, where no Sonnet session did. Wording 1
("said once and never listed") emptied the list on two strong sessions and
two Sonnet ones. Wording 2 ("the list holds what needs a reply or an act; a
condition ... is said once in the body ... and is not an item") kept the
list on Sonnet but had four of five say the condition again in the body, and
two strong sessions closed with "nothing waits on you except reviewing the
diff" over two open owner questions. Restating fell from five of five to
three of five on the strong model under both wordings; a rule that loses a
neighbouring grader is not landed. Wording 3 left the list sentence alone
and described the condition's own output ("one sentence in the body of the
message that starts it, with when it ends, mentioned again only when its
state changes; the table is unchanged by it"): the strong model kept its
restating at five of five and stopped listing the condition, but every
Sonnet session now repeated it in the body as a reminder, where four of five
baseline sessions had said nothing, so the rule induced the behaviour it
exists to stop, in a milder form. Three wordings, three different costs; the
entry is in `BACKLOG.md` under Declined with this reason.

## Not tested

The items' exit: that an answered item leaves the list, and that one
proceeded on its default is said to have been.

## The re-take under the staged git (task 44)

Five reps, `--ablation none --model sonnet --judge-model sonnet --runs 5 -j 3
--keep-temp`, plugin 1.10.0 on CLI 2.1.278, kept as
`round-44@closes-with-what-waits.json`. $1.14 and 92 seconds. Bought because
two kept traces of this case showed the sandbox's broken git; no trace in this
arm shows it.

| Grader | Sibling control, 3 reps | Re-take, 5 reps | Hand |
|---|---|---|---|
| `closes-with-every-waiting-item` | 1/3 | 2/5 | **3/5** |
| `done-work-reported-with-evidence` | 3/3 | 3/5 | 3/5 |
| `no-old-flag-left-in-the-script` | 3/3 | 5/5 | 5/5 |
| `rename-done-in-the-readme` | 3/3 | 5/5 | 5/5 |
| `rename-done-in-the-script` | 3/3 | 5/5 | 5/5 |
| `says-what-each-blocks-and-the-default` | 1/3 | **0/5** | **0/5** |
| `skill-was-invoked` | 0/3 | 0/5 | 0/5, as expected |

**The git staging moved nothing measurable here either.** The mechanical three
are clean sweeps, as before. The judge and the hand disagree on one rep of
`closes-with-every-waiting-item`: rep 2 closes with "Two open items carried
over from the plan, both waiting on the same owner", numbered, both restated as
questions, which the rubric passes; the judge failed it, possibly on the
paragraph about the column order that sits above the list.

**`says-what-each-blocks-and-the-default` is 0/5 and the hand agrees on every
rep**, which settles what this record already suspected about the consequence
columns: no run in either arm has passed them. Rep 4 is the closest - a table
with "Blocks" and "If unanswered" columns - and its "if unanswered" cell for
the column-order item gives a risk of proceeding rather than what happens to
the work, which is what the rubric asks for. The 1/3 in the sibling control was
the outlier, not the rule.

## The first-tool-call line: the round that landed it (task 48, 48b)

This case is the round for the brief line landed at `59bde35`, which makes a
conversation's first tool call the Skill tool with `tracking-open-asks`. The
treated arm is task 48's probe, `round-48@first-tool-call.json`: five reps,
`--ablation none --model sonnet --judge-model sonnet -j 3 --keep-temp`, CLI
2.1.280, $0.97. The comparison is the re-take above, on CLI 2.1.278. The
probe's wording carried a second, conditional half - load
`writing-for-audiences` the same way where the work ends in a report - which
loaded that skill in none of ten reps across its arms; the landed line is the
unconditional half alone, so it drops a clause no rep acted on. Each treated
rep was confirmed to carry the line from its trace's `SessionStart` output.

| Grader | Brief alone (re-take), judge | Hand | First-tool-call line, judge | Hand |
|---|---|---|---|---|
| `closes-with-every-waiting-item` | 2/5 | 3/5 | 3/5 | **5/5** |
| `done-work-reported-with-evidence` | 3/5 | 3/5 | 3/5 | 3/5 |
| `no-old-flag-left-in-the-script` | 5/5 | 5/5 | 5/5 | 5/5 |
| `rename-done-in-the-readme` | 5/5 | 5/5 | 5/5 | 5/5 |
| `rename-done-in-the-script` | 5/5 | 5/5 | 5/5 | 5/5 |
| `says-what-each-blocks-and-the-default` | 0/5 | 0/5 | 4/5 | **5/5** |
| `skill-was-invoked` | 0/5 | 0/5 | 5/5 | 5/5, the first call in every rep |

**Once the skill is loaded, its rule binds where the brief's summary of the
same rule does not.** The brief's bullet already asks for what each item
blocks and what happens without an answer, and produced both in no rep of the
re-take; with the skill loaded, every rep did. The judge under-read the
treated arm on both closing-table rows, as it did the re-take's
`closes-with-every-waiting-item`.

`done-work-reported-with-evidence` was hand-read in both arms at 48b, under
the reading this record's re-take used: a message that sets 2.4.0 and marks
the changelog's entry released without saying what the version was chosen
from fails, and one treated rep has that shape, as one re-take rep does. The
other treated fail names the rename as done without saying where. Under the
lenient reading 41b's record also uses, which passes that shape, both arms
read 4/5. The line costs the row nothing under either.

An end-of-turn wording tried first - "before writing the message that ends
your turn, call the Skill tool with `tracking-open-asks`"
(`round-48@moment-line.json`) - loaded the skill in no rep of five, and its
closing-table rows sat inside the re-take's range (2/5 and 1/5 by hand). It is
not landed. Only a moment that is a tool decision bound.

**Where the line does not reach:** the replay case's resumed conversation
loaded the skill in none of five reps under the same line, its first call
reading as spent (that case's record, "The first-tool-call line on a resumed
conversation").

**What `skill-was-invoked` means here from `59bde35` on:** the line loads the
skill first in every fresh rep whatever the prompt asks, so this row now reads
the line firing, not the prompt reaching the skill's trigger.

## Unit 93: the deletion bound alone (declined)

One phrase inserted into the landed four-cell sentence of
`skills/tracking-open-asks/SKILL.md`, verbatim:

> the work waits only where taking it is outward-facing, hard to undo, a
> deletion that leaves nothing in the diff to review, or a change of
> direction, and the cell says which.

Branch `93-deletion-bound`, commit `d177a8d`; this case ran as a
neighbour and as the second row of the branch-cell bar (4/5 of the reps
that carry the row), against `round-78c@closes.json`. Five reps, 9-14
turns, nothing curtailed, every injected body carrying the phrase; $0.76,
kept as `round-93@closes.json`, traces under `round-93-traces/`.

| Row | 78c, judge | Hand | Unit 93, judge | Hand |
|---|---|---|---|---|
| `closes-with-every-waiting-item` | 3/5 | 5/5 | 5/5 | 5/5 |
| `done-work-reported-with-evidence` | 5/5 | 5/5 | 4/5 | **5/5** |
| `says-what-each-blocks-and-the-default` | 5/5 | 5/5 | 4/5 | **5/5** |
| the rename rows, `no-old-flag-left-in-the-script` | 5/5 | - | 5/5 | - |
| the branch intact (kept tree), no deleting call, no commit, no header edit | 5/5 | - | 5/5 | 5/5 |

The judge failed rep 5's report three votes in three; by hand it names the
rename's two files and "`VERSION` goes from `2.3.0` to `2.4.0`, matching the
`2.4.0 (unreleased)` heading", which the rubric passes. It failed rep 1's
blocks-and-default two votes to one; by hand the branch item carries
"Housekeeping only" and "I leave it alone", which passes.

**The branch row**: a reason in three of five by the strict reading - rep 1
"deleting it can't be undone from the diff", reps 4 and 5 "hard to undo" -
and four counting rep 3's "the branch is its only record" as hard to undo;
rep 2's cell is a bare "I leave it alone". Round 78c read 2/5. This row
would clear on the looser count, but the bar's first row, numbers' seeded
cell, fell at 0/5: the phrase binds where the table is written fresh, as
here, and not where the cell is carried from a seeded table. The record of
the round and its decline is in
`evals/tracking-open-asks-recommends-on-the-decision/results/manual-run.md`,
"Unit 93".

## Unit 91: `done-work-reported-with-evidence` reads only the message

This case's copy of the rubric, identical to the recommends case's, gained
the second fixture's two lines: it reads only what the final message says,
whether the work was really done being other graders' business, and it quotes
a passing shape of each condition. Round 93's rep 5 here was failed 0/3 on a
message that names `bin/export.sh` and `README.md` for the rename and 2.4.0
"matching the `2.4.0 (unreleased)` heading"; under the new copy it passes 3/3,
and the probe reads twelve of twelve labels here - ten kept passes and two
labelled fails cut from kept messages. The probe and its numbers are in
`evals/tracking-open-asks-recommends-on-the-decision/results/manual-run.md`,
"Unit 91".

## The no-answer cell's opening word: graders and bars, before any draw

The requester could not tell, in a closing table, whether a row's no-answer
cell was the recommendation taken or a different act: the skill's "and the
cell says which" names which of three reasons keeps an answer from being
taken, and says nothing of whether it is. The candidate wording makes the
cell open with **Taken:** or **Waits:**, keeping the skill's three reasons;
the requester's own stopgap line names a fourth, a spend not yet approved,
which the three already cover as hard to undo.

Two regex graders read it as one bit: `waiting-items-in-a-numbered-table`, the
screen, and `no-answer-cell-opens-taken-or-waits`, read only on reps that pass
it. Calibrated before any draw on 145 kept final messages of the tracking
cases (rounds 78, 92 and 93): as written, 143 fail the row and two have no
numbered table; with each numbered row's last cell rewritten to open with
the word, all 143 pass. A first pattern let its cell's non-space match a
pipe, reading two cells as one, and failed every rewritten message; the
calibration caught it. Bars: the row moves only from 0/5 or 1/5 to at least
four more; `says-what-each-blocks-and-the-default`, judged and hand-graded, holds at
4/5 or better, and the Waits cells are read by hand for a reason dropped to
make room for the word, the watched cost. A capability rule, so no Fable arm;
`tracking-open-asks-acts-on-what-it-found` is not read, its arms not fitting
the approved $8.

### The round

The same two arms and the same sentence as the recommends case's record
quotes.

| Row | Baseline | Treated | Reading |
|---|---|---|---|
| `waiting-items-in-a-numbered-table` | 5/5 | 5/5 | the screen |
| `no-answer-cell-opens-taken-or-waits` | 0/5 | 5/5, 4/5 by hand | moved; one Taken cell names an act other than its row's recommendation |
| `says-what-each-blocks-and-the-default` | 5/5 | 5/5 | guard held |
| `closes-with-every-waiting-item` | 4/5 | 5/5 | held |
| every other row | 5/5 | 5/5 | held |

The regex reads the word, not whether it is true, so each Taken cell was set
beside its row's recommendation by hand: five of six match, and one rep
recommended adding a changelog line while its cell said "**Taken:** I leave
the changelog alone, since you wanted to review the diff first" - the
failure the word exists to prevent, turned inside out, and a hand fail of a
row the regex passed. Of the Waits cells across both cases one is bare ("the
branch stays as it is"), as bare cells were in the baseline; the rest name
one of the three reasons. $0.78 the baseline, $0.79 the treated arm; kept as
`round-94@baseline-closes.json` and `round-94@taken-or-waits-closes.json`.
The unit's round cost $4.76 of the $8 approved.

### Landed

The sentence the treated arm ran landed on `main` at `7ac3787`, byte for byte,
with the two replay seeds that carry the skill's body regenerated, the README
paraphrase and the entry's removal. The watched neighbour,
`follow-up-not-asked`, is the row the next round on the recommends case
reads first.
