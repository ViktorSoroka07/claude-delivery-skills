#!/bin/sh
# Builds the eval fixture for delegating-to-subagents' brief-against-the-role
# rule: a small ops repository whose three nightly job logs are summarised, by
# the repository's own convention, by a `log-summariser` agent role that holds
# no tool to write a file (Read, Grep, Glob). The prompt asks for one summary
# file per log, so a coordinator following the skill's "name the path the
# agent writes its report to" hands a file to a role that cannot write one.
#
# $1 = target directory (created; must not exist or be empty).
# $2 = directory the role's definition is written into, resolved before the
#      build moves into $1 - the run's own agent
#      directory, since the runner reads user-level agents and not a project's
#      .claude/agents/ (optional; omitted, no role is written).
#
# Invented content throughout - jobs and a team that never existed.
set -e
T=${1:?target directory}
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "log-digest.sh: $T is not empty; refusing to build a fixture over existing files" >&2
  exit 1
fi
AGENTS=''
if [ -n "${2:-}" ]; then mkdir -p "$2" && AGENTS=$(cd "$2" && pwd); fi
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
mkdir -p "$T/logs" "$T/summaries"
cd "$T"
git init -q -b main
git config user.email fixture@example.invalid
git config user.name Fixture
git config commit.gpgsign false

cat > CLAUDE.md <<'EOF'
# nightly-ops

The nightly batch runs five jobs; each night's log lands in `logs/`.

- Logs are summarised by the `log-summariser` agent, one log per dispatch, so
  the summaries read the same from night to night.
- A summary says which jobs ran, which failed and the first error line of each
  failure, and ends with a one-line verdict.
- Summaries live in `summaries/`, named after the log (`nightly-01.log` ->
  `summaries/nightly-01.md`).
EOF

job_block() { # night job status [error]
  printf '[night %s] %s started\n' "$1" "$2"
  printf '[night %s] %s reading config from jobs/%s.yaml\n' "$1" "$2" "$2"
  printf '[night %s] %s processed %s records\n' "$1" "$2" "$(( ${#2} * 137 ))"
  if [ "$3" = ok ]; then
    printf '[night %s] %s finished OK\n' "$1" "$2"
  else
    printf '[night %s] %s ERROR %s\n' "$1" "$2" "$4"
    printf '[night %s] %s retrying once\n' "$1" "$2"
    printf '[night %s] %s ERROR %s\n' "$1" "$2" "$4"
    printf '[night %s] %s FAILED after 2 attempts\n' "$1" "$2"
  fi
}

night() { # n failing-job error
  for j in invoice-sync fx-rates ledger-rollup customer-export audit-trim; do
    if [ "$j" = "$2" ]; then job_block "$1" "$j" fail "$3"; else job_block "$1" "$j" ok; fi
  done
  printf '[night %s] batch finished: 4 OK, 1 FAILED\n' "$1"
}

night 01 invoice-sync "upstream billing API timed out after 30s" > logs/nightly-01.log
night 02 fx-rates "rate feed returned HTTP 503" > logs/nightly-02.log
night 03 ledger-rollup "no space left on device writing /var/batch/rollup.tmp" > logs/nightly-03.log
: > summaries/.gitkeep

git add -A
git commit -q -m "Nightly logs"

if [ -n "$AGENTS" ]; then
  cat > "$AGENTS/log-summariser.md" <<'EOF'
---
name: log-summariser
description: Summarises one nightly batch log - which jobs ran, which failed and the first error line of each failure, with a one-line verdict. Use for every log under logs/.
tools: Read, Grep, Glob
---

You summarise one nightly batch log. Read the log you are given and report:
which jobs ran, which failed, the first error line of each failure, and a
one-line verdict for the night. Report only what the log shows.
EOF
fi
echo "built log-digest fixture in $T"
