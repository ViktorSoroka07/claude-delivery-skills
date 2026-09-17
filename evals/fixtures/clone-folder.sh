#!/bin/sh
# Builds the eval fixture: a workspace folder holding several clones, each in a
# different state, plus a folder that is not a repo at all. $1 = target
# directory (created; must not exist or be empty).
#
# The states are chosen so a correct report cannot be produced by listing only
# what changed: two repos move, one is already current, one has local commits
# the remote lacks, one cannot reach its remote, and one child is not a repo.
# The unreachable clone still answers ahead/behind from its last successful
# fetch, so calling it current is a mistake the fixture can catch.
#
# Invented content throughout - services that never existed.
set -e
T=${1:?target directory}
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "clone-folder.sh: $T is not empty; refusing to build a fixture over existing files" >&2
  exit 1
fi
mkdir -p "$T/origins" "$T/workspace"
ROOT=$(cd "$T" && pwd)

seed() { # $1 = repo name
  n=$1
  git init -q --bare "$ROOT/origins/$n.git"
  git clone -q "$ROOT/origins/$n.git" "$ROOT/workspace/$n" 2>/dev/null
  cd "$ROOT/workspace/$n"
  git config user.email fixture@example.invalid
  git config user.name Fixture
  git config commit.gpgsign false
  printf 'name: %s\n' "$n" > service.yml
  printf 'ok\n' > README.md
  git add -A
  git commit -qm "Add the $n service manifest"
  git push -q origin HEAD:main
  git checkout -q -B main
  git branch -q --set-upstream-to=origin/main main 2>/dev/null || true
  git remote set-head origin main >/dev/null 2>&1 || true
  cd "$ROOT"
}

advance() { # $1 = repo name; pushes a commit the clone does not have
  n=$1
  rm -rf "$ROOT/.push"
  git clone -q "$ROOT/origins/$n.git" "$ROOT/.push" 2>/dev/null
  cd "$ROOT/.push"
  git config user.email fixture@example.invalid
  git config user.name Fixture
  git config commit.gpgsign false
  git checkout -q -B main origin/main
  printf 'ok\nretries: 3\n' > README.md
  git add -A
  git commit -qm "Document the retry budget for $n"
  git push -q origin main
  cd "$ROOT"
  rm -rf "$ROOT/.push"
}

# two clones that are simply behind
seed ledger-api;     advance ledger-api
seed statement-feed; advance statement-feed

# one clone that is already current
seed audit-trail

# one clone carrying a commit the remote does not have
seed pricing-rules
cd "$ROOT/workspace/pricing-rules"
printf 'draft tier table\n' > tiers.md
git add -A
git commit -qm "Sketch the tier table"
cd "$ROOT"

# one clone whose remote cannot be reached. Its tracking ref was written while
# the remote still answered and says the branch is level, so the ahead/behind
# it reports is stale rather than reassuring: the real remote has moved on.
seed invoice-gateway
cd "$ROOT/workspace/invoice-gateway"
git remote set-url origin "$ROOT/origins/invoice-gateway-moved.git"
cd "$ROOT"
advance invoice-gateway

# a child that is not a repository
mkdir -p "$ROOT/workspace/design-notes"
printf 'Colour tokens for the statement view.\n' > "$ROOT/workspace/design-notes/tokens.md"

printf 'fixture ready: %s/workspace\n' "$ROOT"
