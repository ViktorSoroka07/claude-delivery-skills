# Manual runs

## What the case reaches, and how its rates are read

Written before any rep. The rules under test are three tests drafted for
`maintaining-project-memory`'s promotion section, each about how the writer of
a rule shapes it for a reader who did not write it and meets it mid-task:

- **the trigger** names what the artifact it governs shows - a field, a
  heading, a marker already in it - not a category the reader must judge the
  artifact into, since a judged trigger can be judged away;
- **a rule that forbids an act says why its replacement needs none of what
  that act supplied**, since what reaches for a forbidden act is often a
  precondition the reader believes the replacement needs;
- **a rule whose work no request names is stated where the reader already
  is** - its imperative, with its boundary, in text every session of that
  reader loads - not behind a pointer.

Every measurement behind the three is on the reader's side: a rule written
the old way, and readers breaking it. Two earlier rounds on this skill read
only the section's fourth test, the landing sweep
([maintaining-project-memory-sweeps-the-copies](../../maintaining-project-memory-sweeps-the-copies/results/manual-run.md)
and its sibling). This case reads the three on the writer's side: whether a
session asked to write a rule writes it in the shape each test asks for.

The fixture (`evals/fixtures/storefront-rules.sh`) is a small shop
repository: the site under `web/`, its API, nightly jobs, a unit suite and a
browser suite, and two skills behind `CLAUDE.md`'s pointers. The prompt is a
requester's rule after two incidents: before you call a change done, if it
touches anything shoppers see, run `make e2e`, and never stop a running dev
server to free its port for the tests - run `make e2e` with it left up; "it
belongs in `skills/testing/SKILL.md`"; do not commit, say in two lines what
changed. It gives each test one thing to act on, and the repository holds
what the test's shape needs:

- **The trigger**: the requester scopes the rule to "anything shoppers see",
  a category a reader judges a change into. The README says `web/` holds
  every page, style and script the browser loads, and that nothing the
  nightly jobs do is shown to a shopper; `api/` is described as plain
  functions, so nothing in the fixture makes it a second answer, and the
  hand read notes which paths each trigger names.
- **The prohibition**: the requester forbids stopping the dev server to free
  its port and says to run the suite with it up, without saying why that
  works. Only `scripts/e2e.sh`, which `make e2e` runs, shows it: the suite
  starts a server of its own on a free port. Neither the testing skill nor
  `CLAUDE.md` says so, and `make e2e` passes with a dev server on 8080,
  checked on the built fixture on the host. A rep probably cannot check it:
  the runner's sandbox policy (a kept run root's `config/settings.json`)
  restricts the network and sets no local binding, so a server started
  inside a rep likely fails to bind. The reason stays readable from
  `scripts/e2e.sh`; which reps ran the suite, and what came back, is read
  per arm before any grader.
- **The placement**: the requester names the testing skill as the rule's
  home. `CLAUDE.md`, the file every session in the repository loads, reaches
  that skill only through a pointer for writing tests, while the rule fires
  whenever any change is finished - work no request names.

Nothing in the testing skill names `web/`, a port or the dev server, so what
a grader finds there the run wrote.

**The condition is the rule landed in the skill the prompt names**, read per
rep from the kept tree before any grader: `skills/testing/SKILL.md` gains an
instruction to run `make e2e` before a change is called done and one never to
stop a running dev server for it, each read by its meaning. It gates the two
graders that read that file. A rep that does not meet it is unmeasured on
those two rows, listed per arm with the shape it took (the rule moved into
`CLAUDE.md` with the skill left a pointer, a half of the rule dropped) and
replaced by a top-up rep for those rows; **a rule moved out of the skill the
requester named is counted per arm as a cost**, not only topped up, since the
wording under test could be what moved it. The imperative row reads the first
five reps of each arm whatever the condition says, since it reads
`CLAUDE.md`.

**Arm membership** is read from every trace before any grader, from the start
hook's output, by a phrase each arm's brief alone carries: the head's "when a
statement crosses a tier (chat to memory, memory to spec, spec to skill or
wiki, one copy onto another)" in a baseline rep, the treated text's "say why a
forbidden act's replacement needs none of what that act supplied" in a treated
rep, and, in the ablation arm below, "whenever you write a rule or a claim into
a memory entry" without the treated phrase. The hook fails open, emitting
nothing on an error, so a rep whose start hook carries no brief at all is an
instrument defect too, re-taken and not counted. **Curtailment** is read first,
from each trace's `result` records: a rep the turn cap or the timeout stopped
is unmeasured and replaced, and why it stopped is read from its trace.

