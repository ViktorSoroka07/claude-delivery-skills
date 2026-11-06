#!/bin/sh
# Runs inside the empty run workspace before the agent starts; the shared
# fixture lives beside this case, reached from this script's own location.
here=$(cd "$(dirname "$0")" && pwd)
f="$here/../fixtures/refund-console.sh"
[ -f "$f" ] || { echo "scaffold: $f not found (script $0, cwd $(pwd))" >&2; exit 1; }
sh "$f" . two-in-one-file >/dev/null

# a working git first on the run's PATH; the sandbox's plain `git` is a stub
sh "$here/../fixtures/stage-git.sh" || exit 1

# No git hook runs in a rep, so the run's git wrapper records each commit's
# files, and which of the two changes it carries, in .git/commit-audit.
sh "$here/../fixtures/commit-audit.sh" currency Awaiting || exit 1
