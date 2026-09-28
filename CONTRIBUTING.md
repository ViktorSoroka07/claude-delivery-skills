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
brief changes only when the pointer or the core does. The line between the
opening paragraph and the rules is no rule: it makes a conversation's first
tool call a load of `tracking-open-asks`, because how a message ends is work no
request names, so a pointer to that skill is never followed. A moment that is a
tool decision is the one form measured to load a skill no request names, and
this one has bound only in fresh conversations: the probe of a line with the
same imperative loaded the skill in none of five reps resuming a
conversation, and after a compaction it is unmeasured.

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

What each grader type is allowed to see, and what besides the rule under test
changes what it sees, decide where a case can put the evidence and how to read
it:

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
  whose trace is gone cannot be read at all. **And the runner counts a refused
  call as a call**: it keeps every `tool_use` in the trace and flags one that a
  hook or the run's permission settings refused, but reads that flag only for
  mock tallies, so a grader on an act either can stop reads the stopped attempt
  as the act. The settings refuse calls with no hook involved: the trace copies
  kept under `evals/results/` from before the gate hold 35 such refusals, and in
  three reps `reapplied-the-contradicted-row` counted a refused source mutation,
  each beside one that ran, so no verdict moved. The plugin's own skill
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
  rule rather than a named task is not reached through that tool by being
  named.** Across the kept runs this was first measured on, all on the
  suite's model, the indicator stood at 59/59 on the cases whose prompt names
  work the skill owns - review this, sync these, file that, prune the store -
  and at 0/13 on the two whose skill fires on how a message ends, which no
  prompt ever asks for, though the brief named that skill and its trigger; a
  hand read of ten of those traces found no Skill call and no sentence of the
  skill's own body anywhere in them. The brief reaching the model is a
  different event and does not imply it: a probe on the same seeded file
  answered that the brief was present, while the ten reps that resumed that
  file invoked the skill in none - so a brief that names a skill and tells
  the session to call it is no evidence the session will. That first half
  takes a probe of its own: a rep's trace carries its own turns only, so what
  a resume put in context is not readable from it. **What reaches such a
  skill is a moment the session acts on.** The brief makes a conversation's
  first tool call a load of `tracking-open-asks`, which put it first in every
  fresh rep measured, all on the suite's model - five of five under an
  earlier wording with the same imperative, twenty-three of twenty-three
  under the landed one - and loaded it in none of five reps resuming a
  conversation under that earlier wording; and the skill gate stops a commit,
  a pull request create, a memory write and a subagent dispatch once each
  until the skill owning the act is loaded. In every kept rep it stopped - a
  commit on a smaller model, a dispatch on the suite's - the first call it
  made after the stop loaded that skill, though the retry passes whether or
  not one does, and a pull request create or a subagent's own act is
  unmeasured. No case yet reaches the memory stop. It matches the directory the
  session keeps memory in, the one under the config directory a run's
  environment names included, but the runner's deny rules cover a run's
  config directory: a shell write the gate parses, naming its own memory under
  `config/projects/` as the run's `CLAUDE_CONFIG_DIR` spells it, would be
  stopped and then refused, and a `Write` or `Edit` there is refused before
  the gate sees it, since those tools check deny rules while validating their
  input, which the CLI does ahead of every hook (read from 2.1.280). When this
  was written the 198 traces in all the kept run roots held 47 calls naming a
  run's memory directory, every one a listing or a read and every one refused,
  and none a write; and the memory case stages its store under
  `store/projects/`, which the stop does not match. A case that wants the stop
  has the rep write through the shell to a path the stop matches - the gate
  runs before the shell's permission check, so it stops even a write that
  check then refuses - or `Write` a new file where the stop matches and no
  deny rule covers the path, and grades the stop and the load rather than a
  written file. A rule in the body
  of a standing-rule skill that neither moment reaches on the case, or of
  `tracking-open-asks` in a resumed conversation whose seeded turns never
  loaded it, still cannot be moved by any round the runner can buy, the reps
  never having read it. A replay fixture can seed that load itself, as the
  first turn of a fresh conversation writes it, and a resume passes the seeded
  body to the model (the replay paragraph below). On such a fixture the
  indicator no longer separates the two fails: it reads only a second load
  by the rep, so its 0/N says nothing about arrival, and whether the seeded
  body arrived is read from a probe rather than from it.
  Check the indicator before designing the arms, not after: the round is
  either restated to land where every rep does read, or it is not a runner
  round at all. And on a case either moment reaches, read a lit indicator as
  the moment firing, not as the prompt reaching the trigger: a fresh case's
  reps load `tracking-open-asks` whatever they were asked, and a rep the gate
  stopped loads the owning skill because it was stopped.
