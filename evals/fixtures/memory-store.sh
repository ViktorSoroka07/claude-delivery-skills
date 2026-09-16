#!/bin/sh
# Builds the eval fixture for the store-wide pruning rule. $1 = target
# directory (created; must not exist or be empty).
#
# `disk/` stands for the filesystem root and holds one live checkout.
# `store/projects/` is a per-checkout memory store keyed by path: each
# directory is the checkout's absolute path with `/` replaced by `-`. Three
# directories sit there: the live checkout's (grouped index, three entries),
# a re-spelled twin whose path never existed (underscore for hyphen, months
# stale, one note that contradicts the live memory), and an ephemeral task
# checkout whose path is gone (empty memory, one stale transcript). Only the
# live directory has a checkout on disk. The live memory also holds an entry
# recorded from observed absence ("no CI gates a push") that the checkout
# has since falsified: it carries a workflow file now.
#
# Invented content throughout - a billing console that never existed.
set -e
T=${1:?target directory}
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "memory-store.sh: $T is not empty; refusing to build over existing files" >&2
  exit 1
fi
mkdir -p "$T/disk/home/dev/work/billing-console/src" "$T/store/projects"
echo 'export const render = () => {}' > "$T/disk/home/dev/work/billing-console/src/render.ts"
mkdir -p "$T/disk/home/dev/work/billing-console/.github/workflows"
printf 'name: ci\non: [push]\njobs:\n  test:\n    runs-on: ubuntu-latest\n    steps:\n      - run: npm test\n' > "$T/disk/home/dev/work/billing-console/.github/workflows/ci.yml"

L="$T/store/projects/-home-dev-work-billing-console/memory"; mkdir -p "$L"
cat > "$L/MEMORY.md" <<'M'
# Billing console memory index

## Conventions the user has ruled on
- [Review style](feedback_review_style.md) — one best fix per finding, no fallbacks

## Repo and tooling traps
- [Test runner trap](project_test_runner_trap.md) — the wrapper script exits green on zero tests
- [No CI](project_no_ci.md) — nothing gates a push; the repo has no CI

## Open items awaiting the user
- [Pending decisions](project_open_decisions.md) — retry policy for the export queue still unowned
M
printf -- '---\nname: review-style\ndescription: "one best fix per finding"\nmetadata:\n  type: feedback\n---\n\nOne Problem, one Suggestion; never a weaker fallback.\n' > "$L/feedback_review_style.md"
printf -- '---\nname: test-runner-trap\ndescription: "wrapper exits green on zero tests"\nmetadata:\n  type: project\n---\n\nThe run-tests wrapper exits 0 when the filter matches nothing; check the test count.\n' > "$L/project_test_runner_trap.md"
printf -- '---\nname: no-ci\ndescription: "nothing gates a push"\nmetadata:\n  type: project\n---\n\nNothing gates a push here: the repo has no CI configuration, so a failing suite reaches main. Run the suite by hand before every push.\n' > "$L/project_no_ci.md"
printf -- '---\nname: open-decisions\ndescription: "retry policy unowned"\nmetadata:\n  type: project\n---\n\nRetry policy for the export queue: nobody owns the decision yet.\n' > "$L/project_open_decisions.md"

W="$T/store/projects/-home-dev-work-billing_console"; mkdir -p "$W/memory"
printf -- '# Memory index\n\n- [Old note](project_old_note.md) — export queue uses a fixed 3-retry loop\n' > "$W/memory/MEMORY.md"
printf -- '---\nname: old-note\ndescription: "export queue retry loop"\nmetadata:\n  type: project\n---\n\nThe export queue retries exactly three times, hard-coded.\n' > "$W/memory/project_old_note.md"
touch -t 202603010900 "$W/memory/MEMORY.md" "$W/memory/project_old_note.md" "$W/memory" "$W"

E="$T/store/projects/-home-dev-scratch-task-4f2a91-billing-console"; mkdir -p "$E/memory"
printf '{"type":"user","message":{"content":"Run the build and report."}}\n' > "$E/9b1c2d3e.jsonl"
touch -t 202607150900 "$E/9b1c2d3e.jsonl" "$E/memory" "$E"
