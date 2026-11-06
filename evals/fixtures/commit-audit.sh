#!/bin/sh
# Rewrites the git wrapper stage-git.sh put first on the run's PATH so that,
# after each call that moves HEAD on the same branch, it appends every commit
# the call created to .git/commit-audit - the subject, then each file on an
# indented line - the format a hand run's post-commit hook writes. No git hook
# runs in a runner rep (every call there sets core.hooksPath to /dev/null), so
# the wrapper is the only record of a rep's commits; a call to git by its full
# path, or plumbing that builds a commit in one call and moves the branch in
# another, escapes it, which is why a rep's trace is compared with its audit.
# Run from the built fixture's directory after stage-git.sh; silent where no
# wrapper exists, which is a hand run. Each argument is a marker: with any,
# every commit also gets a line "  carries: <marker>=<0|1> ..." saying whether
# a line the commit added holds that marker, which is how a grader reads which
# workstream a commit carries without parsing a diff.
set -u
wrapper="$(cd .. && pwd)/.evalbin/git"
[ -f "$wrapper" ] || exit 0
real=$(sed -n 's/^exec \(.*\) "\$@"$/\1/p' "$wrapper")
[ -n "$real" ] || { echo "commit-audit: no git found in $wrapper" >&2; exit 1; }
common=$(cd "$(git rev-parse --git-common-dir)" && pwd)
if [ $# -gt 0 ]; then
  printf '%s\n' "$@" > "$common/commit-audit-markers"
fi
sed "s|__GIT__|$real|g" > "$wrapper" <<'WRAPPER'
#!/bin/sh
before=$(__GIT__ rev-parse -q --verify HEAD 2>/dev/null)
branch=$(__GIT__ symbolic-ref -q HEAD 2>/dev/null)
start=$(date +%s)
__GIT__ "$@"
rc=$?
after=$(__GIT__ rev-parse -q --verify HEAD 2>/dev/null)
if [ -n "$after" ] && [ "$after" != "$before" ] &&
   [ "$(__GIT__ symbolic-ref -q HEAD 2>/dev/null)" = "$branch" ]; then
  common=$(cd "$(__GIT__ rev-parse --git-common-dir)" && pwd)
  __GIT__ rev-list --reverse --since="@$start" "$after" ${before:+"^$before"} |
  while read -r c; do
    { printf 'commit %s\n' "$(__GIT__ log -1 --format=%s "$c")"
      __GIT__ diff-tree --no-commit-id --name-only -r --root "$c" | sed 's/^/  /'
      if [ -f "$common/commit-audit-markers" ]; then
        line='  carries:'
        while read -r m; do
          if __GIT__ show --format= -U0 "$c" | grep '^+' | grep -Fq -- "$m"; then v=1; else v=0; fi
          line="$line $m=$v"
        done < "$common/commit-audit-markers"
        printf '%s\n' "$line"
      fi
    } >> "$common/commit-audit"
  done
fi
exit $rc
WRAPPER
chmod +x "$wrapper"
