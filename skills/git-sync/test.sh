#!/bin/bash
# Fixture harness for git-sync.sh.
#
# Every status the script can emit gets a fixture here. The script publishes its
# vocabulary via --print-status-vocab; t_vocab compares it against the expected
# list below and against the statuses this file's own assertions cover, so a
# status added to the script without a fixture fails the run.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd -P)"
SYNC="$HERE/git-sync.sh"
ROOT="${TMPDIR:-/tmp}/git-sync-tests.$$"

PASS=0; FAIL=0

# --- expected status vocabulary (independent of the script) -------------------
EXPECTED_VOCAB="BLOCKED CONFLICT DECLINED DIVERGED FETCH-FAIL IN-USE LOCAL NO-BRANCH STASHED UPDATED WOULD-UPDATE ok"

# --- helpers ------------------------------------------------------------------

say() { printf '%s\n' "$*"; }
ok_() { PASS=$((PASS+1)); printf '  \033[32mPASS\033[0m %s\n' "$1"; }
no_() { FAIL=$((FAIL+1)); printf '  \033[31mFAIL\033[0m %s\n' "$1"; [ $# -gt 1 ] && printf '       %s\n' "$2"; }

# Summary rows are "STATUS name ...". The prompt block also prints repo names, so
# a row only counts when its first field is one of the statuses declared above.
VOCAB_RE="^($(printf '%s' "$EXPECTED_VOCAB" | tr ' ' '|'))$"
row_for() { printf '%s\n' "$1" | awk -v r="$2" -v re="$VOCAB_RE" '$2==r && $1 ~ re {print; exit}'; }

assert_status() {
  local out="$1" repo="$2" want="$3" label="${4:-$2 is $3}"
  local line got
  line=$(row_for "$out" "$repo")
  got=$(printf '%s\n' "$line" | awk '{print $1}')
  if [ "$got" = "$want" ]; then ok_ "$label"
  else no_ "$label" "wanted '$want', got '${got:-<none>}' | row: ${line:-<no row for $repo>}"; fi
}

assert_no_row() {
  local out="$1" repo="$2" label="$3"
  if [ -z "$(row_for "$out" "$repo")" ]; then ok_ "$label"
  else no_ "$label" "unexpected row: $(row_for "$out" "$repo")"; fi
}

assert_row_contains() {
  local out="$1" repo="$2" needle="$3" label="$4"
  local line; line=$(row_for "$out" "$repo")
  if printf '%s\n' "$line" | grep -qF "$needle"; then ok_ "$label"
  else no_ "$label" "row lacks '$needle': ${line:-<no row for $repo>}"; fi
}

assert_row_lacks() {
  local out="$1" repo="$2" needle="$3" label="$4"
  local line; line=$(row_for "$out" "$repo")
  if [ -z "$line" ]; then no_ "$label" "no row for $repo"
  elif printf '%s\n' "$line" | grep -qF "$needle"; then no_ "$label" "row unexpectedly has '$needle': $line"
  else ok_ "$label"; fi
}

assert_contains() {
  local out="$1" needle="$2" label="$3"
  if printf '%s\n' "$out" | grep -qF "$needle"; then ok_ "$label"
  else no_ "$label" "missing substring: $needle"; fi
}

assert_eq() {
  local got="$1" want="$2" label="$3"
  if [ "$got" = "$want" ]; then ok_ "$label"; else no_ "$label" "wanted '$want', got '$got'"; fi
}

gc() { local d="$1"; shift; git -C "$d" "$@"; }

# a 20-line file so origin and a local edit can touch the same file in
# different hunks (a clean stash pop) or the same line (a conflicting one)
lines_file() {
  local path="$1" line="$2" marker="$3" i
  : > "$path"
  for i in $(seq 1 20); do
    if [ "$i" = "$line" ]; then printf '%s\n' "$marker" >> "$path"
    else printf 'line %02d\n' "$i" >> "$path"; fi
  done
}

new_repo() {
  local name="$1"
  local dir="$WS/$name"
  git init -q --bare "$WS/.origins/$name.git"
  git clone -q "$WS/.origins/$name.git" "$dir" 2>/dev/null
  gc "$dir" config user.email t@t; gc "$dir" config user.name tester
  printf 'a1\n' > "$dir/a.txt"
  lines_file "$dir/b.txt" 0 ""
  gc "$dir" add -A; gc "$dir" commit -qm init
  gc "$dir" push -q origin HEAD:main
  gc "$dir" checkout -q -B main
  gc "$dir" branch -q --set-upstream-to=origin/main main 2>/dev/null
  gc "$dir" remote set-head origin main >/dev/null 2>&1
}

# push a commit to origin that rewrites b.txt with a marker on $2
advance_origin() {
  local name="$1"
  local line="${2:-1}"
  local s="$WS/.scratch/$name"
  rm -rf "$s"; git clone -q "$WS/.origins/$name.git" "$s" 2>/dev/null
  gc "$s" config user.email t@t; gc "$s" config user.name tester
  gc "$s" checkout -q -B main origin/main
  lines_file "$s/b.txt" "$line" "ORIGIN-CHANGE"
  gc "$s" add -A; gc "$s" commit -qm "origin advances b.txt line $line"
  gc "$s" push -q origin main
  gc "$WS/$name" fetch -q origin 2>/dev/null
}

# --- fixture construction -----------------------------------------------------

build_workspace() {
  WS="$ROOT/ws"
  rm -rf "$WS" "$ROOT/wt"; mkdir -p "$WS/.origins" "$WS/.scratch" "$ROOT/wt"

  # ok - already current
  new_repo current

  # UPDATED - on main, clean, behind
  new_repo behind;      advance_origin behind 1

  # UPDATED - dirty, but incoming commits do not touch the dirty file
  new_repo dirtyclear;  advance_origin dirtyclear 1
  printf 'LOCAL-EDIT\n' > "$WS/dirtyclear/a.txt"

  # BLOCKED / DECLINED - dirty file is also changed by the incoming commits
  for n in overlap declining; do
    new_repo "$n"; advance_origin "$n" 1
    lines_file "$WS/$n/b.txt" 1 "MY-EDIT"
  done

  # STASHED - same file, different hunk, so the pop applies cleanly
  new_repo stashable;   advance_origin stashable 1
  lines_file "$WS/stashable/b.txt" 20 "MY-EDIT-FAR-AWAY"

  # CONFLICT - same file, same line, so the pop cannot apply
  new_repo conflicting; advance_origin conflicting 1
  lines_file "$WS/conflicting/b.txt" 1 "MY-EDIT-SAME-LINE"

  # UPDATED (ref only) - parked on a feature branch, main behind
  new_repo parked;      advance_origin parked 1
  gc "$WS/parked" checkout -q -b feature/work

  # ok, but parked on a feature branch: the row must still say where you stand
  new_repo parkedcurrent
  gc "$WS/parkedcurrent" checkout -q -b feature/parked

  # IN-USE - main checked out in a second worktree
  new_repo inuse;       advance_origin inuse 1
  gc "$WS/inuse" checkout -q -b other
  gc "$WS/inuse" worktree add -q "$ROOT/wt/inuse" main

  # DIVERGED - local main carries a commit origin does not have
  new_repo diverged;    advance_origin diverged 1
  printf 'local only\n' > "$WS/diverged/c.txt"
  gc "$WS/diverged" add -A; gc "$WS/diverged" commit -qm "local only commit"

  # DIVERGED, but only ahead: a local commit and nothing new on origin
  new_repo ahead
  printf 'local only\n' > "$WS/ahead/c.txt"
  gc "$WS/ahead" add -A; gc "$WS/ahead" commit -qm "local only commit"

  # UPDATED - a second remote that cannot be reached must not fail the repo
  new_repo secondremote; advance_origin secondremote 1
  gc "$WS/secondremote" remote add stale "$ROOT/does-not-exist.git"

  # LOCAL - no remote at all
  mkdir -p "$WS/noremote"; git init -q "$WS/noremote"
  gc "$WS/noremote" config user.email t@t; gc "$WS/noremote" config user.name tester
  printf 'x\n' > "$WS/noremote/x.txt"; gc "$WS/noremote" add -A; gc "$WS/noremote" commit -qm init

  # FETCH-FAIL - origin points nowhere
  new_repo broken
  gc "$WS/broken" remote set-url origin "$ROOT/does-not-exist.git"

  # NO-BRANCH - origin has main, there is no local branch of that name.
  # -B, not -b: a clone made under init.defaultBranch=trunk already carries a
  # branch of that name.
  new_repo nolocal;     advance_origin nolocal 1
  gc "$WS/nolocal" checkout -q -B trunk
  gc "$WS/nolocal" branch -q -D main
  if gc "$WS/nolocal" show-ref --verify --quiet refs/heads/main; then
    no_ "fixture nolocal has no local main" "setup failed: main still exists"
  fi

  # a plain folder, not a repo
  mkdir -p "$WS/plainfolder"; printf 'hi\n' > "$WS/plainfolder/readme.txt"
}

# --- tests --------------------------------------------------------------------

t_vocab() {
  say ""; say "== status vocabulary is fully fixtured =="
  local got want
  got=$("$SYNC" --print-status-vocab | tr ' ' '\n' | sort | tr '\n' ' ' | sed 's/ *$//')
  want=$(printf '%s' "$EXPECTED_VOCAB" | tr ' ' '\n' | sort | tr '\n' ' ' | sed 's/ *$//')
  assert_eq "$got" "$want" "the script publishes the expected vocabulary"
  local asserted missing=""
  asserted=$(grep -E '^ *assert_status ' "$0" | awk '{print $4}' | sort -u)
  for s in $got; do
    printf '%s\n' "$asserted" | grep -qx "$s" || missing="$missing $s"
  done
  assert_eq "${missing# }" "" "every status the script emits is asserted by a fixture"
}

t_main_sweep() {
  say ""; say "== folder sweep: one status per fixture =="
  build_workspace
  local out
  out=$("$SYNC" "$WS" --jobs 4 --quiet </dev/null 2>&1)

  assert_status "$out" current    ok         "current repo reports ok"
  assert_status "$out" behind     UPDATED    "behind repo fast-forwards"
  assert_status "$out" dirtyclear UPDATED    "dirty repo with no overlap fast-forwards"
  assert_status "$out" overlap    BLOCKED    "dirty repo with overlap is blocked"
  assert_status "$out" parked     UPDATED    "parked repo updates main by refspec"
  assert_status "$out" inuse      IN-USE     "main checked out elsewhere is skipped"
  assert_status "$out" diverged   DIVERGED   "diverged main is reported, not merged"
  assert_row_lacks "$out" diverged "nothing to pull" "a truly diverged repo is told to merge"
  assert_status "$out" ahead      DIVERGED   "ahead-only main is reported, not merged"
  assert_row_contains "$out" ahead "nothing to pull" "an ahead-only repo is told there is nothing to pull"
  assert_status "$out" secondremote UPDATED  "an unreachable second remote does not fail the repo"
  assert_status "$out" noremote   LOCAL      "remoteless repo is LOCAL, not an error"
  assert_status "$out" broken     FETCH-FAIL "unreachable origin is FETCH-FAIL"
  assert_row_contains "$out" broken "fatal" "the FETCH-FAIL detail names the cause, not the generic hint"
  assert_status "$out" nolocal    NO-BRANCH  "missing local default branch is NO-BRANCH"
  assert_contains "$out" "plainfolder" "the non-repo folder is named in the footer"

  say ""; say "== a row never hides which branch you are standing on =="
  assert_status "$out" parkedcurrent ok "a current repo on a feature branch reports ok"
  assert_row_contains "$out" parkedcurrent "feature/parked" "the ok row names the checked-out branch"
  assert_row_contains "$out" parked "feature/work" "the ref-only row names the checked-out branch"
  assert_row_lacks "$out" behind "on " "a repo on its default branch carries no parked note"

  say ""; say "== the working trees were respected =="
  assert_eq "$(cat "$WS/dirtyclear/a.txt")" "LOCAL-EDIT" "uncommitted edit survived the fast-forward"
  assert_eq "$(sed -n 1p "$WS/overlap/b.txt")" "MY-EDIT" "blocked repo's edit is untouched"
  assert_eq "$(gc "$WS/parked" rev-parse --abbrev-ref HEAD)" "feature/work" "parked repo stayed on its feature branch"
  assert_eq "$(gc "$WS/parked" rev-parse main)" "$(gc "$WS/parked" rev-parse origin/main)" "parked repo's local main reached origin/main"
  assert_eq "$(gc "$WS/diverged" rev-parse main)" "$(gc "$WS/diverged" rev-parse HEAD)" "diverged repo's main was not moved"
  assert_eq "$(gc "$WS/inuse" rev-parse main)" "$(gc "$WS/inuse" rev-parse main)" "in-use repo was not disturbed"

  say ""; say "== exit code =="
  "$SYNC" "$WS" --jobs 4 --quiet </dev/null >/dev/null 2>&1
  assert_eq "$?" "1" "exit 1 when a repo needs attention"
}

t_dry_run() {
  say ""; say "== --dry-run makes no local change =="
  build_workspace
  local before after out
  before=$(gc "$WS/behind" rev-parse main)
  out=$("$SYNC" "$WS" --jobs 4 --quiet --dry-run </dev/null 2>&1)
  after=$(gc "$WS/behind" rev-parse main)
  assert_status "$out" behind WOULD-UPDATE "dry run reports WOULD-UPDATE"
  assert_status "$out" inuse IN-USE "dry run reports IN-USE where the live run would"
  assert_eq "$before" "$after" "dry run left local main where it was"
}

t_fetch_only() {
  say ""; say "== --fetch-only moves remote-tracking refs only =="
  build_workspace
  local before after
  before=$(gc "$WS/behind" rev-parse main)
  "$SYNC" "$WS" --jobs 4 --quiet --fetch-only </dev/null >/dev/null 2>&1
  after=$(gc "$WS/behind" rev-parse main)
  assert_eq "$before" "$after" "local main untouched"
  if [ "$(gc "$WS/behind" rev-parse origin/main)" != "$after" ]; then ok_ "origin/main was fetched"
  else no_ "origin/main was fetched" "the remote ref did not move"; fi
}

t_stash_accept() {
  say ""; say "== overlap prompt: accepting stashes, fast-forwards, pops =="
  build_workspace
  local out; out=$(printf 'a\n' | "$SYNC" "$WS" --jobs 4 --quiet 2>&1)
  assert_status "$out" stashable STASHED "accepted repo reports STASHED"
  assert_eq "$(sed -n 20p "$WS/stashable/b.txt")" "MY-EDIT-FAR-AWAY" "the local edit was restored by the pop"
  assert_eq "$(sed -n 1p "$WS/stashable/b.txt")" "ORIGIN-CHANGE" "the incoming change is present too"
  assert_eq "$(gc "$WS/stashable" stash list | wc -l | tr -d ' ')" "0" "no stash entry left behind"
  assert_eq "$(gc "$WS/stashable" rev-parse main)" "$(gc "$WS/stashable" rev-parse origin/main)" "main reached origin/main"
}

t_stash_decline() {
  say ""; say "== overlap prompt: declining changes nothing =="
  build_workspace
  local before out
  before=$(gc "$WS/declining" rev-parse main)
  out=$(printf 'n\n' | "$SYNC" "$WS" --jobs 4 --quiet 2>&1)
  assert_status "$out" declining DECLINED "declined repo reports DECLINED"
  assert_eq "$(gc "$WS/declining" rev-parse main)" "$before" "declined repo's main did not move"
}

t_conflict() {
  say ""; say "== overlap prompt: a conflicting pop is reported, not swallowed =="
  build_workspace
  local out; out=$(printf 'a\n' | "$SYNC" "$WS/conflicting" --quiet 2>&1)
  assert_status "$out" conflicting CONFLICT "a conflicting pop reports CONFLICT"
  assert_eq "$(gc "$WS/conflicting" stash list | wc -l | tr -d ' ')" "1" "the stash entry is kept for recovery"
}

t_ask_flag() {
  say ""; say "== --ask prompts even when there is no overlap =="
  build_workspace
  local before out
  before=$(gc "$WS/dirtyclear" rev-parse main)
  out=$(printf 'n\n' | "$SYNC" "$WS" --jobs 4 --quiet --ask 2>&1)
  assert_status "$out" dirtyclear DECLINED "--ask lets a safe dirty repo be declined"
  assert_eq "$(gc "$WS/dirtyclear" rev-parse main)" "$before" "declined under --ask, main did not move"
}

t_need_you() {
  say ""; say "== the summary counts only repos that need the user =="
  local W="$ROOT/needyou"
  rm -rf "$W"; mkdir -p "$W/.origins" "$W/.scratch"
  WS="$W"
  new_repo current
  new_repo declining; advance_origin declining 1
  lines_file "$W/declining/b.txt" 1 "MY-EDIT"
  mkdir -p "$W/noremote"; git init -q "$W/noremote"
  gc "$W/noremote" config user.email t@t; gc "$W/noremote" config user.name tester
  printf 'x\n' > "$W/noremote/x.txt"; gc "$W/noremote" add -A; gc "$W/noremote" commit -qm init

  local out; out=$(printf 'n\n' | "$SYNC" "$W" --quiet 2>&1)
  assert_status "$out" declining DECLINED "the declined fixture reports DECLINED"
  assert_status "$out" noremote LOCAL "the remoteless fixture reports LOCAL"
  assert_eq "$(printf '%s\n' "$out" | grep -c "need you")" "0" "DECLINED and LOCAL rows are not counted as needing the user"
}

t_single_repo() {
  say ""; say "== a repo as the target syncs only itself =="
  build_workspace
  local out before after
  before=$(gc "$WS/dirtyclear" rev-parse main)
  out=$("$SYNC" "$WS/behind" --quiet </dev/null 2>&1)
  after=$(gc "$WS/dirtyclear" rev-parse main)
  assert_status "$out" behind UPDATED "single-repo mode syncs the target"
  assert_no_row "$out" current "single-repo mode reports no sibling"
  assert_eq "$before" "$after" "a sibling repo was left alone"
}

t_no_recursion() {
  say ""; say "== only direct children are swept =="
  build_workspace
  mkdir -p "$WS/nested"
  git init -q --bare "$WS/.origins/deep.git"
  git clone -q "$WS/.origins/deep.git" "$WS/nested/deep" 2>/dev/null
  gc "$WS/nested/deep" config user.email t@t; gc "$WS/nested/deep" config user.name tester
  printf 'x\n' > "$WS/nested/deep/x.txt"
  gc "$WS/nested/deep" add -A; gc "$WS/nested/deep" commit -qm init
  gc "$WS/nested/deep" push -q origin HEAD:main
  local out; out=$("$SYNC" "$WS" --jobs 4 --quiet </dev/null 2>&1)
  assert_no_row "$out" deep "a grandchild repo is not swept"
}

t_exotic_names() {
  say ""; say "== repo names with spaces and non-ASCII characters =="
  local W="$ROOT/exotic"
  rm -rf "$W"; mkdir -p "$W/.origins" "$W/.scratch"
  WS="$W"
  new_repo "repo with spaces";   advance_origin "repo with spaces" 1
  new_repo "unicode-репо-名前";  advance_origin "unicode-репо-名前" 1

  local out; out=$("$SYNC" "$W" --quiet </dev/null 2>&1)

  # names with spaces defeat column-position parsing, so assert the refs moved
  assert_eq "$(gc "$W/repo with spaces" rev-parse main)" \
            "$(gc "$W/repo with spaces" rev-parse origin/main)" "a name with spaces syncs"
  assert_eq "$(gc "$W/unicode-репо-名前" rev-parse main)" \
            "$(gc "$W/unicode-репо-名前" rev-parse origin/main)" "a non-ASCII name syncs"
  assert_contains "$out" "repo with spaces" "the spaced name appears in the table"
  assert_contains "$out" "unicode-репо-名前" "the non-ASCII name appears in the table"

  # The branch column starts at the same *character* offset on every row. Byte
  # offsets differ by design once a name is not ASCII, so measuring those tests
  # the opposite of what the padding is for.
  local cols n
  cols=$(printf '%s\n' "$out" | grep '^  UPDATED' | while IFS= read -r line; do
    n=$(printf '%s' "${line%%main*}" | LC_ALL=C tr -d '\200-\277' | wc -c | tr -d ' ')
    printf '%s\n' "$n"
  done | sort -u | grep -c .)
  assert_eq "$cols" "1" "the branch column aligns across ASCII and non-ASCII names"
}

t_scale() {
  say ""; say "== many repos, high concurrency =="
  local W="$ROOT/scale" i
  rm -rf "$W"; mkdir -p "$W/.origins" "$W/.scratch"
  WS="$W"
  for i in $(seq 1 20); do new_repo "r$i"; advance_origin "r$i" 1; done

  local out; out=$("$SYNC" "$W" --jobs 16 --quiet </dev/null 2>&1)
  local n; n=$(printf '%s\n' "$out" | awk -v re="$VOCAB_RE" '$1 ~ re' | grep -c .)
  assert_eq "$n" "20" "all 20 repos reported exactly once at -j16"

  local bad=0
  for i in $(seq 1 20); do
    [ "$(gc "$W/r$i" rev-parse main)" = "$(gc "$W/r$i" rev-parse origin/main)" ] || bad=$((bad+1))
  done
  assert_eq "$bad" "0" "every repo actually fast-forwarded under contention"
}

t_interrupt() {
  say ""; say "== an interrupt inside the stash window does not strand your work =="
  local W="$ROOT/intr"
  rm -rf "$W"; mkdir -p "$W/.origins" "$W/.scratch"
  WS="$W"
  new_repo interruptme; advance_origin interruptme 1
  lines_file "$W/interruptme/b.txt" 1 "MY-EDIT-AT-RISK"

  # post-merge fires after the fast-forward, holding the window open between
  # `stash push` and `stash pop` long enough to interrupt deterministically
  local hook="$W/interruptme/.git/hooks/post-merge"
  printf '#!/bin/sh\nsleep 6\n' > "$hook"; chmod +x "$hook"

  # SIGTERM, not SIGINT: a shell sets SIGINT to ignored in background jobs when
  # job control is off, and bash cannot trap a signal ignored on entry, so no
  # SIGINT this harness sends can ever reach the handler. Both signals run
  # on_interrupt, so TERM tests the same path Ctrl-C takes interactively.
  local log="$ROOT/intr.log"
  printf 'a\n' | "$SYNC" "$W/interruptme" --quiet > "$log" 2>&1 &
  local pid=$!
  sleep 2
  kill -TERM "$pid" 2>/dev/null
  wait "$pid" 2>/dev/null

  if grep -q 'interrupted while interruptme' "$log"; then ok_ "the interrupt is announced, not silent"
  else no_ "the interrupt is announced, not silent" "log: $(tr '\n' ' ' < "$log" | cut -c1-160)"; fi

  # the edit is either back in the tree or still in the stash, never nowhere
  local intree=0 instash=0
  grep -q 'MY-EDIT-AT-RISK' "$W/interruptme/b.txt" 2>/dev/null && intree=1
  gc "$W/interruptme" stash list | grep -q . && instash=1
  if [ "$intree" = "1" ] || [ "$instash" = "1" ]; then ok_ "the uncommitted work is recoverable"
  else no_ "the uncommitted work is recoverable" "not in the tree and not in the stash"; fi

  if [ "$intree" = "0" ] && [ "$instash" = "1" ]; then
    if grep -q 'stash@{0}' "$log"; then ok_ "when it stays stashed, the log says where"
    else no_ "when it stays stashed, the log says where" "no recovery line in the log"; fi
  else
    ok_ "the work was restored to the tree automatically"
  fi
}

# --- run ----------------------------------------------------------------------

if [ ! -x "$SYNC" ]; then
  printf 'git-sync.sh not found or not executable at %s\n' "$SYNC" >&2
  exit 2
fi

mkdir -p "$ROOT"
trap 'rm -rf "$ROOT"' EXIT

say "git-sync test suite"
say "workspace: $ROOT"

t_vocab
t_main_sweep
t_dry_run
t_fetch_only
t_stash_accept
t_stash_decline
t_conflict
t_ask_flag
t_need_you
t_single_repo
t_no_recursion
t_exotic_names
t_scale
t_interrupt

say ""
say "-----------------------------------------"
printf '%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
