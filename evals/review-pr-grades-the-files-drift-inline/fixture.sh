#!/bin/sh
# Runs inside the empty run workspace before the agent starts; the shared
# fixture lives beside this case, reached from this script's own location.
here=$(cd "$(dirname "$0")" && pwd)
f="$here/../fixtures/ticket-gateway.sh"
[ -f "$f" ] || { echo "scaffold: $f not found (script $0, cwd $(pwd))" >&2; exit 1; }
sh "$f" . >/dev/null
