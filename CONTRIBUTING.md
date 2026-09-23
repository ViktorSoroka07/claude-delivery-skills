# Contributing

These skills are refined from real delivery work. That is what makes them good,
and it is also the risk: the work happens in private repositories, and the
details leak in through provenance notes rather than through code. The first
half of this document is about keeping the repository publishable; the rest is
how a change is tested, described, and released.

## Setup (once per clone)

    git config core.hooksPath .githooks
    git config user.email <the address you publish under>
    cp .leakwords.local.example .leakwords.local   # then fill it in

The hook does nothing until `core.hooksPath` is set - git does not run hooks
from a tracked directory on its own, and it never ships `.git/hooks` in a clone.
**A clone with no setup step has no protection.**

The identity line is the same kind of protection, and the one whose failure
cannot be undone in place: where the machine's global `user.email` belongs to an
employer, that address lands in this repository's public history, and removing
it means rewriting history rather than making a follow-up commit.
`scripts/scan-history.sh` audits author and committer identities against the
local wordlist, so the slip is caught before a push - but that wordlist is
local, so CI never runs this check. Making the identity a function of the
directory instead - git's conditional includes, with no `user.email` at the top
level and `user.useConfigOnly = true` so an uncovered repository refuses to
commit rather than guessing - settles it for every clone at once, including the
ones not made yet.

## What must never appear

| Never | Write instead |
|---|---|
| Internal codenames, product names | "the planning tool", "a repo-level skill" |
| Client or internal repository names | "an upstream repo" |
| Ticket ids (`AB#...`), issue and PR numbers | "a work item", "a PR review" |
| Branch names from real work | "a real feature branch" |
| Commit SHAs from other repositories | omit |
| Internal hosts and `@company` addresses | omit |
| The word "client" | omit - it invites "which client?" |

## Write the mechanism, not the circumstances

A lesson from real work has two parts. The **mechanism** is what goes wrong and
why - it is portable, and it is the only part that teaches. The **circumstances**
are which repo, which subsystem, which library, which branch - they identify the
work and teach nothing.

Before a lesson enters a skill, restate it in one sentence with no proper nouns.
If it cannot be stated that way, it is not distilled yet - keep working on it in
conversation, not in the file. Then apply the test to every detail that remains:
**if removing it does not weaken the warning, it was circumstance.**

Two examples from this repository's own history:

- Kept: "on a 750-line branch, eight agents cost more than the findings were
  worth" - anonymous, and it is the sentence that actually teaches the cost of
  running every review axis.
- Removed: the companion sentence naming the subsystem that branch touched -
  it added flavor, not force.