- **The landing sweep reaches every case whose rep changes a rule file git
  does not ignore, or a `CLAUDE.local.md` whether git ignores it or not - one
  inside an ignored directory only where the rep wrote it with `Edit` or
  `Write`.** In the arm carrying the plugin, a turn that wrote a `SKILL.md`,
  `CLAUDE.md`, `CLAUDE.local.md`, `AGENTS.md`, `GEMINI.md`, `CONTRIBUTING.md`
  or `README.md`, or a `.md` directly under `agents/`, under
  `skills/<name>/references/` or under a `references/` beside a `SKILL.md`, is
  handed at its stop the lines elsewhere that still carry what its change
  replaced, where the hook finds any, and the rep acts on them before its turn
  ends. The arm without the plugin has no such moment, so a grader on any file
  the hand-off can name reads the hook's work beside the wording's. The hook
  loads no skill, and none of the thirty-five eval reps it spoke to loaded
  `maintaining-project-memory`, whose rule it carries, so that skill's
  indicator does not show it firing. When this was written, the reps of five
  cases in the kept runs wrote a rule file: the three sweep cases and the
  writer case by design, and the tracking case, whose rename edits the
  fixture's `README.md` in every rep. Fed each rep's own `Edit` and `Write`
  calls up to its first stop on a fresh build of the fixture, the hook handed
  lines on the sweep cases and nothing to any of the thirty-eight tracking and
  writer reps, so those two cases' rates stay comparable across the landing
  only while a replay of their reps stays silent. The hand-off is not in the
  stream-json trace: it is a `hook_additional_context` attachment in the
  session transcript under the run's `config/projects/`, which only
  `--keep-temp` keeps, and the hook's state is under the run's `sealed/tmp/`.
  So replay the hook on a case's reps before designing a round on any case
  whose reps write a rule file, and where it speaks, read the hand-off from
  the transcript before reading a grader.

**A grader file's frontmatter ends at the first `---` after its opening line,
wherever that `---` sits, and so does a `prompt.md`'s.** The runner reads both
the same way, and a mock responder file too: it drops a leading byte-order
mark, matches `/^---\s*\n([\s\S]*?)---\s*\n?/`, and parses as YAML only the
text between a first line of `---` and the next three dashes - mid-line, inside
a quoted value or in a comment as readily as on a line of their own. Dashes
inside the frontmatter therefore cut it short. Where the cut leaves invalid
YAML, a quote left open say, or YAML that is not a mapping, or drops a key the
body cannot stand in for, such as `type` or a `tool_used` grader's `tool`, the
case is refused at load and costs nothing. Any other cut loads without a
warning. The value is shortened at the dashes, so an unquoted `^---$` becomes
`^`, and every key after the cut falls to its default. In every regex grader
here `match` and `flags` follow `pattern`, and in every `tool_used` grader
`min`, `max` and `arm` follow `input_match`, so those are the likely losses: a
lost `match` reads `contains`, so a pattern cut to a bare anchor - `^`, or the
lookbehind a whole-file pattern opens with - passes on every target whatever
mode the grader declared, and a `not_contains` grader whose pattern survived
the cut passes exactly where the text it forbids is present; a lost `min` and
`max` turn a `max: 0` grader into one that requires the call it forbids. A lost
`target` or `focus` sends the grader back to the final message. A regex, `llm`
or `baseline` grader whose `pattern` or `criteria` was among the lost takes the
rest of the file - the rest of the cut line, the lost keys, the closing fence
and the body - as its pattern or rubric, and a `prompt.md` cut that loads puts
that text at the head of its prompt. A whole-file pattern over a file with
frontmatter fences of its own is where the dashes arrive unnoticed: the landing
sweep's restraint case was refused on its first launch for one. Spell three
dashes in a pattern `-{3}` and keep the value quoted, as every pattern and
`input_match` here is, so a run the spelling missed leaves the quote open and
the case refused rather than loaded. Or put the pattern alone in the body: a
regex grader whose frontmatter names no pattern takes its whole body, trimmed,
as the pattern, so that body carries no rationale beside it; the body may hold
`---` freely, and it is read raw rather than as YAML, so a pattern moved there
from a double-quoted value loses one level of backslashes - `\n`, not `\\n`.

