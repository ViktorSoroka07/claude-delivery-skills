#!/bin/bash
# Runs the whole suite under several global git configurations.
#
# The script inherits whatever git config the user has, and a setting that is
# harmless in isolation can change what a plumbing command does. Each profile
# below is a config a real developer runs, applied with GIT_CONFIG_GLOBAL so it
# governs every git call the suite makes without touching the real ~/.gitconfig.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd -P)"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/git-sync-matrix.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT INT TERM

PASS=0; FAIL=0

profile() {
  local name="$1" body="$2"
  local cfg="$WORK/$name.gitconfig"
  printf '%s\n' "$body" > "$cfg"

  printf '\n\033[1m%s\033[0m\n' "$name"
  printf '%s\n' "$body" | sed 's/^/    /'

  if GIT_CONFIG_GLOBAL="$cfg" GIT_CONFIG_NOSYSTEM=1 bash "$HERE/test.sh" > "$WORK/$name.log" 2>&1; then
    printf '  \033[32mPASS\033[0m %s\n' "$(grep -E 'passed,' "$WORK/$name.log" | tail -1)"
    PASS=$((PASS+1))
  else
    printf '  \033[31mFAIL\033[0m %s\n' "$(grep -E 'passed,' "$WORK/$name.log" | tail -1)"
    grep 'FAIL' "$WORK/$name.log" | sed 's/^/    /' | head -8
    FAIL=$((FAIL+1))
  fi
}

profile "baseline" "# no global settings"

profile "merge-and-pull-opinions" "[merge]
    ff = false
[pull]
    rebase = true
[rebase]
    autoStash = true"

profile "stash-and-fetch-opinions" "[stash]
    showUntrackedFiles = all
[fetch]
    prune = false
    parallel = 4
[core]
    autocrlf = input"

profile "renamed-default-branch" "[init]
    defaultBranch = trunk
[push]
    default = current
[advice]
    detachedHead = false"

profile "quiet-status-and-diff" "[status]
    showUntrackedFiles = no
[diff]
    noprefix = true
[core]
    pager = cat
[gc]
    auto = 0"

printf '\n-----------------------------------------\n'
printf '%d profiles passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