**The graders**, three judged, one condition each, `--judge-model sonnet`:

- `trigger-names-what-the-change-shows` reads the skill: the condition under
  which the rule says to run `make e2e` names a path, directory, file pattern,
  file type or file list, alone or defining a category - not only a category,
  not a path given only as an example of one, and not no condition at all.
- `forbidden-act-says-why-replacement-needs-none` reads the skill: the rule
  forbidding the stop says, with the prohibition, what `make e2e` runs on - a
  server of its own, a free port or one of its own - rather than only the
  harm, or a bare claim that the port is unneeded or the two can run together.
- `imperative-in-the-file-every-session-loads` reads `CLAUDE.md`: the file
  itself tells its reader to run `make e2e` before calling a change done - not
  only a pointer naming the subject, the moment or the prohibition.
- `skill-was-invoked` for `maintaining-project-memory` is the trigger's
  indicator, informational: in the treated arm the brief carries the three
  tests to every rep, so a rep that writes the rule as they ask without
  loading the skill was carried by the brief.

**Every grader is hand-graded from each rep's kept tree, and each hand grade
is written before the runner's verdict is read.** Beside them, read by hand
in every arm and not graded: whether the rule applies to every change (no
condition at all - a dropped qualifier, which the trigger test's wording could
make likelier, so a rise reads as that cost and not as the trigger test
failing to bind); whether `CLAUDE.md`'s line carries the rule's boundary
(`web/`, or the category) or leaves it behind the pointer; whether the rule
landed anywhere else as well (`.claude/`, the release skill); nothing else in
the skill or `CLAUDE.md` rewritten; and the reply in two lines. Turn and
duration spreads come from each trace's `result` records.

## Calibration of the judged graders, before any rep

Sixteen trees written by hand from both sides of each grader's line, each the
fixture's `skills/testing/SKILL.md` and `CLAUDE.md` edited as a rep might
leave them, labelled before any verdict was read. Twelve came first, and the
blind verifier labelled those twelve from the grader texts alone and agreed on
all 36 cells. On its findings the prohibition grader moved "it doesn't use
port 8080" to its fail list - a bare claim that the port is unneeded, like
"there is no need to free the port" - and gained a line that a reason stated
away from the prohibition does not count; the trigger grader gained lines for
a path given only as an example and for file types named by language. One
label moved with the rubric, before any verdict. Four more trees were added
for the shapes the verifier found missing.

The trees went through the three graders as they stand in this case, copied
byte for byte into a throwaway plugin whose scaffold writes each tree's two
files and whose prompt asks for one word, `--model haiku --judge-model sonnet
--ablation none --runs 1`, for $1.17: **the judge agreed with the hand label
on all 48 cells, every one by three votes to none.**

| Tree | What it is | trigger | prohibition | `CLAUDE.md` |
|---|---|---|---|---|
| c01 | the fixture untouched | fail | fail | fail |
| c02 | the prompt's rule copied into the skill | fail | fail | fail |
| c03 | `web/`; its own server on a free port; the imperative in `CLAUDE.md` | pass | pass | pass |
| c04 | "a page, style or script"; "runs alongside without any conflict"; the pointer widened to "when to run the browser suite" | fail | fail | fail |
| c05 | `web/` beside the category; "does not use port 8080"; the imperative in `CLAUDE.md` | pass | fail | pass |
| c06 | the condition in a heading; the harm alone; the prohibition and a pointer in `CLAUDE.md` | pass | fail | fail |
| c07 | every change; a free port for its own server; the imperative for every change | fail | pass | pass |
| c08 | `.html`, `.css`, `.js`; "no need to free the port"; "follow the browser-test rule in the skill" | pass | fail | fail |
| c09 | the category, with `web/` on another line; "its own copy of the site"; the imperative with the category | fail | pass | pass |
| c10 | "user-facing (`web/` or `api/`)"; "a port of its own"; the imperative added to the pointer bullet | pass | pass | pass |
| c11 | `web/**`; "doesn't conflict"; "when to run it: the skill" | pass | fail | fail |
| c12 | "users see (the UI)"; "starts its own server"; `CLAUDE.md` untouched | fail | pass | fail |
| c13 | `web/`; the reason only in the list of suites | pass | fail | fail |
| c14 | a path as an example; "its own copy of the site"; the imperative with its boundary behind the pointer | fail | pass | pass |
| c15 | "HTML, CSS or JavaScript"; "doesn't need port 8080"; the imperative in `CLAUDE.md` | pass | fail | pass |
| c16 | `web/**`; "a port the OS picks"; the pointer widened to "the browser-suite rule for `web/` changes" | pass | pass | fail |

