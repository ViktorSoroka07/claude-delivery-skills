#!/bin/sh
# Self-tests for the comment-discipline hooks (hooks/*.py). Each test feeds a
# hook the JSON payload the harness sends it and asserts on the verdict; the
# commit-time tests build a throwaway repo with real staged content. Run from
# anywhere inside the repo; exits non-zero on any FAIL. Both hooks fail open,
# so an import or syntax error is invisible in a session - the smoke tests
# here are the only place such a break surfaces.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
PY=$(command -v python3 || command -v python)
fails=0

WRITE_HOOK="$ROOT/hooks/comment-discipline.py"
COMMIT_HOOK="$ROOT/hooks/comment-discipline-commit.py"

check() { # $1 = description, $2 = expected exit, $3 = actual exit
  if [ "$2" = "$3" ]; then
    echo "PASS: $1"
  else
    echo "FAIL: $1 (expected exit $2, got $3)"
    fails=$((fails+1))
  fi
}

contains() { # $1 = description, $2 = haystack, $3 = needle
  case "$2" in
    *"$3"*) echo "PASS: $1" ;;
    *) echo "FAIL: $1 (output lacks '$3')"; fails=$((fails+1)) ;;
  esac
}

lacks() { # $1 = description, $2 = haystack, $3 = needle
  case "$2" in
    *"$3"*) echo "FAIL: $1 (output contains '$3')"; fails=$((fails+1)) ;;
    *) echo "PASS: $1" ;;
  esac
}

mkrepo() {
  R="$WORK/$1"
  mkdir -p "$R"
  cd "$R" || exit 9
  git init -q .
  git config user.name Test
  git config user.email test@example.com
}

write_payload() { # $1 = file_path, $2 = new_string (no quotes/backslashes)
  printf '{"tool_name":"Edit","tool_input":{"file_path":"%s","new_string":"%s"}}' "$1" "$2"
}

commit_payload() { # $1 = command (no quotes/backslashes)
  printf '{"tool_name":"Bash","tool_input":{"command":"%s"}}' "$1"
}

# 1. Both hooks survive garbage stdin - the fail-open path. A broken import
#    exits 1 here, and this is the only harness that ever sees it.
printf '' | "$PY" "$WRITE_HOOK"
check "write hook fails open on empty stdin" 0 $?
printf '' | "$PY" "$COMMIT_HOOK"
check "commit hook fails open on empty stdin" 0 $?

# 2. Write hook: a narrative tell in an edit warns (exit 2, stderr names it).
out=$(write_payload /x/f.py '# previously a loop\nx = 1\n' | "$PY" "$WRITE_HOOK" 2>&1)
check "write hook flags a narrative tell" 2 $?
contains "write hook stderr names the backstop" "$out" "backstop"

# 3. Write hook: an earned present-tense comment passes, including one using
#    phrasing near the tell list ("without a ...") - the false-positive guard.
write_payload /x/f.py '# index is sorted by key\nx = 1\n' | "$PY" "$WRITE_HOOK" 2>/dev/null
check "write hook passes a clean invariant comment" 0 $?
write_payload /x/f.py '# deadlocks without a timeout on the outer lock\nx = 1\n' | "$PY" "$WRITE_HOOK" 2>/dev/null
check "write hook passes a present-tense invariant near the tell list" 0 $?

# 4. Write hook: prose files are exempt.
write_payload /x/notes.md '# previously a loop\n' | "$PY" "$WRITE_HOOK" 2>/dev/null
check "write hook skips markdown" 0 $?

# 5. Commit hook: a staged tell is reported when a commit command runs.
mkrepo t5
printf '# previously a loop\nx = 1\n' > f.py
git add f.py
out=$(commit_payload 'git commit -m x' | "$PY" "$COMMIT_HOOK")
check "commit hook exits 0 (warn-only)" 0 $?
contains "commit hook reports the staged tell" "$out" "narrative tells"
lacks "commit hook reports the line without the diff prefix" "$out" "tells: +"

