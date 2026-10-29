#!/bin/sh
# Runs inside the empty run workspace before the agent starts; the shared
# fixture lives beside this case, reached from this script's own location.
here=$(cd "$(dirname "$0")" && pwd)
f="$here/../fixtures/refund-console.sh"
[ -f "$f" ] || { echo "scaffold: $f not found (script $0, cwd $(pwd))" >&2; exit 1; }
sh "$f" . owner-staged >/dev/null

# a working git first on the run's PATH; the sandbox's plain `git` is a stub
sh "$here/../fixtures/stage-git.sh" || exit 1

# No git hook runs in a rep - the sandbox sets core.hooksPath=/dev/null - so the
# wrapper on the run's PATH appends each commit a call makes to the audit instead.
wrapper="$(cd .. && pwd)/.evalbin/git"
[ -f "$wrapper" ] || exit 0
real=$(sed -n 's/^exec \(.*\) "\$@"$/\1/p' "$wrapper")
[ -n "$real" ] || { echo "scaffold: no git found in $wrapper" >&2; exit 1; }
cat > "$wrapper" <<EOF
#!/bin/sh
before=\$($real rev-parse -q --verify HEAD 2>/dev/null)
branch=\$($real symbolic-ref -q HEAD 2>/dev/null)
start=\$(date +%s)
$real "\$@"
rc=\$?
after=\$($real rev-parse -q --verify HEAD 2>/dev/null)
if [ -n "\$after" ] && [ "\$after" != "\$before" ] &&
   [ "\$($real symbolic-ref -q HEAD 2>/dev/null)" = "\$branch" ]; then
  audit="\$(cd "\$($real rev-parse --git-common-dir)" && pwd)/commit-audit"
  $real rev-list --reverse --since="@\$start" "\$after" \${before:+"^\$before"} |
  while read -r c; do
    { printf 'commit %s\n' "\$($real log -1 --format=%s "\$c")"
      $real diff-tree --no-commit-id --name-only -r --root "\$c" | sed 's/^/  /'; } >> "\$audit"
  done
fi
exit \$rc
EOF
