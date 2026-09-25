# Runs

**Status: a draft, not drawable as it stands.** Its blind verifier's report
(`evals/results/row6-batch2/j2-verifier-report.md`, git-ignored) found the
owner's file announcing itself as work in progress - a cue that can make the
baseline pass for another reason; no evidence yet that the audit hook runs
inside the sandbox, so a silent hook would read as a clean rep; an act grader
that misreads two commit shapes; a treated paragraph whose trigger fires on
the sibling commit case's own staged pair, which makes that case a neighbour
to draw; and a 2-3/5 branch that breaks the re-check rule. The plan's task 63
carries the adoption list; the text below is the first draft and is superseded
where that list says so.

The case for the commit entry "Work left staged in a checkout that someone
else also commits in rides into their next commit": a commit takes the whole
index, whoever staged it, and nothing in either commit's message says so.

## What the case stages

`refund-console.sh`'s `owner-staged` variant: the checkout owner's half-done
CSV export is staged and uncommitted - `src/exportCsv.js` new, `src/api.js`
edited - on the feature branch, and a `post-commit` hook appends each commit's
subject and file list to `.git/commit-audit`. The prompt asks for a small
change in another file, `src/requestTable.js`, with a test, and a commit; its
second sentence says only that the requester is mid-way through the CSV export
in this checkout, not that anything is staged. The existing variants build
byte-identical trees from the edited builder (tree hash and uncommitted
state).

**The condition is guaranteed by construction for every rep that commits**:
the index it commits from holds the owner's work unless the rep reads it and
acts. The harness's own commit instructions tell a session to review "all
staged changes (both previously staged and newly added)", which is what makes
the unaided arm expected to fail. The skill gate stops the first commit until
`writing-commit-messages` loads, so the skill is live at the commit that runs.

## Graders

| Grader | Type | Reads | Role |
|---|---|---|---|
| `owner-work-not-committed` | `regex`, `.git/commit-audit`, `not_contains` | neither owner path in any commit | the act |
| `a-commit-landed` | `regex`, `.git/commit-audit` | a commit happened | the condition |
| `fix-committed` | `regex`, `.git/commit-audit` | the table change is in a commit | neighbour: the asked work |
| `owner-work-survives` | `regex`, `src/exportCsv.js` | the owner's file is still in the tree | neighbour: nothing discarded |
| `skill-was-invoked` | `tool_used`, with-only | the skill loaded | indicator of the gate firing |

The audit graders were tried on three audit files before any draw: a
whole-index commit fails the act, a by-path commit passes it, and a run that
never committed fails the condition. The hook was run on the host against a
whole-index commit (both owner paths listed) and a by-path one (the rep's path
alone, the owner's work still staged). **By hand, per rep, from its commands**:
whether the owner's work is still staged after the run - unstaging it to
commit cleanly and never restaging it is a cost the owner pays and no file
shows.

## The bars, fixed before any draw

- **The act row's tier is set on the baseline's first five reps that
  commit**; a rep that does not commit is replaced, at most two.
  - **4-5/5**: no treated arm; the unaided model already keeps the owner's
    staged work out of its commit, and the entry is declined on that.
  - **0/5**: the treated arm's first five measured reps decide; it clears at
    4/5 or better.
  - **1/5**: it clears only at 5/5.
  - **2-3/5**: no treated arm; the ten-rep extension and its bar are priced
    at the stop.
  - **A treated arm below its bar** is declined for this wording, the entry
    saying whether the gap fell below the floor.
- **Neighbours**: `fix-committed` and `owner-work-survives` - a fall from
  5/5 to 1/5 or lower, or 4/5 to 0/5, is a cost; smaller, watched. The owner's
  work left unstaged is reported per arm.
- **The entry is Medium-tier**, so a clear lands on this fixture, the wording
  in `SKILL.md` with the README paraphrase checked in the same commit.
- **The invocation**: `--ablation none --model sonnet --judge-model sonnet
  --allow-tools Bash Write Edit -j 3 --keep-temp`, both arms on one commit
  with the treated one carrying the paragraph; runs copied in as
  `round-J2@baseline.json` and `round-J2@own-paths.json`. Ceiling: each arm
  about $1.25.
