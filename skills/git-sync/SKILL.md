---
name: git-sync
description: Use when asked to fetch, sync, refresh or update the git repos in a folder rather than one at a time — "sync all my repos", "fetch everything under this directory", "which of these clones are behind", "bring my checkouts up to date" — and when surveying what has moved across many clones before starting work. Runs a bundled script; the judgement is in reading its output, not in doing the git work by hand.
---

# git-sync

`git-sync.sh` fetches every repo under a folder and fast-forwards each one's
default branch, so "are my clones current" costs one command instead of one
`cd` per repo.

**Run the script. Do not do this by hand.** Looping `git -C <dir> pull` over a
folder is what this replaces, and that loop gets the parked-branch, dirty-tree
and extra-worktree cases wrong every time.

## Run it

The script sits beside this file, in the base directory the skill loader prints
on invocation. Call it by absolute path from there:

    <skill dir>/git-sync.sh <folder>    # sweep the folder's direct children
    <skill dir>/git-sync.sh <repo>      # just that repo
    <skill dir>/git-sync.sh             # the current directory

Flags: `--dry-run` (report only), `--fetch-only` (move no local branch),
`--ask` (confirm before touching any repo with local changes), `-j N`, `-q`.
`-h` prints the full contract.

**Target resolution.** A directory containing `.git` is treated as that one
repo. Anything else sweeps its **direct children only**, never recursing, so
pointing it at a workspace root syncs the checkouts in it and not their
vendored submodules or nested clones.

## What it guarantees

Local branches move **only by fast-forward**. A repo either advances or reports
why it did not, and no path in the script discards a commit or an uncommitted
edit.

Three cases carry the whole value, because they are what a hand-rolled loop
breaks:

- **Parked on a feature branch.** The default branch is updated by refspec
  (`git fetch origin <branch>:<branch>`), which moves the ref with no checkout
  and which git rejects unless it is a fast-forward. The branch that is checked
  out, and the working tree, are never touched.
- **Dirty working tree.** The script intersects the paths the incoming commits
  touch with the paths that are locally modified. An empty intersection means
  the fast-forward is guaranteed to succeed with every local edit preserved, so
  it happens without asking. A non-empty one means git is guaranteed to refuse,
  so the script offers to stash, fast-forward and pop instead. Deciding this
  before attempting the merge is what lets it report a reason rather than relay
  a git error.
- **Default branch checked out in another worktree.** Detected and skipped; git
  would refuse the refspec fetch, and the pre-check turns that error into a
  status.

The default branch is resolved per repo from `refs/remotes/origin/HEAD`, falling
back to `main` then `master`. Hardcoding one name silently reports "nothing to
do" on every repo that uses the other.

## Reading the output

| Status | Means | What to do |
|---|---|---|
| `UPDATED` | Fast-forwarded | nothing |
| `STASHED` | Stashed, fast-forwarded, restored | nothing |
| `ok` | Already current | nothing |
| `DECLINED` | Offered, the user said no | nothing |
| `BLOCKED` | Incoming commits touch files the user has edited | they commit or stash, then rerun |
| `DIVERGED` | Local default branch holds commits the remote lacks | the user merges or rebases; never do it for them |
| `CONFLICT` | The stash pop conflicted | **say so immediately**: that repo holds conflict markers and the work is in `stash@{0}` |
| `IN-USE` | Default branch checked out in another worktree | sync it from that worktree, or leave it |
| `LOCAL` | No remote configured | nothing; this is not an error |
| `NO-BRANCH` | No local branch matching the remote's default | nothing automatic |
| `FETCH-FAIL` | Remote unreachable or auth failed | check network or credentials |
| `WOULD-UPDATE` | `--dry-run` only | rerun without `--dry-run` |

Exit `1` when any repo is `FETCH-FAIL`, `DIVERGED`, `CONFLICT` or `BLOCKED`.

## The end result is a disposition table

The script's output is an input, not the answer. Finish by presenting a
**disposition table covering every direct child of the folder**, grouped in this
order: the repos that need the user, then those that moved, then those already
current, then the non-repo folders collapsed into one line. Columns: repo,
branch (when it is not the default one), what the run did in plain words, and
the action the user takes next.

Four rules make it trustworthy:

- **Every child appears.** Derive the rows from the folder, never from the repos
  that happened to change. A repo missing from the table reads as "fine".
- **No disposition without its action**, or an explicit dash. A status the
  reader has to interpret is an unfinished row.
- **A stale remote-tracking ref is not evidence.** A repo whose fetch failed
  still reports an ahead/behind count, computed against the last successful
  fetch. Never call such a repo current; say the comparison is stale.
- **Re-read the folder rather than replaying the run.** Clones move while a
  session works, by another session or by the user. State anything that changed
  underneath, rather than reporting the run's own output as current truth.

Expand `DIVERGED` and `FETCH-FAIL` rows with the underlying git output.
Unpushed local commits look like a sync problem and are not one, and a hosting
provider's fetch error usually distinguishes "renamed or deleted" from "you lost
access" only in its full text.

## When not to run it

This mutates local branches, so it runs **on an explicit ask**. Never fold it
into an automatic freshness sweep, and never run it mid-task to "check
something". Where a repository's own rules limit sessions to read-only git
operations, those rules govern and this script is not an exception to them:
`--dry-run` and `--fetch-only` are the modes that respect them, and both still
write remote-tracking refs, which is what `git fetch` does.

## Maintaining it

`MAINTAINING.md`, beside this file, owns the test and mutation procedure. Read
it before changing a check or adding a status.
