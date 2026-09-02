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

# 6. The warn tier prints but does not block. Guards against the shell's echo
#    interpreting a backslash escape in a pattern and silently killing the tier.
mkrepo t6
PRREF=$(printf 'PR %s' '12345')
echo "see $PRREF here" > f.txt
git add f.txt
out=$(git commit -qm warn 2>&1)
rc=$?
check "warn-tier commit still succeeds" 0 $rc
case "$out" in
  *WARNING*) echo "PASS: warn tier printed a WARNING" ;;
  *) echo "FAIL: no WARNING in hook output"; fails=$((fails+1)) ;;
esac

# 6b. A warn shape inside a generated marker region is a copy of text already
#     scanned in the file that owns it, so it stays quiet - otherwise every
#     regeneration reprints the same warning. The identical text outside the
#     region still warns, which is what keeps the exemption honest.
mkrepo t6b
printf 'intro\n\n<!-- triggers -->\n| see %s here | link |\n<!-- /triggers -->\n' "$PRREF" > README.md
git add README.md
out=$(git commit -qm gen 2>&1)
rc=$?
check "generated-region commit still succeeds" 0 $rc
case "$out" in
  *WARNING*) echo "FAIL: warn fired on a generated-region copy"; fails=$((fails+1)) ;;
  *) echo "PASS: warn tier skips a generated-region copy" ;;
esac
printf 'intro\n\nprose with %s in it\n\n<!-- triggers -->\n| see %s here | link |\n<!-- /triggers -->\n' "$PRREF" "$PRREF" > README.md
git add README.md
out=$(git commit -qm outside 2>&1)
case "$out" in
  *WARNING*) echo "PASS: the same shape outside the region still warns" ;;
  *) echo "FAIL: warn tier missed a shape outside the region"; fails=$((fails+1)) ;;
esac

# 7. A wordlist saved with CRLF line endings (a Windows editor) still catches
#    its terms - a trailing carriage return must not blind either guard.
mkrepo t7
echo "mentions secretword here" > f.txt
git add f.txt
git commit -qm leak --no-verify
printf 'secretword\r\n' > .leakwords.local
./scripts/scan-history.sh >/dev/null 2>&1
check "scanner catches a CRLF wordlist term" 1 $?
echo "secretword again" > g.txt
git add g.txt
git commit -qm leak2 >/dev/null 2>&1
check "hook blocks a CRLF wordlist term" 1 $?

# 8. A staged SKILL.md whose frontmatter breaks strict YAML is blocked -
#    the colon-space-in-unquoted-scalar class both check paths must catch -
#    and the corrected line commits cleanly (no false positive on the fix).
mkrepo t8
mkdir -p skills/demo
printf -- '---\nname: demo\ndescription: reviews a thing well: post, stage\n---\nbody\n' > skills/demo/SKILL.md
git add skills/demo/SKILL.md
git commit -qm skill >/dev/null 2>&1
check "broken SKILL.md frontmatter is blocked" 1 $?
printf -- '---\nname: demo\ndescription: reviews a thing well - post, stage\n---\nbody\n' > skills/demo/SKILL.md
git add skills/demo/SKILL.md
git commit -qm skill2 >/dev/null 2>&1
check "valid SKILL.md frontmatter commits" 0 $?

echo
if [ $fails -eq 0 ]; then
  echo "ALL PASS"
  exit 0
fi
echo "$fails test(s) failing"
exit 1
