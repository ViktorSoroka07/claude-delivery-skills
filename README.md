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
              │                 │
              └────────┬────────┘
                       v
              writing-plan-docs   (the plan at start, the shipped spec at finish)
```

`review-pr` and `writing-pr-descriptions` sit outside the build chain — each
fires on its own request: reviewing an existing PR or branch, and creating or
syncing a PR description.

| Skill | When it fires | What it adds |
|---|---|---|
| **plan-feature** | "I want to build X" | Idea → reviewed plan, then stops. Ground-truths every claim the design makes about systems you did not write, before the plan is written. |
| **implement-plan** | "implement this plan" | Plan → built. Guarantees the plan carries a gates task, checks its premises are settled, delegates execution, runs the gates. |
| **implementation-gates** | work is about to be called done | Proves the new tests could actually fail (targeted mutation sweep), re-checks external claims, and keeps written verification records honest. |
| **review-pr** | "review this PR / branch" | Two-pass multi-axis review: parallel single-axis agents plus a mutation-testing agent, then a fresh-eyes verifier prompted to refute every finding. Posts nothing without being asked. |
| **writing-plan-docs** | creating or syncing a plan/spec doc | Keeps the document a current-state spec, never a changelog — the doc describes the destination, not the route. |
| **writing-pr-descriptions** | creating or syncing a PR description | Describes the diff, not the branch: net delta, deliberate scope boundary, references that survive a squash-merge. |

## What it looks like

An illustrative `review-pr` run — what the skill's contract produces, abridged:

```
> review PR 214

Axes chosen from the diff: mutation + correctness + doc-vs-code — tested
logic changed and the PR carries a spec. Say the word to add or drop one.

  [parallel subagents review a pinned worktree at commit a1b2c3d;
   the mutation agent edits files in its own worktree]

Pass 2 (fresh-eyes verifier, prompted to refute each finding):
5 confirmed, 2 refuted, 1 adjusted, 1 added by the sweep.

review-findings-214.md written — 3 medium, 3 minor. Nothing was posted;
say "post" to publish the final findings to the PR as inline threads.
```

The mutation axis measures rather than reads — its evidence looks like:

| Mutation | Result |
|---|---|
| `>=` → `>` at the window boundary | KILLED by `test_window_edges` |
| drop `retries` from the emitted row | SURVIVED → finding: the missing assertion, spelled out |

That's the default path. `review-pr` also carries, each behind its own ask:
**deep mode** (a blind re-review plus one isolated skeptic per finding),
**staged posting** (GitHub PENDING reviews, for holding publication until you
submit), **apply mode** (fixes land only after every new test is proven failing
against the pre-fix code), and **thread disposition** (reply-and-resolve with
verification that each fix actually landed). The skill files are the full
documentation — every mode is specified where the agent reads it.

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

Claude Code discovers each `<skill>/SKILL.md` folder placed directly in a
skills directory. On a machine with no personal skills yet:

    git clone https://github.com/ViktorSoroka07/claude-delivery-skills ~/.claude/skills

If `~/.claude/skills` already has content, clone the repo elsewhere and copy
the skill folders you want into it — or into a project's `.claude/skills/` —
re-copying after each `git pull` (a nested clone puts the `SKILL.md` files one
level too deep to be discovered).

Works best alongside:

- the [superpowers](https://github.com/obra/superpowers) plugin — `plan-feature`
  and `implement-plan` delegate design, plan-writing, execution, and completion
  to its skills (`brainstorming`, `writing-plans`, `executing-plans`,
  `subagent-driven-development`, `verification-before-completion`,
  `finishing-a-development-branch`) or to a repo's own forks of them;
- `gh` (GitHub) or the `az` CLI / a PAT (Azure DevOps) for `review-pr` — those
  are the two platforms it carries mechanics for.

Works on macOS, Linux, and Windows: the guard scripts are POSIX sh, which Git
for Windows already provides — hooks run under its bundled Git Bash, no extra
setup. CI exercises all three.

## Opinionated defaults

Plans live in `docs/plans/`; review findings go to an untracked MD in the repo
root, never into chat; repo-specific facts (gate commands, test commands, bot
reviewers) live in a project memory entry named `review-repo-nuances` that the
skills read and maintain. Adjust to taste — the skills state their mechanisms, so
the seams are visible.

## Beyond Claude Code

The protocols here are assistant-agnostic: the mutation-sweep protocol, the
evidence hierarchy (real data > an existing consumer > documentation > a
coherent argument), the plan-doc lifecycle, the PR-description contract, and
the finding format all lift cleanly into Cursor rules, Copilot instructions,
or an `AGENTS.md` — `writing-plan-docs` and `writing-pr-descriptions` port
almost verbatim.

The orchestration does not: subagent dispatch (parallel single-axis reviewers,
the clean-context verifier), skill-to-skill chaining, and project memory are
Claude Code machinery, and the full skills assume them. Ported without those
primitives, `review-pr` collapses into "one context reviews carefully" — the
failure mode it exists to escape. So this repo stays Claude Code-native, and
the portable parts are yours to lift.

## Provenance

These skills are distilled from real delivery work on production repositories.
Identifying details are removed; the mechanisms — each one paid for by an actual
incident — are what remain. `CONTRIBUTING.md` explains how that line is kept.

A personal project — not affiliated with or endorsed by Anthropic.