Library-recognizable API names are fingerprints even when nothing else is named:
rename them to verbs that describe the behavior (`await run(x)`,
`runInBackground(x)`) rather than keeping a framework's own distinctive
vocabulary - unless the rule is *about* that framework. The same goes for
stack-specific commands: state the trap ("the runtime's built-in test runner may
not be what the repo's scripts run"), not the vendor.

The pre-commit hook cannot make this judgment - it blocks identifiers, not
flavor. This section is the check that runs before the hook ever sees the text.

The same standard gates new platform references (a gitlab.md, a bitbucket.md):
they are earned by real use, never written from documentation. A reference
file's value is the traps that diverge from the obvious - API behavior nobody
writes down until it burns them - and those cannot be generated. Until someone
has done real reviews on a platform, review-pr's honest answer there is its
unknown-platform fallback, not a speculative reference.

## Where a lesson waits

A lesson that has passed the one-sentence test but not yet been re-derived
into its skill goes in [`BACKLOG.md`](BACKLOG.md), naming the skill it is
aimed at. The file is tracked, so an entry meets the same bar as a skill and
the pre-commit hook scans it like one. Promoting, parking or declining an
entry removes it from the queue in the same commit; a parked or declined
entry keeps its line beside the queue - parked in
[`backlog/parked.md`](backlog/parked.md), declined in
[`backlog/declined.md`](backlog/declined.md), both tracked and scanned the
same way - so the same lesson is not queued twice. A promoted one keeps no
line: the mechanism is in the skill it was re-derived into. An entry is
committed by the session that writes it, in a commit of its own, as soon as
it is written: the commit body carries the observation behind the sentence,
which the entry cannot, and an uncommitted entry is a stray change every
later session has to explain or step around.

**Queuing starts with a search, not with a line.** Nobody re-reads a
backlog, and the one moment anyone has a mechanism in hand with the file
open is when they are about to queue it - so that is where recurrence gets
recorded. Search all three files for the mechanism first - `grep -rin` over
`BACKLOG.md` and `backlog/`, because a mechanism that has already been
parked or declined is exactly the one a fresh line duplicates, and a search
stopping at the queue cannot see it. Search on two or three words of what
goes wrong, not the words an entry would have used, because the same defect
arrives described differently every time, and a doubtful match is read in
full before a second line is written. Where the mechanism is already in the
queue, add a sighting to that entry instead of a new line, so each entry
carries its own count and recurrence needs no separate bookkeeping; where it
is parked, the move back carries the sighting; where it is declined, the
reason there answers the line rather than licensing it. Only a session that
hit the mechanism itself adds a sighting: reading an entry and agreeing with
it is not an observation.

The count goes in the parenthetical the entry already carries, each sighting
its own circumstance and held to the same no-proper-nouns bar as the entry's
sentence; [`BACKLOG.md`](BACKLOG.md)'s header shows the shape. An entry
carrying no count stands at the one sighting that queued it, so the first
sighting added to it makes two.

**Recurrence is the promotion filter.** A mechanism met once is a hypothesis
about how things fail; one that bites twice is a rule, and the second
sighting is the evidence the first one lacked - so an entry is worth a
wording round when it carries two sightings, or one sighting whose failure
was measured (a rate, a run, or a failure that landed and whose cost the
entry names - a near miss caught before it cost anything is a sighting, not
a measurement). A second sighting is other work or another place, never the
same failure met twice in one pass. An entry that has reached neither by the
time a round reads it is parked - a finding about the mechanism rather than
a defeat. A parked entry keeps its sentence, so the mechanism search above
still matches it, and ends with the circumstance that would make it two; a
later sighting moves it back to its tier already carrying two, which makes
it eligible at once. Declined is the other outcome and a different one: the
entry has been answered rather than left waiting, and the grounds a decline
rests on are in [`backlog/declined.md`](backlog/declined.md)'s preamble. They
are not one finding - a wording tested and failed and an effect measured and
below the instrument are different things to have learned, as the floor below
says - and an entry still untested and short a sighting is parked, never
declined. The tier says how much a rule would be worth; the count is what says
it is ready to test.

## Provenance without leaking

A provenance note has two jobs: proving the rule came from real experience, and
letting you find the incident later. **Only the first one survives publication.**
The second needs identifiers, and identifiers are what cannot be here.

So write `(learned from a real PR review)` and stop. Do not add a date: once the
ticket reference is gone the date indexes nothing, and a two-year-old stamp makes
a live rule read as stale.

This applies to `(checked YYYY-MM-DD)` on an external-API fact too. That date is
more defensible - it says how stale the observation is - but nobody refreshes it,
so it rots into false precision. State the finding; drop the stamp.

## One full statement per lesson

A lesson lands in full once, in the file that owns it - usually a platform
reference or the posting reference, which load only at the moment they apply.
Every other mention is a pointer clause. `SKILL.md`, the file every invocation
pays for, changes only when the trigger, a mode, or the finding format
changes. Writing a lesson out at full altitude in every file that mentions it
grew one skill by a fifth in a day: the copies drift apart, and the growth is
paid on every load.

The one deliberate duplicate is `implementation-gates`' plan task. It is copied
verbatim into plans in repositories that do not carry the plugin, so it holds
its own definitions (the equivalence test included) inline and references no
plugin file. Do not tidy that duplication into a cross-reference: a plan that
points at a file its executor cannot read runs no gate.

`hooks/session-brief.md` is the strictest case: it loads into every session,
so each rule there is a pointer to the skill that owns it plus a one-sentence
core, never the full statement. A change to a rule lands in its skill; the
brief changes only when the pointer or the core does. The one sentence above
the rules is no rule: it makes a conversation's first tool call a load of
`tracking-open-asks`, because how a message ends is work no request names, so
a pointer to that skill is never followed. A moment that is a tool decision is
the one form measured to load a skill no request names, and it binds only in
a fresh conversation.

## The README paraphrases; the skill files own

The README describes skills for a human deciding what to install and what to
ask for; the skill files are what agents execute. That makes the README a
paraphrase with a declared owner, never a second authority: it carries mode
names and one-line purposes, not trigger phrases, qualifiers, or boundary
conditions - operational detail in a paraphrase is the part that drifts first.
A change to a skill's user-visible modes or defaults includes a sweep of its
README section in the same commit.

The exception is text the README does not write. The trigger index and the
component inventory sit inside marker regions that `sh scripts/generate-inventory.sh`
fills from the skill files, so they carry the owner's own sentences rather than a
paraphrase of them, and CI fails when they are stale. Hand-editing inside a marker
region is the drift the generator exists to prevent: change the skill's
`description:` and regenerate.

## Testing a wording change

A skill or agent edit that changes behavior is tested the way code is: a
baseline that fails without the change, then the change, then the same run
passing. Reading the new text and finding it clear is not a test - the
wording that read fine to the author is what a weaker model negotiated with.

`evals/` holds the cases, in the layout `claude plugin eval` expects: one
directory per case with `prompt.md` (frontmatter: runs, tools, limits),
`graders/*.md` (one grader per file; an `llm` grader's rubric is the file
body, and `focus: {source: file, path: ...}` points it at a file the run
left behind), `case.yaml` naming a `fixture.sh` beside it as the scaffold,
and that script building the fixture repo from `evals/fixtures/`. The
scaffold runs inside the empty run workspace, with no arguments and no
environment, and `$0` is the script's own absolute path in the case
directory — which is how `fixture.sh` reaches the shared fixtures. Run with
`--scaffold`, grant the tools the cases use (the case's own `allowed_tools`
cannot widen the read-only set), pin the model with `--model`, and read the
ablation arm - the command runs each case with and without the plugin,
which is the baseline for free:

    claude plugin eval . --scaffold --allow-tools Bash Write Edit Agent --model sonnet --runs 5

A grader marked `arm: with-only` is left out of that two-arm score: the run
shows it as a sign the plugin fired and compares nothing on it. The mark
suits a grader that presupposes an output only the plugin asks for (the
limits of a table the no-plugin arm never writes). The grader for the
behaviour a case is named for stays unmarked, because the no-plugin arm
failing it is the baseline; a case whose named behaviour is marked has no
scored row that moves when the rule is deleted.

What each grader type is allowed to see decides where a case can put the
evidence, and the five rules are not interchangeable:

- **`focus` on an `llm` grader and `target` on a `regex` grader resolve one
  literal existing file** in the run's workspace. A glob throws "does not
  exist", a directory throws "is not a regular file", and an absent path
  throws and is scored a fail, `not_contains` included. A grader can therefore
  only read a file whose path is fixed before the run: where the output's name
  would be the run's choice, the case prompt names the path, and where it
  cannot (a memory entry the skill itself names), the grader reads the index
  that points at the file instead.
- **An `llm` grader with no `focus` is shown the run's final message and
  nothing else.** A rubric about a document the run wrote is then a vote on
  the summary of it, which is the one text that cannot hold the evidence.
- **A `file_exists` grader reads the run's own file changes, not the
  workspace tree.** A file the scaffold wrote and the run left alone reports
  missing, and `exists: false` passes whether the run deleted the path or
  never touched it - so no grader proves a deletion, and a case whose
  behaviour is a deletion is hand-graded against the tree. Where a
  scaffold-seeded file's survival is the thing to grade, a regex over a line
  the scaffold wrote does it: that target resolves against the workspace, so
  an intact file passes, a deleted one throws and is scored a fail, and a
  rewritten one fails on the missing line.
- **A `tool_used` grader's `input_match` is tested against the call's whole
  input JSON, the free prose in it included** - `Bash`'s `description` field,
  which the model writes for a reader, and any comment the command itself
  carries. A pattern on a bare identifier matches those as readily as the
  code, and scores a call that changed something else as the act: two matched
  that way in the round the record-audit graders were calibrated on. The
  breadth reaches inside a file body as well, because a heredoc or a `Write`
  carries the whole file with its untouched lines, so a pattern on the line
  the act would change reads a file that still holds that line as the act
  applied - where a hand parse looking for the rewrite reads the same call as
  nothing applied. Anchor on the transformation rather than on either half of
  it: the replaced text together with the line that replaces it, or a whole
  body written without the part the act removes. **The tools such a grader does
  not name are a blind spot its two arms need not share**, because the
  instruction under test is what chooses the tool: a wording asking for every
  row of a record one at a time reads as a rule to use the editing tool, since
  the mutation protocol the same skill carries glosses one-at-a-time as an
  `old_string` unique to the target line - that tool's own parameter, named by
  the instruction and not by the grader. It moved six reps of ten onto `Edit`,
  where the `Bash`-anchored grader read four of ten against a hand reading of
  ten of ten, and the round it was built to decide would have scored as no
  difference. Keep a companion grader over each tool the act could arrive
  through, read those rates across the arms rather than a run at a time, and
  hand-read the draw of every rep one of them fails - which needs `--keep-temp`
  on the invocation, since the runner deletes each run's workspace and a fail
  whose trace is gone cannot be read at all. **And the runner counts a call a
  hook refused as a call**: it keeps every `tool_use` in the trace and flags a
  refused one, but reads that flag only for mock tallies, so a grader on an act
  a hook can stop reads the stopped attempt as the act. The plugin's own skill
  gate stops a commit, a pull request create, a memory write and a subagent
  dispatch once each until the skill that owns the act is loaded, so under it a
  `min: 1` grader on `Agent` passes a rep whose one dispatch was refused, and a
  pattern over `git commit` commands reads a narrated message the gate turned
  away as the one that landed. Anchor a grader on such an act in what the act
  leaves behind - the log the commits landed in, the file a dispatch was told to
  write - or count the refused calls out of the trace by hand before its rate is
  read.
- **A `tool_used: Skill` grader is the trigger's own indicator.** Mark it
  `arm: with-only`: under the two-arm run it is shown and scored in neither
  arm, and the arm without the plugin never evaluates it, so it cannot throw
  there. It is what separates a case's fail into "the skill never loaded" and
  "the skill loaded and its rules did not hold", which no scored grader on the
  outcome can do. Under `--ablation none` the mark does nothing and the
  grader is scored like any other. **And a skill whose condition is a standing
  rule rather than a named task is not reached through that tool at all.**
  Across this suite's kept runs the indicator stands at 59/59 on the cases
  whose prompt names work the skill owns - review this, sync these, file that,
  prune the store - and at 0/13 on the two whose skill fires on how a message
  ends, which no prompt ever asks for; a hand read of ten of those traces found
  no Skill call and no sentence of the skill's own body anywhere in them. The
  brief reaching the model is a different event and does not imply it: a probe
  on the same seeded file answered that the brief was present, while the ten
  reps that resumed that file invoked the skill in none - so a brief that names
  a skill and tells the session to call it is no evidence the session will.
  That first half takes a probe of its own: a rep's trace carries its own turns
  only, so what a resume put in context is not readable from it. A rule living
  in such a skill's body therefore cannot be moved by any round the runner can
  buy, the reps never having read it. Check the indicator before designing the
  arms, not after: the round is either restated to land where every rep does
  read, or it is not a runner round at all.

**A new grader is mechanical unless its condition is irreducibly semantic.**
`regex`, `file_exists` and `tool_used` cost nothing per rep, return the same
verdict every time, and can be tried against an artifact that already exists
before a case is ever run; an `llm` grader is a judgement bought per rep and
read through whatever that judge does with the rubric's shape. The
compact-packing case is the precedent: five regex graders over the findings
file replaced one rubric that had failed three files which pack correctly by
hand.

The boundary is what the pattern is anchored to. **A pattern matching a string
the fixture seeded scores whether the run edited the draft, not whether it did
what the rule asks** - the unaided arm fails by keeping the seeded word, the
treated arm passes by deleting it, and the row looks like the rule working
until the fixture's wording is softened, after which the grader passes in both
arms with nothing to say it has stopped measuring. Anchor a pattern in what the
run must produce - a figure it has to carry across from the notes, a path, a
marker the rule requires - and it is a grader; anchor it in what the fixture
planted and it is a diff detector. Where the rule is about what the run writes
instead, and where - a requirement beside the options, a proportion before the
failure, a frame around an imperative, a pointer whose path the run chooses -
no pattern reaches it, and a judged rubric is the instrument even where it
grades harshly. Both were tried on one family and the trial is written up under
the judge paragraph below.

**A calibration whose reps all land on one side of a grader tests only one of
its two errors.** Reps that all pass can show it failing a good rep, never
passing a bad one, and reps that all fail show the reverse. The gap is widest
on a pattern that must not match, because the side left out is the failure the
grader exists to catch: on a set with no failure in it, a pattern that matches
nothing reads exactly as well as one that matches every failure. The commit
case's narration list read ten of ten on ten reps of the suite's model, none of
which narrated, and five of five on five reps of a smaller model run on the
same fixture, three of which narrate by hand in words the list lacked; only the
second set could show it. Calibrate a grader on reps from both sides of its
line - a smaller model's, a baseline arm's, or artifacts written to sit just
across it, which a regex scores for nothing - and where no rep from the other
side exists, say beside the rate which of its errors is untested.

**The default judge is the weakest part of the instrument, and the next baseline
is run with `--judge-model sonnet`.** Scored against hand labels on two kept
findings files — one that should pass the rubric it is put through and one that
should fail it — the default judge agreed on five of eight cells and the
stronger judge on eight of eight, and every one of the default judge's three
misses is a condition that a hand read and the stronger judge both pass, failed
in all three reps and on twenty-six of the twenty-seven votes behind them.
Consistency is not correctness. Loosening a rubric's wording moved nothing;
splitting it into one grader per condition is what let the stronger judge grade
each condition separately, and left the default judge where it was. The judge
line is about 2% of a baseline's cost and the stronger judge adds $2.00–3.50 to
it, which is the whole price of the difference. `evals/judge-calibration.md`
carries the rows, the recipe for adding more for cents, and the limits of what
they cover; treat a multi-condition rubric over a file of a few kilobytes as
ungraded until a judge has been shown to read that shape. A grader cannot name
its own judge — `model`, `judge_model`, `judge-model` and `judgeModel` are
rejected at load — so this is an invocation-level decision, and the two other
levers stay worth using on their own merits: one condition per grader, and a
hand grade from the `evidence` the run JSON keeps. A baseline taken with the
default judge carries this error on every multi-condition rubric it contains.

**A shape neither judge reads: many tone rubrics over one document.** The two
upstream-report cases put nine of them over a three-kilobyte report, and their
rows were scored by the settled judge and then hand-graded from the kept
`evidence`. On thirty cells it agreed on eighteen, and all twelve disagreements
are the same shape - the judge failing a report the rubric's own text passes: a
title carrying no verdict word and no size, an imperative under a frame the
rubric itself names as an option, an opening that states the clean categories
the rubric asks for. The error does not fall evenly on the two arms, so the
difference between them is not preserved either - a hand read narrowed two rows
in one case and widened the same two in the other. **A family of this shape is
judged for screening and hand-graded for deciding:** a row says where the arms
differ, and any decision resting on one - a regression, a retirement flag, a
promotion, a rate quoted anywhere - is taken from a hand grade of both arms out
of `evidence` first. The cells, the misses quoted, and the mechanical
alternative tried against them are in
[that case's record](evals/reporting-defects-upstream-leaves-the-decisions/results/manual-run.md).

**And a rubric's rate moves with how much the run writes about its subject,
which is what a wording changes - a mechanism the tone family above shares
rather than owns.** One content rubric on a review case, asking whether the
findings report any of a record's true rows as unsupported, held at four of
five on a baseline and fell to none of five - three votes to none in every
rep - under a wording that made each run re-apply every row and write a
per-row verdict list. Every one of those files affirms the rows by name; what
the judge answered is that the findings report on them. Read as a rate it is a
regression the tree does not contain, and it would have declined a wording that
costs nothing. So where a wording changes how much a run writes about what a
rubric judges, that rubric's rate is not comparable across the arms at all:
hand-grade the row in both arms, and say so in the case's record, because the
next round there will read the same rate.

**A judged rate read across a repair to the instrument is two readings, not a
trend, and the move between them can be the judge's alone** - the two sides
differ by a fix everyone agrees was needed, so the new rate looks like the
truth the old one obscured, and the mechanism above offers a cause ready-made.
The same grader as above, on a sibling case, held ten of ten before the
sandbox's git was staged and five of eight after, with the model, the rubric
and the judge unchanged; a hand read scored both sides in full, every file
flagging the record's planted false row and none of the seven true ones. The
ready-made cause is that a working git let the runs re-apply the mutations they
audit, so they wrote verdict language beside the record for the judge to
misread - "all 9 tests stay green", "two mutations survive (Findings 6 and 9),
not one". The ten runs before the repair refute it: each reached a working git
by its full path, each re-applied the contradicted row, and one wrote
"reapplying it leaves all 9 tests green" and "Findings 6 and 9 both survive,
not just 9" in a file the judge passed. The same judge had already failed three
files of ten that a hand read passes, on that case's baseline arm, before any
repair. So hand-grade the row on both sides before either number is carried,
test a cause for the move against the side the repair had not reached before
writing it down, and treat a rate that improves for the instrument's sake with
the same suspicion as one that falls.

A Bash-granting case runs under the OS sandbox, and the sandbox refuses to
start when the Docker configuration directory in the home folder contains
a symbolic link (Docker Desktop's CLI plugins are links); the run then
reports an error on every case and costs nothing. With that cleared, **a git
act inside the sandbox needs a git the sandbox can find, which is not the one
the machine finds**. The system's `git` there is a shim that dies writing a cache file
outside the paths the sandbox allows, and the working binary loses the PATH
search from any position, being a symbolic link into a tree the sandbox will
not let the shell stat - so the lookup skips it and falls through to the shim,
while that same path still runs when named in full. Prepending its directory
therefore changes nothing, which is why the failure reads as a PATH order
problem and is not one. Every case's `fixture.sh` calls
`evals/fixtures/stage-git.sh`, which writes a real wrapper into the run's own
home and a `.zshenv` putting its directory first - the one init file of six
that the run's shell reads, and one the sandbox denies the run itself writing.
**A new case is not finished until its scaffold carries that line**, whether or
not its graded act is a git command, because without it the failure is silent:
it costs the reps turns, it splits them on whether one discovers the absolute
path - seven of ten did in the round that measured it, while three reported the
act as blocked and escalated it, which is the right thing to do with an act
that cannot be performed and a fail of the act's grader all the same - and both
that grader and any grader reading the list the act belongs on are unusable for
the round rather than failed. With the line, ten of ten performed the act on
the re-take and none of them named a path.

Settle a question about what a run's environment holds from what a run keeps,
not from the runner's flags or from how the runner must work. `--keep-temp`
leaves the run root, whose `config/settings.json` is the sandbox policy itself -
which paths are writable, which readable - and whose `out/trace.jsonl` holds
every command a rep ran with its output. A case file's `execution.env` is real
but takes `EVAL_*` keys only; everything else a run's environment needs comes
from the shell the runner is invoked from, or from the scaffold.

The runner's two arms are the plugin and no plugin at all, which answers
whether the plugin changes behaviour; whether one edited sentence does is a
run of the old text against the new, by hand or as two runner runs with
`--ablation none` on two worktrees. Until the machine allows the runner, and
for that comparison, the same test is done by hand:

1. Build one fixture per run with the case's own script, from inside an empty
   directory (`cd <empty dir> && sh <plugin root>/evals/<case>/fixture.sh`): it
   finds the shared builder from its own path and passes the case's variant,
   which a direct call to the builder leaves out.
2. Start five fresh sessions on the model of interest per arm, with the eval
   prompt verbatim — on both models, and so twenty sessions, where the rules
   below make the rule a restraint one — each a process of its own (`claude -p`,
   run from the fixture directory, with `--plugin-dir <that arm's worktree>`
   where the plugin is not installed from the clone, while the files on disk
   hold that arm's text). A subagent dispatched from a working session is not
   fresh: it gets the skill and agent text its parent loaded at start, so an
   arm produced by swapping a file under a live session runs the other arm's
   text. Confirm the arm from each transcript, by a phrase only one text has.
   An agent contract is run as the agent (`--agent`), and a rule about what a
   later message must hold is run as two turns (`--resume`), which the runner
   cannot do.
3. Grade every run against the grader criteria in the case directory, reading
   the tree the run left behind rather than its reply: a run has reported a
   rewrite it never wrote. Where the graded behaviour is an act rather than an
   output - a check run, a mutation applied, a file read - the run's own tool
   calls are the evidence, because the artifact shows only what the run chose
   to report: one rep here re-applied three of a record's four mutations and
   wrote about none of them, and its findings file reads exactly like a rep
   that never looked.

The arms depend on what changed:

- **A wording change:** the current contract and the edited one.
- **A new skill:** no Skill tool at all, and the skill installed but not named
  in the brief - the shape the plugin command runs, and the only arm that
  tests the trigger as well as the rules.

Rules that held in practice, each answering a failure seen here:

- **Stop if the baseline does not fail.** A rule the weaker model keeps
  unaided tests nothing; check which graders the baseline fails before running
  the treatment arm, because a blunt violation is one it strips on its own.
- **Five reps per arm.** A single sample lies in both directions: a wording
  that fails one run in two still passes a lone trial half the time, while
  five clean runs leave such a rule about a three-in-a-hundred chance of
  hiding, and a one-in-three failure about one in eight. Five is where the
  batch is still cheap to run and a survivor is a signal rather than luck.
- **The instrument has a floor, and a rule below it is declined rather than
  measured harder.** Finding that a baseline fails is a question about a rate,
  and the reps above answer it. Showing that a wording *moved* the rate is a
  question about a gap between two arms, and the same reps answer that far
  worse: at five an arm, the smallest gap that is not noise is four runs in
  five - 5/5 against 1/5, or 4/5 against 0/5 - while 5/5 against 2/5 is the
  kind of split a fair coin produces often enough to mean nothing. Ten an arm
  buys a half - 10/10 against 5/10 - and no better; 10/10 against 9/10 is a
  coin toss at any rep count anyone here will pay for. At three reps - what a
  row pinned below the suite's five gives - only a clean sweep separates the
  arms at all, and it does so exactly. So the floor is roughly this: an effect
  of one run in five needs about twenty-five reps an arm to show, and one run
  in ten about forty-five - ninety runs for a single row, several times what a
  tested promotion is worth.
  **A candidate whose expected effect is smaller than that is restated so it
  binds every run, or declined** - and where it is declined, the entry says
  that the effect was below the instrument rather than that the wording
  failed, which are different findings about the mechanism.
- **Before the floor, check that a rep reaches the condition the rule fires
  on.** The floor sizes the gap two arms can separate; it does not ask the
  prior question, whether a rep ever puts the model in the state the rule
  governs. **A condition no rep reaches on its own may still be stageable,
  and those are two findings rather than one.** What the kept runs show is
  whether the condition has occurred, never whether a fixture can be made to
  produce it, so what answers it is the case format's own inputs and not the
  traces: `context.history_file` seeds a prior conversation, resuming a
  transcript the case ships, so a rule about what a second message must do is
  reachable although every case in the suite is a single prompt. A rule whose
  condition the format can seed is untested rather than untestable, and what
  stands between it and a round is a fixture nobody has built. Where staging
  that condition means changing the fixture in the one way that removes it -
  shrinking the window a rule about remaining room would
  be measured against - the rule is untestable by this instrument rather than
  unproven, and the entry says that rather than that the effect was too small,
  which are different findings again. One candidate closed on this check
  alone: its rule is carried by a hook that fires past a context threshold and
  every rep the runner keeps peaks well under that threshold, so both arms
  would have scored alike for a reason having nothing to do with the wording.
- **A seeded prior conversation is a frozen copy of instruction text, and the
  case it feeds has no second arm.** The start hook does not fire on a resume -
  its matcher covers a startup, a clear and a compaction, and a resume is none
  of them - so a replay fixture carries the always-on brief itself, as the
  attachment a recorded session writes. The one run of such a case under
  `with-without` - the probe that established the replay - reported a single
  arm, and the only other kept runs reporting one arm under that flag are ones
  the runner marks `partial` for having been interrupted: a replay case
  contributes no ablation row, so it neither produces a retirement signal nor
  can be read as one, and its wording round is two `--ablation none` runs on
  two trees like every other. What does bind is the freezing, and it binds
  harder than it first read. The seeded copy is the brief as it stood when the
  fixture was generated, so a wording that changes the brief does not reach a
  rep on the fixture alone; the answer written here was that a replay round
  therefore tests a wording landing in the skill's own text, which the run
  loads live. The first replay run falsified that: the reps never called the
  Skill tool, so the skill's text is not live to them either, and neither
  carrier reaches a rep by default. **A replay round tests a brief wording, and
  regenerates the fixture once per arm so each arm's seeded copy carries its
  own text** - by a generator that reads the brief rather than holding a copy,
  and deterministically, so that regenerating it and finding no diff is the
  staleness check against the live file. Should a later run report both arms,
  the seeded brief reaches the arm meant to be without the plugin, and that
  row understates it.
- **A capability rule is measured on the weakest model the plugin supports.**
  Where a rule exists because the model does not know to do the thing, that
  model is both where the gap is and the more sensitive instrument: a rule the
  strongest model keeps from intent alone is the one a weaker model
  negotiates, and that negotiation is the defect the test hunts. The instrument
  is set to that model rather than derived from it — `--model sonnet` on the
  runner invocation above is the floor the skills are held to — which makes it
  the default model of interest, and for this kind of rule the author's own
  reading is already the strong-model pass.
- **A restraint rule is measured on the strongest model in use here as well.**
  Where a rule exists because the model does too much, or applies something
  everywhere, the failure scales with capability and can be absent from the
  instrument entirely: one candidate's failure appeared in eight of ten
  sessions on the strongest model and in none on the instrument, so a baseline
  taken on the instrument alone would have read as a rule that tests nothing.
  Its cost is asymmetric the same way — the strong model over-applies a wording
  it has understood — so the case's other graders are read on the model that
  showed the failure, which is where a wording that over-applies breaks one.
  That candidate was declined on exactly that evidence: three wordings, each
  reaching its own grader and each costing a neighbour. Here the author's
  reading is not the strong-model pass; over-application shows in reps.
- **A limit one arm crosses and the other does not is a difference between
  the arms that is not the rule.** A run the turn cap or the timeout curtails
  is unmeasured rather than failed: the graders that read output it never
  reached carry a verdict the cap produced rather than the run - so the rep is
  replaced, not counted. Its trace is not discarded with it. On the rep that
  met this, four of the eight graders still scored the calls it had made -
  three passing, the act grader among them, and one failing on the edits the
  rep really made - and that rep's draw was read by hand from those calls like
  every other's. The reason it curtailed is itself a finding, with two
  sources only its trace separates: a rule that asks for more work costs more
  turns, and a defect in the instrument costs every rep of both arms turns,
  which leaves both less room and lets the arm asking for more meet the cap
  first - so the crossing reads as the wording's cost alone. The rep this rule
  was drawn from crossed a case's sixty-turn cap under a wording whose own
  sentence prices the work it asks for, and with at least eight of its sixty
  calls spent on a broken git every rep of both arms shared; with the git
  repaired, that case's reps under the same wording peaked at thirty-six. Read
  the turn and duration spread of both arms before reading any grader - from
  each trace's `result` records, not the run JSON's `turns`, which keeps only
  the last of them: a rep that dispatches a subagent can write one record for
  its work and another for the short tail after the agent reports, so a rep
  that ran sixty-five turns reads as six - and read what a curtailed rep spent
  its turns on: where the instrument took them, repair it and re-take; where
  the treated arm's own work brings it near the cap, raise `max_turns` and
  `timeout_seconds` in both arms and re-take, rather than comparing an arm that
  finished against one that was stopped.
- **Fresh sessions, the skill unnamed in the prompt.** Each rep must be an independent
  trial with no context carried from the last, and a skill that fires only
  when named has a trigger defect a named arm would hide.
- **When reps disagree on the shape of the output, the wording is not
  binding.** Restate it as what the output *is* rather than adding words.
- **A grader asks for the failing sentence to be quoted**, so its verdict can
  be audited.
- **The fixture carries one defect: the one under test.** A judge grades
  whatever contradiction it finds, so a header that miscounts its own body or
  a fix the base already had fails the rule's grader on a defect the rule had
  nothing to do with, and the verdict reads as the rule's. Read the fixture
  as the judge will before its first run.
- **Both arms are graded on every grader of the case, never on the new one
  alone.** A rule can reach its own grader in every rep while sending the
  model into a behaviour a neighbouring grader forbids; the baseline arm
  shows which graders the current text already passes, and a rule that
  loses one of them has not earned its place however well it scores on its
  own.
- **A rule promoted at the Strong tier is tested on a second fixture in a
  domain unlike the skill's own examples**, and a second fixture is worth more
  than a sixth rep anywhere else. It is the only way to tell a learned category
  from an echoed example: reps on one fixture cannot separate a wording that
  carries the mechanism from one that matched that fixture's vocabulary, and a
  Strong entry is by definition claimed to hold generally. The payoff is
  measured, not theoretical - the upstream-report rules scored high on their own
  domain and the second domain showed most of that was the weaker model's own
  default against blunt violations, leaving three rules doing the work the skill
  is credited with. Where the skill has no second fixture yet, building one is
  part of that promotion's cost and the entry waits in its tier until it exists;
  landing on one domain and calling it general is the thing this rule forbids. A
  wording that reaches its grader on one domain and not on the other has not
  failed - it has found its boundary, which goes inside the rule's own sentence
  or declines it.
- **The operator's own instruction files come off for the batch.** A hand run
  inherits the user-level instruction file and settings of the machine it runs
  on, and any rule there that bears on the behaviour under test - a command the
  settings deny, an action an instruction reserves for the operator - binds
  every rep in both arms and reads back as the plugin's result. Move those files
  aside for the batch and restore them from a trap that verifies checksums; a
  case whose correct behaviour the machine forbids is otherwise unmeasurable in
  either arm.

**Runs are read across releases, not one at a time.** `python3
scripts/eval-trend.py` folds every run JSON at the top of `evals/results/` -
where a run is copied to be read, the runner's own timestamped directories
beneath it being left alone - into one row per case, grader and release, so a
grader that has been sliding for three releases is no longer indistinguishable
from one that broke yesterday. It reads
only runs the settled judge graded - a row judged by the default judge is not
comparable with one judged by the model named above, and folding them together
records that judge's noise as a trend - and only runs of this plugin's own
suite, so a calibration probe's throwaway case stays out. What it leaves out is
listed with the reason rather than dropped in silence. Two things it lifts out
of the count, because a check that could not have passed is unmeasured rather
than failed: a run that carries an error, such as one the turn cap or the
timeout curtailed, lifted whole since some of its graders read output the run
never reached and nothing in a verdict says which; and a grader skipped at a
cost ceiling. If the runner's skip marker ever stops matching, it still counts
those verdicts, and warns that they may not be real.

**A round's arms are named in the file, never inferred from it.** The two arms
of a wording round are two runs of one case at one release with different skill
text, so they share that fold's whole key and would sit in one row as though
the declined wording were the shipped text - and nothing in the run's own JSON
says which arm a run is: the ablation mode reads `none` in both, each arm being
its own invocation, and the checkout path says only that two runs came from
different trees, never which text either held. Copy a round in as
`<round>@baseline.json` and
`<round>@<wording>.json`: those runs are kept out of the release trend and
reported under `Named arms`, where a round's arms are read against each other
and against no release. What a name cannot fix, the fold flags - a release row
fed by two plugin checkouts is marked and warned about, because one version
run from two working trees is two bodies of text it has no way to tell apart.

## When a rule outlives the model that needed it

A rule lands here because a model needed it, and it is paid for on every load
after that. Nothing holds a model still, so some rules stop being needed — and
the instrument already collects the signal for nothing, because the default run
scores both arms. **A row whose no-plugin arm scores as well as its plugin arm
is the flag.**

It is a flag and not a result: three things produce that shape, and only one of
them is a rule to retire.

1. **The row is not measuring.** A grader that passes without the behaviour
   converges the arms for free — `exists: false` on a path the run never touched
   passes either way, and a rubric with no `focus` votes on a final message that
   holds no evidence in either arm. Show that the row can fail before reading
   its convergence — twenty of this suite's `llm` graders carry no
   `focus`, so this is the common shape and not an exotic one.
2. **Nothing landed behind the row.** A case scores every grader it was given,
   not only the behaviour it is named for, so a row can guard something the
   model does unaided with no rule behind it at all. There is nothing to retire;
   what the row is now is a regression guard on a behaviour that is free today.
3. **The model has internalised the rule.** This one is the retirement, and it
   is confirmed by measurement rather than by the flag.

The same arithmetic hides the flag as readily as it fakes one, so a row that
does *not* converge is a reading only where its graders resolved. One case here
had two file-reading rows sitting at 0/3 in the unaided arm on thrown graders
alone, which reads as the plugin winning both; once the prompt named the file
those graders read, one row still separated (0/3 against 3/3) and the other
scored 3/3 in both arms. The row that converged is the second reading above:
its candidate sentence had been declined, the weaker model having found the
thing it asked for in five of five reps.

**The retirement test is the landing test run backwards.** The rule's text is
whatever its landing commit added — to the skill that owns it, and to any copy
in the brief's core line, an agent contract or the README paraphrase — and the
arm without the rule is the current tree with exactly that removed, in a
worktree the hand run's `--plugin-dir` then points at. Where the landing commit
carried two rules, which happens here, only the hunks of the one under test
come out.

    git show <landing-commit> -- skills agents hooks/session-brief.md README.md \
      | git apply -R --check

**Expect that to refuse, and read the refusal as information.** Reversing a
landing patch works only while nothing has rewritten the lines around it, and
the files rules land in are the files that keep growing: of this repository's
landings to date, 40 of 77 no longer reverse-apply. The diff still says which
sentences the rule is, so where the reversal refuses, take those sentences out
of the current text by hand. The parent's file
(`git show <landing-commit>^:<file>`) is not that arm unless
`git log <landing-commit>..HEAD -- <file>` is empty: where the file has moved on
since, its parent is the current text minus every rule that landed after this
one, which is a different arm than the one under test — and it is wrong silently
where `git apply -R` is wrong loudly.

Run the two texts against each other as an edited sentence is run above, on the
model that kind of rule is measured on. That section carries over, the
both-arms-every-grader rule included, except in two places. **Its first rule
inverts:** here the arm without the rule passing is the result being looked for,
not the signal to stop — the entry check and the exit check are one question
read in opposite directions. And **the comparison point is the landing's own
rows**, which hold only while the case and its fixture have not moved since they
were taken: where a record dates its tables it says which fixture commits
re-stale them, and where it does not, the case's own history answers it. Where
they have moved, or where the rule landed before anyone measured it, the run
supplies both arms itself and the comparison is between those two.

The rule is deleted from every file that carries it — the files the pathspec
above names, not the case, the fixture or the backlog — when the arm without it
matches the rate the arm with it scored at landing.

Record the retirement the way the landing was recorded — the rows in the case's
`results/manual-run.md`, the measurement in the commit body — and keep the case.
A retired rule's case is the only thing that would show the behaviour coming
back, and what was being paid for on every load was the rule, not the case.

Run the sweep when the model in use changes, and while the rows it reads
against are still current: once the comparison has gone stale, every rule in
the sweep costs a fresh two-arm run instead of a reading.

## A skill that carries executable content

Most skills here are instructions alone, and an eval case is the whole test. A
skill that ships a script has two layers instead, and neither substitutes for
the other:

- **The script's own gates, beside the script.** They prove the code does what
  the skill claims. `git-sync` carries `test.sh` (a fixture per outcome, checked
  against the set of outcomes the script publishes),
  `mutate.sh` (each check broken in turn, the suite required to fail on that
  check's own assertion), and `matrix.sh` (the suite re-run under several global
  configurations, because a script inherits the user's). They live in the skill
  directory, not in `scripts/`, which holds this repository's own tooling.
- **An eval case, for the judgement the script cannot make.** Whether the model
  actually runs the script instead of hand-rolling the loop it replaces, and
  whether it reports the result the way the skill asks, are properties of the
  instructions. `git-sync-reports-every-repo` covers both.

The failure this split exists to prevent is a green suite standing in for a
skill nobody follows: every gate can pass on a script the model never invokes.

Two rules the gates themselves have to obey:

- **A check must be able to fail.** Prove it by breaking the thing it watches
  and watching it go red. Two checks written here could not fail at all and
  were green for reasons unrelated to the code: one measured column alignment
  in bytes, which is the quantity the padding exists to make irrelevant, and
  one sent a signal that a shell sets to ignored in background jobs, so it
  never reached the handler under test. A mutation harness is how they were
  caught.
- **A fixture must not assume the environment it was written in.** The
  configuration matrix exists for the script, and it audits the fixtures for
  free: one setup here silently did nothing under a renamed default branch,
  because `checkout -b <name>` fails when a clone already carries that branch,
  and the assertion downstream then reported a healthy repo as a defect. Assert
  the setup built what it claims before asserting anything about the result.

## Versioning and releases

The manifest version in `.claude-plugin/plugin.json` is the release trigger:
CI creates the tag and the GitHub release when a push to main carries a
version that has no release yet, after the guard jobs pass, with notes
generated from the commit messages since the previous tag. A push that leaves
the version alone releases nothing, so the bump is the decision.

| Bump | When |
|---|---|
| Major | a component is removed, or a mode's trigger phrase changes |
| Minor | a skill, agent, or hook changes behavior - a new rule, a changed default, a new component |
| Patch | wording that changes no behavior |

Make the bump in the commit that changes the behavior, not in a separate
"release" commit.

**The generated notes are the starting point, not the release.** A commit
subject states the outcome of a change for this tree, which is not what the
release gave someone who installed the plugin - so a release is not finished
until its notes say in prose what changed for a user: a short paragraph for
each change a subject alone does not explain, what it now does and why that
shape, with the generated list left beneath them. Write each paragraph from the
commit's body, where the mechanism is, rather than from its subject.
`gh release edit <tag> --notes-file <file>` publishes them. Two things bind:
the notes are published text that strangers read, so "What must never appear"
governs every sentence; and `gh auth status` must show the account that owns
this repository before any edit, since a machine can hold several.

## Before pushing

Three checks, in this order. CI runs all three and fails on any of them, but
the first is the one to run before the push rather than after: a leak that
reaches the remote is fixed only by rewriting history.

1. `sh scripts/scan-history.sh` - audits every commit's contents, messages and
   author identities, not just the working tree. A clean `git status` proves
   nothing about history.
2. `sh scripts/generate-inventory.sh` - after adding or removing a skill,
   agent, or hook. It rewrites the canonical inventory statements in the README
   and both plugin manifests from the tree, and CI fails when they are stale.
   The trigger index follows the order of the README's catalog ("What each
   skill solves"), so a new skill needs its catalog entry first: a skill the
   catalog does not name fails the generator rather than landing at the end of
   the table.
3. `sh scripts/check-refs.sh` - verifies the tree's internal references
   resolve.

A fourth check is not a script: **one doc-vs-code pass over the prose that loads
into sessions**, each changed sentence read against the file it cites and its
neighbouring copies. `CLAUDE.md`'s review section says what that means and what
is exempt; what belongs here is the range it runs over, because that is what
decides whether it runs at all.

**The range is a watermark, not the last push.**

    git diff prose-passed..HEAD -- hooks skills agents CLAUDE.md CONTRIBUTING.md README.md

`prose-passed` is a lightweight local tag marking the commit through which this
prose has actually been read - lightweight so that `git push --follow-tags`
never carries it, and created at the last release tag in a clone that has none.
Anchoring the pass to the push instead is what let one range reach four passes'
worth unread: a push deferred by choice is an event that may never arrive, and
the range grows without bound while the instruction still reads as scheduled.

`BACKLOG.md` and `backlog/` are outside that pathspec deliberately - their
entries are not reviewed, and they change often enough to drive the threshold
below on their own - so the parts a session obeys, the three files' headers,
are read in the same pass from a diff over those files alone.

**The pass is its own unit of work**, never started inside a task - reading tens
of commits' prose for sense and executing a task well do not share one session's
attention. It is due when the diff passes about 150 changed lines, when a push
is about to be handed over whatever the size, or when two task units that
changed that pathspec or one of the three files' headers have landed since the
last one, whichever comes first - a unit that wrote only run records, eval
files or backlog entries leaves the pass nothing to read. It closes by fixing
what it found, one workstream per commit, and then moving the tag to the head
it read (`git tag -f prose-passed <sha>`). **Moving the tag is the pass's only
durable output**, so a pass that skips it will be redone from the wrong place -
and a session that finds the threshold crossed says so at its stop rather than
absorbing the pass into the task in hand.

## If something already landed

Do not just delete it in a new commit; the old blob stays reachable. Rewrite the
history with `git filter-repo --replace-text rules.txt --replace-message rules.txt`
(the same file works for both), then re-run the scanner.

**Check grammar afterwards, separately.** Mechanical substitution can leave a
sentence broken while every leak check still passes: substituting a branch name
turned `the <branch> run` into `the a real feature branch run` on the first pass
here. A clean leak scan is not evidence of readable prose - check for doubled
articles (`the a`, `a a`) as a separate step.
