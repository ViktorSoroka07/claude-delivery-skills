# Runs

**Status: declined on its baseline**, read together with its second-domain
sibling `writing-commit-messages-splits-one-page-by-version`: the act held
in every rep of both fixtures, and the one grader that moved is below what
ten reps separate. The backlog's interactive-add entry left the queue for
`backlog/declined.md` on this draw.

The case for the entry "A rule that tells a session to split staged work
with the interactive add command cannot be followed in a harness that runs
no interactive command, so every session that needs the split invents a
route of its own": the skill's one-commit-per-workstream section names
`git add -p`, and the entry's three sightings were sessions that worked out
a throwaway index or a hunk-filtered patch instead, one of them left with an
index holding stale entries after a format-on-commit hook.

## What the case stages

`refund-console.sh`'s `two-in-one-file` variant: the request table and its
test each carry two of the requester's own changes, uncommitted and
unstaged - a `currency` field on each row, and the empty table headed
"Awaiting requests" instead of "Requests" - two adjacent lines of a
nine-line file, so no hunk boundary separates them. The prompt names both
changes and asks for two commits, one per change. The run's git wrapper,
rewritten by `evals/fixtures/commit-audit.sh`, appends each commit to
`.git/commit-audit` with its subject, its files and a `carries:` line saying
whether the commit's added lines hold `currency` and whether they hold
`Awaiting`, so a grader reads which change a commit carries without parsing
a diff. The scaffold calls `stage-git.sh`, and no git hook runs in a rep.

Graders: the file on two commits' lists (`two-commits-touch-the-file`), a
commit carrying only `currency` and one carrying only `Awaiting`, both
changes still in the tree, a screen on the interactive add and the index
routes (`no-interactive-or-index-route`, `min: 0` beside `max: 0`), and the
skill indicator, which reads the gate. Before any draw, a by-version split
driven through the wrapper passed every grader and a single commit failed
the three that measure the act.

## The bar

The standing rule (CLAUDE.md, Commits): a baseline that already passes the
act means decline, not land. The route screen was a watched neighbour, not
the act: the entry's cost is the invented route's, and a route that costs
nothing is a difference the floor decides. This was the session's reading
before the draw and was not written here first.

## Baseline

`claude plugin eval . --scaffold --allow-tools Bash Write Edit Agent --model
sonnet --runs 5 --case 'writing-commit-messages-splits-*' --judge-model
sonnet --keep-temp --ablation none --trust-plugin --no-publish -j 2
--max-cost-usd 6`, CLI 2.1.318, `claude-sonnet-5-5`, from a worktree at the
commit that added the cases (the skill text unchanged), Docker closed and
`~/.docker` aside. Both cases together: $1.05, 205 s. This case: five reps,
$0.10-0.12 and 8-13 turns each.

| Grader | Rate |
|---|---|
| two-commits-touch-the-file | 5/5 |
| currency-commit-carries-only-currency | 5/5 |
| awaiting-commit-carries-only-awaiting | 5/5 |
| tree-keeps-currency | 5/5 |
| tree-keeps-awaiting | 5/5 |
| no-interactive-or-index-route | 4/5 |
| skill-was-invoked | 5/5 |

Routes, from the kept traces: four reps wrote the file as each commit's
version in turn - one through the edit tool, three with `sed -i`, two
parking the full file with a stash they restored - and committed by path or
with `-a`; one rep wrote each version to a temporary file, stored it as a
blob with `hash-object -w` and placed it with `update-index --cacheinfo`,
which the screen names and which produced two correct commits. No rep
reached for `git add -p`, and no rep left the index or the tree in a state
the graders could see.

Read with the sibling case (its own record has the table): across the two
domains the act held 10/10 and the screen 7/10, the three index-route reps
all producing correct commits. A wording on the route could move three reps
in ten at most, below the floor for ten reps (a half) and for five (four in
five); the cost the entry's sightings carry - an index left stale by a
format-on-commit hook - needs a hook that no runner rep runs, and its effect
is bounded by that same rate. Declined as below the instrument.

The wording drafted for the treated arm, never drawn, replacing the skill's
"split them (`git add -p`) before writing either message":

> split them before writing either message. Commit by path where the
> workstreams are whole files. Where one file carries both, there is no
> interactive add in a harness that runs no prompt, and a route built around
> that — a hunk-filtered patch applied to the index, a throwaway index — is
> where an index is left holding stale entries or a hook's reformat lands in
> the wrong commit: write the file as the first commit's version, commit it
> by path, write it as the second commit's, and commit again.

Run JSON kept as `evals/results/round-splitbyversion@baseline.json`
(git-ignored); the ten run roots were kept under `/private/tmp/e-*` for the
hand read above and are the operator's to sweep.
