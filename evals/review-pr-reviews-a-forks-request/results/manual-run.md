# Manual runs

## What the case measures

Review-pr's setup for a pull request opened from a fork (backlog entry "review a request opened from a fork"): the base repository carries the request's head under `refs/pull/12/head` and has no branch of its head name, so the current text's `git fetch origin <branch>` fails. The fixture (`evals/fixtures/github-request.sh fork`) serves a local bare base repository through the clone's `core.sshCommand` and answers `gh` through a stand-in, so the platform reads as GitHub with no network; the head commit is absent from the clone until fetched.

## Bars, fixed before the first draw

Only the baseline arm is bought first: review-pr on `main`, the plugin loaded, five reps, `--model sonnet`. A rep reaches the head when a fetch by `pull/12/head` or by the head SHA succeeded and the review read the code at that commit, read from each rep's trace (`fetched-the-requests-head` and `findings-name-the-head` are screens beside it). Four or more of five reaching it unaided declines the entry as unneeded on this model (task 68); one or fewer asks the owner for the treated arm (branch `69c-fork`); two or three is undecided at five reps.

## The blind verifier's findings, adopted before the first draw

A blind verifier built both variants as the runner does, read the runner's grader and scaffold code and checked GitHub live on a fork's pull request (`evals/results/task69-verifierCD/report.md`). Adopted, each checked at source first:

- The fork's own repository is served (a second mirror carrying the head branch), the SSH stand-in dispatches on the repository path, `https://github.com/` URLs are rewritten to SSH, `head.repo` carries `clone_url` and `ssh_url`, and `refs/pull/12/merge` exists: fetching from the fork works here as it does on GitHub, where the first build refused it.
- `gh pr checkout` behaves as the real command does (fetches `refs/pull/12/head` into a local branch and switches to it) instead of refusing with a hint naming the answer.
- The `gh` stand-in finds the endpoint wherever `gh api` carries it, fills `{owner}/{repo}`, splits `--flag=value`, and treats `-f`/`-F` as a POST.
- The scaffold removes its source build from the run's temp directory and pins the commit dates' offset: the head is `bd2f605` on every machine.
- `head-commit-fetched`, a `file_exists` on the head commit's loose object, is the mechanical anchor; `fetched-the-requests-head` is a screen of the route.

Routes, classified now: a fetch by `pull/12/head`, by the head's SHA, from the fork's remote, or through `gh pr checkout` reaches the head (`head-commit-fetched`); `gh pr checkout` also switches the user's branch, which the skill forbids, and is recorded beside the verdict as that separate violation. Reviewing `gh pr diff` applied onto `main` reaches no commit and does not count. A rep whose trace reads the fixture's stand-ins (`forge-internals-untouched`) is contaminated and replaced. The bar is unchanged: four or more of five reaching the head unaided declines the entry; one or fewer asks for the treated arm; two or three is undecided.

## Baseline, five reps (round 69c)

Model `claude-sonnet-5-5` in every rep's `init` event; CLI 2.1.289; review-pr on `main` at `88776c6`, the plugin loaded, `--judge-model sonnet`. $1.55, 14-26 turns. Kept as `evals/results/round-69c@baseline.json`, traces in `evals/results/round69cd-traces/`.

| Row | Baseline |
|---|---|
| `head-commit-fetched` | 5/5 |
| `fetched-the-requests-head` | 5/5 |
| `findings-name-the-head` | 5/5 |
| `findings-file-written` | 5/5 |
| `forge-internals-untouched` | 5/5 |
| `skill-was-invoked` | 5/5 |

Every rep ran the current text's `git fetch origin feat/close-ticket`, met GitHub's own refusal ("couldn't find remote ref"), and fetched `pull/12/head` unaided (one into `refs/pr/12`); none used `gh pr checkout`, the fork's remote, or a stand-in. The reps' `git checkout -- <file>` calls restore files in their own worktrees between mutations. Five of five reach the head unaided, so by the bar fixed before the draw the entry is unneeded on this model; the posting re-verify half was not exercised and rests on the same knowledge. Recommended: decline, the owner's call.
