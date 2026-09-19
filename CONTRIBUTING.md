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
pre-commit hook scans it like one. Promoting or declining an entry removes it
from the queue in the same commit - a declined entry keeps one line with its
reason, so the same lesson is not queued twice. An entry is committed by the
session that writes it, in a commit of its own, as soon as it is written: the
commit body carries the observation behind the sentence, which the entry
cannot, and an uncommitted entry is a stray change every later session has to
explain or step around.

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
about how things fail; one that bites twice is a rule, and the second sighting
is the evidence the first one lacked - so an entry is worth a wording round
when it carries two sightings, or one sighting whose failure was measured (a
rate, a run, a named failure). A second sighting is other work or another
place, never the same failure met twice in one pass. An entry that has reached
neither by the time a round reads it moves to Declined with "observed once,
never recurred" - a finding about the mechanism rather than a defeat, and a
later sighting requeues it already carrying two, which makes it eligible at
once. The tier says how much a rule would be worth; the count is what says it
is ready to test.

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
  behaviour is a deletion is hand-graded against the tree.
- **A `tool_used: Skill` grader is the trigger's own indicator.** Mark it
  `arm: with-only`: under the two-arm run it is shown and scored in neither
  arm, and the arm without the plugin never evaluates it, so it cannot throw
  there. It is what separates a case's fail into "the skill never loaded" and
  "the skill loaded and its rules did not hold", which no scored grader on the
  outcome can do. Under `--ablation none` the mark does nothing and the
  grader is scored like any other.

**The default judge is the weakest part of the instrument.** Measured on one
findings file of about six kilobytes that satisfies a four-condition rubric in
full: the default judge failed three of the four conditions three votes to
none, and a stronger judge passed the same file on the same wordings. Loosening
the wording changed nothing; splitting the rubric into one grader per condition
changed nothing under the default judge and was what let the stronger one grade
each condition separately. One file is one measurement, but it is the only
direction the evidence points, so treat a multi-condition rubric over a file of
that size as ungraded until a judge has been shown to read it. The levers are:
one condition per grader, `--judge-model` on the invocation (a grader cannot
name its own judge — the key is rejected at load), and a hand grade from the
`evidence` the run JSON keeps. A baseline taken with the default judge carries this error on every
multi-condition rubric it contains.

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
   prompt verbatim, each a process of its own (`claude -p`, run from the
   fixture directory, with `--plugin-dir <that arm's worktree>` where the
   plugin is not installed from the clone, while the files on disk hold that
   arm's text). A
   subagent dispatched from a working session is not fresh: it gets the skill
   and agent text its parent loaded at start, so an arm produced by swapping
   a file under a live session runs the other arm's text. Confirm the arm
   from each transcript, by a phrase only one text has. An agent contract is
   run as the agent (`--agent`), and a rule about what a later message must
   hold is run as two turns (`--resume`), which the runner cannot do.
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
- **Sonnet as the model of interest.** The skills have to hold on the weakest
  model a user will run them with, and the weaker model is the more sensitive
  instrument: a rule the strongest model keeps from intent alone is the one a
  weaker model negotiates, and that negotiation is the defect the test hunts.
  The author's own reading is already the strong-model run.
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
- **A second fixture in a domain unlike the skill's own examples is worth more
  than a sixth rep.** It is the only way to tell a learned category from an
  echoed example.
- **The operator's own instruction files come off for the batch.** A hand run
  inherits the user-level instruction file and settings of the machine it runs
  on, and any rule there that bears on the behaviour under test - a command the
  settings deny, an action an instruction reserves for the operator - binds
  every rep in both arms and reads back as the plugin's result. Move those files
  aside for the batch and restore them from a trap that verifies checksums; a
  case whose correct behaviour the machine forbids is otherwise unmeasurable in
  either arm.

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

## If something already landed

Do not just delete it in a new commit; the old blob stays reachable. Rewrite the
history with `git filter-repo --replace-text rules.txt --replace-message rules.txt`
(the same file works for both), then re-run the scanner.

**Check grammar afterwards, separately.** Mechanical substitution can leave a
sentence broken while every leak check still passes: substituting a branch name
turned `the <branch> run` into `the a real feature branch run` on the first pass
here. A clean leak scan is not evidence of readable prose - check for doubled
articles (`the a`, `a a`) as a separate step.
