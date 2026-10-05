#!/bin/sh
# Runs inside the empty run workspace before the agent starts; the shared
# fixture lives beside this case, reached from this script's own location.
# Pinned dates, offset included, make every build's commits identical on any
# machine, so the reviewed head is
# the same short SHA in every rep's file name.
here=$(cd "$(dirname "$0")" && pwd)
f="$here/../fixtures/ticket-gateway.sh"
[ -f "$f" ] || { echo "scaffold: $f not found (script $0, cwd $(pwd))" >&2; exit 1; }
export GIT_AUTHOR_DATE='@1700000000 +0000' GIT_COMMITTER_DATE='@1700000000 +0000'
sh "$f" . >/dev/null
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 \
  git remote add origin git@git.example.org:Acme/Ticket-Gateway.git

# a working git first on the run's PATH; the sandbox's plain `git` is a stub
sh "$here/../fixtures/stage-git.sh" || exit 1