Every tree sits on both sides of some line, and each line has near cases on
both sides: for the trigger, the path against the README's category words, a
path in the condition against one elsewhere or given as an example, file types
against kinds of thing; for the prohibition, what the suite runs on against a
bare claim, and the reason with the prohibition against the reason in the list
of suites; for `CLAUDE.md`, the imperative against a pointer naming the
subject, the moment or the rule's scope. What the grader passes and the hand
column reads is c14's shape, an imperative whose boundary sits behind the
pointer. The trees, their labels, the probe plugin and its JSON are kept with
the round's results.

## The bars, fixed before any draw

Each judged grader is one test's row, so three rows are read, and a row
crossing its bar is reported with that count beside it. **Each row's tier is
set on the baseline's first five measured reps**, and a row's extension does
not re-tier the others. The bars keep to CONTRIBUTING's floor: at five reps an
arm, only 4/5 against 0/5 or 5/5 against 1/5.

- **0/5**: the treated arm's first five measured reps decide the row; it
  clears at 4/5 or better.
- **1/5**: the same five decide it; it clears only at 5/5.
- **2-3/5**: both arms go to ten measured reps - an extension fixed here, not a
  re-check bought on a reading, and bought only for such a row - and the row
  clears when all ten of the treated arm reach 9/10 or better and exceed all
  ten of the baseline's by five or more (9/10 against 4/10, 10/10 against
  5/10), the half ten reps an arm can separate.
- **4-5/5**: the row's test is not needed on the suite's model where the defect
  is this plain, and no arm is bought for it. If a treated arm is bought for
  another row, this one is read there as a neighbour: 5/5 falling to 1/5 or
  lower, or 4/5 to 0/5, is a cost the landing answers before anything lands;
  4/5 falling to 1/5 is a watched cost, below the floor.

**The treated arm is bought when any row's baseline is 0-3/5**, and its reps
are read on every grader.

**The treated text is a package**: its brief bullet also restates when the
bullet fires - "whenever you write a rule or a claim into ... a skill, ... an
instruction file", where the head's names crossings of a tier and not chat
into a skill - and that alone can send a rep to re-derive the rule, which
could move any of the three rows without the clause for it. **So a row that
clears is the package's until an ablation arm separates it**: the treated text
without the three tests' clauses and A2 - the section's and the brief's
restated trigger, with the head's re-derive and qualifier clauses and nothing
else - five reps, fixed here and bought only where a row clears. A cleared row
is the clause's where the treated arm exceeds the ablation arm by the floor
(4/5 against 0/5, 5/5 against 1/5); at the ablation arm's 4-5/5 the restated
trigger carries it and the clause is not shown needed; between the two the
arms are not separated and the record says so.

**Purchase order and the ceiling**: the judge probe, the baseline, the
treated arm, the extension where a row's tier asks for it, then the ablation
arm - each only while the round's spend stays within the approved $4-5.
Whatever the ceiling stops is priced for the owner at the stop rather than
bought.

**What each outcome decides.** A row that clears, and is the clause's by the
ablation arm, has shown its test's writer-side effect on this fixture; its
landing still waits on the neighbours task 49 priced for the brief's bullet,
since that bullet reaches every session - a purchase that is the owner's. A
row whose treated arm falls below its bar does not land from this case, and
each miss's trace says what was in front of the rep when it wrote: the
brief's clause in every treated rep's start hook, and the skill's bullet only
where the rep loaded the skill - the brief says "where the reader already is
rather than behind a pointer", the skill "in text every session of that reader
loads" - so a miss is read separately by which of the two the rep had. A row
at 4-5/5 on the baseline goes back as unneeded on the writer's side on the
suite's model.

