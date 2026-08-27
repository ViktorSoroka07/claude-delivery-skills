#!/bin/sh
# Self-tests for the leak guard (.githooks/pre-commit + scripts/scan-history.sh).
# Each test builds a throwaway repo, installs the guard, and proves a bypass
# stays closed. Run from anywhere inside the repo; exits non-zero on any FAIL.
#
# Leak fixtures are assembled at runtime with printf so this file never
# contains a contiguous blocked pattern - otherwise the guard would
# (correctly) refuse to commit its own tests, and the history scanner would
# flag them forever after.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
fails=0

TICKET=$(printf 'AB%s' '#12345')
DATE=$(printf '2026-%s' '01-02')
IDHOST=$(printf 'x.visual%s' 'studio.com')

mkrepo() {
  R="$WORK/$1"
  mkdir -p "$R"
  cd "$R" || exit 9
  git init -q .
  git config user.name Test
  git config user.email test@example.com
  mkdir -p .githooks scripts
  cp "$ROOT/.githooks/pre-commit" .githooks/
  cp "$ROOT/scripts/scan-history.sh" scripts/
  chmod +x .githooks/pre-commit scripts/scan-history.sh
  git config core.hooksPath .githooks
  printf '# scratch wordlist - keeps the missing-file NOTE out of test output\n' > .leakwords.local
  printf 'harmless\n' > base.txt
  git add -A
  git commit -qm init
}

check() { # $1 = description, $2 = expected exit, $3 = actual exit
  if [ "$2" = "$3" ]; then
    echo "PASS: $1"
  else
    echo "FAIL: $1 (expected exit $2, got $3)"
    fails=$((fails+1))
  fi
}

# 1. A staged structural leak is blocked.
mkrepo t1
echo "leak $TICKET here" > f.txt
git add f.txt
git commit -qm leak >/dev/null 2>&1
check "staged ticket id is blocked" 1 $?

# 2. A renamed-and-modified file with a leak is blocked (rename bypass).
mkrepo t2
i=0
while [ $i -lt 60 ]; do echo "stable line $i survives the rename" >> big.txt; i=$((i+1)); done
git add big.txt
git commit -qm addbig
git mv big.txt renamed.txt
echo "leak $DATE" >> renamed.txt
git add renamed.txt
git commit -qm rename >/dev/null 2>&1
check "renamed-and-modified leak is blocked" 1 $?

# 3. A malformed wordlist term must not blind the scanner (silent-failure bypass).
mkrepo t3
echo "contact $TICKET" > f.txt
git add f.txt
git commit -qm leak --no-verify -q
printf 'codename(\n' > .leakwords.local
./scripts/scan-history.sh >/dev/null 2>&1
check "scanner still finds the leak with a malformed term present" 1 $?

# 4. A leaking committer identity fails the scan.
mkrepo t4
git -c user.name=Bob -c user.email="bob@$IDHOST" commit -q --allow-empty -m id --no-verify
./scripts/scan-history.sh >/dev/null 2>&1
check "leaking committer identity fails the scan" 1 $?

# 5. A clean history scans CLEAN, exit 0.
mkrepo t5
git commit -q --allow-empty -m more
./scripts/scan-history.sh >/dev/null 2>&1
check "clean history scans CLEAN" 0 $?

echo
if [ $fails -eq 0 ]; then
  echo "ALL PASS"
  exit 0
fi
echo "$fails test(s) failing"
exit 1
