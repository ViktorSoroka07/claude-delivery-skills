# Runs

**Status: drawable.** The blind verifier's findings
(`evals/results/row6-batch2/j2-verifier-report.md`, git-ignored; the plan's
task 63 lists the ones to adopt) were adopted before any draw, and the bars
below were fixed before the first one. What each adoption changed is under
"What the verifier changed"; the draws follow the bars.

The case for the commit entry "Work left staged in a checkout that someone
else also commits in rides into their next commit": a commit takes the whole
index, whoever staged it, and nothing in either commit's message says so.

## What the case stages

`refund-console.sh`'s `owner-staged` variant: the checkout owner's half-done
CSV export is staged and uncommitted - `src/exportCsv.js` new, `src/api.js`
edited - on the feature branch, and each commit's subject and its files, one
indented line each, reach `.git/commit-audit` (how, under "What the verifier
changed", item 2). The
prompt asks for a small change in another file, `src/requestTable.js`, with a
test, and a commit; its second sentence says only that the requester is
midway through the CSV export in this checkout, not that anything is staged.
Nothing in the staged files labels them as anyone's unfinished work: the
module carries no header, and the API edit carries an ordinary `TODO`.

**The condition holds by construction for every rep that commits**: the index
it commits from holds the owner's work unless the rep reads it and acts. The
harness's own commit instructions tell a session to review "all staged changes
(both previously staged and newly added)". The skill gate stops the first
commit, and every commit sent in the same message, until
`writing-commit-messages` loads, so the skill is live at the commit that runs.

## What the verifier changed

1. **The cue.** The owner's module opened with `// Work in progress: CSV export
   ...`, which told every rep reading the staged diff whose the work was, apart
   from any rule. The line is gone; the builder's other nine variants build
   byte-identical trees and index trees from the old and new builder, and only
   `owner-staged`'s index tree differs.
2. **The hook inside the sandbox: it never runs.** Two Haiku probes before any
   counted draw settled it ($0.02, `round-J2@hook-probe-haiku.json` and
   `round-J2@hook-probe-3.json`, CLI 2.1.312). The first rep committed by path
   - the trace shows `[feature/mount-table 1d4ca61]` - and the audit held no
   commit line. The second printed the rep's environment: every Bash command
   in a runner rep carries `GIT_CONFIG_KEY_n`/`GIT_CONFIG_VALUE_n` pairs
   setting `core.hooksPath=/dev/null` and `hook.<name>.enabled=false` for every
   hook git knows, while the hook file itself ran and wrote when called
   directly. So the audit comes from the run's git wrapper instead: the case's
   scaffold rewrites the wrapper `stage-git.sh` puts first on the run's PATH so
   that, after each call that moves `HEAD` on the same branch, it appends every
   commit the call created - subject, then files - to `.git/commit-audit`, the
   hook's format. A branch switch logs nothing, and an amend, a fixup, an
   undo-and-redo or a commit from a subdirectory logs as the hook would; a call
   to git by its full path, or plumbing that builds a commit in one call and
   moves the branch in another, escapes it, and each rep's trace is compared
   with its audit for that reason. The post-commit hook stays for a hand run,
   where the wrapper is not on the PATH and hooks run. `a-commit-landed` now
   needs a commit line followed by a file line, so an audit that could not list
   files reads as no commit rather than a clean one.
3. **The act's anchors.** The act and `fix-committed` read the hook's indented
   file lines, so a subject naming `src/api.js` no longer fails a clean rep.
   The act now has a second half, `owner-work-left-staged`: the owner's new
   file still in `.git/index`, read only over reps that pass the first half,
   which separates a commit by path from unstaging everything to commit and
   never restaging. `owner-work-survives` drops an alternative that never
   occurred in its file, and `owner-api-edit-survives` guards the owner's other
   file.
4. **The trigger and its exceptions.** The treated paragraph fires on staged
   work "you were not asked to commit", so the sibling case's "Commit what's
   staged" does not trip it; it names the shared-path, amend and `--fixup`
   routes that take the owner's work anyway, and the new file that a bare
   `git commit -- <paths>` refuses. Its last clause, "never leave your own work
   staged between one step and the next", is out of this round: it answers the
   entry's sighted half (a session's staged work riding into the owner's
   commit), which a single-prompt case with no second committer cannot reach,
   so it stays queued as untested.
5. **The neighbour.** The sibling commit case is drawn in both arms whenever a
   treated arm is.
6. **The 2-3/5 branch.** Its extension and bar are fixed below, before the
   first draw.
7. **One commit for both arms.** Both arms run from worktrees at one commit of
   `main` carrying this case and the landed skill gate (task 61, `3429af9`,
   every act of a stopped message stopped); the treated worktree adds the
   paragraph alone. Ceilings sit above the expected spend.

Also adopted from the same report, at no cost: the paragraph sits at the end of
the section, so it no longer splits the split rule from the paragraph that
refers back to it; it drops "in the checkout", a word the prompt also uses.

## Graders

Each audit grader was scored on audits of hand-built commit shapes before any
draw, with the runner's frontmatter parse and `new RegExp(pattern, flags)`:
the shapes were built through the case's own scaffold, with the sandbox's
hook-disabling environment set, so the audits are the wrapper's:

| Shape | landed | not committed | left staged | fix | api survives |
|---|---|---|---|---|---|
| whole index (`git add` + `git commit`) | P | **F** | P | P | P |
| by path (`git commit -- src/requestTable.js`) | P | P | P | P | P |
| new test file added, then by path | P | P | P | P | P |
| `git reset`, commit, no restage | P | P | **F** | P | P |
| by path, subject naming `src/api.js` | P | P | P | P | P |
| by path, then `--amend -m` (whole index) | P | **F** | P | P | P |
| by path, then `--amend -- <path>` | P | P | P | P | P |
| by path, then `--fixup=HEAD -- <path>` | P | P | P | P | P |
| `git reset --soft HEAD~1` after a whole-index commit, then by path | P | **F** | P | P | P |
| commit by path, stash, switch to `main` and back, pop | P | P | P | P | P |
| no commit | **F** | P | P | **F** | P |
| owner's API edit discarded, then by path | P | P | P | P | **F** |

The undo-and-redo shape fails the act on the rule's letter while the history
it leaves is clean, so a rep of that shape is labelled apart by hand.

The runner reads `.git/index`, a binary file, as a `regex` target without
throwing: the first probe rep's `owner-work-left-staged` passed on it.

| Grader | Type | Reads | Role |
|---|---|---|---|
| `owner-work-not-committed` | `regex`, `.git/commit-audit`, `not_contains` | neither owner path on any commit's file lines | the act, first half |
| `owner-work-left-staged` | `regex`, `.git/index` | the owner's new file still in the index | the act, second half |
| `a-commit-landed` | `regex`, `.git/commit-audit` | a commit with files | the condition |
| `fix-committed` | `regex`, `.git/commit-audit` | the table change on a commit's file lines | neighbour: the asked work |
| `owner-work-survives` | `regex`, `src/exportCsv.js` | the owner's module still in the tree | neighbour: nothing discarded |
| `owner-api-edit-survives` | `regex`, `src/api.js` | the owner's API edit still in the tree | neighbour: nothing discarded |
| `skill-was-invoked` | `tool_used`, with-only | the skill loaded | indicator of the gate firing |

**A rep passes the act** when both halves pass. **By hand, per rep, from its
commands**: whether the owner's `src/api.js` edit is still staged at the end
(tracked either way, so no file shows it), reported per arm beside the act.

## The treated text

The skill's "One commit per workstream" section gains a last paragraph:

> **The index is shared: commit your own paths.** A commit takes whatever is staged, whoever staged it, so work someone else left staged rides into your commit under your message. Before committing, read what is staged (`git status`); where it holds work you were not asked to commit, commit your own paths by name — `git add` any new file of yours, then `git commit -- <paths>` — and leave the rest staged as you found it. A path that also holds their staged hunks carries those in with it, and an amend or a `--fixup` takes the whole index too unless it names its paths.

Each git claim in it was run on the fixture: a commit by path leaves the
owner's two paths staged, as an amend or a `--fixup` naming the path does; a
new file named in `git commit -- <paths>` without an `add` is refused
("pathspec ... did not match any file(s) known to git"); a commit of a path
holding the owner's hunks carries them. Not addressed, since the fixture never
reaches it: a hunk-level split (`git add -p`) beside someone else's staged
work, where a commit by path takes the working tree's whole file.

## Which model

A capability rule, measured on the instrument alone. The failure is not
knowing that a commit takes the whole index, which a stronger model is less
likely to show, not more; the over-application a stronger model could show -
holding back work it was asked to commit - is what the sibling case's rows
read, on the model that shows the failure.

## The bars, fixed before any draw

- **Before any grader**: read the first rep's trace and audit. For every rep,
  the trace's own commit output (`[feature/mount-table <sha>] ...`) and the
  audit must agree; a rep whose trace shows a landed commit while
  `a-commit-landed` fails is an instrument defect that stops the round, never
  replaced. A throw on `owner-work-left-staged` stops the round the same way.
- **A rep that never commits is unmeasured on the act** and replaced, by one
  rule in both arms: at most two replacements an arm, and an arm still short
  after them is reported short, not padded. Each arm's non-committing reps are
  a row of their own; a treated arm with two or more beyond the baseline's is
  a cost on the asked work, read beside `fix-committed`.
- **The act's tier is set on the baseline's first five measured reps.**
  - **4-5/5**: no treated arm. On this fixture the current plugin already keeps
    another person's staged work out of a session's commit; the entry's tested
    half is declined on that, and its sighted half - the session's own staged
    work riding into another committer's commit - stays queued as untested.
  - **0/5**: the treated arm's first five measured reps decide; it clears at
    4/5 or better.
  - **1/5**: it clears only at 5/5.
  - **2-3/5**: stop for the owner with the extension's price; the extension is
    fixed now, so its draws pool with these: five more baseline reps (ten in
    all) and ten treated, the treated arm clearing where its count of ten
    exceeds the pooled baseline's by five or more, and declined below the
    instrument otherwise.
  - **A treated arm below its bar** is declined for this wording, the record
    saying whether the gap fell below the floor.
- **Neighbours**: `fix-committed`, `owner-work-survives` and
  `owner-api-edit-survives`; and, whenever a treated arm is drawn, the sibling
  `commit-message-states-the-change` in both arms, five reps each, every one of
  its rows. A fall from 5/5 to 1/5 or lower, or from 4/5 to 0/5, is a cost and
  declines the wording; a smaller fall is watched.
- **The entry is Medium-tier**, so a clear lands on this fixture: the paragraph
  in `SKILL.md`, the README paraphrase checked in the same commit, and the
  entry's line rewritten to its untested half rather than removed.
- **The invocation**: `--scaffold --trust-plugin --no-publish --allow-tools
  Bash Write Edit --model sonnet --judge-model sonnet --ablation none -j 3
  --keep-temp`; runs kept as `round-J2@baseline.json` and
  `round-J2@own-paths.json`, the sibling as `round-J2@sibling-baseline.json`
  and `round-J2@sibling-own-paths.json`. Expected about $0.25-0.40 a rep (the
  sibling commit case's kept reps cost $0.15-0.21 and do less), so each arm's
  ceiling is $3.00 and the sibling's $1.50. The model is read from each rep's
  `init` event and written here, and both arms' turn and duration spread is
  read from each trace's `result` records before any grader.

## The baseline

Model `claude-sonnet-5-5` in every rep's `init` event; CLI 2.1.312; `--ablation
none`, the plugin at `5ef8d1b` (the landed gate, no treated paragraph);
`round-J2@baseline.json`, $0.69 for five reps, 13-16 turns and 20-25 seconds
each, none curtailed and none replaced. Every rep loaded
`writing-commit-messages` before its commit that ran (one through the gate's
stop), and every rep's trace and audit agree on what was committed.

| Grader | Baseline |
|---|---|
| a-commit-landed (condition) | 5/5 |
| owner-work-not-committed (act) | 5/5 |
| owner-work-left-staged (act) | 5/5 |
| fix-committed | 5/5 |
| owner-work-survives | 5/5 |
| owner-api-edit-survives | 5/5 |
| skill-was-invoked (indicator) | 5/5 |

**The act is 5/5, so no treated arm is drawn.** Every rep ran `git status`
first, saw the two staged files, and committed its own two paths by name -
`--only` in one rep, `-o` in one, `-- <paths>` in three - leaving the owner's
module and API edit staged (read from each rep's final index, by hand).

**Before the decline is written, one probe of the label left in the prompt.**
The prompt's second sentence, "I'm midway through the CSV export in this same
checkout", names whose the staged work is, and in the landed sighting nobody
named anything; every rep's reasoning before its commit pointed at that export.
So five more reps, same commit, same graders, with the prompt's first sentence
alone (`docs/plans/task63-probe/`, git-ignored; `round-J2@probe-unlabelled.json`,
about $0.70), read on their own with this bar, fixed before they run:
- **4-5/5**: the decline stands for both shapes - another person's staged work
  in files the session never touched stays out of its commit unaided, named or
  not.
- **0-1/5**: the label carried the baseline. The decline is not written; the
  entry stays queued with this case's unlabelled variant as its fixture and the
  paragraph above as its wording, priced for the owner.
- **2-3/5**: unsettled; recorded as such, and the entry stays queued with the
  reading.
