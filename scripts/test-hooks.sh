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
land_payload 'test -d .git/rebase-merge && echo rebasing' | "$PY" "$LAND_HOOK" 2>/dev/null
check "landing hook does not read a path through .git as a merge" 0 $?
land_payload 'git --no-pager -C . merge feature/x' | "$PY" "$LAND_HOOK" 2>/dev/null
check "landing hook reads a merge behind git's own options" 2 $?

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

echo
GATE_HOOK="$ROOT/hooks/skill-gate.py"
NW=$(cd "$WORK" && { pwd -W 2>/dev/null || pwd; })
GSTATE="$WORK/gate-state"
mkdir -p "$GSTATE"

# The hook reads the memory directory from its environment and the settings
# files it can reach, so each run starts from none of the operator's.
gate_hook() { # $@ = NAME=value pairs added to the hook's environment
  env -u CLAUDE_CONFIG_DIR -u CLAUDE_CODE_REMOTE_MEMORY_DIR -u CLAUDE_COWORK_MEMORY_PATH_OVERRIDE \
    -u CLAUDE_PROJECT_DIR HOME="$NW/home" USERPROFILE="$NW/home" TMPDIR="$GSTATE" "$@" "$PY" "$GATE_HOOK"
}

gate_payload() { # $1 = tool, $2 = session, $3 = agent id ('' = main thread), $4 = transcript, $5 = command or path
  "$PY" -c 'import json, sys
tool, session, agent, transcript, value = sys.argv[1:6]
key = {"Bash": "command", "Write": "file_path", "Edit": "file_path", "Agent": "prompt", "Task": "prompt"}[tool]
p = {"hook_event_name": "PreToolUse", "session_id": session, "transcript_path": transcript,
     "tool_name": tool, "tool_input": {key: value}}
if agent:
    p["agent_id"] = agent
print(json.dumps(p))' "$@"
}

gate() { gate_payload "$@" | gate_hook; }

skill_call() { # $1 = skill; one transcript line holding a Skill tool call
  printf '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"delivery-skills:%s"}}]}}\n' "$1"
}

DENY='"permissionDecision": "deny"'
MEM="$WORK/home/.claude/projects/-work-repo/memory"
printf '{"type":"user","message":{"content":"ship it"}}\n' > "$WORK/t-none.jsonl"
skill_call writing-commit-messages > "$WORK/t-commit.jsonl"
printf '{"type":"user","message":{"content":"<command-name>/delivery-skills:writing-commit-messages</command-name>"}}\n' > "$WORK/t-slash.jsonl"
printf '{"type":"user","message":{"content":"Call the Skill tool with delivery-skills:writing-commit-messages"}}\n' > "$WORK/t-prose.jsonl"

# 21. Skill gate: an act the session chose on its own is stopped once until the
#     skill that owns it is loaded, and never twice - a second stop on the same
#     act is a block.
printf '' | TMPDIR="$GSTATE" "$PY" "$GATE_HOOK"
check "skill gate fails open on empty stdin" 0 $?

out=$(gate Bash g1 '' "$WORK/t-none.jsonl" 'git commit -m x')
check "skill gate exits 0 when it stops" 0 $?
contains "skill gate stops a commit with no load in the transcript" "$out" "$DENY"
contains "skill gate names the commit's skill" "$out" "delivery-skills:writing-commit-messages"
contains "skill gate's reason opens by saying it is no error" "$out" "Not an error"
out=$(gate Bash g1 '' "$WORK/t-none.jsonl" 'git commit -m x')
empty "skill gate stands aside on the retry of a stopped act" "$out"

out=$(gate Bash g2 '' "$WORK/t-commit.jsonl" 'git commit -m x')
empty "skill gate passes a commit once its skill is loaded" "$out"
out=$(gate Bash g3 '' "$WORK/t-slash.jsonl" 'git commit -m x')
empty "skill gate counts a slash-command load" "$out"
out=$(gate Bash g4 '' "$WORK/t-prose.jsonl" 'git commit -m x')
contains "skill gate does not count the skill's name in prose as a load" "$out" "$DENY"