## The treated text

A detached worktree at the case's commit carries, from task 49's draft as the
two sweep rounds tested it (their diff is kept under
`evals/results/task49c-verifier/`):

- the section's own trigger restated as the files a rule is written into;
- the three tests after the qualifier bullets, word for word as tested there,
  with the placement test's clause "the drift a single copy prevents is
  prevented instead by the search in the next bullet" removed, since the
  bullet it points at is not carried;
- A2, the pointer bullet's boundary: "except the imperative of a rule whose
  work no request names, which stays in text every session loads", with its
  "brought into line whenever the skill's copy moves" removed, whose keeper was
  the sweep;
- the brief's bullet 3 restated with the three tests' clauses and without the
  search clause: 138 words, against 71 at the head.

**The landing sweep is not carried**, and neither are its two red-flag rows.
It has read below its bar twice on this skill, the turn's-end hook 49d priced
is to carry its search instead of a sentence, and a sweeping rep would search
for the rule's subject, find `CLAUDE.md`'s testing pointer and rewrite it
because it lists the subject - which the imperative row would read as the
placement test binding. **A2 is carried** because it is the placement test's
own consistency fix: without it a rep that loads the skill reads "a pointer
naming the skill ... never a paraphrase of it here" beside a test asking for
the imperative in text every session loads. It is about condensing a memory
entry, which this case has none of, and reaches only reps that load the skill,
so it rides along untested here. For the landing, whenever it comes: without
the hook, A2 creates a second copy nothing keeps in line, and the README's
paragraph on condensing memory to a pointer contradicts it.

The case, the treated text, the calibration trees and these bars went
through one blind verifier before any draw; its findings and what was done
with each are kept with the round's results, every adopted one reproduced at
source first.

**Not bought, and why:** a baseline on the strongest model, since none of the
three is a restraint rule; a second fixture in another domain, which is the
landing's question if the three clear here.

## The baseline arm: five reps, all measured

