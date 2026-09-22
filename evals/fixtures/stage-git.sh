#!/bin/sh
# Puts a working git first on the PATH of the run being staged. Called with no
# arguments from a case's fixture.sh, which runs in the run workspace.
#
# Inside the eval sandbox, plain `git` is Apple's /usr/bin/git shim, which dies
# writing its xcrun cache into the host temp directory the sandbox denies. The
# Homebrew binary runs when it is named in full, but it loses the PATH search
# whatever its position: it is a symlink into a Cellar the sandbox will not let
# the shell stat, so the lookup skips it and falls through to the shim.
#
# Hence a real wrapper rather than a symlink, in the run's own home, and a
# .zshenv that puts its directory first - the one init file the run's shell
# reads, and one the sandbox denies the run itself writing. Every nested shell
# reads it again, so the line it writes only prepends where it has not already.
# The workspace's parent is that home; nothing lands in the tree the run reads.
#
# A machine with no git outside /usr/bin is left alone: the run then behaves as
# it did before this script, rather than failing in the scaffold.
set -e
home=$(cd .. && pwd)

git_bin=''
for candidate in "$(command -v git 2>/dev/null)" /opt/homebrew/bin/git /usr/local/bin/git; do
  [ -n "$candidate" ] || continue
  [ "$candidate" = /usr/bin/git ] && continue
  [ -x "$candidate" ] || continue
  git_bin=$candidate
  break
done
[ -n "$git_bin" ] || exit 0

mkdir -p "$home/.evalbin"
printf '#!/bin/sh\nexec %s "$@"\n' "$git_bin" > "$home/.evalbin/git"
chmod +x "$home/.evalbin/git"
cat > "$home/.zshenv" <<'ZSHENV'
case ":$PATH:" in
  *":$HOME/.evalbin:"*) ;;
  *) PATH="$HOME/.evalbin:$PATH"; export PATH ;;
esac
ZSHENV
