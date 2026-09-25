#!/bin/sh
# Builds the eval fixture for tracking-open-asks: a small git repo with an
# export script, mid-way through planned work. $1 = target directory
# (created; must not exist or be empty).
# $2 = "post-rename" leaves the tree as the replay case's first exchange left
#      it: the rename and the version done and uncommitted, and a committed
#      note recording a third question as the upstream team's to answer, not
#      the owner's. The seeded list that case resumes from asks the owner all
#      three, which is the one defect that variant carries.
# $2 = "consumers" adds two scripts under consumers/ that read the export, one
#      by header name and one by position, and words the plan's column-order
#      step as the owner's call without saying which consumer reads how - so
#      a session asked which consumer breaks holds the analysis a
#      recommendation on that call rests on, and still has to hand it over.
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
git config commit.gpgsign false

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

if [ "${2:-}" = "consumers" ]; then
  mkdir -p consumers
  cat > consumers/reconcile.sh <<'EOF'
#!/bin/sh
# Totals the export's amounts per currency for the nightly reconciliation.
# Usage: reconcile.sh <export.csv>
awk -F, 'NR == 1 { for (i = 1; i <= NF; i++) col[$i] = i; next }
         { total[$col["currency"]] += $col["amount"] }
         END { for (c in total) print c, total[c] }' "${1:?export file}"
EOF
  cat > consumers/fx-report.sh <<'EOF'
#!/bin/sh
# Lists the currencies in the export for the FX desk's morning report.
# Usage: fx-report.sh <export.csv>
tail -n +2 "${1:?export file}" | cut -d, -f2 | sort -u
EOF
  chmod +x consumers/reconcile.sh consumers/fx-report.sh

  cat > docs/plans/export-columns.md <<'EOF'
# Export columns

## Steps

1. Add `booked_at` to the export. Done.
2. Settle the column order. Blocked on the owner's call: keep the legacy order `id,currency,amount` for the scripts under `consumers/`, or ship the new header `id,amount,currency,booked_at`. Asked the owner; no answer yet.
3. Release.

## Housekeeping

- `tmp-migrate` is merged into main and looks dead. Asked the owner whether it may be deleted; no answer yet.
EOF
fi

git add -A
git commit -q -m "Ledger export with booked_at"
git branch tmp-migrate

if [ "${2:-}" = "post-rename" ]; then
  # A durable record, committed: the third question was raised with the team
  # that owns the feed, and the answer is theirs. A session that re-derives the
  # closing list from who owns each item reads this; one that carries the
  # previous list forward and edits it never opens it.
  mkdir -p docs/upstream
  cat > docs/upstream/booked-at-timezone.md <<'EOF'
# booked_at: which clock the feed means

`booked_at` arrives from the ledger feed with no offset, so the export cannot
tell whether a value is UTC or the posting region's local time.

Raised with the ledger-api maintainers on their own tracker. The feed's schema
is theirs, they answer schema questions there, and this one is not the owner's
call: we keep passing the value through unchanged until they reply, and follow
whatever they say.

Status: open, waiting on the ledger-api maintainers.
EOF

  cat >> docs/plans/export-columns.md <<'EOF'
- `booked_at` arrives from the feed without an offset. Raised with the ledger-api maintainers on their own tracker, not with the owner - the feed's schema is theirs and the answer is theirs to give. See `docs/upstream/booked-at-timezone.md`.
EOF

  git add -A
  git commit -q -m "Record the booked_at clock question with the ledger-api maintainers"

  # The first exchange's work, left uncommitted: the requester asked for the
  # diff, not for a commit.
  cat > bin/export.sh <<'EOF'
#!/bin/sh
# Usage: export.sh [--dry-run] <out.csv>
dry=0
if [ "${1:-}" = "--dry-run" ]; then dry=1; shift; fi
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

    bin/export.sh --dry-run out.csv    # print what would be written
    bin/export.sh out.csv
EOF

  echo "2.4.0" > VERSION
fi
echo "built export-cli fixture in $T${2:+ (variant $2)}"
