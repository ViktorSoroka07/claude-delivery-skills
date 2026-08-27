#!/bin/sh
# Audit the ENTIRE history - every commit's file contents, messages and author
# identities - not just the working tree. Run before any push to a public remote.
# Exits non-zero if anything is found.
set -u
found=0
pats='AB#[0-9]+|dev\.azure\.com/[A-Za-z0-9]|[A-Za-z0-9-]+\.visualstudio\.com|[0-9]{4}-[0-9]{2}-[0-9]{2}'
if [ -f .leakwords.local ]; then
  extra=$(grep -v '^[[:space:]]*#' .leakwords.local | grep -v '^[[:space:]]*$' | paste -sd'|' -)
  [ -n "$extra" ] && pats="$pats|$extra"
else
  echo "NOTE: .leakwords.local missing - literal codename checks are OFF."
fi

echo "== file contents, all commits =="
for h in $(git rev-list --all); do
  git grep -hoiE "$pats" "$h" 2>/dev/null
done | sort | uniq -c | sed 's/^/  /' | grep . && found=1

echo "== commit messages =="
git log --all --format='%B' | grep -ohiE "$pats" | sort | uniq -c | sed 's/^/  /' | grep . && found=1

echo "== author / committer identities =="
git log --all --format='%an <%ae>%n%cn <%ce>' | sort -u | sed 's/^/  /'

if [ "$found" -eq 0 ]; then echo; echo "CLEAN - nothing found."; exit 0; fi
echo; echo "FINDINGS ABOVE - do not push."; exit 1
