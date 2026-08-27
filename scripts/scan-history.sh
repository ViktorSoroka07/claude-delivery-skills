#!/bin/sh
# Audit the ENTIRE history - every commit's file contents, messages and author
# identities - not just the working tree. Run before any push to a public remote.
# Exits non-zero if anything is found.
#
# Structural shapes are checked as regexes; .leakwords.local terms as FIXED
# STRINGS (grep -F), so a malformed term cannot invalidate the scan. The hook's
# WARN shapes (PR numbers, bare SHAs) are advisory and deliberately not audited
# here - they false-positive on placeholder examples.
set -u
found=0
pats='AB#[0-9]+|dev\.azure\.com/[A-Za-z0-9]|[A-Za-z0-9-]+\.visualstudio\.com|[0-9]{4}-[0-9]{2}-[0-9]{2}'

words=$(mktemp)
trap 'rm -f "$words"' EXIT
if [ -f .leakwords.local ]; then
  # tr -d '\r': the file is user-created and may carry CRLF endings (a
  # Windows editor); a trailing \r on a term makes it silently match nothing.
  tr -d '\r' < .leakwords.local | grep -v '^[[:space:]]*#' | grep -v '^[[:space:]]*$' > "$words"
else
  echo "NOTE: .leakwords.local missing - literal codename checks are OFF."
fi

echo "== file contents, all commits =="
for h in $(git rev-list --all); do
  git grep -hoiE "$pats" "$h" --
  [ -s "$words" ] && git grep -hoiF -f "$words" "$h" --
done | sort | uniq -c | sed 's/^/  /' | grep . && found=1

echo "== commit messages =="
msgs=$(mktemp)
git log --all --format='%B' > "$msgs"
{ grep -ohiE "$pats" "$msgs"; [ -s "$words" ] && grep -ohiF -f "$words" "$msgs"; } \
  | sort | uniq -c | sed 's/^/  /' | grep . && found=1
rm -f "$msgs"

echo "== author / committer identities =="
ids=$(mktemp)
git log --all --format='%an <%ae>%n%cn <%ce>' | sort -u > "$ids"
sed 's/^/  /' "$ids"
{ grep -ohiE "$pats" "$ids"; [ -s "$words" ] && grep -ohiF -f "$words" "$ids"; } \
  | sort -u | sed 's/^/  LEAKING IDENTITY: /' | grep . && found=1
rm -f "$ids"

if [ "$found" -eq 0 ]; then echo; echo "CLEAN - nothing found."; exit 0; fi
echo; echo "FINDINGS ABOVE - do not push."; exit 1
