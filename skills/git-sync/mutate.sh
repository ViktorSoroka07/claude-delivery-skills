#!/bin/bash
# Mutation harness for git-sync.sh.
#
# For each mutation: apply it, assert the file actually changed, run test.sh,
# require a failure naming the specific assertion the mutation targets, restore,
# and assert the restored file is byte-identical. A mutation that survives, or
# that fails on some other assertion, is reported as such.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd -P)"
SYNC="$HERE/git-sync.sh"
BACKUP="$(mktemp "${TMPDIR:-/tmp}/git-sync-orig.XXXXXX")"
OUT="$(mktemp "${TMPDIR:-/tmp}/git-sync-mut.XXXXXX")"
cp "$SYNC" "$BACKUP"
ORIG_SUM="$(shasum "$SYNC" | awk '{print $1}')"
trap 'cp "$BACKUP" "$SYNC"; rm -f "$BACKUP" "$OUT"' EXIT INT TERM

KILLED=0; SURVIVED=0; MISFIRED=0

run_mutation() {
  local label="$1" find="$2" replace="$3" target="$4"

  printf '\n\033[1m%s\033[0m\n' "$label"
  printf '  target assertion: %s\n' "$target"

  cp "$BACKUP" "$SYNC"
  if ! python3 - "$SYNC" "$find" "$replace" <<'PY'
import sys
path, find, replace = sys.argv[1], sys.argv[2], sys.argv[3]
text = open(path).read()
if text.count(find) != 1:
    sys.stderr.write("mutation target appears %d times, expected 1\n" % text.count(find))
    sys.exit(1)
open(path, "w").write(text.replace(find, replace))
PY
  then
    printf '  \033[31mNOT APPLIED\033[0m the target text was not found exactly once; the mutation proves nothing\n'
    MISFIRED=$((MISFIRED+1)); cp "$BACKUP" "$SYNC"; return
  fi

  if [ "$(shasum "$SYNC" | awk '{print $1}')" = "$ORIG_SUM" ]; then
    printf '  \033[31mNOT APPLIED\033[0m the edit did not change the file; the mutation proves nothing\n'
    MISFIRED=$((MISFIRED+1)); cp "$BACKUP" "$SYNC"; return
  fi

  bash "$HERE/test.sh" > "$OUT" 2>&1
  local rc=$?

  if [ "$rc" -eq 0 ]; then
    printf '  \033[31mSURVIVED\033[0m the suite still passes with the check broken\n'
    SURVIVED=$((SURVIVED+1))
  elif grep -q "FAIL.*$target" "$OUT"; then
    printf '  \033[32mKILLED\033[0m by: %s\n' "$target"
    KILLED=$((KILLED+1))
  else
    printf '  \033[33mWRONG REASON\033[0m the suite failed, but not on the target assertion:\n'
    grep 'FAIL' "$OUT" | sed 's/^/    /' | head -5
    MISFIRED=$((MISFIRED+1))
  fi

  cp "$BACKUP" "$SYNC"
  if [ "$(shasum "$SYNC" | awk '{print $1}')" != "$ORIG_SUM" ]; then
    printf '  \033[31mRESTORE FAILED\033[0m the file is not byte-identical to the original\n'
    exit 2
  fi
}

printf 'baseline: '
if bash "$HERE/test.sh" >/dev/null 2>&1; then printf '\033[32mgreen\033[0m\n'
else printf '\033[31mred - fix the suite before mutating\033[0m\n'; exit 2; fi

# The refspec fetch is what moves a parked repo's default branch. Dropping the
# destination half still exits 0, so only the ref comparison catches it.
run_mutation "M1  refspec fetch no longer writes the local ref" \
  'fetch --quiet origin "$db:$db"' \
  'fetch --quiet origin "$db"' \
  "parked repo's local main reached origin/main"

# Overlap detection decides whether a dirty repo is fast-forwarded silently or
# handed to you. Forcing it non-empty sends a safe repo to the prompt.
run_mutation "M2  overlap detection reports overlap everywhere" \
  'comm -12 "$d" "$i" | grep -v ' \
  'printf "FORCED\n"; true ' \
  "dirty repo with no overlap fast-forwards"

# The ancestry guard is what separates a branch that is behind from one that has
# drifted. Without it a diverged repo falls through to a doomed merge attempt.
run_mutation "M3  ancestry guard removed" \
  'if ! git -C "$dir" merge-base --is-ancestor "$before" "$after" 2>/dev/null; then' \
  'if false; then' \
  "diverged main is reported, not merged"

# A row reports on the default branch, which may not be the branch checked out.
# Dropping the parked note changes no status, so only a detail assertion sees it.
run_mutation "M4  the ok row stops naming the checked-out branch" \
  'emit ok "$name" "$db" "" NONE "$parked" "$dir"' \
  'emit ok "$name" "$db" "" NONE "" "$dir"' \
  "the ok row names the checked-out branch"

# The stash window is the one place an interrupt can move a user's work without
# telling them. Forgetting to arm it changes no status and no output on a normal
# run; only a run that is actually signalled can see it.
run_mutation "M5  the stash window stops arming the interrupt guard" \
  'STASH_REPO="$path"' \
  'STASH_REPO=""' \
  "the interrupt is announced, not silent"

# Column padding is computed from character counts. Using byte counts aligns
# every ASCII row correctly, so only a non-ASCII fixture exposes it.
run_mutation "M6  column padding reverts to byte counts" \
  'wn - f[7] + 1, "", f[4], wb - f[8] + 1, ""' \
  'wn - length(f[3]) + 1, "", f[4], wb - length(f[4]) + 1, ""' \
  "the branch column aligns across ASCII and non-ASCII names"

# A fetch failure's last line is usually the generic access-rights hint, so
# taking it reports every unreachable remote with the same uninformative text.
run_mutation "M7  the fetch error reverts to its last line" \
  'fmsg="$(printf '\''%s\n'\'' "$ferr" | grep -m1 '\''^fatal:'\'')"' \
  'fmsg="$(printf '\''%s\n'\'' "$ferr" | tail -1)"' \
  "the FETCH-FAIL detail names the cause, not the generic hint"

printf '\n-----------------------------------------\n'
printf '%d killed, %d survived, %d misfired\n' "$KILLED" "$SURVIVED" "$MISFIRED"
[ "$SURVIVED" -eq 0 ] && [ "$MISFIRED" -eq 0 ]
