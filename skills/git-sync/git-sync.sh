#!/bin/bash
#
# git-sync - fetch every repo under a folder and fast-forward its default branch.
# Run with -h for the contract.

set -uo pipefail

VERSION="1.0.0"

# test.sh compares this list against the statuses its own assertions cover,
# so a status added here without a fixture fails the suite.
STATUS_VOCAB="UPDATED ok STASHED DECLINED BLOCKED DIVERGED CONFLICT IN-USE LOCAL NO-BRANCH FETCH-FAIL WOULD-UPDATE"

SEP=$'\037'

# ---------------------------------------------------------------- options ----

TARGET=""
JOBS=8
ASK=0
NO_WRITE=0
DRY_RUN=0
QUIET=0

usage() {
  cat <<EOF
git-sync $VERSION - fetch every repo in a folder and fast-forward its default branch.

usage: git-sync.sh [DIR] [options]

  DIR                 a git repo (syncs just that one) or a folder (syncs its
                      direct children, no recursion). Defaults to \$PWD.

options:
  -j, --jobs N        parallel fetches (default $JOBS)
      --ask           ask before fast-forwarding any repo with local changes,
                      not only the ones git refuses on its own
      --fetch-only    fetch and prune, leave every local branch alone
      --dry-run       fetch and report what is behind, change no local branch
  -q, --quiet         no live progress line (the summary still prints)
      --no-color      plain output
  -h, --help          this text

what happens to each repo:
  on its default branch, clean          fast-forward
  on its default branch, dirty          fast-forward when the incoming commits
                                        touch none of your changed files,
                                        otherwise offer to stash, fast-forward
                                        and pop
  on any other branch                   the default branch ref fast-forwards
                                        with no checkout; your branch and your
                                        working tree stay untouched
  no remote, or default branch checked
  out in another worktree               reported and skipped

Local branches move only by fast-forward, so a repo either advances or reports
why it did not.

exit status: 0 when every repo is current, 1 when any needs your attention.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --version) printf 'git-sync %s\n' "$VERSION"; exit 0 ;;
    --print-status-vocab) printf '%s\n' "$STATUS_VOCAB"; exit 0 ;;
    -j|--jobs) JOBS="${2:-8}"; shift 2; continue ;;
    --jobs=*) JOBS="${1#*=}" ;;
    --ask) ASK=1 ;;
    --fetch-only) NO_WRITE=1 ;;
    --dry-run) NO_WRITE=1; DRY_RUN=1 ;;
    -q|--quiet) QUIET=1 ;;
    --no-color) NO_COLOR=1 ;;
    -*) printf 'git-sync: unknown option %s\n' "$1" >&2; usage >&2; exit 2 ;;
    *) if [ -n "$TARGET" ]; then printf 'git-sync: more than one directory given\n' >&2; exit 2; fi
       TARGET="$1" ;;
  esac
  shift
done

case "$JOBS" in ''|*[!0-9]*) printf 'git-sync: --jobs needs a number\n' >&2; exit 2 ;; esac
[ "$JOBS" -lt 1 ] && JOBS=1

TARGET="${TARGET:-.}"
if [ ! -d "$TARGET" ]; then printf 'git-sync: no such directory: %s\n' "$TARGET" >&2; exit 2; fi
TARGET="$(cd "$TARGET" && pwd -P)"

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_RST=$'\033[0m'; C_DIM=$'\033[2m'; C_GRN=$'\033[32m'; C_YEL=$'\033[33m'
  C_RED=$'\033[31m'; C_BLU=$'\033[36m'; C_B=$'\033[1m'
else
  C_RST=""; C_DIM=""; C_GRN=""; C_YEL=""; C_RED=""; C_BLU=""; C_B=""
fi

TMP="$(mktemp -d "${TMPDIR:-/tmp}/git-sync.XXXXXX")"
trap '[ -n "${TMP:-}" ] && rm -rf "$TMP"' EXIT

