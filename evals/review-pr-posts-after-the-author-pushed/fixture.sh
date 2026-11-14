#!/bin/sh
# Runs inside the empty run workspace before the agent starts; the shared
# fixture lives beside this case, reached from this script's own location.
# The posting case's request, except that its author pushed one more commit
# after the review: the forge serves that commit as the head, and the clone
# reaches it only by a fetch.
here=$(cd "$(dirname "$0")" && pwd)
f="$here/../fixtures/github-request.sh"
[ -f "$f" ] || { echo "scaffold: $f not found (script $0, cwd $(pwd))" >&2; exit 1; }

sh "$here/../fixtures/stage-git.sh" || exit 1
sh "$f" . post >/dev/null

export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=jo-dev GIT_AUTHOR_EMAIL=jo-dev@example.invalid
export GIT_COMMITTER_NAME=jo-dev GIT_COMMITTER_EMAIL=jo-dev@example.invalid
export GIT_AUTHOR_DATE='@1700003600 +0000' GIT_COMMITTER_DATE='@1700003600 +0000'
home=$(cd .. && pwd)
mirror="$home/.forge/acme/ticket-gateway.git"
F="$(pwd)/.git/forge"
reviewed=$(git rev-parse origin/feat/close-ticket) || exit 1
merge_base=$(git merge-base main "$reviewed") || exit 1

# The author's push: a change outside the reviewed lines, so every anchor
# holds at the new head and re-verifying it is a fetch and a look.
work=$(mktemp -d "${TMPDIR:-/tmp}/author-push.XXXXXX")
git clone -q -b feat/close-ticket "file://$mirror" "$work" || exit 1
cat > "$work/package.json" <<'EOF'
{ "name": "ticket-gateway", "private": true, "type": "module",
  "engines": { "node": ">=20" },
  "scripts": { "test": "node --test", "lint": "sh scripts/lint.sh" } }
EOF
git -C "$work" commit -q -am "Require Node 20 for the test runner" || exit 1
pushed=$(git -C "$work" rev-parse HEAD)
git -C "$work" push -q origin "HEAD:refs/heads/feat/close-ticket" "HEAD:refs/pull/12/head" || exit 1
base=$(git -C "$work" rev-parse origin/main)
git -C "$work" diff "$base...$pushed" > "$F/pr.diff"
rm -r "$work"

# The stand-in names the head in its own script and in the request it serves.
for file in "$home/.evalbin/gh" "$F/pull.json" "$F/pr.json"; do
  sed "s/$reviewed/$pushed/g" "$file" > "$file.next" && cat "$file.next" > "$file" && rm "$file.next"
done

# The frontmatter post-review.py reads, recording the head the review covered.
{
  printf -- '---\nrepo: github.com/acme/ticket-gateway\npr: 12\nreviewed_sha: %s\nmerge_base: %s\nposted: null\n---\n\n' \
    "$reviewed" "$merge_base"
  cat review-findings-12.md
} > review-findings-12.md.next && mv review-findings-12.md.next review-findings-12.md