**A file whose first line is not `---` has no frontmatter at all.** A grader
file with a blank line above its fence is left out of the case without a
warning - or, where it was the case's only grader, the case is refused as an
`invalid case.yaml` with `graders: Required`, which blames `case.yaml` whether
or not the case has one and names no grader file - and a `prompt.md` hands its whole
frontmatter to the model as part of the prompt and runs on the defaults for
every key it held, turns, timeout, tools, runs and tags alike. Each file is
free to check before a launch - that expression and a YAML parse in Bun, whose
parser the runner calls, show what the runner will read - and every grader file
and `prompt.md` in the suite read as its author wrote it when this was written.
The match is then `new RegExp(pattern, flags)` over the target, a leading
byte-order mark dropped first from a file target: the runner applies no flag
the grader does not declare, bar the `g` a `count:N` match adds to count, and
`flags` defaults to empty, so `^` and `$` anchor the whole target rather than
its lines, and `$` its very end, never before a final newline. The
`input_match` of a `tool_used` or `tool_order` grader is compiled with no flags
at all.

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

**Which tools a run had is settled the same way: a case's `allowed_tools` is
neither the tool set nor the grant.** The runner starts each run in `dontAsk`
mode, where a call that would have to ask is refused, and passes it an allow
list made of every tool the invocation's `--allow-tools` grants - the
file-writing ones scoped to the workspace and the run's temp directory - plus
the case list's entries from the runner's read-only set (`Read`, `Glob`,
`Grep`, `Skill`, `Agent` and a few more). A tool the invocation grants is
allowed whether the case lists it or not, and a gated tool the case lists
without a grant is only reported as not granted. Every tool that is neither
granted nor in that read-only set is withheld from the session, bar a few the
runner never withholds - `ToolSearch` and, beside a granted `Edit` or `Write`,
`NotebookEdit` among them, both listed in every `init` event counted below
though neither is in that read-only set and no invocation on record grants
either - so a call to a withheld tool never runs, though the model can still
name one and the trace keeps the attempt; the read-only set is never
withheld. The `init` event near the head of each trace lists the tools the
session holds.
When this rule was written the run JSONs under `evals/results/` pointed to 192
kept run roots holding a trace, across seven cases, and in every one that list
names tools the case never did - on the commit case, whose list names none of
the three, `Edit` and `Write`, which the invocation granted, and `Task`, the
name `init` gives the dispatch tool the cases list as `Agent`. Every refusal
those traces record is of a tool its case does list, turned away by a path
check - a directory the run's deny rules cover, a file outside the workspace
under `dontAsk`, a `cd` the checker cannot resolve - or by the skill gate; and
the one tool the session held that any rep called off its list ran every time.
The mutation case leaves out `Skill`, so its runs held the tool without an
allow rule for it; in the arm of its runner re-take that carries the
first-tool-call line every rep called it twice, the Skill tool's own
permission check let each call through, and each returned "Launching skill".
The allow and deny lists are passed on the run's command line and the run root
keeps neither: its `config/settings.json` carries the sandbox's path policy
and no block of tool permissions. So read which tools a run had from its
`init` event, and whether a call to one could run from that call's result,
never from the case file - nor from the call's presence in the trace, since
the runner counts a refused call as a call (the `tool_used` rules above).

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
- **A draw bought to re-check a reading is read without the draw that
  prompted it.** A rate that looks wrong is what buys the extra reps, so
  pooling them with the draw that looked wrong counts that draw twice - once
  as the reason the re-check was bought and again as evidence for what it
  found - and a draw picked out for looking wrong overstates the gap on
  average, which pooling carries into the verdict. Size the re-check by the
  floor above on its own draws, and set its bar on those draws alone before
  they run. The same holds for every purchase after it: a re-check whose own
  reading comes back undecided and buys more draws is itself a prompting
  reading, so the new draws are read without it too, unless the extension
  and its bar on all the draws were fixed before the first of them ran. The
  pooled rate may stand beside the bar, never in its place. A re-check that
  does not convict leaves a gap below its floor open, not cleared. And
  whenever one grader of many crosses a threshold - the one that prompted a
  re-check included - say how many were read, since the more graders a round
  reads, the likelier one of them crosses by chance alone. The instance is
  the commit case, read on the suite's model as a neighbour of the brief's
  first-tool-call line and the skill gate. The grader asking the currency
  commit's body to say why read 2/5 on the first draw of the plugin carrying
  both, against 14/15 by hand on fifteen earlier reps with neither the line
  nor a gate that fired, ten of them on the case's earlier prompt. The
  re-check's bar, set on its own five draws before they ran, met 3/5 and came
  back undecided; the session then pooled, read 5/10 against 14/15 as a cost,
  and five more draws were bought, reading 4/5 - every draw by hand as by the
  judge. Pooled, 9/15 against 14/15 is p ≈ 0.04, one-sided by an exact test,
  and a bar the session had set on the pooled rate said decline; read without
  what prompted them, the second draw is p ≈ 0.14 and the third p ≈ 0.45 -
  7/10 together, p ≈ 0.16 - and fourteen graders had been read across the two
  cases watched as neighbours. The line landed, and since ten reps against
  14/15 convict only an observed gap of about four in ten or wider (5/10 is
  p ≈ 0.02, 6/10 p ≈ 0.06), its body row stays a watched cost that the case's
  next round reads first.
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
  loads live. The first replay baseline falsified that: none of its ten reps
  called the Skill tool, so the skill's text reached none of them - under a
  brief that did not yet make that load a conversation's first tool call.
  Under a brief that did, it loaded in none of five reps resuming the case
  either, the seeded turn having ended with no call. The generator now seeds
  the load a fresh conversation's first turn makes - the Skill call, its
  result and the skill's body as the harness injects it - and a one-rep probe
  on a file seeded that way quoted a sentence only that body holds, word for
  word, with no Skill call of its own. So the skill's text is frozen in the
  seed too, and **a replay round tests whichever text the seed carries, the
  brief's or the skill's, and regenerates the fixture once per arm so each
  arm's seeded copy carries its own text** - by a generator that reads both
  rather than holding a copy, and deterministically, so that regenerating it
  and finding no diff is the staleness check against the live files, which
  `scripts/check-refs.sh` runs. Every kept rate from before the seeded load
  is a rate on the fixture without it. Should a later run report both arms,
  the seeded text reaches the arm meant to be without the plugin, and that
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
- **A condition that decides which reps count is one test in both arms, and a
  replay that settles it for a rep is fed every input the live code reads, or
  names the one it is not fed.** Where whether a rep counts rests on what a
  component did at some moment - a hook's hand-off at a stop, say - the arm
  without the component has nothing to read, and a replay stands in: the
  component's code, as the treated arm ran it, run offline on a fresh build of
  the fixture brought to the rep's state at that moment. A replay agrees with
  the live run except where an input it was not given, or was given in a form
  the live run did not see, matters, and those reps are not rare by chance,
  since what a case exists to catch is often the behaviour that writes that
  input. The landing-sweep hook leaves out the lines the turn wrote in a rule
  file or with `Edit` or `Write`, and learns of a write outside its rule files
  only from the turn's successful `Edit` and `Write` calls in the session
  transcript. The landing sweep's restraint case first replayed it with no
  transcript: on a turn that brought every copy into line before its first
  stop, both false positives included, the hook fed that turn's transcript was
  silent, while the replay handed the false positive that is not a rule file -
  so the rule re-taking a silent treated rep as an instrument defect would have
  dropped the double fail the case was built to catch. A blind verifier found
  it before any draw, and it was reproduced. The replay now applies the rep's
  own successful `Edit` and `Write` calls from before its first stop and hands
  the hook a transcript of exactly those. So list what the live code reads
  before a replay decides anything - for that hook, among others, the prompt id
  and working directory the stop names, the rule files as they stood at the
  prompt with the `HEAD` and time that snapshot recorded, the turn's calls in
  the transcript, git's `HEAD`, reflog, index and ignore rules at the stop, the
  lines it has already handed in the session, and the clock its search runs
  against - and feed each one, or name the one left out and read by hand every
  rep it could change; and read a replay's agreement with the live component on
  the reps at hand as clearing it only for the shapes those reps took. The same
  case's first draft filtered one arm alone - a treated rep counted only where
  the hook handed both false positives or the rep had written one before its
  first stop, every baseline rep that met the case's condition counted - and a
  filter's drops are not a random draw: the reps it could drop were treated
  reps that had written no false positive early, so the counted treated reps
  would have leaned toward the early writers, each a fail by the case's own
  rule, and the treated rate down with them wherever the dropped reps passed
  more often than the counted ones. The condition is now one test in both arms,
  read from the hand-off where the hook ran and from the replay where it did
  not, and a rep either arm drops for it is replaced.
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
those verdicts, and warns that they may not be real. The lift is the reading's
repair, not the launch's, so set `--max-cost-usd` above a batch's expected
spend: the runner checks the ceiling before each launch against what is
already spent, never against the run about to start, so a run still launches
below the ceiling and, once its cost reaches what is left, has every judged
grader scored as a fail - and a ceiling set far below one run's cost is no
preview of what a filter selects, since it buys the first run whole.

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
   resolve, and that each replay case's `history.jsonl` is byte-identical to
   what its `make-history.py` builds from the tree now. Any change that alters
   what a generator builds - to the brief, to the skill a seed loads, or to the
   generator itself - fails it as stale until the fixture is regenerated,
   naming the command that regenerates it. A generator that cannot build at
   all, broken or missing a file it reads, fails it as `fails to build`
   instead, which names only the generator and discards its error output.

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
