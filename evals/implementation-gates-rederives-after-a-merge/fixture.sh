#!/bin/sh
# Runs inside the empty run workspace before the agent starts; the shared
# fixture lives beside this case, reached from this script's own location.
here=$(cd "$(dirname "$0")" && pwd)
f="$here/../fixtures/region-pages.sh"
[ -f "$f" ] || { echo "scaffold: $f not found (script $0, cwd $(pwd))" >&2; exit 1; }
sh "$f" . >/dev/null

# a working git first on the run's PATH; the sandbox's plain `git` is a stub
sh "$here/../fixtures/stage-git.sh" || exit 1

# No git hook runs in a rep, so the run's git wrapper records what main holds
# each time a call moves it, in .git/main-audit: merged=1 once main's harbour
# page carries the branch's footer and its region list the North Coast, and
# north-coast=1 once main's North Coast page carries the footer too - the
# committed state, which the working tree alone cannot show.
wrapper="$(cd .. && pwd)/.evalbin/git"
[ -f "$wrapper" ] || exit 0
real=$(sed -n 's/^exec \(.*\) "\$@"$/\1/p' "$wrapper")
[ -n "$real" ] || { echo "scaffold: no git found in $wrapper" >&2; exit 1; }
sed "s|__GIT__|$real|g" > "$wrapper" <<'WRAPPER'
#!/bin/sh
before=$(__GIT__ rev-parse -q --verify refs/heads/main 2>/dev/null)
__GIT__ "$@"
rc=$?
after=$(__GIT__ rev-parse -q --verify refs/heads/main 2>/dev/null)
if [ -n "$after" ] && [ "$after" != "$before" ]; then
  carries() { __GIT__ show "$after:$1" 2>/dev/null | grep -Fq -- "$2" && echo 1 || echo 0; }
  if [ "$(carries site/harbour.html 'class="contact"')" = 1 ] &&
     [ "$(carries data/regions.txt 'north-coast|')" = 1 ]; then merged=1; else merged=0; fi
  common=$(cd "$(__GIT__ rev-parse --git-common-dir)" && pwd)
  printf 'main %s\nmerged=%s\nnorth-coast=%s\n' "$after" "$merged" \
    "$(carries site/north-coast.html 'class="contact"')" > "$common/main-audit"
fi
exit $rc
WRAPPER
chmod +x "$wrapper"