out=$(gate Bash g5 '' "$WORK/t-none.jsonl" 'gh pr create --title t --body b')
contains "skill gate stops a GitHub pull request create" "$out" "delivery-skills:writing-pr-descriptions"
out=$(gate Bash g6 '' "$WORK/t-none.jsonl" 'az repos pr create --title t')
contains "skill gate stops an Azure DevOps pull request create" "$out" "delivery-skills:writing-pr-descriptions"
out=$(gate Write g7 '' "$WORK/t-none.jsonl" "$MEM/feedback.md")
contains "skill gate stops a Write into a memory directory" "$out" "delivery-skills:maintaining-project-memory"
out=$(gate Edit g8 '' "$WORK/t-none.jsonl" "$MEM/MEMORY.md")
contains "skill gate stops an Edit in a memory directory" "$out" "delivery-skills:maintaining-project-memory"
out=$(gate Bash g9 '' "$WORK/t-none.jsonl" "cat > \"$MEM/note.md\" <<'EOF'
body
EOF")
contains "skill gate stops a shell redirect into a memory directory" "$out" "delivery-skills:maintaining-project-memory"
out=$(gate Agent g10 '' "$WORK/t-none.jsonl" 'review the diff')
contains "skill gate stops the first subagent dispatch" "$out" "delivery-skills:delegating-to-subagents"
out=$(gate Task g24 '' "$WORK/t-none.jsonl" 'review the diff')
contains "skill gate stops a dispatch under the tool's other name" "$out" "delivery-skills:delegating-to-subagents"

CFG="$NW/cfg"
mkdir -p "$CFG" "$NW/proj/.claude"
out=$(gate_payload Write g25 '' "$WORK/t-none.jsonl" "$CFG/projects/-w/memory/a.md" | gate_hook CLAUDE_CONFIG_DIR="$CFG")
contains "skill gate stops a memory write under a moved config directory" "$out" "delivery-skills:maintaining-project-memory"
out=$(gate Write g25 '' "$WORK/t-none.jsonl" "$CFG/projects/-w/memory/a.md")
empty "skill gate takes a moved store from the environment, not from the path" "$out"
out=$(gate_payload Write g26 '' "$WORK/t-none.jsonl" "$NW/remote/projects/-w/memory/a.md" | gate_hook CLAUDE_CODE_REMOTE_MEMORY_DIR="$NW/remote")
contains "skill gate stops a memory write under a remote memory directory" "$out" "delivery-skills:maintaining-project-memory"
out=$(gate_payload Bash g27 '' "$WORK/t-none.jsonl" "echo x > $NW/cowork/a.md" | gate_hook CLAUDE_COWORK_MEMORY_PATH_OVERRIDE="$NW/cowork")
contains "skill gate stops a write into an overridden memory directory" "$out" "delivery-skills:maintaining-project-memory"
printf '{"autoMemoryDirectory": "%s"}\n' "$NW/notes" > "$CFG/settings.json"
out=$(gate_payload Edit g28 '' "$WORK/t-none.jsonl" "$NW/notes/a.md" | gate_hook CLAUDE_CONFIG_DIR="$CFG")
contains "skill gate stops an edit in the directory the user's settings name" "$out" "delivery-skills:maintaining-project-memory"
out=$(gate_payload Write g29 '' "$WORK/t-none.jsonl" "$NW/notes-old/a.md" | gate_hook CLAUDE_CONFIG_DIR="$CFG")
empty "skill gate passes a sibling that shares the named directory's prefix" "$out"
printf '{"autoMemoryDirectory": "~/proj-notes"}\n' > "$NW/proj/.claude/settings.local.json"
out=$(gate_payload Write g30 '' "$WORK/t-none.jsonl" "$NW/home/proj-notes/a.md" | gate_hook CLAUDE_PROJECT_DIR="$NW/proj")
contains "skill gate stops a write in the directory a project's local settings name" "$out" "delivery-skills:maintaining-project-memory"
out=$(gate_payload Bash g31 '' "$WORK/t-none.jsonl" 'echo x >> ~/proj-notes/b.md' | gate_hook CLAUDE_PROJECT_DIR="$NW/proj")
contains "skill gate reads that directory written from the home prefix" "$out" "delivery-skills:maintaining-project-memory"
out=$(gate Write g32 '' "$WORK/t-none.jsonl" 'C:\Users\x\.claude\projects\-w\memory\a.md')
contains "skill gate stops a memory write whose path uses backslashes" "$out" "delivery-skills:maintaining-project-memory"

out=$(gate Bash g33 '' "$WORK/t-none.jsonl" "echo x >| $MEM/a.md")
contains "skill gate stops a clobbering redirect into memory" "$out" "delivery-skills:maintaining-project-memory"
out=$(gate Bash g34 '' "$WORK/t-none.jsonl" "cp -t $MEM/ a.md")
contains "skill gate stops a copy whose target directory comes first" "$out" "delivery-skills:maintaining-project-memory"
out=$(gate Bash g35 '' "$WORK/t-none.jsonl" "mv --target-directory=$MEM a.md")
contains "skill gate stops a move naming its target directory as an option" "$out" "delivery-skills:maintaining-project-memory"
out=$(gate Bash g36 '' "$WORK/t-none.jsonl" "cp a.md $MEM/ 2>/dev/null")
contains "skill gate stops a copy into memory followed by a redirect" "$out" "delivery-skills:maintaining-project-memory"
out=$(gate Bash g37 '' "$WORK/t-none.jsonl" "tee /tmp/x < $MEM/note.md")
empty "skill gate passes a tee that reads the memory store" "$out"

out=$(gate Bash g11 '' "$WORK/t-none.jsonl" "cat $MEM/MEMORY.md 2>/dev/null")
empty "skill gate passes a read of the memory store" "$out"
out=$(gate Bash g11 '' "$WORK/t-none.jsonl" "cp $MEM/MEMORY.md $WORK/backup.md")
empty "skill gate passes a copy out of the memory store" "$out"
out=$(gate Write g11 '' "$WORK/t-none.jsonl" "$WORK/repo/memory/notes.md")
empty "skill gate passes a write to a memory directory outside the store" "$out"

out=$(gate Bash g12 '' "$WORK/t-none.jsonl" 'echo "then git commit -m x and gh pr create"')
empty "skill gate does not read quoted text as an act" "$out"
out=$(gate Bash g12 '' "$WORK/t-none.jsonl" "$(printf 'cat <<EOF\ngit commit -m x\nEOF')")
empty "skill gate does not read a heredoc body as an act" "$out"
out=$(gate Bash g12 '' "$WORK/t-none.jsonl" 'git log --grep "gh pr create"')
empty "skill gate does not read a quoted search term as an act" "$out"
out=$(gate Bash g12 '' "$WORK/t-none.jsonl" 'git help commit')
empty "skill gate does not read git help commit as a commit" "$out"
out=$(gate Bash g12 '' "$WORK/t-none.jsonl" 'git commit --help')
empty "skill gate passes a help invocation" "$out"
out=$(gate Bash g13 '' "$WORK/t-none.jsonl" "$(printf 'git commit -q -F - <<EOF\nNote the PR\n\nOpen it with gh pr create later.\nEOF')")
contains "skill gate stops a heredoc commit as a commit" "$out" "delivery-skills:writing-commit-messages"
lacks "skill gate does not read the heredoc body's pull request as an act" "$out" "writing-pr-descriptions"
out=$(gate Bash g20 '' "$WORK/t-none.jsonl" "$(printf "cat <<'EOF' > %s/note.md\nbody\nEOF" "$MEM")")
contains "skill gate stops a memory write whose heredoc marker comes first" "$out" "delivery-skills:maintaining-project-memory"
out=$(gate Bash g21 '' "$WORK/t-none.jsonl" "$(printf "cat <<'EOF' | git commit -F -\nNote the PR\n\nOpen it with gh pr create later.\nEOF")")
contains "skill gate stops a commit piped from a heredoc" "$out" "delivery-skills:writing-commit-messages"
lacks "skill gate does not read the piped heredoc's pull request as an act" "$out" "writing-pr-descriptions"
out=$(gate Bash g22 '' "$WORK/t-none.jsonl" "$(printf "cat <<'EOF' | gh pr create --title t --body-file -\nbody\nEOF")")
contains "skill gate stops a pull request piped from a heredoc" "$out" "delivery-skills:writing-pr-descriptions"
out=$(gate Bash g23 '' "$WORK/t-none.jsonl" "$(printf "cat <<'EOF' | tee %s/note.md\nit's the body\nEOF" "$MEM")")
contains "skill gate stops a tee into memory fed by a heredoc" "$out" "delivery-skills:maintaining-project-memory"

out=$(gate Bash g14 '' "$WORK/t-none.jsonl" 'git -C "/tmp/some repo" commit -m x && gh pr create --fill')
contains "skill gate names every unloaded act of a command in one stop" "$out" "writing-pr-descriptions"
contains "skill gate's combined stop names the commit's skill too" "$out" "writing-commit-messages"
out=$(gate Bash g14 '' "$WORK/t-none.jsonl" 'git -C "/tmp/some repo" commit -m x && gh pr create --fill')
empty "skill gate stands aside on the combined command's retry" "$out"

mkdir -p "$WORK/parent/subagents"
skill_call writing-commit-messages > "$WORK/parent.jsonl"
printf '{"type":"user","message":{"content":"commit the fix"}}\n' > "$WORK/parent/subagents/agent-a1.jsonl"
skill_call writing-commit-messages > "$WORK/parent/subagents/agent-a2.jsonl"
out=$(gate Bash g15 '' "$WORK/parent.jsonl" 'git commit -m x')
empty "skill gate passes the parent whose own transcript has the load" "$out"
out=$(gate Bash g15 a1 "$WORK/parent.jsonl" 'git commit -m x')
contains "skill gate stops a subagent whose parent loaded the skill and it did not" "$out" "$DENY"
out=$(gate Bash g15 a2 "$WORK/parent.jsonl" 'git commit -m x')
empty "skill gate passes a subagent that loaded the skill itself" "$out"
out=$(gate Bash g1 a3 "$WORK/t-none.jsonl" 'git commit -m x')
contains "skill gate's stop of the parent does not let a subagent's act through" "$out" "$DENY"

out=$(gate Bash g16 a9 "$WORK/no-such-parent.jsonl" 'git commit -m x')
contains "skill gate stops once where the transcript is absent" "$out" "$DENY"
out=$(gate Bash g16 a9 "$WORK/no-such-parent.jsonl" 'git commit -m x')
empty "skill gate never blocks where the transcript is absent" "$out"
out=$(printf '{"tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' | TMPDIR="$GSTATE" "$PY" "$GATE_HOOK")
empty "skill gate passes an input with no session to key its stop on" "$out"
out=$(printf '{"session_id":"g17","tool_name":"Bash","tool_input":"git commit -m x"}' | TMPDIR="$GSTATE" "$PY" "$GATE_HOOK")
empty "skill gate passes a tool input that is not an object" "$out"
mkdir -p "$WORK/blocked-state"
printf 'x' > "$WORK/blocked-state/delivery-skills-gate"
out=$(printf '{"session_id":"g18","transcript_path":"%s","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' "$WORK/t-none.jsonl" | TMPDIR="$WORK/blocked-state" "$PY" "$GATE_HOOK")
check "skill gate exits 0 where its stop cannot be recorded" 0 $?
empty "skill gate does not stop an act whose stop it cannot record" "$out"

echo
# 22. Registration: a checkout at a commit older than a hook lacks its script,
#     and exit 2 from a PreToolUse, Stop or UserPromptSubmit hook is a block, so
#     each registered command exits 0 where its script is absent and still runs
#     the script where it is present.
OLD="$WORK/old-checkout"
mkdir -p "$OLD/hooks" "$WORK/shim"
if [ "$(basename "$PY")" != python3 ]; then
  { echo '#!/bin/sh'; echo "exec \"$PY\" \"\$@\""; } > "$WORK/shim/python3"
  chmod +x "$WORK/shim/python3"
fi
"$PY" -c 'import json, sys
for event in json.load(open(sys.argv[1]))["hooks"].values():
    for matcher in event:
        for hook in matcher["hooks"]:
            print(hook["command"])' "$ROOT/hooks/hooks.json" > "$WORK/commands"
while IFS= read -r cmd; do
  name=${cmd##*/hooks/}
  printf '' | env PATH="$WORK/shim:$PATH" CLAUDE_PLUGIN_ROOT="$OLD" sh -c "$cmd" >/dev/null 2>&1
  check "registration exits 0 without ${name%%.py*}.py" 0 $?
done < "$WORK/commands"
out=$(printf '{"session_id":"g19","transcript_path":"%s","tool_name":"Bash","tool_input":{"command":"git commit -m x"}}' "$WORK/t-none.jsonl" \
  | env PATH="$WORK/shim:$PATH" TMPDIR="$GSTATE" CLAUDE_PLUGIN_ROOT="$ROOT" sh -c "$(grep skill-gate.py "$WORK/commands")")
contains "registration runs the gate where its script is present" "$out" "$DENY"
for tool in Bash Write Edit Agent Task; do
  "$PY" -c 'import json, re, sys
for matcher in json.load(open(sys.argv[1]))["hooks"]["PreToolUse"]:
    if any("skill-gate.py" in hook["command"] for hook in matcher["hooks"]):
        sys.exit(0 if re.fullmatch(matcher["matcher"], sys.argv[2]) else 1)
sys.exit(1)' "$ROOT/hooks/hooks.json" "$tool"
  check "registration routes $tool to the gate" 0 $?
done

echo
# 23. Landing sweep: at a prompt it copies the rule files; at the stop it hands
#     the lines elsewhere that still carry what the turn's change to one of
#     them replaced. Each repository below holds an owner list, a checklist
#     copy in the same file, CLAUDE.md's and README.md's copies, and probes
#     for each threshold and exclusion.
SWEEP_HOOK="$ROOT/hooks/landing-sweep.py"
SW="$WORK/sweep-state"
mkdir -p "$SW"
cat > "$WORK/sweep_edit.py" <<'EOF'
import json, os, sys
# argv: file, old, new ("\n" for a line break), then optionally a transcript
# and a prompt id: the replacement is recorded there as the Edit call that made it.
path, old, new = sys.argv[1], sys.argv[2].replace("\\n", "\n"), sys.argv[3].replace("\\n", "\n")
text = open(path).read()
assert old in text, (path, old)
open(path, "w").write(text.replace(old, new, 1))
if len(sys.argv) > 5:
    n = sum(1 for _ in open(sys.argv[4])) if os.path.exists(sys.argv[4]) else 0
    with open(sys.argv[4], "a") as fh:
        fh.write(json.dumps({"type": "assistant", "message": {"content": [{"type": "tool_use", "id": "u%d" % n,
                 "name": "Edit", "input": {"file_path": path, "old_string": old, "new_string": new}}]}}) + "\n")
        fh.write(json.dumps({"type": "user", "promptId": sys.argv[5], "message": {"content": [{"type": "tool_result",
                 "tool_use_id": "u%d" % n, "content": "ok"}]}, "toolUseResult": {"filePath": path}}) + "\n")
EOF
sweep_repo() { # $1 = directory, $2 = "nogit" for a tree with no repository
  mkdir -p "$1/skills/handoff" "$1/docs"
  cat > "$1/skills/handoff/SKILL.md" <<'EOF'
# Handoff

The next person has the note and nothing else: not your terminal, not your
memory of why the work went the way it did.

## What a hand-over note carries

1. **What was done** - each change, and where it landed.
2. **What is still open** - every unfinished item, with who owns it now.
3. **How to check the current state** - the command that shows it.

Put the note where the work lives: the ticket, or the pull request if
there is no ticket.

Lead with the current state.

## Before you send

- [ ] The note says how to check the current state.
EOF
  cat > "$1/CLAUDE.md" <<'EOF'
# Working here

- Hand-over notes carry what was done and where it landed, what is still open
  and who owns it, and how to check the current state.
- Dates in notes are absolute, never "yesterday".
EOF
  cat > "$1/README.md" <<'EOF'
# playbook

- **handoff** - writes the note you leave when work changes hands: what was
  done, what is still open, and how to check the current state.
- **standup** - writes the daily update.

Notes go where the work lives: the ticket, or the pull request.
EOF
  printf '## How to check the current state\n\nSay what was done and what is still open.\n' > "$1/docs/guide.md"
  printf 'Say what was done first.\n' > "$1/docs/one.md"
  printf 'Always lead with the current state.\n' > "$1/docs/style.md"
  printf 'New starters learn this first: the next person has the note and nothing else.\n' > "$1/docs/onboarding.md"
  [ "${2:-}" = nogit ] && return
  (cd "$1" && git init -q -b main . && git config user.name Test && git config user.email test@example.com \
    && git add -A && git commit -qm init)
}
add_item() { # $1 = repository, then optionally a transcript and a prompt id
  "$PY" "$WORK/sweep_edit.py" "$1/skills/handoff/SKILL.md" \
    '3. **How to check the current state** - the command that shows it.\n' \
    '3. **How to check the current state** - the command that shows it.\n4. **How to roll it back** - the step that undoes each change.\n' \
    ${2:+"$2"} ${3:+"$3"}
}
sweep_submit() { # $1 = cwd, $2 = session, $3 = prompt
  printf '{"hook_event_name":"UserPromptSubmit","session_id":"%s","prompt_id":"%s","cwd":"%s"}' "$2" "$3" "$1" \
    | TMPDIR="$SW" "$PY" "$SWEEP_HOOK"
}
sweep_stop() { # $1 = cwd, $2 = session, $3 = prompt, $4 = stop_hook_active, $5 = transcript
  printf '{"hook_event_name":"Stop","session_id":"%s","prompt_id":"%s","cwd":"%s","stop_hook_active":%s,"transcript_path":"%s"}' \
    "$2" "$3" "$1" "${4:-false}" "${5:-}" | TMPDIR="$SW" "$PY" "$SWEEP_HOOK"
}
context() { # the hand-off's text
  printf '%s' "$1" | "$PY" -c 'import json, sys
data = sys.stdin.read()
if data:
    print(json.loads(data)["hookSpecificOutput"]["additionalContext"])'
}
handed() { # the hand-off's listed lines, one "path:lines" a line
  printf '%s' "$1" | "$PY" -c 'import json, re, sys
data = sys.stdin.read()
if data:
    text = json.loads(data)["hookSpecificOutput"]["additionalContext"]
    print("\n".join(re.findall(r"^- \x60([^\x60]+)\x60", text, re.M)))'
}

printf '' | TMPDIR="$SW" "$PY" "$SWEEP_HOOK"
check "sweep fails open on empty stdin" 0 $?
out=$(printf '[1]' | TMPDIR="$SW" "$PY" "$SWEEP_HOOK")
check "sweep fails open on a payload that is not an object" 0 $?
empty "sweep says nothing on a payload that is not an object" "$out"

# The item a turn adds to a list: the list's headlines are what every copy
# carries, the list itself is the turn's own, and a heading is never handed.
R="$WORK/sw-item"; sweep_repo "$R"
out=$(sweep_submit "$R" s1 p1)
empty "sweep's snapshot half prints nothing" "$out"
add_item "$R"
out=$(sweep_stop "$R" s1 p1)
kind=$(printf '%s' "$out" | "$PY" -c 'import json,sys; print(json.load(sys.stdin)["hookSpecificOutput"]["hookEventName"])' 2>/dev/null)
check "sweep hands its lines as the Stop hook's additional context" 0 $?
contains "sweep's context is a Stop hook's" "$kind" "Stop"
got=$(handed "$out")
contains "sweep hands the short form the change left behind" "$got" "CLAUDE.md:3-4"
contains "sweep hands the README's copy" "$got" "README.md:3-4"
contains "sweep hands a copy further down the owner itself" "$got" "skills/handoff/SKILL.md:20"
lacks "sweep leaves out the list the change joined" "$got" "skills/handoff/SKILL.md:8"
contains "sweep hands a file carrying two phrases" "$got" "docs/guide.md:3"
lacks "sweep never hands a heading line" "$got" "docs/guide.md:1"
lacks "sweep needs two phrases in a file the turn did not write" "$got" "docs/one.md"
contains "sweep names the file the turn changed" "$out" "this turn changed \`skills/handoff/SKILL.md\`"
contains "sweep says where its phrases came from" "$out" "the items of the list your change joined"
contains "sweep asks for a short form carried, never cut" "$out" "never cut to a pointer"
contains "sweep says to leave a record of the old wording" "$out" "leave it and say so in your reply"
first=$(printf '%s\n' "$got" | head -1)
case "$first" in
  CLAUDE.md:*|README.md:*) echo "PASS: sweep ranks the lines carrying the most phrases first" ;;
  *) echo "FAIL: sweep ranks the lines carrying the most phrases first (first is '$first')"; fails=$((fails+1)) ;;
esac

# At most once a prompt: the continued turn's stop is silent, and so is any
# later stop of the same prompt.
out=$(sweep_stop "$R" s1 p1 true)
empty "sweep stays silent at the stop its own hand-off continued" "$out"
out=$(sweep_stop "$R" s1 p1)
empty "sweep hands at most once a prompt" "$out"

# A line handed and seen is not handed again: the next prompt adds a fifth
# item to the same list, and every copy still reads as it did.
sweep_submit "$R" s1 p2 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/SKILL.md" '4. **How to roll it back** - the step that undoes each change.\n' \
  '4. **How to roll it back** - the step that undoes each change.\n5. **Who to ask** - the person who knows the most.\n'
out=$(sweep_stop "$R" s1 p2)
empty "sweep never hands a line twice in a session" "$out"

# A hand-off another hook discarded (no later stop showed stop_hook_active)
# was never seen, so its lines are handed again.
R="$WORK/sw-unseen"; sweep_repo "$R"
sweep_submit "$R" s2 p1 >/dev/null
add_item "$R"
sweep_stop "$R" s2 p1 >/dev/null
out=$(sweep_stop "$R" s2 p1)
empty "sweep stays silent at a second stop of its prompt" "$out"
sweep_submit "$R" s2 p2 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/SKILL.md" '4. **How to roll it back** - the step that undoes each change.\n' \
  '4. **How to roll it back** - the step that undoes each change.\n5. **Who to ask** - the person who knows the most.\n'
got=$(handed "$(sweep_stop "$R" s2 p2)")
contains "sweep hands again the lines of a hand-off no stop saw" "$got" "CLAUDE.md:3-4"

# A copy the turn already brought into line is not handed back, whichever
# way it was written; the item put into a wrong bullet still is.
R="$WORK/sw-fixed"; sweep_repo "$R"
mkdir -p "$R/guides"
sed -n '3,4p' "$R/CLAUDE.md" | sed 's/^[- ] //' > "$R/guides/README.md"
sweep_submit "$R" s3 p1 >/dev/null
add_item "$R"
"$PY" "$WORK/sweep_edit.py" "$R/CLAUDE.md" 'and how to check the current state.' 'how to check the current state, and how to roll it back.'
"$PY" "$WORK/sweep_edit.py" "$R/guides/README.md" 'and how to check the current state.' 'how to check the current state, and how to roll it back.'
got=$(handed "$(sweep_stop "$R" s3 p1)")
lacks "sweep does not hand back a copy the turn fixed" "$got" "CLAUDE.md"
lacks "sweep does not hand back a wrapped paragraph fixed on one line" "$got" "guides/README.md"
contains "sweep still hands the copy the turn left" "$got" "README.md:3-4"
R="$WORK/sw-wrong"; sweep_repo "$R"
sweep_submit "$R" s4 p1 >/dev/null
add_item "$R"
"$PY" "$WORK/sweep_edit.py" "$R/CLAUDE.md" 'never "yesterday".' 'never "yesterday"; say how to roll each change back.'
got=$(handed "$(sweep_stop "$R" s4 p1)")
contains "sweep hands a copy whose file the turn wrote in another bullet" "$got" "CLAUDE.md:3-4"

# The words a change replaced, and a file carrying the only phrase there is.
R="$WORK/sw-replaced"; sweep_repo "$R"
sweep_submit "$R" s5 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/SKILL.md" \
  'Put the note where the work lives: the ticket, or the pull request if\nthere is no ticket.' 'Put the note in the team channel.'
out=$(sweep_stop "$R" s5 p1)
contains "sweep hands a copy of the words the change replaced" "$(handed "$out")" "README.md:7"
contains "sweep keeps only the runs carrying three content words" "$(context "$out")" \
  "\`README.md:7\` - \"the work lives: the ticket,\", \"work lives: the ticket, or\", \"ticket, or the pull request\"
"
contains "sweep says it read the replaced words" "$out" "the words it replaced"
R="$WORK/sw-single"; sweep_repo "$R"
sweep_submit "$R" s6 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/SKILL.md" 'Lead with the current state.' 'Start from the open items.'
contains "sweep hands one phrase where only one exists" "$(handed "$(sweep_stop "$R" s6 p1)")" "docs/style.md:1"

# A prose addition: the paragraphs beside it are what a copy repeats, and the
# owner's own paragraph those phrases were read from is not handed.
R="$WORK/sw-beside"; sweep_repo "$R"
sweep_submit "$R" s7 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/SKILL.md" 'went the way it did.\n' 'went the way it did.\n\nWrite it the day you hand over.\n'
out=$(sweep_stop "$R" s7 p1)
got=$(handed "$out")
contains "sweep hands a copy of the paragraph beside an addition" "$got" "docs/onboarding.md:1"
lacks "sweep does not hand the paragraph its phrases came from" "$got" "skills/handoff/SKILL.md:3"
contains "sweep says it read the paragraphs beside the addition" "$out" "the paragraphs beside what it added"

# A list of fewer than two items is no list a copy enumerates: an item added
# to a list of one, or a list started between paragraphs, is a prose addition,
# read by the paragraphs beside it.
R="$WORK/sw-oneitem"; sweep_repo "$R"
mkdir -p "$R/skills/handoff/references"
printf '# Leaving\n\n## Before you go\n\n- Record the open branches and who owns them\n' > "$R/skills/handoff/references/leaving.md"
printf 'Before leaving, record the open branches and who owns them, then log off.\n' > "$R/docs/leaving.md"
printf '# Release\n\nThe release notes are drafted by the author of the change before merge.\n\nThe tag is cut on Thursday.\n' > "$R/skills/handoff/references/release.md"
printf 'Remember that the release notes are drafted by the author of the change before merge.\n' > "$R/docs/release.md"
(cd "$R" && git add -A && git commit -qm short)
sweep_submit "$R" s68 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/references/leaving.md" 'who owns them\n' 'who owns them\n- Hand over the deploy keys\n'
contains "sweep reads the item a list of one held beside the item added to it" "$(handed "$(sweep_stop "$R" s68 p1)")" "docs/leaving.md:1"
(cd "$R" && git commit -qam leaving)
sweep_submit "$R" s69 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/references/release.md" 'before merge.\n\n' 'before merge.\n\n- Link the ticket\n- Name the reviewer\n\n'
contains "sweep reads the paragraphs beside a list it started" "$(handed "$(sweep_stop "$R" s69 p1)")" "docs/release.md:1"

# In the owning file, the paragraphs a beside phrase was read from are left
# out for that phrase alone: a restatement below a list the turn appended to
# still carries the words the turn replaced above it.
R="$WORK/sw-ownbeside"; sweep_repo "$R"
mkdir -p "$R/skills/handoff/references"
printf '# Checks\n\nAlways run the full browser suite before calling a storefront change finished today.\n\n- Keep the dev server up\n- Use a free port\n\nIn short: always run the full browser suite before calling a storefront change finished.\n' > "$R/skills/handoff/references/checks.md"
(cd "$R" && git add -A && git commit -qm checks)
sweep_submit "$R" s71 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/references/checks.md" 'Always run the full browser suite' 'Run the smoke suite'
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/references/checks.md" '- Use a free port\n' '- Use a free port\n- Log the port\n'
contains "sweep hands a restatement in the owner beside a list the turn appended to" \
  "$(handed "$(sweep_stop "$R" s71 p1)")" "skills/handoff/references/checks.md:9"
printf '# Notes\n\nThe release notes are drafted by the author of the change before merge.\n\nThe tag is cut on Thursday.\n\n- Keep the dev server up\n- Use a free port\n\nRemember: the release notes are drafted by the author of the change before merge.\n' > "$R/skills/handoff/references/notes.md"
(cd "$R" && git add -A && git commit -qm notes)
sweep_submit "$R" s72 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/references/notes.md" 'before merge.\n\nThe tag' 'before merge.\n\nAnnounce it in the channel.\n\nThe tag'
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/references/notes.md" '- Use a free port\n' '- Use a free port\n- Log the port\n'
contains "sweep reads the owner's beside lines from its prose additions alone" \
  "$(handed "$(sweep_stop "$R" s72 p1)")" "skills/handoff/references/notes.md:13"

# A deletion writes no line: the paragraph or list after it is not the
# turn's, in the owning file or in another file the turn wrote.
R="$WORK/sw-deleted"; sweep_repo "$R"
mkdir -p "$R/skills/handoff/references"
printf '# Gates\n\nRun the eight local gates at the head before handing over any push.\n\n## Checklist\n\nAn obsolete intro line.\n\n- Run the eight local gates at the head before handing over any push\n- Name the next reviewer for every pull request\n' > "$R/skills/handoff/references/gates.md"
printf 'An obsolete note the turn deletes.\n\nAlways lead with the current state.\n' > "$R/docs/style.md"
(cd "$R" && git add -A && git commit -qm gates)
sweep_submit "$R" s74 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/references/gates.md" 'Run the eight local gates at the head before handing over any push.\n' \
  'Run the nine local gates at the head before handing over any push.\n'
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/references/gates.md" 'An obsolete intro line.\n\n' ''
contains "sweep hands a list after a deletion in the owner" "$(handed "$(sweep_stop "$R" s74 p1)")" "skills/handoff/references/gates.md:7"
(cd "$R" && git commit -qam gates)
sweep_submit "$R" s75 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/SKILL.md" 'Lead with the current state.' 'Start from the open items.'
"$PY" - "$WORK/t-deleted.jsonl" "$R/docs/style.md" <<'EOF'
import json, sys
path = sys.argv[2]
text = open(path).read()
old = "An obsolete note the turn deletes.\n\n"
open(path, "w").write(text.replace(old, ""))
with open(sys.argv[1], "w") as fh:
    fh.write(json.dumps({"type": "assistant", "message": {"content": [{"type": "tool_use", "id": "x1", "name": "Edit",
             "input": {"file_path": path, "old_string": old, "new_string": ""}}]}}) + "\n")
    fh.write(json.dumps({"type": "user", "promptId": "p1", "message": {"content": [{"type": "tool_result",
             "tool_use_id": "x1", "content": "ok"}]}, "toolUseResult": {"originalFile": text}}) + "\n")
EOF
contains "sweep hands a paragraph after a deletion in a file the turn wrote" \
  "$(handed "$(sweep_stop "$R" s75 p1 false "$WORK/t-deleted.jsonl")")" "docs/style.md:1"

# A headline needs two content words; the whole list a change rewrote while
# joining it is the turn's own.
R="$WORK/sw-thin"; sweep_repo "$R"
mkdir -p "$R/skills/handoff/references"
printf '## Links\n\n- **Tickets** - the tracker.\n- **Dashboards** - the graphs.\n' > "$R/skills/handoff/references/links.md"
printf 'Tickets and dashboards are linked from the note.\n' > "$R/docs/links.md"
sweep_submit "$R" s25 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/references/links.md" '- **Dashboards** - the graphs.\n' '- **Dashboards** - the graphs.\n- **Runbooks** - the recoveries.\n'
out=$(sweep_stop "$R" s25 p1)
empty "sweep drops a headline of one content word" "$out"
R="$WORK/sw-rewrite"; sweep_repo "$R"
sweep_submit "$R" s26 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/SKILL.md" '3. **How to check the current state** - the command that shows it.\n' \
  '3. **How to check the current state** - the command, and what healthy looks like.\n4. **How to roll it back** - the step that undoes each change.\n'
got=$(handed "$(sweep_stop "$R" s26 p1)")
contains "sweep hands the copies of a list a change rewrote while joining it" "$got" "CLAUDE.md:3-4"
lacks "sweep leaves out the whole list a change rewrote while joining it" "$got" "skills/handoff/SKILL.md:8"

# A heading is a Markdown one: a line opening with # inside a code block, or
# in a file that is not Markdown, is a comment, and is handed.
R="$WORK/sw-comment"; sweep_repo "$R"
mkdir -p "$R/scripts"
printf '\140\140\140sh\n# say what was done and what is still open\n\140\140\140\n\n## What was done, and what is still open\n' > "$R/docs/code.md"
printf '#!/bin/sh\n# say what was done and what is still open\necho ok\n' > "$R/scripts/notes.sh"
(cd "$R" && git add -A && git commit -qm comments)
sweep_submit "$R" s70 p1 >/dev/null
add_item "$R"
got=$(handed "$(sweep_stop "$R" s70 p1)")
contains "sweep hands a comment line inside a code block" "$got" "docs/code.md:2"
contains "sweep hands a comment line in a file that is not Markdown" "$got" "scripts/notes.sh:2"
lacks "sweep never hands a heading line after a closed code block" "$got" "docs/code.md:5"

# The read paths: a change committed within the turn, a copy fixed by the
# shell, a new file, a tree with no git.
R="$WORK/sw-commit"; sweep_repo "$R"
sweep_submit "$R" s8 p1 >/dev/null
add_item "$R"
(cd "$R" && git commit -qam "add the rollback")
contains "sweep reads a change committed within the turn" "$(handed "$(sweep_stop "$R" s8 p1)")" "CLAUDE.md:3-4"
R="$WORK/sw-shell"; sweep_repo "$R"
sweep_submit "$R" s9 p1 >/dev/null
add_item "$R"
sed 's/and how to check the current state\./how to check the current state, and how to roll it back./' "$R/README.md" > "$WORK/readme.tmp"
cat "$WORK/readme.tmp" > "$R/README.md"
got=$(handed "$(sweep_stop "$R" s9 p1)")
lacks "sweep knows a rule file the shell wrote" "$got" "README.md"
R="$WORK/sw-new"; sweep_repo "$R"
sweep_submit "$R" s10 p1 >/dev/null
mkdir -p "$R/skills/new" "$R/notes"
printf '# New\n\n1. **What was done** - each change.\n2. **What is still open** - each item.\n' > "$R/skills/new/SKILL.md"
out=$(sweep_stop "$R" s10 p1)
empty "sweep stays silent on a new rule file, which lost nothing" "$out"
sweep_submit "$R" s10 p2 >/dev/null
add_item "$R"
cp "$R/CLAUDE.md" "$R/notes/README.md"
got=$(handed "$(sweep_stop "$R" s10 p2)")
lacks "sweep does not hand a new rule file the turn wrote" "$got" "notes/README.md"
R="$WORK/sw-nogit"; sweep_repo "$R" nogit
mkdir -p "$R/.cache" "$R/node_modules"
cp "$R/CLAUDE.md" "$R/.cache/copy.md"
cp "$R/CLAUDE.md" "$R/node_modules/copy.md"
sweep_submit "$R" s11 p1 >/dev/null
add_item "$R"
got=$(handed "$(sweep_stop "$R" s11 p1)")
contains "sweep reads a tree with no git through its snapshot" "$got" "CLAUDE.md:3-4"
lacks "sweep's walk skips dot directories" "$got" ".cache"
lacks "sweep's walk skips dependency trees" "$got" "node_modules"

# No snapshot: the before-state comes from undoing the turn's own Edit calls,
# and only the calls whose results carry this prompt's id.
R="$WORK/sw-undo"; sweep_repo "$R"
add_item "$R" "$WORK/t-undo.jsonl" p1
got=$(handed "$(sweep_stop "$R" s12 p1 false "$WORK/t-undo.jsonl")")
contains "sweep undoes the turn's Edit calls where no snapshot exists" "$got" "CLAUDE.md:3-4"
R="$WORK/sw-undo2"; sweep_repo "$R"
add_item "$R" "$WORK/t-undo2.jsonl" p10
out=$(sweep_stop "$R" s13 p1 false "$WORK/t-undo2.jsonl")
empty "sweep leaves an earlier prompt's calls alone" "$out"
R="$WORK/sw-rel"; sweep_repo "$R"
"$PY" - "$WORK/t-rel.jsonl" "$R" <<'EOF'
import json, sys
path = sys.argv[2] + "/skills/handoff/SKILL.md"
text = open(path).read()
old = "3. **How to check the current state** - the command that shows it.\n"
new = old + "4. **How to roll it back** - the step that undoes each change.\n"
open(path, "w").write(text.replace(old, new))
with open(sys.argv[1], "w") as fh:
    fh.write("not json\n")
    fh.write(json.dumps({"type": "assistant", "message": {"content": [{"type": "tool_use", "id": "r1", "name": "Edit",
             "input": {"file_path": "skills/handoff/SKILL.md", "old_string": old, "new_string": new}}]}}) + "\n")
    fh.write(json.dumps({"type": "user", "promptId": "p1", "message": {"content": [{"type": "tool_result",
             "tool_use_id": "r1", "content": "ok"}]}, "toolUseResult": {"originalFile": text}}) + "\n")
EOF
got=$(handed "$(sweep_stop "$R" s14 p1 false "$WORK/t-rel.jsonl")")
contains "sweep resolves a relative path against the session's directory, past a bad line" "$got" "CLAUDE.md:3-4"

R="$WORK/sw-create"; sweep_repo "$R"
add_item "$R" "$WORK/t-create.jsonl" p1
"$PY" - "$WORK/t-create.jsonl" "$R" <<'EOF'
import json, os, sys
path = sys.argv[2] + "/notes/copy.md"
os.makedirs(os.path.dirname(path))
body = open(sys.argv[2] + "/CLAUDE.md").read()
open(path, "w").write(body)
with open(sys.argv[1], "a") as fh:
    fh.write(json.dumps({"type": "assistant", "message": {"content": [{"type": "tool_use", "id": "w1", "name": "Write",
             "input": {"file_path": path, "content": body}}]}}) + "\n")
    fh.write(json.dumps({"type": "user", "promptId": "p1", "message": {"content": [{"type": "tool_result",
             "tool_use_id": "w1", "content": "ok"}]}, "toolUseResult": {"type": "create", "filePath": path}}) + "\n")
EOF
got=$(handed "$(sweep_stop "$R" s24 p1 false "$WORK/t-create.jsonl")")
contains "sweep reads the turn's Edit next to a Write that created a file" "$got" "CLAUDE.md:3-4"
lacks "sweep reads a file a Write created as the turn's own" "$got" "notes/copy.md"

R="$WORK/sw-delete"; sweep_repo "$R"
"$PY" - "$WORK/t-delete.jsonl" "$R" <<'EOF'
import json, sys
path = sys.argv[2] + "/skills/handoff/SKILL.md"
text = open(path).read()
old = "3. **How to check the current state** - the command that shows it.\n"
open(path, "w").write(text.replace(old, ""))
with open(sys.argv[1], "w") as fh:
    fh.write(json.dumps({"type": "assistant", "message": {"content": [{"type": "tool_use", "id": "d1", "name": "Edit",
             "input": {"file_path": path, "old_string": old, "new_string": ""}}]}}) + "\n")
    fh.write(json.dumps({"type": "user", "promptId": "p1", "message": {"content": [{"type": "tool_result",
             "tool_use_id": "d1", "content": "ok"}]}, "toolUseResult": {"originalFile": text}}) + "\n")
EOF
got=$(handed "$(sweep_stop "$R" s27 p1 false "$WORK/t-delete.jsonl")")
contains "sweep undoes a deletion from the file the result says it had" "$got" "CLAUDE.md:4-5"
R="$WORK/sw-ignored"; sweep_repo "$R"
mkdir -p "$R/notes"
printf 'notes/\n' > "$R/.gitignore"
(cd "$R" && git add .gitignore && git commit -qm ignore)
cp "$R/skills/handoff/SKILL.md" "$R/notes/SKILL.md"
"$PY" "$WORK/sweep_edit.py" "$R/notes/SKILL.md" '3. **How to check the current state** - the command that shows it.\n' \
  '3. **How to check the current state** - the command that shows it.\n4. **How to roll it back** - the step that undoes each change.\n' \
  "$WORK/t-ignored2.jsonl" p1
out=$(sweep_stop "$R" s28 p1 false "$WORK/t-ignored2.jsonl")
empty "sweep leaves alone a rule file git ignores" "$out"
R="$WORK/sw-local"; sweep_repo "$R"
printf 'CLAUDE.local.md\n' > "$R/.gitignore"
(cd "$R" && git add .gitignore && git commit -qm ignore)
sed -n '/^## What a hand-over/,/^3\./p' "$R/skills/handoff/SKILL.md" > "$R/CLAUDE.local.md"
sweep_submit "$R" s65 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/CLAUDE.local.md" '3. **How to check the current state** - the command that shows it.\n' \
  '3. **How to check the current state** - the command that shows it.\n4. **How to roll it back** - the step that undoes each change.\n'
contains "sweep reads a CLAUDE.local.md git ignores, whichever tool wrote it" "$(handed "$(sweep_stop "$R" s65 p1)")" "CLAUDE.md:3-4"
R="$WORK/sw-pending"; sweep_repo "$R"
sweep_submit "$R" s29 p1 >/dev/null
add_item "$R"
mkdir -p "$SW/delivery-skills-landing-sweep-$(id -u)/s29/handed-p1.json"
out=$(sweep_stop "$R" s29 p1)
empty "sweep hands nothing it cannot record as handed" "$out"

# A file outside the working repository is searched in its own repository.
R="$WORK/sw-here"; sweep_repo "$R"
B="$WORK/sw-there"; sweep_repo "$B"
sweep_submit "$R" s15 p1 >/dev/null
add_item "$B" "$WORK/t-there.jsonl" p1
got=$(handed "$(sweep_stop "$R" s15 p1 false "$WORK/t-there.jsonl")")
contains "sweep searches a file outside the working repository in its own" "$got" "sw-there/CLAUDE.md:3-4"

# A pull within the turn rewrote the owner under it; the turn wrote nothing.
R="$WORK/sw-pull"; sweep_repo "$R"
U="$WORK/sw-upstream"
git clone -q "$R" "$U"
(cd "$U" && git config user.name Test && git config user.email test@example.com)
add_item "$U"
(cd "$U" && git commit -qam "add the rollback")
sweep_submit "$R" s16 p1 >/dev/null
(cd "$R" && git -c pull.ff=only pull -q "$U" main)
out=$(sweep_stop "$R" s16 p1)
empty "sweep leaves out what an in-turn pull rewrote" "$out"

# One snapshot a prompt, never overwritten: a prompt typed while the turn runs
# carries the running turn's id; the queued prompt's own turn falls back to
# the latest snapshot.
R="$WORK/sw-key"; sweep_repo "$R"
sweep_submit "$R" s17 p1 >/dev/null
add_item "$R"
sweep_submit "$R" s17 p1 >/dev/null
contains "sweep never overwrites a prompt's snapshot" "$(handed "$(sweep_stop "$R" s17 p1)")" "CLAUDE.md:3-4"
R="$WORK/sw-latest"; sweep_repo "$R"
sweep_submit "$R" s18 p1 >/dev/null
add_item "$R"
contains "sweep falls back to the session's latest snapshot" "$(handed "$(sweep_stop "$R" s18 p9)")" "CLAUDE.md:3-4"

# The prefilter reaches untracked files and never ignored ones, but every
# tracked file, one the ignore rules match included.
R="$WORK/sw-grep"; sweep_repo "$R"
printf 'ignored.md\ndocs/forced.md\n' > "$R/.gitignore"
cp "$R/CLAUDE.md" "$R/docs/forced.md"
(cd "$R" && git add .gitignore && git add -f docs/forced.md && git commit -qm ignore)
cp "$R/CLAUDE.md" "$R/docs/untracked.md"
cp "$R/CLAUDE.md" "$R/ignored.md"
sweep_submit "$R" s19 p1 >/dev/null
add_item "$R"
got=$(handed "$(sweep_stop "$R" s19 p1)")
contains "sweep searches untracked files" "$got" "docs/untracked.md"
lacks "sweep never searches ignored files" "$got" "ignored.md"
contains "sweep searches a tracked file the ignore rules match" "$got" "docs/forced.md"

# A soft reset or a rebase after the turn committed its change keeps the
# change the turn's own.
R="$WORK/sw-squash"; sweep_repo "$R"
sweep_submit "$R" s30 p1 >/dev/null
add_item "$R"
(cd "$R" && git commit -qam land && git reset -q --soft HEAD~1 && git commit -qm land2)
contains "sweep keeps a change squashed by a soft reset within the turn" "$(handed "$(sweep_stop "$R" s30 p1)")" "CLAUDE.md:3-4"
R="$WORK/sw-rebase"; sweep_repo "$R"
U="$WORK/sw-rebase-up"
git clone -q "$R" "$U"
(cd "$U" && git config user.name Test && git config user.email test@example.com \
  && printf 'more\n' >> docs/one.md && git commit -qam upstream)
sweep_submit "$R" s31 p1 >/dev/null
add_item "$R"
(cd "$R" && git commit -qam land && git -c pull.rebase=true pull -q "$U" main)
contains "sweep keeps a change the turn committed before a rebase" "$(handed "$(sweep_stop "$R" s31 p1)")" "CLAUDE.md:3-4"

R="$WORK/sw-autostash"; sweep_repo "$R"
U="$WORK/sw-autostash-up"
git clone -q "$R" "$U"
(cd "$U" && git config user.name Test && git config user.email test@example.com \
  && sed 's/^The next person has the note/The next reader has the note/' skills/handoff/SKILL.md > s.tmp \
  && cat s.tmp > skills/handoff/SKILL.md && git commit -qm upstream skills/handoff/SKILL.md)
sweep_submit "$R" s41 p1 >/dev/null
add_item "$R" "$WORK/t-autostash.jsonl" p1
(cd "$R" && git -c merge.autoStash=true -c pull.ff=only pull -q "$U" main >/dev/null 2>&1)
contains "sweep keeps a file the turn edited though a pull rewrote it too" \
  "$(handed "$(sweep_stop "$R" s41 p1 false "$WORK/t-autostash.jsonl")")" "CLAUDE.md:3-4"

# A headline is the item's bold lead, at most six words, else its first
# clause; a list with blank lines between its items is still a list.
R="$WORK/sw-lead"; sweep_repo "$R"
mkdir -p "$R/skills/handoff/references"
printf '# Rules\n\n- Commit each entry **as soon as it is written** in its own commit.\n- Push the branch **before handing over a push** to anyone.\n- **Search before you write a new entry anywhere in the queue** - every file.\n' > "$R/skills/handoff/references/rules.md"
printf 'Commit each entry as soon as it lands, and push the branch before handing over.\n' > "$R/docs/rules.md"
printf 'Search before you write a new line, and commit each entry as soon as it lands.\n' > "$R/docs/cap.md"
printf 'Keep drafts as soon as it is written, and before handing over a push.\n' > "$R/docs/drafts.md"
sweep_submit "$R" s32 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/references/rules.md" 'every file.\n' 'every file.\n- **Name the owner** - who decides.\n'
got=$(handed "$(sweep_stop "$R" s32 p1)")
contains "sweep reads a headline as the item's first clause" "$got" "docs/rules.md:1"
contains "sweep caps a bold lead at six words" "$got" "docs/cap.md:1"
lacks "sweep never reads a bold span inside an item as its headline" "$got" "docs/drafts.md"
R="$WORK/sw-loose"; sweep_repo "$R"
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/SKILL.md" \
  '1. **What was done** - each change, and where it landed.\n2. **What is still open**' \
  '1. **What was done** - each change, and where it landed.\n\n2. **What is still open**'
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/SKILL.md" 'with who owns it now.\n3.' 'with who owns it now.\n\n3.'
(cd "$R" && git commit -qam loose)
sweep_submit "$R" s33 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/SKILL.md" 'the command that shows it.\n' 'the command that shows it.\n\n4. **How to roll it back** - the step that undoes each change.\n'
contains "sweep reads a list whose items blank lines separate" "$(handed "$(sweep_stop "$R" s33 p1)")" "CLAUDE.md:3-4"
sweep_submit "$R" s33 p2 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/SKILL.md" '1. **What was done**' '0. **Who to ask** - the person who knows.\n\n1. **What was done**'
contains "sweep reads the items below a new first item of a loose list" "$(handed "$(sweep_stop "$R" s33 p2)")" "CLAUDE.md:3-4"

# A skill's references/ is a rule file wherever the skill sits - a
# single-skill repository keeps both at its root - and a references/ with no
# SKILL.md beside it is any docs folder.
R="$WORK/sw-refs"; sweep_repo "$R"
mkdir -p "$R/references" "$R/tool/references"
printf '# Playbook\n\nThe notes are under references/.\n' > "$R/SKILL.md"
sed -n '/^## What a hand-over/,/^3\./p' "$R/skills/handoff/SKILL.md" > "$R/references/notes.md"
cp "$R/references/notes.md" "$R/tool/references/notes.md"
(cd "$R" && git add -A && git commit -qm refs)
sweep_submit "$R" s66 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/references/notes.md" '3. **How to check the current state** - the command that shows it.\n' \
  '3. **How to check the current state** - the command that shows it.\n4. **How to roll it back** - the step that undoes each change.\n'
contains "sweep arms on a references/ beside a SKILL.md" "$(handed "$(sweep_stop "$R" s66 p1)")" "CLAUDE.md:3-4"
(cd "$R" && git commit -qam notes)
sweep_submit "$R" s67 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/tool/references/notes.md" '3. **How to check the current state** - the command that shows it.\n' \
  '3. **How to check the current state** - the command that shows it.\n4. **How to roll it back** - the step that undoes each change.\n'
empty "sweep never arms on a references/ with no SKILL.md beside it" "$(sweep_stop "$R" s67 p1)"

# A word the normalizing drops a character from is not what the prefilter
# searches the raw files for.
R="$WORK/sw-ident"; sweep_repo "$R"
mkdir -p "$R/skills/handoff/references"
printf '# Hook\n\n## Inputs\n\n1. **Check session_id presence** - first.\n2. **Read transcript_path lines** - then.\n' > "$R/skills/handoff/references/inputs.md"
printf 'The hook will check session_id presence, then read transcript_path lines.\n' > "$R/docs/inputs.md"
sweep_submit "$R" s34 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/references/inputs.md" '- then.\n' '- then.\n3. **Write the marker** - last.\n'
contains "sweep's prefilter finds a copy whose words carry underscores" "$(handed "$(sweep_stop "$R" s34 p1)")" "docs/inputs.md:1"

# A block too large to diff word by word as a whole is diffed line by line
# where its line count held.
R="$WORK/sw-rows"; sweep_repo "$R"
"$PY" - "$R" <<'EOF'
import sys
rows = "".join("| `/v1/items/%d` | GET | returns the item list for the account %d | yes |\n" % (i, i) for i in range(3000))
open(sys.argv[1] + "/README.md", "a").write("\n| Endpoint | Method | What it does | Auth |\n|---|---|---|---|\n" + rows)
open(sys.argv[1] + "/docs/api.md", "w").write("It returns the item list for the account 7 on request.\n")
EOF
(cd "$R" && git commit -qam rows)
sweep_submit "$R" s35 p1 >/dev/null
"$PY" - "$R/README.md" <<'EOF'
import sys
p = sys.argv[1]
text = open(p).read()
open(p, "w").write(text.replace("returns the item list for", "lists the items of"))
EOF
got=$(handed "$(sweep_stop "$R" s35 p1)")
contains "sweep diffs a large block line by line" "$got" "docs/api.md:1"
lacks "sweep reads only the rows a large block changed" "$got" "CLAUDE.md"
R="$WORK/sw-rows-unlike"; sweep_repo "$R"
"$PY" - "$R" <<'EOF'
import sys
rows = "".join("| `/v1/items/%d` | GET | returns the item list for the account %d | yes |\n" % (i, i) for i in range(500))
open(sys.argv[1] + "/README.md", "a").write("\n| Endpoint | Method | What it does | Auth |\n|---|---|---|---|\n" + rows)
open(sys.argv[1] + "/docs/api.md", "w").write("It returns the item list for the account 207 | yes on request.\n")
open(sys.argv[1] + "/docs/five.md", "w").write("See `/v1/items/5` | GET | returns the item list for the account 5 here.\n")
EOF
(cd "$R" && git add -A && git commit -qm rows)
sweep_submit "$R" s60 p1 >/dev/null
"$PY" - "$R/README.md" <<'EOF'
import sys
p = sys.argv[1]
text = open(p).read().replace(" | yes |", " | no |")
text = text.replace("| `/v1/items/5` | GET | returns the item list for the account 5 | no |",
                    "| `/v2/ledger` | POST | posts a ledger entry for the whole organisation at once | admin only |")
open(p, "w").write(text)
EOF
got=$(handed "$(sweep_stop "$R" s60 p1)")
contains "sweep pairs a large table's like rows where one row is unlike" "$got" "docs/api.md:1"
lacks "sweep never pairs a large table's unlike row" "$got" "docs/five.md"

# Outside git: a rule file under a working directory with no repository is
# searched through that directory's text documents only, and one outside the
# working directory alone.
R="$WORK/sw-nogit-docs"; sweep_repo "$R" nogit
cp "$R/CLAUDE.md" "$R/docs/session.jsonl"
mkdir -p "$R/agents"
printf '# Reviewer\n\n## Checks\n\n1. **Read the whole diff** - first.\n2. **Name every finding** - then.\n' > "$R/agents/reviewer.md"
printf 'The reviewer will read the whole diff and name every finding.\n' > "$R/docs/reviewer.md"
sweep_submit "$R" s36 p1 >/dev/null
add_item "$R"
"$PY" "$WORK/sweep_edit.py" "$R/agents/reviewer.md" '- then.\n' '- then.\n3. **Rank them** - last.\n'
got=$(handed "$(sweep_stop "$R" s36 p1)")
lacks "sweep's walk outside git reads text documents only" "$got" "session.jsonl"
contains "sweep arms on an agent contract outside git" "$got" "docs/reviewer.md:1"
H="$WORK/sw-home"; mkdir -p "$H/.claude/projects"
printf '# Global\n\n## Rules\n\n1. **Never add attribution to commits** - ever.\n2. **Commit in its own call** - then push.\n' > "$H/.claude/CLAUDE.md"
printf '{"text": "Never add attribution to commits. Commit in its own call."}\n' > "$H/.claude/projects/t.jsonl"
printf 'Never add attribution to commits. Commit in its own call.\n' > "$H/.claude/projects/notes.md"
R="$WORK/sw-work"; sweep_repo "$R"
"$PY" "$WORK/sweep_edit.py" "$H/.claude/CLAUDE.md" '- then push.\n' '- then push.\n3. **Sign nothing** - never.\n' "$WORK/t-home.jsonl" p1
out=$(sweep_stop "$R" s37 p1 false "$WORK/t-home.jsonl")
empty "sweep searches a file in no repository outside the working directory alone" "$out"
A="$WORK/sw-contracts/agents"; mkdir -p "$A"
printf '# Reviewer\n\n## Checks\n\n1. **Read the whole diff** - first.\n2. **Name every finding** - then.\n\n## Before you reply\n\n- Read the whole diff and name every finding.\n' > "$A/reviewer.md"
"$PY" "$WORK/sweep_edit.py" "$A/reviewer.md" '- then.\n' '- then.\n3. **Rank them** - last.\n' "$WORK/t-contract.jsonl" p1
contains "sweep arms on an agent contract it searches alone" \
  "$(handed "$(sweep_stop "$R" s42 p1 false "$WORK/t-contract.jsonl")")" "sw-contracts/agents/reviewer.md:11"

# The hand-off: lines carrying what the change replaced rank above lines
# found only beside it; a change that is itself temporary is left alone.
R="$WORK/sw-rank"; sweep_repo "$R"
sweep_submit "$R" s38 p1 >/dev/null
add_item "$R"
text=$(context "$(sweep_stop "$R" s38 p1)")
contains "sweep says to leave every line of a trial wording" "$text" "If your change is itself temporary"
contains "sweep counts a test fixture among the records to leave" "$text" "a test fixture or its expected output"
lacks "sweep says nothing of neighbouring text where it read none" "$text" "beside your addition"
R="$WORK/sw-beside2"; sweep_repo "$R"
sweep_submit "$R" s39 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/SKILL.md" 'went the way it did.\n' 'went the way it did.\n\nWrite it the day you hand over.\n'
text=$(context "$(sweep_stop "$R" s39 p1)")
contains "sweep says a line found beside the addition may need nothing" "$text" "needs your change only where it covers the same ground"
contains "sweep's lead names the neighbouring paragraphs it read" "$text" "what the paragraphs beside your addition say"

# A file that is not a regular file is never read, and the state is private.
R="$WORK/sw-dev"; sweep_repo "$R" nogit
ln -s /dev/zero "$R/docs/README.md"
mkfifo "$R/skills/README.md"
out=$(sweep_submit "$R" s40 p1)
check "sweep's snapshot passes a rule file that is a device or a pipe" 0 $?
mode=$("$PY" -c 'import os, stat, sys; print(oct(stat.S_IMODE(os.stat(sys.argv[1]).st_mode)))' "$SW/delivery-skills-landing-sweep-$(id -u)/s40")
check "sweep keeps its state private" "0o700" "$mode"

# The list's headlines are what it said before the turn, whichever change of
# the turn rewrote an item.
R="$WORK/sw-count"; sweep_repo "$R"
mkdir -p "$R/skills/handoff/references"
printf '# Parts\n\n## What ships\n\n- **Eighteen skills** - each owns a rule.\n- **Three agent types** - each owns a pass.\n- **Four hooks** - each owns a moment.\n' > "$R/skills/handoff/references/parts.md"
printf 'Eighteen skills, three agent types and four hooks.\n' > "$R/docs/stale.md"
printf 'Nineteen skills, three agent types and four hooks.\n' > "$R/docs/current.md"
(cd "$R" && git add -A && git commit -qm parts)
sweep_submit "$R" s43 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/references/parts.md" '**Eighteen skills**' '**Nineteen skills**'
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/references/parts.md" 'owns a moment.\n' 'owns a moment.\n- **One sweep** - at the stop.\n'
text=$(context "$(sweep_stop "$R" s43 p1)")
contains "sweep searches a list's headlines as they stood before the turn" "$text" '"Eighteen skills"'
lacks "sweep never searches a headline's new wording" "$text" '"Nineteen skills"'

# A long bullet merged into its neighbour keeps its replaced runs; rows of
# unlike text are never paired because their count held.
R="$WORK/sw-long"; sweep_repo "$R"
"$PY" - "$R" <<'EOF'
import sys
r = sys.argv[1]
a = " ".join("alpha%03d" % i for i in range(320))
b = " ".join("beta%03d" % i for i in range(320))
with open(r + "/CLAUDE.md", "a") as fh:
    fh.write("- " + a + "\n- " + b + "\n")
open(r + "/docs/alpha.md", "w").write(" ".join("alpha%03d" % i for i in range(100, 112)) + "\n")
open(r + "/docs/beta.md", "w").write(" ".join("beta%03d" % i for i in range(200, 212)) + "\n")
EOF
(cd "$R" && git commit -qam long)
sweep_submit "$R" s44 p1 >/dev/null
"$PY" - "$R/CLAUDE.md" <<'EOF'
import sys
p = sys.argv[1]
text = open(p).read()
a = " ".join("alpha%03d" % i for i in range(320))
b = " ".join("beta%03d" % i for i in range(320))
new_b = b.replace("beta205 beta206", "gamma205 gamma206")
open(p, "w").write(text.replace("- " + a + "\n- " + b + "\n", "- " + new_b + "\n- " + " ".join("delta%03d" % i for i in range(320)) + "\n"))
EOF
got=$(handed "$(sweep_stop "$R" s44 p1)")
contains "sweep reads the runs a deleted long bullet lost" "$got" "docs/alpha.md:1"
contains "sweep reads the runs a long bullet's rewording lost" "$got" "docs/beta.md:1"

# A blank line joins two items of one list, never a numbered list to a
# bulleted one.
R="$WORK/sw-kinds"; sweep_repo "$R"
mkdir -p "$R/skills/handoff/references"
printf '# Kinds\n\n1. **First numbered step** - one.\n2. **Second numbered step** - two.\n\n- **Loose bullet one** - a.\n- **Loose bullet two** - b.\n' > "$R/skills/handoff/references/kinds.md"
printf 'First numbered step, then the second numbered step.\n' > "$R/docs/numbered.md"
(cd "$R" && git add -A && git commit -qm kinds)
sweep_submit "$R" s45 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/references/kinds.md" '- b.\n' '- b.\n- **Loose bullet three** - c.\n'
lacks "sweep never joins a bulleted list to the numbered one above it" "$(handed "$(sweep_stop "$R" s45 p1)")" "docs/numbered.md"
R="$WORK/sw-nested"; sweep_repo "$R"
mkdir -p "$R/skills/handoff/references"
printf '# Release\n\n1. **Prepare the release branch** - cut it.\n   - check the version file\n\n2. **Tag the build** - sign it.\n   - push the tag\n\n3. **Publish the notes** - post them.\n   - link the tag\n' > "$R/skills/handoff/references/steps.md"
printf '# Parts\n\n- **Prepare the release branch** - cut it.\n  1. check the version file\n\n- **Tag the build** - sign it.\n  1. push the tag\n\n- **Publish the notes** - post them.\n  1. link the tag\n' > "$R/skills/handoff/references/parts.md"
printf '1. **Prepare the release branch** - cut it.\n2. **Tag the build** - sign it.\n   - push the tag\n\n- **Loose bullet one** - a.\n- **Loose bullet two** - b.\n' > "$R/skills/handoff/references/after.md"
printf 'Prepare the release branch, then tag the build, then publish the notes.\n' > "$R/docs/steps.md"
(cd "$R" && git add -A && git commit -qm nested)
sweep_submit "$R" s56 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/references/steps.md" '   - link the tag\n' '   - link the tag\n\n4. **Announce it** - in the channel.\n'
contains "sweep joins a loose numbered list across its items' nested bullets" "$(handed "$(sweep_stop "$R" s56 p1)")" "docs/steps.md"
(cd "$R" && git commit -qam steps)
sweep_submit "$R" s57 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/references/parts.md" '  1. link the tag\n' '  1. link the tag\n\n- **Announce it** - in the channel.\n'
contains "sweep joins a loose bulleted list across its items' nested steps" "$(handed "$(sweep_stop "$R" s57 p1)")" "docs/steps.md"
(cd "$R" && git commit -qam parts)
sweep_submit "$R" s58 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/references/after.md" '- b.\n' '- b.\n- **Loose bullet three** - c.\n'
lacks "sweep never joins a bulleted list to a numbered one ending in nested bullets" "$(handed "$(sweep_stop "$R" s58 p1)")" "docs/steps.md"
(cd "$R" && git commit -qam after)
printf '# Spaced\n\n1. **Prepare the release branch** - cut it.\n\n   - check the version file\n\n2. **Tag the build** - sign it.\n\n   - push the tag\n\n3. **Publish the notes** - post them.\n\n   - link the tag\n' > "$R/skills/handoff/references/spaced.md"
(cd "$R" && git add -A && git commit -qm spaced)
sweep_submit "$R" s64 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/references/spaced.md" '   - link the tag\n' '   - link the tag\n\n4. **Announce it** - in the channel.\n'
contains "sweep joins an item to the nested bullets a blank line sets under it" "$(handed "$(sweep_stop "$R" s64 p1)")" "docs/steps.md"

# A move's own change is never handed as the turn's: a pull before the
# turn's edit, and a pull that is the turn's only act on a file already dirty.
R="$WORK/sw-pulled"; sweep_repo "$R"
U="$WORK/sw-pulled-up"
git clone -q "$R" "$U"
(cd "$U" && git config user.name Test && git config user.email test@example.com \
  && sed 's/^The next person has the note/The next reader has the note/' skills/handoff/SKILL.md > s.tmp \
  && cat s.tmp > skills/handoff/SKILL.md && git commit -qm upstream skills/handoff/SKILL.md)
sweep_submit "$R" s46 p1 >/dev/null
(cd "$R" && git -c pull.ff=only pull -q "$U" main)
add_item "$R" "$WORK/t-pulled.jsonl" p1
got=$(handed "$(sweep_stop "$R" s46 p1 false "$WORK/t-pulled.jsonl")")
contains "sweep hands the turn's own change after a pull" "$got" "CLAUDE.md:3-4"
lacks "sweep never hands a pulled change as the turn's" "$got" "docs/onboarding.md"
R="$WORK/sw-dirty"; sweep_repo "$R"
U="$WORK/sw-dirty-up"
git clone -q "$R" "$U"
(cd "$U" && git config user.name Test && git config user.email test@example.com \
  && sed 's/^The next person has the note/The next reader has the note/' skills/handoff/SKILL.md > s.tmp \
  && cat s.tmp > skills/handoff/SKILL.md && git commit -qm upstream skills/handoff/SKILL.md)
add_item "$R"
sweep_submit "$R" s47 p1 >/dev/null
(cd "$R" && git -c merge.autoStash=true -c pull.ff=only pull -q "$U" main >/dev/null 2>&1)
empty "sweep leaves a file dirty before the prompt that only a pull moved" "$(sweep_stop "$R" s47 p1)"

# The first move of a turn, not its last, is the one a commit before it
# counts from; a deleted item of the list is what it said before; the
# list's heading is read where it stood before lines above it moved.
R="$WORK/sw-twomoves"; sweep_repo "$R"
sweep_submit "$R" s51 p1 >/dev/null
add_item "$R"
(cd "$R" && git commit -qam land && git reset -q --soft HEAD~1 && git stash -q && git checkout -q -b other \
  && git stash pop -q && printf 'more\n' >> docs/one.md && git commit -qm other docs/one.md)
contains "sweep counts a commit from the turn's first move" "$(handed "$(sweep_stop "$R" s51 p1)")" "CLAUDE.md:3-4"
R="$WORK/sw-twopulls"; sweep_repo "$R"
U="$WORK/sw-twopulls-up"
git clone -q "$R" "$U"
(cd "$U" && git config user.name Test && git config user.email test@example.com \
  && sed 's/^The next person has the note/The next reader has the note/' skills/handoff/SKILL.md > s.tmp \
  && cat s.tmp > skills/handoff/SKILL.md && git commit -qm upstream skills/handoff/SKILL.md)
sweep_submit "$R" s55 p1 >/dev/null
(cd "$R" && git -c pull.ff=only pull -q "$U" main && git checkout -q -b other)
empty "sweep reads each move's own diff, not only the last move's" "$(sweep_stop "$R" s55 p1)"
R="$WORK/sw-dropped"; sweep_repo "$R"
sweep_submit "$R" s52 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/SKILL.md" '1. **What was done** - each change, and where it landed.\n' ''
add_item "$R"
contains "sweep reads an item the turn deleted as one the list held" "$(handed "$(sweep_stop "$R" s52 p1)")" "docs/guide.md:3"
R="$WORK/sw-heading"; sweep_repo "$R"
printf 'What a hand-over note carries: what was done first.\n' > "$R/docs/head.md"
(cd "$R" && git add -A && git commit -qm head)
sweep_submit "$R" s53 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/SKILL.md" 'went the way it did.\n' \
  'went the way it did.\n\nOne.\n\nTwo.\n\nThree.\n\nFour.\n\nFive.\n\nSix.\n\nSeven.\n\nEight.\n\nNine.\n\nTen.\n'
add_item "$R"
contains "sweep reads the list's heading where it stood before the turn" "$(handed "$(sweep_stop "$R" s53 p1)")" "docs/head.md:1"
R="$WORK/sw-renamed"; sweep_repo "$R"
printf 'What a hand-over note carries: what was done first.\n' > "$R/docs/head.md"
printf 'What every handover message includes: what was done first.\n' > "$R/docs/newhead.md"
(cd "$R" && git add -A && git commit -qm heads)
sweep_submit "$R" s62 p1 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/SKILL.md" '## What a hand-over note carries' '## What every handover message includes'
add_item "$R"
got=$(handed "$(sweep_stop "$R" s62 p1)")
contains "sweep searches a heading the turn renamed by its old wording" "$got" "docs/head.md:1"
lacks "sweep never searches a renamed heading by its new wording" "$got" "docs/newhead.md"
R="$WORK/sw-merge"; sweep_repo "$R"
(cd "$R" && git checkout -q -b feature \
  && sed 's/^The next person has the note/The next reader has the note/' skills/handoff/SKILL.md > s.tmp \
  && cat s.tmp > skills/handoff/SKILL.md && rm s.tmp && printf 'Say what was done last.\n' > docs/one.md \
  && git commit -qam feature && git checkout -q main && printf 'Say what was done second.\n' > docs/one.md \
  && git commit -qam main1)
"$PY" -c 'import time; time.sleep(1 - time.time() % 1)'
sweep_submit "$R" s61 p1 >/dev/null
(cd "$R" && { git merge -q feature >/dev/null 2>&1 || true; } && printf 'Say what was done.\n' > docs/one.md \
  && git add -A && git commit -qm merged)
empty "sweep never hands a merged branch's change as the turn's" "$(sweep_stop "$R" s61 p1)"

# A long document whose every paragraph changed is diffed within the budget.
R="$WORK/sw-paras"; sweep_repo "$R"
"$PY" - "$R" <<'EOF'
import sys
r = sys.argv[1]
paras = ["Paragraph %d keeps the ledger sync notes for team %d in order." % (i, i) for i in range(1000)]
open(r + "/README.md", "a").write("\n" + "\n\n".join(paras) + "\n")
open(r + "/docs/para.md", "w").write("It keeps the ledger sync notes for team 500 in order.\n")
EOF
(cd "$R" && git commit -qam paras)
sweep_submit "$R" s54 p1 >/dev/null
"$PY" - "$R/README.md" <<'EOF'
import sys
p = sys.argv[1]
text = open(p).read()
open(p, "w").write(text.replace("keeps the ledger sync notes", "holds the ledger notes"))
EOF
contains "sweep diffs a document whose every paragraph changed within its budget" "$(handed "$(sweep_stop "$R" s54 p1)")" "docs/para.md:1"
R="$WORK/sw-longlist"; sweep_repo "$R"
"$PY" - "$R" <<'EOF'
import sys
r = sys.argv[1]
items = ["%d. **Step %d** keeps the ledger sync notes for team %d in order.\n   - checked by team %d" % (i + 1, i, i, i)
         for i in range(2000)]
open(r + "/README.md", "a").write("\n" + "\n\n".join(items) + "\n")
open(r + "/docs/para.md", "w").write("It keeps the ledger sync notes for team 500 in order.\n")
EOF
(cd "$R" && git commit -qam steps)
sweep_submit "$R" s63 p1 >/dev/null
"$PY" - "$R/README.md" <<'EOF'
import sys
p = sys.argv[1]
lines = open(p).read().split("\n")
for n, line in enumerate(lines):
    if "**Step " in line and int(line.split("**Step ")[1].split("**")[0]) % 2 == 0:
        lines[n] = line.replace("keeps the ledger sync notes", "holds the ledger notes")
open(p, "w").write("\n".join(lines))
EOF
text=$(context "$(sweep_stop "$R" s63 p1)")
contains "sweep reads a long loose list whose items carry nested bullets within its budget" "$text" "docs/para.md:1"
lacks "sweep finishes a long loose list's search before its time limit" "$text" "stopped at its time limit"

# A state directory that is open to others or a link is never used.
R="$WORK/sw-open"; sweep_repo "$R"
mkdir -p "$WORK/open-tmp/delivery-skills-landing-sweep-$(id -u)" "$WORK/link-tmp" "$WORK/link-target"
chmod 777 "$WORK/open-tmp/delivery-skills-landing-sweep-$(id -u)"
chmod 700 "$WORK/link-target"
ln -s "$WORK/link-target" "$WORK/link-tmp/delivery-skills-landing-sweep-$(id -u)"
printf '{"hook_event_name":"UserPromptSubmit","session_id":"s48","prompt_id":"p1","cwd":"%s"}' "$R" | TMPDIR="$WORK/open-tmp" "$PY" "$SWEEP_HOOK"
empty "sweep writes nothing into a state directory others can open" "$(ls -A "$WORK/open-tmp/delivery-skills-landing-sweep-$(id -u)")"
printf '{"hook_event_name":"UserPromptSubmit","session_id":"s48","prompt_id":"p1","cwd":"%s"}' "$R" | TMPDIR="$WORK/link-tmp" "$PY" "$SWEEP_HOOK"
empty "sweep writes nothing through a state directory that is a link" "$(ls -A "$WORK/link-target")"

# A line found only beside an addition is marked, and keeps one of the eight
# places when other lines fill the rest.
R="$WORK/sw-slot"; sweep_repo "$R"
for n in 1 2 3 4 5 6 7 8 9; do cp "$R/CLAUDE.md" "$R/docs/copy$n.md"; done
sweep_submit "$R" s49 p1 >/dev/null
add_item "$R"
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/SKILL.md" 'went the way it did.\n' 'went the way it did.\n\nWrite it the day you hand over.\n'
text=$(context "$(sweep_stop "$R" s49 p1)")
contains "sweep marks a line found beside the addition" "$text" "\`docs/onboarding.md:1\` - beside: "
contains "sweep keeps the eighth place for a line found beside the addition" "$(printf '%s\n' "$text" | grep '^- `' | sed -n 8p)" "docs/onboarding.md:1"
sweep_stop "$R" s49 p1 true >/dev/null
(cd "$R" && git add -A && git commit -qm t1)
sweep_submit "$R" s49 p2 >/dev/null
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/SKILL.md" '4. **How to roll it back** - the step that undoes each change.\n' \
  '4. **How to roll it back** - the step that undoes each change.\n5. **Who to ask** - the owner of each open item.\n'
"$PY" "$WORK/sweep_edit.py" "$R/skills/handoff/SKILL.md" 'went the way it did.\n' 'went the way it did.\n\nSend it before you log off.\n'
got=$(handed "$(sweep_stop "$R" s49 p2)")
lacks "sweep records the beside line it listed in place of the eighth" "$got" "docs/onboarding.md"
contains "sweep hands later the line the beside line kept out of the list" "$got" "docs/copy6.md"

# The hand-off leaves with 0 even when its reader has gone.
R="$WORK/sw-pipe"; sweep_repo "$R"
sweep_submit "$R" s50 p1 >/dev/null
add_item "$R"
rc=$("$PY" - "$SWEEP_HOOK" "$R" "$SW" <<'EOF'
import json, os, subprocess, sys
r, w = os.pipe()
os.close(r)
payload = {"hook_event_name": "Stop", "session_id": "s50", "prompt_id": "p1", "cwd": sys.argv[2], "stop_hook_active": False}
p = subprocess.run([sys.executable, sys.argv[1]], input=json.dumps(payload).encode(), stdout=w,
                   stderr=subprocess.DEVNULL, env=dict(os.environ, TMPDIR=sys.argv[3]))
print(p.returncode)
EOF
)
check "sweep exits 0 when the reader of its hand-off has gone" 0 "$rc"

# Eight lines at most, the rest counted.
R="$WORK/sw-many"; sweep_repo "$R"
for n in 1 2 3 4 5 6 7 8 9; do cp "$R/CLAUDE.md" "$R/docs/copy$n.md"; done
sweep_submit "$R" s20 p1 >/dev/null
add_item "$R"
out=$(sweep_stop "$R" s20 p1)
n=$(handed "$out" | grep -c .)
check "sweep lists eight lines at most" 8 "$n"
contains "sweep counts the lines past eight" "$out" "- and 5 more lines in 5 files"

# The phrase cap: a replaced passage past it is not searched past it.
R="$WORK/sw-cap"; sweep_repo "$R"
"$PY" - "$R" <<'EOF'
import sys
r = sys.argv[1]
words = ["word%03d" % i for i in range(420)]
with open(r + "/skills/handoff/SKILL.md", "a") as fh:
    fh.write("\n" + " ".join(words) + "\n")
open(r + "/docs/early.md", "w").write(" ".join(words[0:12]) + "\n")
open(r + "/docs/late.md", "w").write(" ".join(words[405:420]) + "\n")
EOF
(cd "$R" && git add -A && git commit -qm long)
sweep_submit "$R" s21 p1 >/dev/null
"$PY" - "$R" <<'EOF'
import sys
p = sys.argv[1] + "/skills/handoff/SKILL.md"
text = open(p).read()
open(p, "w").write(text.replace(" ".join("word%03d" % i for i in range(420)), " ".join("other%03d" % i for i in range(420))))
EOF
got=$(handed "$(sweep_stop "$R" s21 p1)")
contains "sweep searches the phrases inside its cap" "$got" "docs/early.md"
lacks "sweep passes silently past its phrase cap" "$got" "docs/late.md"

# The time budget ends the work silently; a state directory that cannot be
# written ends it before any hand-off.
R="$WORK/sw-budget"; sweep_repo "$R"
sweep_submit "$R" s22 p1 >/dev/null
add_item "$R"
out=$(printf '{"hook_event_name":"Stop","session_id":"s22","prompt_id":"p1","cwd":"%s","stop_hook_active":false}' "$R" \
  | DELIVERY_SKILLS_SWEEP_BUDGET=0 TMPDIR="$SW" "$PY" "$SWEEP_HOOK")
check "sweep exits 0 past its time budget" 0 $?
empty "sweep hands nothing past its time budget" "$out"
printf 'x' > "$WORK/sweep-blocked"
out=$(printf '{"hook_event_name":"UserPromptSubmit","session_id":"s23","prompt_id":"p1","cwd":"%s"}' "$R" \
  | TMPDIR="$WORK/sweep-blocked" "$PY" "$SWEEP_HOOK")
check "sweep's snapshot exits 0 where its state cannot be written" 0 $?
empty "sweep's snapshot prints nothing where its state cannot be written" "$out"
out=$(printf '{"hook_event_name":"Stop","session_id":"s22","prompt_id":"p1","cwd":"%s","stop_hook_active":false}' "$R" \
  | TMPDIR="$WORK/sweep-blocked" "$PY" "$SWEEP_HOOK")
check "sweep's stop exits 0 where its state cannot be written" 0 $?
empty "sweep hands nothing it cannot record as handed" "$out"

for event in UserPromptSubmit Stop; do
  "$PY" -c 'import json, sys
for matcher in json.load(open(sys.argv[1]))["hooks"].get(sys.argv[2], []):
    if any("landing-sweep.py" in hook["command"] for hook in matcher["hooks"]):
        sys.exit(0)
sys.exit(1)' "$ROOT/hooks/hooks.json" "$event"
  check "registration runs the sweep on $event" 0 $?
done

if [ $fails -eq 0 ]; then
  echo "ALL PASS"
  exit 0
fi
echo "$fails test(s) failing"
exit 1