Five reps of the plugin at the case's commit, `--ablation none --model sonnet
--judge-model sonnet -j 3 --keep-temp` on CLI 2.1.281: $1.10, kept as
`round-49e@baseline.json`, each rep's trace and tree under
`evals/results/task49e-baseline-traces/` with the hand grades written before
the runner's verdicts were read. Nothing curtailed: one `result` record per
trace, all `success`, 8-12 turns against 40 and 17-35 seconds against 600.
Every start hook carries the head's brief phrase. No rep ran `make e2e` or
bound a port, so the sandbox's refusal never came into play; every rep read
`scripts/e2e.sh`, four of them after searching for `8080` or `e2e`, to check
what the port claim rested on. No rep loaded `maintaining-project-memory`.

**The condition: met in all five.** Each rep added a "Before calling a change
done" section to the testing skill carrying both halves of the rule, and
changed nothing else; `CLAUDE.md` is untouched in all five.

| Grader | Runner | Hand |
|---|---|---|
| `trigger-names-what-the-change-shows` | 0/5 | 0/5 |
| `forbidden-act-says-why-replacement-needs-none` | 5/5 | 5/5 |
| `imperative-in-the-file-every-session-loads` | 0/5 | 0/5 |
| `skill-was-invoked` | 0/5 | 0/5 |

Runner and hand agree on all twenty cells. Every trigger is the requester's
category - "anything a shopper sees", once "or can do", once followed by
"browsing, cart, checkout, or any page or API a storefront request can reach"
- and none names `web/`; no rep opened the README. Every prohibition carries
the reason with it, in the words of the script it read: "the suite starts its
own server on its own free port" (four reps), "on a free port the OS picks"
(one).

**By the bars fixed before the draw:** the trigger and placement rows at 0/5
buy the treated arm, each clearing at 4/5; the prohibition row at 5/5 is not
needed on the suite's model where the reason sits in a file the writer opens
anyway, and is read in the treated arm as a neighbour.

## The treated arm: five reps, all measured, neither row clears

Five reps of the treated text from the worktree pinned at `f72b8e1`, the same
flags: $0.95, kept as `round-49e@treated.json`, traces, trees and hand grades
under `evals/results/task49e-treated-traces/`. Nothing curtailed: one `result`
record per trace, all `success`, 7-11 turns and 21-39 seconds. Every start
hook carries the treated phrase. No rep ran `make e2e`.

**The condition: met in all five**, and `CLAUDE.md` untouched in all five.
Three reps loaded the skill - reps 1 and 4 before reading anything, rep 2
after reading the script and before its one edit - and each of those traces
carries the section's treated bullets in the loaded text; reps 3 and 5 had
the brief's clause alone.

| Rep | Skill loaded | Trigger as written | trigger | prohibition | `CLAUDE.md` |
|---|---|---|---|---|---|
| 1 | first call after the brief's | "anything a shopper sees or does - browsing, the cart, checkout" | fail | pass | fail |
| 2 | before its edit | "a path a shopper takes - browsing, cart, checkout" | fail | pass | fail |
| 3 | no | "anything a shopper sees" | fail | pass | fail |
| 4 | first call after the brief's | "a shopper-facing path - browsing, cart, checkout" | fail | fail | fail |
| 5 | no | "anything a shopper sees - a page, an API response shape, checkout, pricing" | fail | pass | fail |

| Grader | Runner | Hand |
|---|---|---|
| `trigger-names-what-the-change-shows` | 0/5 | 0/5 |
| `forbidden-act-says-why-replacement-needs-none` | 4/5 | 4/5 |
| `imperative-in-the-file-every-session-loads` | 0/5 | 0/5 |
| `skill-was-invoked` | 3/5 | 3/5 |

Runner and hand agree on all twenty cells, every judged one by three votes to
none. Three graders were read and none crossed its bar.

**Reading, by the bars fixed before any draw: neither test lands.**

- **The trigger: 0/5 against a bar of 4/5, on a 0/5 baseline.** The reps
  moved the trigger toward the concrete - three listed the shopper's journeys
  ("browsing, the cart, checkout"), and reps 1 and 2 wrote the rule's
  exclusion out ("a change confined to code a shopper's path never reaches
  doesn't need it") - but in the category's own terms: a journey is still a
  category the reader judges a change into, and no rep looked for what in the
  repository marks it. None opened the README or listed the tree.
- **The placement: 0/5 against 4/5, on a 0/5 baseline.** No rep touched
  `CLAUDE.md`. The requester named the rule's home, and every rep wrote it
  there and nowhere else; rep 5, which had the brief's clause alone, is the
  one rep that acted on the rule's reach, widening the testing skill's own
  `description:` to fire "before calling any change that touches what a
  shopper sees done" - inside the file it was told to use, and a trigger for a
  skill the repository's sessions never load as one.
- **Having the section's bullets loaded decided nothing.** The three reps that
  loaded the skill before writing missed both rows exactly as the two that had
  the brief's clause alone did - so a stop that delivers the skill at the write
  would not be expected to move either row on this case.
- **The prohibition, read as a neighbour: 4/5 against the baseline's 5/5**,
  not a cost by the bar. The miss is rep 4, which loaded the skill first,
  never opened the Makefile or the script, and wrote the harm and then an
  instruction the script contradicts ("run the suite against it as it stands,
  or use a different port") in seven turns, the fewest of either arm.

The ablation arm was fixed to be bought only where a row cleared, and the
extension only for a row at 2-3/5 on the baseline; neither was bought. Spent
on the round: $1.17 for the judge probe, $1.10 for the baseline, $0.95 for
the treated arm - **$3.22** of the approved ~$4-5.

## The restated round (row 6's D): the writer asked to say what it cannot settle

The round above moved no writer on the trigger or the placement: every rep
kept the requester's category and wrote the rule only where the requester said
it belongs, three of them with the section loaded. A test asking the writer to
override what the requester said loses to the requester. The restated text
asks instead for acts the writer can take while doing what it was asked:

- **the trigger**: keep the requester's category and define it by a mark the
  change will carry, where the repository names one - or ask the requester in
  the same reply which mark defines it;
- **the placement**: write the rule where the requester said, and where that
  home loads only when its own work is named, say in the same reply that it
  will be read only then, and offer the always-loaded line that would carry
  its imperative.

**The treated text** is two bullets in the promotion section, after the
qualifier bullets, their example taken from another domain (a schema change
under `migrations/`) so a rep that loads the skill is not handed this
fixture's answer; and, on the brief's bullet 3, the tier list naming chat
written into a skill or an instruction file, plus one clause carrying both
acts with the skill's condition and its gloss of a mark. At the head's brief
the skill loaded in none of the five baseline reps and in three of five under
49e's restated trigger, so **the brief clause is what reaches every rep**, and
a row that clears with no rep loading the skill is the brief clause's alone,
the skill's bullets landing untested. The treated start hook's phrase is
"Where a rule's trigger is a category the reader must judge a change into".

**Two new graders read the reply**, one condition each, over the final message
the prompt asks to be two lines: `reply-names-the-trigger-a-judgement` (the
requester asked which mark should define the trigger, or a mark proposed for
them to accept or refuse) and `reply-says-where-the-rule-is-read` (the requester
told that the rule, where it was put, will be read only when testing work is
named). Each fails a report of the act already done - a trigger already scoped
to a path, an imperative already written into `CLAUDE.md` - since the tree is
read for that, and a rep cannot pass by saying it did what its tree does not
show. **A rep passes a test's row where its tree grader or its reply grader
passes**: the trigger by `trigger-names-what-the-change-shows` or the first,
the placement by `imperative-in-the-file-every-session-loads` or the second.
The placement row passed through the reply is **disclosure**, not placement -
the writer telling the requester the rule will not reach its reader - and is
reported as such; whether an offer came with the warning is read by hand.

**Their calibration, before any draw.** Twenty-one final messages through the
settled judge - the ten kept replies of the two arms above and eleven written
across the lines - labelled first. The first rubrics asked for two things each
(the trigger flagged as judged *and* a mark; the warning *and* an offer), and
the judge passed three boundary messages the labels failed, three votes to none
each: a table row proposing `web/` with no word that the trigger is judged, an
offer to add the rule to `CLAUDE.md` with no reason, and a warning whose remedy
was the skill's own description. The rubrics went to one condition each, the
labels were rewritten from their text before the re-probe, and on the eleven
boundary messages **the judge agreed on all twenty-two cells, three votes to
none**; the ten kept replies fail both conditions under either version. $1.45
in all.

## The bars, fixed before any draw (row 6's D)

- **The baseline is the arm above**, not a fresh one: `hooks/session-brief.md`,
  the promotion section, `tracking-open-asks` and the skill gate are unchanged
  since it ran, and what did change - the landing-sweep hook, landed after it -
  handed nothing when replayed on its reps. Both rows sit at **0/5** on it: the
  tree graders 0/5 by runner and hand, and all ten kept replies fail both reply
  graders.
- **0/5 on both rows: the treated arm's first five measured reps decide each
  row; it clears at 4/5 or better.** The condition and arm membership are read
  from each trace before any grader, as above; a rep missing the condition is
  replaced, at most two, and past that the rows are read on the reps measured.
- **What each outcome decides.** Both entries are Strong-tier, and this is
  their one domain (CONTRIBUTING, the second-fixture rule), and the clause
  sits in the brief every session reads, whose neighbours this case does not
  measure: **no row lands from this round.** A row that clears is recorded as
  tested on one domain - the entry keeps its tier, its next round a second
  fixture and the brief's neighbours - with the placement row named as
  disclosure where the reply carried it. A row below its bar is declined for
  this wording, the entry saying whether the gap fell below the floor. One row
  clearing and the other not lands nothing either way: the clause is one text.
- **Neighbour**: the prohibition row, 5/5 on this baseline, is a cost at 1/5
  or lower and watched above that.
- **The landing sweep**: every treated rep's session transcript is read for a
  `hook_additional_context` hand-off; where one spoke, both rows are graded on
  the rep's state at its first stop - the tree its own `Edit` and `Write` calls
  left, and the message that ended that stop.
- **By hand, in both arms, beside the graders**, as 49e read them: whether the
  rule applies to every change; which paths the trigger names, since `web/`
  alone leaves out pricing under `api/` that a shopper sees; and whether a
  `CLAUDE.md` line carries the rule's boundary.
- **Every judged row is hand-graded before a decision rests on it.** Seven
  graders feed the two rows and the neighbour; a crossing is reported with
  that count. Ceiling: about $1.50 for the arm, set at $2.50.
