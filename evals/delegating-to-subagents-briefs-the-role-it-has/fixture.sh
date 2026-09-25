#!/bin/sh
# Runs inside the empty run workspace before the agent starts; the shared
# fixture lives beside this case, reached from this script's own location.
# The role goes into the run's own config directory, two levels up from the
# workspace: the runner reads user-level agents, not the project's.
here=$(cd "$(dirname "$0")" && pwd)
f="$here/../fixtures/log-digest.sh"
[ -f "$f" ] || { echo "scaffold: $f not found (script $0, cwd $(pwd))" >&2; exit 1; }
sh "$f" . ../../config/agents >/dev/null

# a working git first on the run's PATH; the sandbox's plain `git` is a stub
sh "$here/../fixtures/stage-git.sh" || exit 1
