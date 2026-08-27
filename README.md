# Claude delivery skills

Six [Claude Code skills](https://docs.anthropic.com/en/docs/claude-code) that harden
the path from idea to merged PR. They exist because the failure mode of agent-driven
development is rarely the code itself — it is everything around the code: plans built
on unverified claims about how external systems behave, tests that pass but would
never have failed, verification records that claim more than what ran, and review
comments that waste the author's time.

Each skill is a `SKILL.md` instruction package. Claude Code loads it when the task
matches, and the instructions change how the model works — what it checks, in what
order, and what it refuses to skip.

## The chain

```
idea ──> plan-feature ──> implement-plan ──> implementation-gates
              │                  │
              │                  └──> writing-plan-docs   (plan doc → shipped spec)
              │
              └──> (separate ask) review-pr ──> writing-pr-descriptions
```

| Skill | When it fires | What it adds |
|---|---|---|
| **plan-feature** | "I want to build X" | Idea → reviewed plan, then stops. Ground-truths every claim the design makes about systems you did not write, before the plan is written. |
| **implement-plan** | "implement this plan" | Plan → built. Guarantees the plan carries a gates task, checks its premises are settled, delegates execution, runs the gates. |
| **implementation-gates** | work is about to be called done | Proves the new tests could actually fail (targeted mutation sweep), re-checks external claims, and keeps written verification records honest. |
| **review-pr** | "review this PR / branch" | Two-pass multi-axis review: parallel single-axis agents plus a mutation-testing agent, then a fresh-eyes verifier prompted to refute every finding. Posts nothing without being asked. |
| **writing-plan-docs** | creating or syncing a plan/spec doc | Keeps the document a current-state spec, never a changelog — the doc describes the destination, not the route. |
| **writing-pr-descriptions** | creating or syncing a PR description | Describes the diff, not the branch: net delta, deliberate scope boundary, references that survive a squash-merge. |

## The ideas underneath

- **Green is not the bar; "would it have gone red" is the bar.** A test suite that
  honestly passes can still be too weak to catch the defect just introduced. The
  gates run ten to twelve targeted mutations over the new lines and treat every
  non-equivalent survivor as a missing assertion.
- **A coherent argument is not evidence.** Every claim about behavior you did not
  write — what an API returns, what a column means, what a tool prints — gets
  settled by a read-only check against real data, an existing consumer, or
  documentation, in that order, at the moment it is cheapest: plan time.
- **Delegate and patch, never restate.** These skills wrap a repo's own skills
  (or the [superpowers](https://github.com/obra/superpowers) set) rather than
  replacing them. What they add is the checks that chains tend to lack, inserted
  at the moments they are cheapest.
- **Records outlive sessions.** Verification sections, plan docs, and PR
  descriptions are written for the reader who arrives after the branch is merged
  and the context is gone — so they state only what ran, and reference only what
  survives history rewrites.

## Install

Clone into your personal skills directory (Claude Code discovers each
`<skill>/SKILL.md` automatically):

    git clone https://github.com/ViktorSoroka07/claude-delivery-skills ~/.claude/skills

Or copy individual skill folders into a project's `.claude/skills/`.

Works best alongside:

- the [superpowers](https://github.com/obra/superpowers) plugin — `plan-feature`
  and `implement-plan` delegate design, plan-writing, execution, and completion
  to its skills (`brainstorming`, `writing-plans`, `executing-plans`,
  `subagent-driven-development`, `verification-before-completion`,
  `finishing-a-development-branch`) or to a repo's own forks of them;
- `gh` (GitHub) or the `az` CLI / a PAT (Azure DevOps) for `review-pr` — those
  are the two platforms it carries mechanics for.

## Opinionated defaults

Plans live in `docs/plans/`; review findings go to an untracked MD in the repo
root, never into chat; repo-specific facts (gate commands, test commands, bot
reviewers) live in a project memory entry named `review-repo-nuances` that the
skills read and maintain. Adjust to taste — the skills state their mechanisms, so
the seams are visible.

## Provenance

These skills are distilled from real delivery work on production repositories.
Identifying details are removed; the mechanisms — each one paid for by an actual
incident — are what remain. `CONTRIBUTING.md` explains how that line is kept.