# Between `stash push` and `stash pop` a repo's uncommitted work lives in the
# stash and not in its tree. STASH_REPO names that repo for exactly that window,
# so an interrupt restores the work or says where it is, instead of exiting
# silently on a tree that looks clean.
STASH_REPO=""
# shellcheck disable=SC2329,SC2317  # reached through trap
on_interrupt() {
  trap - INT TERM
  if [ -n "$STASH_REPO" ]; then
    printf '\ngit-sync: interrupted while %s had your work stashed.\n' "$(basename "$STASH_REPO")" >&2
    if git -C "$STASH_REPO" stash pop >/dev/null 2>&1; then
      printf 'git-sync: restored it, the repo is as you left it.\n' >&2
    else
      printf 'git-sync: could NOT restore it. Your work is in stash@{0}:\n  git -C %s stash pop\n' "$STASH_REPO" >&2
    fi
  fi
  [ -n "${TMP:-}" ] && rm -rf "$TMP"
  exit 130
}
trap on_interrupt INT TERM

ulen() { printf '%s' "$1" | LC_ALL=C tr -d '\200-\277' | wc -c | tr -d ' '; }

# ---------------------------------------------------------------- targets ----

REPOS=""
SKIPPED=""

if [ -e "$TARGET/.git" ]; then
  REPOS="$TARGET"
