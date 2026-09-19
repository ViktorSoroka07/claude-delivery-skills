#!/bin/sh
# Self-tests for the hooks (hooks/*.py). Each test feeds a
# hook the JSON payload the harness sends it and asserts on the verdict; the
# commit-time tests build a throwaway repo with real staged content. Run from
# anywhere inside the repo; exits non-zero on any FAIL. Every hook fails open,
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
LAND_HOOK="$ROOT/hooks/landed-branch.py"

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

empty() { # $1 = description, $2 = haystack
  if [ -z "$2" ]; then
    echo "PASS: $1"
  else
    echo "FAIL: $1 (expected no output, got '$2')"
    fails=$((fails+1))
  fi
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

land_payload() { # $1 = command (no quotes/backslashes)
  printf '{"tool_name":"Bash","tool_input":{"command":"%s"}}' "$1"
}

# 1. Both hooks survive garbage stdin - the fail-open path. A broken import
#    exits 1 here, and this is the only harness that ever sees it.
printf '' | "$PY" "$WRITE_HOOK"
check "write hook fails open on empty stdin" 0 $?
printf '' | "$PY" "$COMMIT_HOOK"
check "commit hook fails open on empty stdin" 0 $?
printf '' | "$PY" "$LAND_HOOK"
check "landing hook fails open on empty stdin" 0 $?

# 2. Write hook: a narrative tell in an edit warns (exit 2, stderr names it).
out=$(write_payload /x/f.py '# previously a loop\nx = 1\n' | "$PY" "$WRITE_HOOK" 2>&1)
check "write hook flags a narrative tell" 2 $?
contains "write hook stderr names the backstop" "$out" "backstop"

write_payload /x/f.py '# otherwise the loop runs twice\nx = 1\n' | "$PY" "$WRITE_HOOK" 2>/dev/null
check "write hook flags the skill's own draft-grep tell (otherwise)" 2 $?

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
TARGET=$(pwd -W 2>/dev/null || pwd)
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

# 10b. Quoted directory arguments resolve too - quoting the path is the
#      default in generated shell, so the backstop must follow it.
out=$(printf '%s' "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"cd \\\"$TARGET\\\" && git commit -m x\"}}" | "$PY" "$COMMIT_HOOK")
contains "commit hook follows a double-quoted cd path" "$out" "narrative tells"
out=$(printf '%s' "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"git -C \\\"$TARGET\\\" commit -m x\"}}" | "$PY" "$COMMIT_HOOK")
contains "commit hook follows a double-quoted -C path" "$out" "narrative tells"

# 10c. A cd on its own line of a multi-line command is a separator too. Run
#      from a clean session repo, so a hit can only come from the target.
mkrepo t10c
printf 'clean = 1\n' > f.py
git add f.py
out=$(printf '%s' "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"ls\\ncd $TARGET\\ngit commit -m x\"}}" | "$PY" "$COMMIT_HOOK")
contains "commit hook follows a newline-separated cd" "$out" "narrative tells"

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

# 14. Landing hook: each forge CLI's merge fires the reminder (exit 2, stderr
#     names the backstop). Run from a plain directory, so a match here can only
#     come from the command text - no repo state is consulted on this path.
cd "$WORK" || exit 9
out=$(land_payload 'gh pr merge 42 --squash --delete-branch' | "$PY" "$LAND_HOOK" 2>&1)
check "landing hook fires on a forge merge" 2 $?
contains "landing hook stderr names the backstop" "$out" "landing-merged-work"
land_payload 'glab mr merge 7' | "$PY" "$LAND_HOOK" 2>/dev/null
check "landing hook fires on the second forge CLI" 2 $?
land_payload 'az repos pr update --id 5 --status completed' | "$PY" "$LAND_HOOK" 2>/dev/null
check "landing hook fires on the third forge CLI" 2 $?

# 15. Landing hook: a local merge fires from the default branch and stays quiet
#     from a feature branch - the same command there syncs the target in.
mkrepo t15
printf 'x = 1\n' > f.py
git add f.py
git commit -qm init
land_payload 'git merge feature/x' | "$PY" "$LAND_HOOK" 2>/dev/null
check "landing hook fires on a local merge from the default branch" 2 $?
git checkout -q -b feature/x
land_payload 'git merge origin/main' | "$PY" "$LAND_HOOK" 2>/dev/null
check "landing hook stays quiet syncing the target into a feature branch" 0 $?

# 16. Landing hook: the plumbing commands the skill itself runs are not merges.
git checkout -q -
land_payload 'git merge-base --is-ancestor abc123 def456' | "$PY" "$LAND_HOOK" 2>/dev/null
check "landing hook ignores git merge-base" 0 $?
land_payload 'gh pr merge --help' | "$PY" "$LAND_HOOK" 2>/dev/null
check "landing hook ignores a help invocation" 0 $?
land_payload 'git merge --abort' | "$PY" "$LAND_HOOK" 2>/dev/null
check "landing hook ignores an aborted merge" 0 $?

# 17. Landing hook: a merge named inside a quoted message is message text, and
#     a failed tool call is not a landing.
out=$(printf '%s' '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"land it with gh pr merge\""}}' | "$PY" "$LAND_HOOK" 2>&1)
check "landing hook does not read a quoted message as a merge" 0 $?
out=$(land_payload 'git commit -q -F - <<EOF\nRecount the cards\n\nThe fifth skill closes the work out after the merge lands.\nEOF' | "$PY" "$LAND_HOOK" 2>&1)
check "landing hook does not read a heredoc commit body as a merge" 0 $?
out=$(land_payload 'gh pr comment 42 --body-file - <<EOF\nReady once gh pr merge runs\nEOF' | "$PY" "$LAND_HOOK" 2>&1)
check "landing hook does not read a heredoc body naming a forge merge as one" 0 $?
out=$(printf '%s' '{"tool_name":"Bash","tool_input":{"command":"gh pr merge 42"},"tool_response":{"is_error":true}}' | "$PY" "$LAND_HOOK" 2>&1)
check "landing hook stays quiet when the command failed" 0 $?
out=$(printf '%s' '{"tool_name":"Edit","tool_input":{"command":"gh pr merge 42"}}' | "$PY" "$LAND_HOOK" 2>&1)
check "landing hook ignores non-Bash tools" 0 $?

echo
BRIEF_HOOK="$ROOT/hooks/session-brief.py"

# 18. Session brief: emits the SessionStart context as JSON naming every
#     owning skill, ignores its stdin, and fails open when its text is missing.
out=$(printf '{"hook_event_name":"SessionStart","source":"startup"}' | "$PY" "$BRIEF_HOOK" 2>/dev/null)
check "session brief exits 0" 0 $?
ctx=$(printf '%s' "$out" | "$PY" -c 'import json,sys; d=json.load(sys.stdin)["hookSpecificOutput"]; assert d["hookEventName"]=="SessionStart"; print(d["additionalContext"])' 2>/dev/null)
check "session brief output is the SessionStart JSON shape" 0 $?
for s in writing-for-audiences review-pr maintaining-project-memory writing-code-comments tracking-open-asks; do
  contains "session brief names $s" "$ctx" "delivery-skills:$s"
done
printf '' | "$PY" "$BRIEF_HOOK" >/dev/null 2>&1
check "session brief survives empty stdin" 0 $?
cp "$BRIEF_HOOK" "$WORK/orphan-brief.py"
out=$(printf '' | "$PY" "$WORK/orphan-brief.py" 2>/dev/null)
check "session brief fails open without its text file" 0 $?
empty "session brief emits nothing without its text file" "$out"

echo
METER_HOOK="$ROOT/hooks/context-meter.py"

meter_payload() { # $1 = transcript path
  printf '{"hook_event_name":"UserPromptSubmit","transcript_path":"%s","prompt":"go"}' "$1"
}

# Every percentage below is a percentage of a window, and the hook takes that
# window from the environment: run with the operator's own value set, these
# cases assert one number and measure another. Each run pins its own.
meter() { env DELIVERY_SKILLS_CONTEXT_WINDOW="${1:-200000}" "$PY" "$METER_HOOK"; }

usage_line() { # $1 = input tokens, $2 = cache-read tokens
  printf '{"type":"assistant","message":{"usage":{"input_tokens":%s,"cache_read_input_tokens":%s}}}\n' "$1" "$2"
}

# 19. Context meter: reports the size the transcript's own usage numbers give,
#     past the threshold only. It fails open like the others, and a session
#     that never sees the line is the failure it exists to prevent, so the
#     silent paths are asserted as tightly as the loud one.
printf '' | meter >/dev/null 2>&1
check "context meter fails open on empty stdin" 0 $?

usage_line 1000 40000 > "$WORK/quiet.jsonl"
out=$(meter_payload "$WORK/quiet.jsonl" | meter 2>/dev/null)
empty "context meter stays silent below the threshold" "$out"

usage_line 2000 150000 > "$WORK/loud.jsonl"
out=$(meter_payload "$WORK/loud.jsonl" | meter 2>/dev/null)
ctx=$(printf '%s' "$out" | "$PY" -c 'import json,sys; d=json.load(sys.stdin)["hookSpecificOutput"]; assert d["hookEventName"]=="UserPromptSubmit"; print(d["additionalContext"])' 2>/dev/null)
check "context meter output is the UserPromptSubmit JSON shape" 0 $?
contains "context meter names how far into the window the session is" "$ctx" "76% of its context window"
contains "context meter names the skill that owns the hand-over" "$ctx" "maintaining-project-memory"

# A subagent's turns land in the same transcript; reading one reports a fresh
# agent's few thousand tokens as the session's own.
cp "$WORK/loud.jsonl" "$WORK/side.jsonl"
printf '{"type":"assistant","isSidechain":true,"message":{"usage":{"input_tokens":3000}}}\n' >> "$WORK/side.jsonl"
out=$(meter_payload "$WORK/side.jsonl" | meter 2>/dev/null)
contains "context meter reads past a subagent's own window" "$out" "76%"

# A window the session has already passed is not the window: the call carrying
# those tokens would have been refused. The percentage is then meaningless, and
# the hook says so instead of telling a session with room left to wind down.
usage_line 9000 250000 > "$WORK/over.jsonl"
out=$(meter_payload "$WORK/over.jsonl" | meter 2>/dev/null)
ctx=$(printf '%s' "$out" | "$PY" -c 'import json,sys; print(json.load(sys.stdin)["hookSpecificOutput"]["additionalContext"])' 2>/dev/null)
contains "context meter reports a window it has passed as miscalibrated" "$ctx" "bigger than the meter assumes"
contains "context meter names the override that fixes it" "$ctx" "DELIVERY_SKILLS_CONTEXT_WINDOW"
lacks "context meter does not tell an over-window session to wind down" "$ctx" "Reach the next seam"

# The same transcript against a window that really is that big stays silent.
out=$(meter_payload "$WORK/over.jsonl" | meter 1000000 2>/dev/null)
empty "context meter stays silent where the window is actually larger" "$out"

# The tail read, on a transcript past the 1 MB the hook seeks back over: the
# seek lands mid-line, and a dropped line must not be the usage line.
"$PY" -c 'import sys
with open(sys.argv[1], "w") as fh:
    fh.write("{\"type\":\"user\",\"pad\":\"" + "x" * 1200000 + "\"}\n")
    fh.write("{\"type\":\"assistant\",\"message\":{\"usage\":{\"input_tokens\":2000,\"cache_read_input_tokens\":150000}}}\n")' "$WORK/big.jsonl"
out=$(meter_payload "$WORK/big.jsonl" | meter 2>/dev/null)
contains "context meter reads the tail of a large transcript" "$out" "76%"

out=$(meter_payload "$WORK/no-such.jsonl" | meter 2>/dev/null)
empty "context meter stays silent without a transcript" "$out"

printf '{"type":"user"}\n' > "$WORK/nousage.jsonl"
out=$(meter_payload "$WORK/nousage.jsonl" | meter 2>/dev/null)
empty "context meter stays silent on a transcript with no usage" "$out"

out=$(meter_payload "$WORK/quiet.jsonl" | DELIVERY_SKILLS_CONTEXT_WINDOW=50000 "$PY" "$METER_HOOK" 2>/dev/null)
contains "context meter follows the window override" "$out" "82%"

echo
STOP_HOOK="$ROOT/hooks/uncommitted-changes.py"

stop_payload() { # $1 = cwd, $2 = session id
  printf '{"hook_event_name":"Stop","session_id":"%s","cwd":"%s","stop_hook_active":false}' "$2" "$1"
}

# 20. Uncommitted-changes hook: names tracked files a turn leaves uncommitted.
#     Stop fires at the end of every turn, so the same line would repeat
#     through a session that is mid-edit; the dedupe marker is what keeps it
#     to once per set, and TMPDIR points it at the throwaway tree here.
printf '' | TMPDIR="$WORK" "$PY" "$STOP_HOOK" >/dev/null 2>&1
check "uncommitted hook fails open on empty stdin" 0 $?

mkrepo t20
printf 'x = 1\n' > f.py
printf 'entry\n' > BACKLOG.md
git add f.py BACKLOG.md
git commit -qm init
out=$(stop_payload "$R" s20a | TMPDIR="$WORK" "$PY" "$STOP_HOOK")
empty "uncommitted hook stays silent on a clean tree" "$out"

printf 'another entry\n' >> BACKLOG.md
out=$(stop_payload "$R" s20a | TMPDIR="$WORK" "$PY" "$STOP_HOOK")
msg=$(printf '%s' "$out" | "$PY" -c 'import json,sys; print(json.load(sys.stdin)["systemMessage"])' 2>/dev/null)
check "uncommitted hook output is the systemMessage shape" 0 $?
contains "uncommitted hook names the file left uncommitted" "$msg" "uncommitted: BACKLOG.md"
contains "uncommitted hook names the rule to follow" "$msg" "one workstream per commit"

# Same set again in the same session is the repeat the dedupe exists for; a
# file joining the set is news, and a commit clearing it resets the state.
out=$(stop_payload "$R" s20a | TMPDIR="$WORK" "$PY" "$STOP_HOOK")
empty "uncommitted hook stays silent on the same set twice" "$out"
printf 'y = 2\n' >> f.py
out=$(stop_payload "$R" s20a | TMPDIR="$WORK" "$PY" "$STOP_HOOK")
contains "uncommitted hook speaks again when the set grows" "$out" "f.py"
git add -A
git commit -qm second
out=$(stop_payload "$R" s20a | TMPDIR="$WORK" "$PY" "$STOP_HOOK")
empty "uncommitted hook stays silent once the set is committed" "$out"

# Untracked files are not what this watches: a scratch file is not a stray
# change, and warning on one would fire in every session.
printf 'scratch\n' > notes.txt
out=$(stop_payload "$R" s20b | TMPDIR="$WORK" "$PY" "$STOP_HOOK")
empty "uncommitted hook ignores untracked files" "$out"

# A staged rename reports "old -> new"; the new name is the one to commit.
git mv f.py g.py
out=$(stop_payload "$R" s20c | TMPDIR="$WORK" "$PY" "$STOP_HOOK")
contains "uncommitted hook names the new side of a rename" "$out" "g.py"
lacks "uncommitted hook does not name the old side of a rename" "$out" "f.py"

# Outside a repository there is nothing to commit and nothing to say.
out=$(stop_payload "$WORK" s20d | TMPDIR="$WORK" "$PY" "$STOP_HOOK")
empty "uncommitted hook stays silent outside a repository" "$out"

if [ $fails -eq 0 ]; then
  echo "ALL PASS"
  exit 0
fi
echo "$fails test(s) failing"
exit 1
