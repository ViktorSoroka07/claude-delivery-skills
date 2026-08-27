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

## Before pushing

    ./scripts/scan-history.sh

This audits every commit's contents, messages and author identities - not just
the working tree. A clean `git status` proves nothing about history.

## If something already landed

Do not just delete it in a new commit; the old blob stays reachable. Rewrite the
history with `git filter-repo --replace-text rules.txt --replace-message rules.txt`
(the same file works for both), then re-run the scanner.

**Check grammar afterwards, separately.** Mechanical substitution can leave a
sentence broken while every leak check still passes: substituting a branch name
turned `the <branch> run` into `the a real feature branch run` on the first pass
here. A clean leak scan is not evidence of readable prose - check for doubled
articles (`the a`, `a a`) as a separate step.