else
  for entry in "$TARGET"/*; do
    [ -d "$entry" ] || continue
    name="$(basename "$entry")"
    case "$name" in .*) continue ;; esac
    if [ -e "$entry/.git" ]; then REPOS="${REPOS}${entry}"$'\n'
    else SKIPPED="$SKIPPED $name"; fi
  done
  REPOS="${REPOS%$'\n'}"
fi

if [ -z "$REPOS" ]; then
  printf 'git-sync: no git repositories found in %s\n' "$TARGET" >&2
  exit 2
fi

TOTAL=$(printf '%s\n' "$REPOS" | grep -c .)

# ----------------------------------------------------------------- worker ----

emit() { # status name branch delta action detail path
  printf '%s%s%s%s%s%s%s%s%s%s%s%s%s\n' \
    "$1" "$SEP" "$2" "$SEP" "$3" "$SEP" "$4" "$SEP" "$5" "$SEP" "$6" "$SEP" "$7"
}

dirty_paths() {
  git -C "$1" -c core.quotepath=false status --porcelain -uall 2>/dev/null |
    awk '{ p=substr($0,4); n=index(p," -> ");
           if (n>0) { print substr(p,1,n-1); print substr(p,n+4) } else print p }'
}

# An empty intersection means `merge --ff-only` succeeds and leaves every local
# change in place; a non-empty one means it refuses and moves nothing.
overlapping_paths() { # dir before after
  local dir="$1" before="$2" after="$3" d i
  d="$(mktemp "$TMP/dirty.XXXXXX")"; i="$(mktemp "$TMP/inc.XXXXXX")"
  dirty_paths "$dir" | sort -u > "$d"
  git -C "$dir" diff --name-only "$before".."$after" 2>/dev/null | sort -u > "$i"
  comm -12 "$d" "$i" | grep -v '^$'
  rm -f "$d" "$i"
}

sync_repo() {
  local dir="$1" name; name="$(basename "$dir")"
  local db cur parked before after delta n_dirty overlap ferr fmsg cand ahead dirtylist shown

  if ! git -C "$dir" remote get-url origin >/dev/null 2>&1; then
    emit LOCAL "$name" "" "" NONE "no remote configured" "$dir"; return
  fi

  if ! ferr="$(git -C "$dir" fetch --prune --quiet origin 2>&1)"; then
    # The last line of a fetch failure is often the generic "make sure you have
    # the correct access rights" hint. The first fatal: line names the cause.
    fmsg="$(printf '%s\n' "$ferr" | grep -m1 '^fatal:')"
    [ -n "$fmsg" ] || fmsg="$(printf '%s\n' "$ferr" | grep -v '^$' | tail -1)"
    emit FETCH-FAIL "$name" "" "" NONE "$(printf '%s' "$fmsg" | cut -c1-58)" "$dir"; return
  fi

  db="$(git -C "$dir" symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null)"
  db="${db#refs/remotes/origin/}"
  if [ -z "$db" ]; then
    for cand in main master; do
      if git -C "$dir" show-ref --verify --quiet "refs/remotes/origin/$cand"; then db="$cand"; break; fi
    done
  fi
  if [ -z "$db" ] || ! git -C "$dir" show-ref --verify --quiet "refs/remotes/origin/$db"; then
    emit NO-BRANCH "$name" "" "" NONE "cannot resolve origin's default branch" "$dir"; return
  fi
  if ! git -C "$dir" show-ref --verify --quiet "refs/heads/$db"; then
    emit NO-BRANCH "$name" "$db" "" NONE "no local $db branch" "$dir"; return
  fi

  # Every status below reports on $db, which is not necessarily the branch the
  # user is standing on. Naming the checked-out branch is what stops a row from
  # reading as a claim about their working tree.
  cur="$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)"
  parked=""
  [ "$cur" != "$db" ] && parked="on $cur"

  before="$(git -C "$dir" rev-parse "$db")"
  after="$(git -C "$dir" rev-parse "origin/$db")"

  if [ "$before" = "$after" ]; then
    emit ok "$name" "$db" "" NONE "$parked" "$dir"; return
  fi
  if ! git -C "$dir" merge-base --is-ancestor "$before" "$after" 2>/dev/null; then
    ahead="$(git -C "$dir" rev-list --count "$after".."$before" 2>/dev/null)"
    if git -C "$dir" merge-base --is-ancestor "$after" "$before" 2>/dev/null; then
      emit DIVERGED "$name" "$db" "" NONE "local $db is ${ahead:-?} ahead, nothing to pull, push when ready${parked:+, $parked}" "$dir"
    else
      emit DIVERGED "$name" "$db" "" NONE "local $db is ${ahead:-?} ahead, merge by hand${parked:+, $parked}" "$dir"
    fi
    return
  fi

  delta="+$(git -C "$dir" rev-list --count "$before".."$after")"

  if [ "$cur" != "$db" ] && git -C "$dir" worktree list --porcelain 2>/dev/null | grep -qx "branch refs/heads/$db"; then
    emit IN-USE "$name" "$db" "$delta" NONE "$db is checked out in another worktree" "$dir"; return
  fi

  if [ "$NO_WRITE" -eq 1 ]; then
    if [ "$DRY_RUN" -eq 1 ]; then emit WOULD-UPDATE "$name" "$db" "$delta" NONE "$parked" "$dir"
    else emit ok "$name" "$db" "$delta" NONE "fetched, $db left alone${parked:+, $parked}" "$dir"; fi
    return
  fi

  if [ "$cur" != "$db" ]; then
    # A refspec fetch moves the ref with no checkout, and git rejects it unless
    # it is a fast-forward.
    if git -C "$dir" fetch --quiet origin "$db:$db" 2>/dev/null; then
      emit UPDATED "$name" "$db" "$delta" NONE "ref only, $parked" "$dir"
    else
      emit BLOCKED "$name" "$db" "$delta" NONE "could not update the $db ref" "$dir"
    fi
    return
  fi

  dirtylist="$(dirty_paths "$dir")"
  n_dirty=$(printf '%s' "$dirtylist" | grep -c .)

  if [ "$n_dirty" -eq 0 ]; then
    if git -C "$dir" merge --ff-only "origin/$db" >/dev/null 2>&1; then
      emit UPDATED "$name" "$db" "$delta" NONE "" "$dir"
    else
      emit BLOCKED "$name" "$db" "$delta" NONE "fast-forward refused" "$dir"
    fi
    return
  fi

  overlap="$(overlapping_paths "$dir" "$before" "$after")"
  if [ -n "$overlap" ]; then
    shown="$(printf '%s' "$overlap" | head -3 | tr '\n' ' ')"
    emit BLOCKED "$name" "$db" "$delta" ASK_STASH "origin also changed: ${shown% }" "$dir"
    return
  fi

  if [ "$ASK" -eq 1 ]; then
    emit BLOCKED "$name" "$db" "$delta" ASK_FF "$n_dirty uncommitted, none touched" "$dir"
    return
  fi

  if git -C "$dir" merge --ff-only "origin/$db" >/dev/null 2>&1; then
    emit UPDATED "$name" "$db" "$delta" NONE "$n_dirty uncommitted, none touched" "$dir"
  else
    emit BLOCKED "$name" "$db" "$delta" ASK_STASH "fast-forward refused" "$dir"
  fi
}

# ----------------------------------------------------------------- fetch -----

running() { jobs -pr 2>/dev/null | grep -c . ; }

progress() {
  [ "$QUIET" -eq 1 ] && return 0
  [ -t 2 ] || return 0
  local done_ inflight
  done_=0
  for f in "$TMP"/res.*; do [ -e "$f" ] && done_=$((done_+1)); done
  inflight=$(cat "$TMP"/run.* 2>/dev/null | tr '\n' ' ' | cut -c1-46)
  printf '\r\033[K%s[%d/%d]%s fetching %s' "$C_DIM" "$done_" "$TOTAL" "$C_RST" "${inflight:-...}" >&2
}

i=0
while IFS= read -r repo; do
  [ -n "$repo" ] || continue
  while [ "$(running)" -ge "$JOBS" ]; do progress; sleep 0.15; done
  i=$((i+1))
  (
    basename "$repo" > "$TMP/run.$i"
    sync_repo "$repo" > "$TMP/res.$i"
    rm -f "$TMP/run.$i"
  ) &
  progress
done <<EOF
$REPOS
EOF

while [ "$(running)" -gt 0 ]; do progress; sleep 0.15; done
wait
[ "$QUIET" -eq 1 ] || { [ -t 2 ] && printf '\r\033[K' >&2; }

cat "$TMP"/res.* 2>/dev/null > "$TMP/all"

# ---------------------------------------------------------------- decide -----

PENDING="$(awk -F"$SEP" '$5!="NONE"' "$TMP/all")"
ANSWER=""
ANSWERED=0

if [ -n "$PENDING" ]; then
  n=$(printf '%s\n' "$PENDING" | grep -c .)
  {
    printf '\n%s%d repo(s) need a decision:%s\n\n' "$C_B" "$n" "$C_RST"
    printf '%s\n' "$PENDING" | awk -F"$SEP" -v y="$C_YEL" -v r="$C_RST" '{
      what = ($5=="ASK_STASH") ? "stash, fast-forward, pop" : "fast-forward"
      printf "  %s%d%s  %-28s %-5s %-30s %s\n", y, NR, r, $2, $4, $6, what
    }'
    printf '\n  Proceed for which?  [a]ll / [n]one / numbers (e.g. 1,3): '
  } >&2
  if IFS= read -r ANSWER; then ANSWERED=1; else ANSWER=""; fi
  printf '\n' >&2
fi

selected() {
  case "$ANSWER" in
    a|A|all|ALL) return 0 ;;
    ''|n|N|no|NO|none|NONE) return 1 ;;
  esac
  printf '%s' "$ANSWER" | tr ',' ' ' | tr -s ' ' '\n' | grep -qx "$1"
}

: > "$TMP/final"
idx=0
while IFS="$SEP" read -r status name branch delta action detail path; do
  [ -n "${status:-}" ] || continue
  if [ "$action" = "NONE" ]; then
    emit "$status" "$name" "$branch" "$delta" NONE "$detail" "$path" >> "$TMP/final"
    continue
  fi
  idx=$((idx+1))
  # DECLINED means you were asked and said no. A repo that could not be asked
  # keeps BLOCKED, which is what git reports about it regardless of any answer.
  if ! selected "$idx"; then
    if [ "$ANSWERED" -eq 1 ] || [ "$action" = "ASK_FF" ]; then
      emit DECLINED "$name" "$branch" "$delta" NONE "$detail" "$path" >> "$TMP/final"
    else
      emit BLOCKED "$name" "$branch" "$delta" NONE "$detail" "$path" >> "$TMP/final"
    fi
    continue
  fi

  if [ "$action" = "ASK_FF" ]; then
    if git -C "$path" merge --ff-only "origin/$branch" >/dev/null 2>&1; then
      emit UPDATED "$name" "$branch" "$delta" NONE "$detail" "$path" >> "$TMP/final"
    else
      emit BLOCKED "$name" "$branch" "$delta" NONE "fast-forward refused" "$path" >> "$TMP/final"
    fi
    continue
  fi

  if ! git -C "$path" stash push -u -q -m "git-sync $(date +%Y-%m-%dT%H:%M:%S)" >/dev/null 2>&1; then
    emit BLOCKED "$name" "$branch" "$delta" NONE "could not stash" "$path" >> "$TMP/final"; continue
  fi
  STASH_REPO="$path"
  if ! git -C "$path" merge --ff-only "origin/$branch" >/dev/null 2>&1; then
    git -C "$path" stash pop -q >/dev/null 2>&1
    STASH_REPO=""
    emit BLOCKED "$name" "$branch" "$delta" NONE "fast-forward refused, stash restored" "$path" >> "$TMP/final"; continue
  fi
  if git -C "$path" stash pop -q >/dev/null 2>&1; then
    STASH_REPO=""
    emit STASHED "$name" "$branch" "$delta" NONE "stashed, fast-forwarded, restored" "$path" >> "$TMP/final"
  else
    STASH_REPO=""
    emit CONFLICT "$name" "$branch" "$delta" NONE "pop conflicted, your work is in stash@{0}" "$path" >> "$TMP/final"
  fi
done < "$TMP/all"

# ---------------------------------------------------------------- report -----

rank() {
  case "$1" in
    UPDATED|STASHED|WOULD-UPDATE) echo 1 ;;
    ok) echo 2 ;;
    DECLINED) echo 3 ;;
    BLOCKED|CONFLICT|DIVERGED) echo 4 ;;
    IN-USE|NO-BRANCH) echo 5 ;;
    LOCAL) echo 6 ;;
    FETCH-FAIL) echo 7 ;;
    *) echo 8 ;;
  esac
}

: > "$TMP/sorted"
while IFS="$SEP" read -r status name branch delta action detail path; do
  [ -n "${status:-}" ] || continue
  printf '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n' \
    "$(rank "$status")" "$SEP" "$status" "$SEP" "$name" "$SEP" "$branch" "$SEP" "$delta" "$SEP" "$detail" \
    "$SEP" "$(ulen "$name")" "$SEP" "$(ulen "$branch")" >> "$TMP/sorted"
done < "$TMP/final"
sort -t"$SEP" -k1,1n -k3,3 "$TMP/sorted" -o "$TMP/sorted"

printf '\n'
awk -F"$SEP" -v grn="$C_GRN" -v yel="$C_YEL" -v red="$C_RED" -v blu="$C_BLU" \
    -v dim="$C_DIM" -v rst="$C_RST" '
  # Columns are padded from the character counts in fields 7 and 8, not from
  # length(), which counts bytes and under-pads any non-ASCII name.
  { if ($7 > wn) wn = $7; if ($8 > wb) wb = $8
    rows[NR] = $0 }
  END {
    for (i = 1; i <= NR; i++) {
      split(rows[i], f, FS)
      s = f[2]
      c = yel
      if (s=="UPDATED" || s=="STASHED" || s=="WOULD-UPDATE") c = grn
      else if (s=="ok") c = dim
      else if (s=="LOCAL" || s=="IN-USE" || s=="DECLINED") c = blu
      else if (s=="FETCH-FAIL" || s=="CONFLICT") c = red
      printf "  %s%-12s%s %s%*s %s%*s %-5s %s%s%s\n",
             c, s, rst, f[3], wn - f[7] + 1, "", f[4], wb - f[8] + 1, "", f[5], dim, f[6], rst
    }
  }
' "$TMP/sorted"

count() { awk -F"$SEP" -v s="$1" '$2==s' "$TMP/sorted" | grep -c . ; }
n_moved=$(( $(count UPDATED) + $(count STASHED) + $(count WOULD-UPDATE) ))
n_ok=$(count ok)
n_att=$(( $(count BLOCKED) + $(count CONFLICT) + $(count DIVERGED) + $(count IN-USE) + $(count NO-BRANCH) + $(count FETCH-FAIL) ))

summary="  ${TOTAL} repo(s)"
[ "$n_moved" -gt 0 ] && summary="$summary, ${n_moved} updated"
[ "$n_ok" -gt 0 ] && summary="$summary, ${n_ok} already current"
[ "$n_att" -gt 0 ] && summary="$summary, ${C_YEL}${n_att} need you${C_RST}"
printf '\n%s\n' "$summary"

if [ -n "$SKIPPED" ]; then
  n_skip=$(printf '%s' "$SKIPPED" | wc -w | tr -d ' ')
  printf '  %s%s folder(s) skipped, not git repos:%s%s\n' "$C_DIM" "$n_skip" "$SKIPPED" "$C_RST"
fi
printf '\n'

n_bad=$(( $(count FETCH-FAIL) + $(count DIVERGED) + $(count CONFLICT) + $(count BLOCKED) ))
[ "$n_bad" -gt 0 ] && exit 1
exit 0
