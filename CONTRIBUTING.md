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
into its skill goes in [`BACKLOG.md`](BACKLOG.md), naming the skill it is aimed
at. The file is tracked, so an entry meets the same bar as a skill and the
pre-commit hook scans it like one. Promoting, parking or declining an entry
removes it from the queue in the same commit - a parked or declined entry
keeps its line, so the same lesson is not queued twice. An entry is
committed by the session that writes it, in a commit of its own, as soon as
it is written: the commit body carries the observation behind the sentence,
which the entry cannot, and an uncommitted entry is a stray change every
later session has to explain or step around.

**Queuing starts with a search, not with a line.** Nobody re-reads a backlog,
and the one moment anyone has a mechanism in hand with the file open is when
they are about to queue it - so that is where recurrence gets recorded. Search
the file for the mechanism first: two or three words of what goes wrong, not
the words an entry would have used, because the same defect arrives described
differently every time, and a doubtful match is read in full before a second
line is written. Where the mechanism is already there, add a sighting to that
entry instead of a new line, so each entry carries its own count and
recurrence needs no separate bookkeeping. Only a session that hit the
mechanism itself adds a sighting: reading an entry and agreeing with it is not
an observation.

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
it eligible at once. Declined is the other outcome and a different one: a
wording tested and failed, or a lesson that belongs outside the skills. The
tier says how much a rule would be worth; the count is what says it is ready
to test.

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
brief changes only when the pointer or the core does.

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
evidence, and the four rules are not interchangeable:

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
- **A `tool_used: Skill` grader is the trigger's own indicator.** Mark it
  `arm: with-only`: under the two-arm run it is shown and scored in neither
  arm, and the arm without the plugin never evaluates it, so it cannot throw
  there. It is what separates a case's fail into "the skill never loaded" and
  "the skill loaded and its rules did not hold", which no scored grader on the
  outcome can do. Under `--ablation none` the mark does nothing and the
  grader is scored like any other.

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

A Bash-granting case runs under the OS sandbox, and the sandbox refuses to
start when the Docker configuration directory in the home folder contains
a symbolic link (Docker Desktop's CLI plugins are links); the run then
reports an error on every case and costs nothing. With that cleared, a case
whose run uses git can still die inside the sandbox where the system's git is
a shim that writes a cache file outside it; such a run leaves no tree to
grade and is unusable, never a fail, and a real git first on the path ends
it. The runner's two arms are the plugin and no plugin at all, which answers
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
  governs. Where staging that condition means changing the fixture in the one
  way that removes it - shrinking the window a rule about remaining room would
  be measured against - the rule is untestable by this instrument rather than
  unproven, and the entry says that rather than that the effect was too small,
  which are different findings again. One candidate closed on this check
  alone: its rule is carried by a hook that fires past a context threshold and
  every rep the runner keeps peaks well under that threshold, so both arms
  would have scored alike for a reason having nothing to do with the wording.
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
scripts/eval-trend.py` folds every kept run under `evals/results/` into one row
per case, grader and release, so a grader that has been sliding for three
releases is no longer indistinguishable from one that broke yesterday. It reads
only runs the settled judge graded - a row judged by the default judge is not
comparable with one judged by the model named above, and folding them together
records that judge's noise as a trend - and only runs of this plugin's own
suite, so a calibration probe's throwaway case stays out. What it leaves out is
listed with the reason rather than dropped in silence. Two things it refuses to
count as failures, because a check that could not have passed is unmeasured
rather than failed: a run the runner curtailed, whose graders all carry a
verdict they could not have earned, and a grader skipped at a cost ceiling. If
the runner's skip marker ever stops matching, it says so instead of counting
those verdicts as real.

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

`BACKLOG.md` is outside that pathspec deliberately - its entries are not
reviewed, and they change often enough to drive the threshold below on their
own - so the one part of it a session obeys, its header, is read in the same
pass from a diff over that file alone.

**The pass is its own unit of work**, never started inside a task - reading tens
of commits' prose for sense and executing a task well do not share one session's
attention. It is due when the diff passes about 150 changed lines, when a push
is about to be handed over whatever the size, or when two task units have landed
since the last one, whichever comes first. It closes by fixing what it found,
one workstream per commit, and then moving the tag to the head it read
(`git tag -f prose-passed <sha>`). **Moving the tag is the pass's only durable
output**, so a pass that skips it will be redone from the wrong place - and a
session that finds the threshold crossed says so at its stop rather than
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
