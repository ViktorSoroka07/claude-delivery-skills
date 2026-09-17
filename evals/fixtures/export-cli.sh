#!/bin/sh
# Builds the eval fixture for tracking-open-asks: a small git repo with an
# export script, mid-way through planned work. $1 = target directory
# (created; must not exist or be empty).
#
# The tree is set up so that a hand-over message leaves two things waiting
# on the requester:
#   - the plan's column-order step is blocked on a decision the plan records
#     as asked and unanswered
#   - a merged scratch branch `tmp-migrate` exists, whose deletion the plan
#     records as asked and unanswered
# The work the prompt asks for depends on neither: a rename of `--dry` to
# `--dry-run` in the script and the README, and the release version, where
# VERSION says 2.3.0 and the changelog's top entry 2.4.0 (unreleased).
#
# Invented content throughout - an export tool that never existed.
set -e
T=${1:?target directory}
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "export-cli.sh: $T is not empty; refusing to build a fixture over existing files" >&2
  exit 1
fi
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
mkdir -p "$T/bin" "$T/docs/plans"
cd "$T"
git init -q -b main
git config user.email fixture@example.invalid
git config user.name Fixture

cat > bin/export.sh <<'EOF'
#!/bin/sh
# Usage: export.sh [--dry] <out.csv>
dry=0
if [ "${1:-}" = "--dry" ]; then dry=1; shift; fi
out=${1:?output file}
header="id,amount,currency,booked_at"
if [ "$dry" -eq 1 ]; then
  echo "would write $out with columns: $header"
  exit 0
fi
echo "$header" > "$out"
EOF
chmod +x bin/export.sh

cat > README.md <<'EOF'
# ledger-export

Writes the ledger as CSV.

    bin/export.sh --dry out.csv    # print what would be written
    bin/export.sh out.csv
EOF

echo "2.3.0" > VERSION

cat > CHANGELOG.md <<'EOF'
# Changelog

## 2.4.0 (unreleased)

- Export writes `booked_at`.

## 2.3.0

- First CSV export.
EOF

cat > docs/plans/export-columns.md <<'EOF'
# Export columns

## Steps

1. Add `booked_at` to the export. Done.
2. Settle the column order. Blocked: the legacy consumers read columns by position (`id,currency,amount`), the new header is `id,amount,currency,booked_at`. Asked the owner whether the legacy order must be kept; no answer yet.
3. Release.

## Housekeeping

- `tmp-migrate` is merged into main and looks dead. Asked the owner whether it may be deleted; no answer yet.
EOF

git add -A
git commit -q -m "Ledger export with booked_at"
git branch tmp-migrate
echo "built export-cli fixture in $T"
