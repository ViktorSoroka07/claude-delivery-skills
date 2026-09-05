# Keeping this repository publishable

These skills are refined from real delivery work. That is what makes them good,
and it is also the risk: the work happens in private repositories, and the
details leak in through provenance notes rather than through code.

## Setup (once per clone)

    git config core.hooksPath .githooks
    cp .leakwords.local.example .leakwords.local   # then fill it in

The hook does nothing until `core.hooksPath` is set - git does not run hooks
from a tracked directory on its own, and it never ships `.git/hooks` in a clone.
**A clone with no setup step has no protection.**

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
`graders/*.md` (one grader per file), and `case.yaml` whose scaffold script
builds the fixture repo from `evals/fixtures/`. Run with `--scaffold`, pin
the model with `--model`, and read the ablation arm - the command runs each
case with and without the plugin, which is the baseline for free:

    claude plugin eval . --scaffold --model sonnet --runs 5

The command is early-access and was not enabled when the suite was written,
so two things are unconfirmed and marked in the case files: the scaffold's
working directory (the cases assume the plugin root), and whether an `llm`
grader accepts a file target. Fix them once when the command first runs and
delete this sentence.

Until it runs here, the same test is done by hand: build a fixture with
`sh evals/fixtures/refund-console.sh <empty dir>`, dispatch five fresh
subagents on the model of interest with the current contract and five with
the edited one, and read every report against the grader criteria in the
case directory. Rules that held in practice: stop if the baseline does not
fail; five reps per arm, single samples lie; when reps disagree on the shape
of the output, the wording is not binding - restate it as what the output
*is* rather than adding words.

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

Two rules the gates themselves have to obey.

**A check must be able to fail.** Prove it by breaking the thing it watches and
watching it go red. Two checks written here could not fail at all and were green
for reasons unrelated to the code: one measured column alignment in bytes, which
is the quantity the padding exists to make irrelevant, and one sent a signal
that a shell sets to ignored in background jobs, so it never reached the handler
under test. A mutation harness is how they were caught.

**A fixture must not assume the environment it was written in.** The
configuration matrix exists for the script, and it audits the fixtures for free:
one setup here silently did nothing under a renamed default branch, because
`checkout -b <name>` fails when a clone already carries that branch, and the
assertion downstream then reported a healthy repo as a defect. Assert the setup
built what it claims before asserting anything about the result.

## Versioning and releases

The manifest version in `.claude-plugin/plugin.json` is the release trigger:
CI creates the tag and the GitHub release when a push to main carries a
version that has no release yet, after the guard jobs pass, with notes
generated from the commit messages since the previous tag. A push that leaves
the version alone releases nothing, so the bump is the decision.

Bump the minor version when a skill, agent, or hook changes behavior - a new
rule, a changed default, a new component. Bump the patch version for wording
that changes no behavior. Bump the major version when a component is removed
or a mode's trigger phrase changes. Make the bump in the commit that changes
the behavior, not in a separate "release" commit.

## Before pushing

    ./scripts/scan-history.sh

This audits every commit's contents, messages and author identities - not just
the working tree. A clean `git status` proves nothing about history.

Adding or removing a skill, agent, or hook changes the component inventory: run
`sh scripts/generate-inventory.sh` afterward - it rewrites the canonical
inventory statements in the README and both plugin manifests from the tree, and
CI fails with that same command when they are stale. The trigger index follows
the order of the README's catalog ("What each skill solves"), so a new skill
needs its catalog entry before the generator will run: a skill the catalog
does not name fails the generator rather than landing at the end of the table. `sh scripts/check-refs.sh`
must also pass; it verifies the tree's internal references resolve.

## If something already landed

Do not just delete it in a new commit; the old blob stays reachable. Rewrite the
history with `git filter-repo --replace-text rules.txt --replace-message rules.txt`
(the same file works for both), then re-run the scanner.

**Check grammar afterwards, separately.** Mechanical substitution can leave a
sentence broken while every leak check still passes: substituting a branch name
turned `the <branch> run` into `the a real feature branch run` on the first pass
here. A clean leak scan is not evidence of readable prose - check for doubled
articles (`the a`, `a a`) as a separate step.
