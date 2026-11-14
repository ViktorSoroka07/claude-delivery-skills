#!/bin/sh
# Runs inside the empty run workspace before the agent starts; the shared
# fixture lives beside this case, reached from this script's own location.
here=$(cd "$(dirname "$0")" && pwd)
f="$here/../fixtures/github-request.sh"
[ -f "$f" ] || { echo "scaffold: $f not found (script $0, cwd $(pwd))" >&2; exit 1; }

# a working git first on the run's PATH; the sandbox's plain `git` is a stub.
# Before the fixture, which writes its gh stand-in beside that wrapper.
sh "$here/../fixtures/stage-git.sh" || exit 1
sh "$f" . post >/dev/null

# The frontmatter post-review.py reads goes in here, not in the shared post
# variant, so the other cases seeding that variant keep the header-line file.
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
head_sha=$(git rev-parse origin/feat/close-ticket) || exit 1
merge_base=$(git merge-base main "$head_sha") || exit 1
{
  printf -- '---\nrepo: github.com/acme/ticket-gateway\npr: 12\nreviewed_sha: %s\nmerge_base: %s\nposted: null\n---\n\n' \
    "$head_sha" "$merge_base"
  cat review-findings-12.md
} > review-findings-12.md.next && mv review-findings-12.md.next review-findings-12.md
