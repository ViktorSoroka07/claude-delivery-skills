#!/bin/bash
# shellcheck disable=SC2016  # mutation targets are literal script text
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

# A branch just created is on the default branch, so pruning is off unless asked
# for; on by default, it deletes that branch on every plain sync.
run_mutation "M8  pruning is on without --prune" \
  'PRUNE=0' \
  'PRUNE=1' \
  "a plain sweep leaves a just-created branch in place"

# Containment read the wrong way round accepts a branch whose upstream is
# behind it, deleting the commits only this clone holds.
run_mutation "M9  the containment test is read the wrong way round" \
  'merge-base --is-ancestor "$2" "$3"' \
  'merge-base --is-ancestor "$3" "$2"' \
  "the branch ahead of its upstream keeps its tip"

run_mutation "M10 every branch counts as on the default branch" \
  'contained "$dir" "$tip" "refs/remotes/origin/$db" && held=' \
  'true && held=' \
  "the local-only branch keeps its tip"

# Only origin was fetched; another remote's ref can outlive its branch.
run_mutation "M11 an upstream on any remote counts as proof" \
  'refs/remotes/origin/*) contained' \
  'refs/remotes/*) contained' \
  "a branch tracking a remote the sweep did not fetch keeps its tip"

# Past this guard the main worktree's path reaches `git worktree remove`, which
# refuses a main working tree, so the branch survives; only the reason shows.
run_mutation "M12 the checked-out guard is dropped" \
  'if [ "$kind" = main ]; then' \
  'if false; then' \
  "the checked-out branch's row says why it was kept"

# update-ref deletes a checked-out branch and leaves HEAD unborn, so a worktree
# parse that misses the main worktree's branch loses it outright.
run_mutation "M13 the main worktree's branch is not read" \
  '/^branch refs\/heads\// { b = substr($0, 19) }' \
  '/^branch refs\/heads\// { if (k != "main") b = substr($0, 19) }' \
  "the branch checked out in the main worktree keeps its tip"

# `git worktree remove` without --force refuses a dirty tree too, so the tree
# survives either way; only the row's reason shows the guard has gone.
run_mutation "M14 the dirty-worktree guard is dropped" \
  'if ! worktree_clean "$wt"; then' \
  'if false; then' \
  "the dirty worktree's row names its uncommitted changes"

run_mutation "M15 the default branch is no longer exempt" \
  '[ "$b" = "$db" ] && continue' \
  ':' \
  "the local default branch is never pruned"

run_mutation "M16 a dry run prunes" \
  'if [ "$NO_WRITE" -eq 1 ]; then
      emit WOULD-PRUNE' \
  'if false; then
      emit WOULD-PRUNE' \
  "a dry run with --prune deletes nothing"

# The restore command is the undo the deletion relies on; it is checked by
# running it, so a command that restores the wrong tip is caught.
run_mutation "M17 the restore command loses the tip" \
  'restore="git -C $qdir branch $qb $tip"' \
  'restore="git -C $qdir branch $qb"' \
  "the printed restore brings pr-behind back at its tip"

run_mutation "M18 the restore command forgets the worktree" \
  'restore="$restore && git -C $qdir worktree add $qwt $qb"' \
  ':' \
  "the printed restore brings the removed worktree back on its branch"

run_mutation "M19 a detached worktree goes unreported" \
  'if [ "$kind" = linked ] && [ -z "$b" ]; then' \
  'if false; then' \
  "a detached worktree is reported"

printf '\n-----------------------------------------\n'
printf '%d killed, %d survived, %d misfired\n' "$KILLED" "$SURVIVED" "$MISFIRED"
[ "$SURVIVED" -eq 0 ] && [ "$MISFIRED" -eq 0 ]
