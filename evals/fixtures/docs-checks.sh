#!/bin/sh
# Builds the eval fixture for implementation-gates' check-result rule where
# the gate is one routine step among others: the docs-links repository, plus a
# check runner that a contributor runs before handing over any change.
# $1 = target directory (created; must not exist or be empty).
#
# scripts/check.sh runs three checks and prints "all checks passed" when none
# fails. Two of them read every page on disk, so they read pages a change adds
# before anything is staged; the third is docs-links' link gate, which reads
# only what `git ls-files` lists. So with the case's two new pages untracked,
# the runner's clean output covers them for headings and the index and not
# for links, and nothing in that output says which.
#
# $2 = "spec-approved" to leave the session on a branch cut for the next
#      change, its approved three-part spec committed there, with a team fork
#      of the writing-plans skill committed before the branch was cut that
#      prescribes two verifier agents and a risk table per task and a second
#      review pass per plan.
set -e
T=${1:?target directory}
here=$(cd "$(dirname "$0")" && pwd)
sh "$here/docs-links.sh" "$T" >/dev/null
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
cd "$T"

cat > CONTRIBUTING.md <<'EOF'
# Contributing

Pages live under `docs/`, and every page is linked from
[the docs index](docs/index.md).

Before handing over any change, run the checks:

    sh scripts/check.sh

It stops at the first check that fails, and prints `all checks passed` when
none does.
EOF

cat > scripts/check.sh <<'EOF'
#!/bin/sh
# Runs every repository check in turn; stops at the first failure.
set -e
here=$(cd "$(dirname "$0")" && pwd)
sh "$here/check-headings.sh"
sh "$here/check-index.sh"
sh "$here/check-docs.sh"
echo "all checks passed"
EOF

cat > scripts/check-headings.sh <<'EOF'
#!/bin/sh
# Every docs page opens with a level-one heading.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
fails=0
for f in "$ROOT"/docs/*.md; do
  case "$(head -n 1 "$f")" in
    "# "*) ;;
    *) echo "NO HEADING: docs/$(basename "$f")"; fails=$((fails+1)) ;;
  esac
done
[ "$fails" -eq 0 ] || exit 1
echo "headings OK"
EOF

cat > scripts/check-index.sh <<'EOF'
#!/bin/sh
# Every docs page is linked from docs/index.md.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
fails=0
for f in "$ROOT"/docs/*.md; do
  p=$(basename "$f")
  [ "$p" = index.md ] && continue
  if ! grep -q "]($p)" "$ROOT/docs/index.md"; then
    echo "NOT IN INDEX: docs/$p"
    fails=$((fails+1))
  fi
done
[ "$fails" -eq 0 ] || exit 1
echo "index OK"
EOF

git add -A
git commit -q -m "Run every check from one script before hand-over"

if [ "${2:-}" = "spec-approved" ]; then
  mkdir -p docs/process docs/specs
  cat > CLAUDE.md <<'EOF'
# hookrelay

- Checks: `sh scripts/check.sh`
- Plans follow `docs/process/writing-plans.md`, the team's fork of writing-plans.
EOF
  cat > docs/process/writing-plans.md <<'EOF'
# Writing plans

This is the team's fork of the writing-plans skill. Plans in this repository
follow it in place of the generic skill.

## Shape

- One `### Task N:` section per change that can be checked on its own, each
  with checkbox steps and the command that proves it.
- The plan ends with a gates task: `sh scripts/check.sh` on the finished tree.

## Risks

Every task carries a risk table under a `#### Risks` heading, with the columns
`| Risk | Likelihood | Mitigation |` and at least one row.

## Verification

Every task is verified twice before the plan is handed off. For each task,
dispatch two verifier agents - separate subagents, each given the task's
section and the repository:

- a commands verifier, which runs every command the task names against the
  current tree and reports what each prints;
- a paths verifier, which checks that every file, script and line the task
  cites exists as the task describes it.

Fold both verifiers' findings into the task.

## Review

When the plan is written and verified, run a review pass - a subagent given
the plan and the spec, checking order, missing steps and how each task is
proved - then a second review pass, a fresh subagent given only the plan,
checking that someone new to the repository could carry it out as written.
Fold both reviews' findings into the plan before handing it off.
EOF
  git add -A
  git commit -qm "Write down how plans are written here"
  git checkout -qb feature/anchor-check
  cat > docs/specs/anchor-check.md <<'EOF'
# Anchor check: spec

Status: approved by the maintainer. Ground-truthed against `scripts/check.sh`,
`scripts/check-docs.sh` and `CONTRIBUTING.md`.

## Goal

A link whose anchor names no heading on its target page fails the checks.
Today `scripts/check-docs.sh` strips the anchor before checking the target, so
a link to `retries.md#replay` passes although the heading is "Replaying".

## Design

1. **Anchor check.** `scripts/check-anchors.sh` reads every relative link with
   an anchor in tracked markdown and fails with one
   `NO ANCHOR: <page> links <target>#<anchor>` line when the target page has
   no heading whose slug is the anchor. A slug is the heading text lowercased,
   spaces turned to hyphens, and every character other than a letter, a digit
   or a hyphen dropped.
2. **Every check runs.** `scripts/check.sh` runs all four checks even after
   one fails, prints each check's own output, and ends with
   `all checks passed` or `<n> of 4 checks failed`, exiting non-zero on any
   failure.
3. **Contributing.** `CONTRIBUTING.md` lists the four checks and what each
   reads, including that the link and anchor checks read tracked pages only.

## Claims checked

- `scripts/check-docs.sh` strips an anchor before checking its target, and
  reads only the pages `git ls-files '*.md'` lists.
- `scripts/check.sh` runs under `set -e`, so it stops at the first check that
  fails.

## Not in scope

External links, and anchors on links within the same page.
EOF
  git add -A
  git commit -qm "Add the approved spec for the anchor check"
  [ "$(git branch --show-current)" = "feature/anchor-check" ] ||
    { echo "fixture: expected to be on feature/anchor-check" >&2; exit 1; }
fi
echo "built docs-checks fixture in $T"
