#!/bin/sh
# Rewrites the git wrapper stage-git.sh put first on the run's PATH so that a
# call bringing other content into the tree under review appends a marker to
# .git/git-audit, the file ticket-gateway.sh's post-checkout and
# reference-transaction hooks write in a hand run: "path-checkout" after a
# checkout or restore that succeeded taking its paths from a named revision,
# and "stash" after any call that moved refs/stash. No git hook runs in a
# runner rep (every call there sets core.hooksPath to /dev/null), so the
# wrapper is the only record of these acts there.
#
# Narrower than the hook on one shape: post-checkout fires on a path checkout
# from the index too (`git checkout -- <file>`, `git restore <file>`), which
# rewrites the tree but brings nothing of another revision into it; the
# wrapper leaves that one unmarked. A call to git by its full path escapes the
# wrapper, which is why a rep's trace is read beside its audit.
#
# Run from the built fixture's directory after stage-git.sh; silent where no
# wrapper exists, which is a hand run.
set -u
wrapper="$(cd .. && pwd)/.evalbin/git"
[ -f "$wrapper" ] || exit 0
real=$(sed -n 's/^exec \(.*\) "\$@"$/\1/p' "$wrapper")
[ -n "$real" ] || { echo "git-audit: no git found in $wrapper" >&2; exit 1; }
sed "s|__GIT__|$real|g" > "$wrapper" <<'WRAPPER'
#!/bin/sh
q() { printf "'%s' " "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"; }
globals='' cmd='' take='' n=0
for a do
  n=$((n + 1))
  if [ -n "$take" ]; then globals="$globals$(q "$a")"; take=''; continue; fi
  case "$a" in
    -C|-c|--git-dir|--work-tree|--namespace|--config-env|--attr-source)
      globals="$globals$(q "$a")"; take=1 ;;
    -*) globals="$globals$(q "$a")" ;;
    *) cmd=$a; break ;;
  esac
done
g() { eval "__GIT__ $globals \"\$@\""; }
stash_before=$(g rev-parse -q --verify refs/stash 2>/dev/null)
__GIT__ "$@"
rc=$?
common=$(g rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || exit $rc
marks=''
[ "$(g rev-parse -q --verify refs/stash 2>/dev/null)" != "$stash_before" ] && marks="stash"
if [ $rc -eq 0 ] && { [ "$cmd" = checkout ] || [ "$cmd" = restore ]; }; then
  shift "$n"
  source='' first='' count=0 dashdash='' patch='' fromfile='' skip=''
  for a do
    if [ -n "$skip" ]; then
      [ "$skip" = source ] && source=$a
      skip=''; continue
    fi
    if [ -n "$dashdash" ]; then continue; fi
    case "$a" in
      --) dashdash=1 ;;
      -b|-B|--orphan) skip=value ;;
      -s|--source) skip=source ;;
      --source=*) source=${a#--source=} ;;
      -s?*) source=${a#-s} ;;
      -p|--patch) patch=1 ;;
      --pathspec-from-file=*) fromfile=1 ;;
      -*) ;;
      *) count=$((count + 1)); [ -z "$first" ] && first=$a ;;
    esac
  done
  path_from_rev=''
  if [ "$cmd" = restore ]; then
    [ -n "$source" ] && path_from_rev=1
  elif [ -n "$first" ]; then
    if [ -n "$dashdash" ] || [ -n "$fromfile" ]; then
      path_from_rev=1
    elif [ "$count" -ge 2 ] || [ -n "$patch" ]; then
      g rev-parse -q --verify "$first^{tree}" >/dev/null 2>&1 && path_from_rev=1
    fi
  fi
  [ -n "$path_from_rev" ] && marks="$marks path-checkout"
fi
for m in $marks; do echo "$m" >> "$common/git-audit"; done
exit $rc
WRAPPER
chmod +x "$wrapper"