# 6. Commit hook: a non-commit command stays silent with tells staged.
out=$(commit_payload 'git status' | "$PY" "$COMMIT_HOOK")
lacks "commit hook ignores non-commit commands" "$out" "narrative tells"

# 7. Commit hook: the staged diff is read repo-wide, not relative to the
#    session CWD - a session parked in a subdirectory must still see a tell
#    staged elsewhere in the tree.
mkrepo t7
mkdir -p sub
printf '# previously a loop\nx = 1\n' > f.py
printf 'clean = 1\n' > sub/g.py
git add f.py sub/g.py
cd sub || exit 9
out=$(commit_payload 'git commit -m x' | "$PY" "$COMMIT_HOOK")
contains "commit hook sees staged tells outside the CWD subtree" "$out" "narrative tells"

# 8. Commit hook: commit -a also sweeps unstaged edits to tracked files.
mkrepo t8
printf 'x = 1\n' > f.py
git add f.py
git commit -qm init
printf '# previously a loop\ny = 2\n' >> f.py
out=$(commit_payload 'git commit -am x' | "$PY" "$COMMIT_HOOK")
contains "commit hook sweeps unstaged tracked edits under -a" "$out" "narrative tells"

# 9. Commit hook: staged markdown is exempt, an earned invariant passes.
mkrepo t9
printf 'previously this said otherwise\n' > notes.md
printf '# deadlocks without a timeout on the outer lock\nx = 1\n' > f.py
git add notes.md f.py
out=$(commit_payload 'git commit -m x' | "$PY" "$COMMIT_HOOK")
lacks "commit hook skips markdown and earned invariants" "$out" "narrative tells"

# 10. Commit hook: 'git -C <dir> commit' and 'cd <dir> && git commit' target
#     the named repo - the session repo's staged lines are not that commit's,
#     and the target repo's staged lines are.
mkrepo t10b
TARGET="$R"
printf 'x = 1\n' > f.py
git add f.py
mkrepo t10a
printf '# previously a loop\nx = 1\n' > f.py
git add f.py
out=$(commit_payload "git -C $TARGET commit -m x" | "$PY" "$COMMIT_HOOK")
lacks "commit hook -C: session-repo tells not pinned on a clean target" "$out" "narrative tells"
( cd "$TARGET" && printf '# previously a loop\ny = 2\n' > g.py && git add g.py )
out=$(commit_payload "cd $TARGET && git commit -m x" | "$PY" "$COMMIT_HOOK")
contains "commit hook cd prefix: target-repo tells are seen" "$out" "narrative tells"

# 11. Commit hook: a directory the command names but the parse cannot resolve
#     means silence, not a scan of the session repo.
out=$(commit_payload "cd $WORK/no-such-dir && git commit -m x" | "$PY" "$COMMIT_HOOK")
lacks "commit hook stays silent on an unresolvable target dir" "$out" "narrative tells"

# 12. Commit hook: flag-lookalikes inside the quoted message are message text.
mkrepo t12
printf 'x = 1\n' > f.py
git add f.py
git commit -qm init
printf '# previously a loop\ny = 2\n' >> f.py
out=$(printf '%s' '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"support --all flag\""}}' | "$PY" "$COMMIT_HOOK")
lacks "commit hook does not read the -m message as a -a flag" "$out" "narrative tells"

# 13. Commit hook: a staged patch file's quoted diff content is not commentary.
mkrepo t13
printf -- '--- a/f.py\n+++ b/f.py\n@@ -1 +1,2 @@\n x = 1\n+# previously a loop\n' > fix.patch
git add fix.patch
out=$(commit_payload 'git commit -m x' | "$PY" "$COMMIT_HOOK")
lacks "commit hook skips staged patch-file content" "$out" "narrative tells"

echo
if [ $fails -eq 0 ]; then
  echo "ALL PASS"
  exit 0
fi
echo "$fails test(s) failing"
exit 1
