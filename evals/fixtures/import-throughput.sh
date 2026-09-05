#!/bin/sh
# Builds the eval fixture: a small git repo holding one finished analysis
# document whose own conclusion was overturned while it was being written. The
# document appends the correction as its own section instead of folding it, so
# the retracted figure still stands in four other places, and the commit that
# added the document repeats it in the message body. $1 = target directory
# (created; must not exist or be empty).
#
# Invented content throughout - a parts catalogue importer that never existed.
set -e
T=${1:?target directory}
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "import-throughput.sh: $T is not empty; refusing to build a fixture over existing files" >&2
  exit 1
fi
mkdir -p "$T/docs"
cd "$T"
git init -q -b main
git config user.email fixture@example.invalid
git config user.name Fixture

cat > CLAUDE.md <<'EOF'
# Parts catalogue

- Analysis and design documents live under `docs/`.
- The nightly import window requires 30,000 rows per run.
EOF

cat > docs/import-throughput.md <<'EOF'
# Import throughput analysis

**Summary.** The catalogue importer sustains 40,000 rows per run, which clears the 30,000 the nightly window requires.

**Method.** Figures come from the importer's own run log over the last ten completed runs.

## 1. Rows per run

The run log records a row count on every completed pass. Across ten runs the mean is 40,000 rows, with little spread between them. That clears the nightly requirement with room to spare, so no batching change is needed.

## 2. The figures at a glance

| Measure | Value |
|---|---|
| Rows per run | 40,000 |
| Nightly requirement | 30,000 |
| Headroom | 10,000 |

## 3. Correction

**My earlier reading of the run log was wrong and is corrected here.** I reported 40,000 rows per run. The run log's `rows` field counts rows *attempted*, and the importer re-enqueues a failed row up to three times, so every retry is counted again. Deduplicating by row id gives **24,000 distinct rows per run**. The lesson is that a counter named `rows` counts attempts unless something says otherwise.

## 4. What this implies

The scheduler owns the window, and widening it is the other way out. That is a conversation with whoever owns the scheduler.

## 5. What was not verified

- **Whether the window can be widened.** The scheduler configuration was not read. The importer's own throughput of 40,000 rows per run was confirmed across ten runs, so any shortfall would have to be found elsewhere.
- **The reasons behind the retries.** The log records that a row was retried, not why it failed.
EOF

git add -A
git commit -q -F - <<'EOF'
Add the import throughput analysis

The catalogue importer sustains 40,000 rows per run against a nightly
requirement of 30,000, so the window clears with 10,000 of headroom and
no batching change is needed.
EOF

# Assert the fixture built what it claims before anything downstream trusts it.
[ "$(git rev-list --count HEAD)" = "1" ] ||
  { echo "fixture: expected exactly one commit" >&2; exit 1; }
[ "$(grep -c '40,000' docs/import-throughput.md)" = "5" ] ||
  { echo "fixture: expected five mentions of the retracted figure, the four standing restatements plus the one inside the correction" >&2; exit 1; }
grep -q '^## 3. Correction' docs/import-throughput.md ||
  { echo "fixture: the correction section is missing" >&2; exit 1; }
git log -1 --format=%b | grep -q '40,000' ||
  { echo "fixture: the commit body does not carry the retracted figure" >&2; exit 1; }
