#!/bin/sh
# Builds the eval fixture for maintaining-project-memory's closing list: a
# small git repo that exports a payroll file and uploads it to a bank's
# bulk-payment portal, left as the replay case's seeded session left it.
# $1 = target directory (created; must not exist or be empty).
#
# The seeded session met two things worth weighing for promotion:
#   - the vivid one: a payroll upload was answered "received" and never
#     imported, because this bank's importer picks up only an upper-case
#     `.CSV` extension and a refactor had lower-cased the export's file name.
#     The rule the fix carries - the extension's case - is this one bank's
#     behaviour and nothing more; the tree shows it as an uncommitted change
#     to scripts/upload.sh that upper-cases the extension before posting.
#   - the quiet one: scripts/upload.sh pipes curl into tee under `set -e`,
#     which without pipefail exits 0 whatever curl returned. The seeded
#     session met it in passing, while ruling the upload itself out; the tree
#     shows `set -o pipefail` added in the same uncommitted change.
#
# Invented content throughout - a bank, a portal and a payroll tool that never
# existed.
set -e
T=${1:?target directory}
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "payroll-upload.sh: $T is not empty; refusing to build a fixture over existing files" >&2
  exit 1
fi
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
mkdir -p "$T/bin" "$T/scripts" "$T/test" "$T/out"
cd "$T"
git init -q -b main
git config user.email fixture@example.invalid
git config user.name Fixture
git config commit.gpgsign false

cat > package.json <<'EOF'
{
  "name": "payroll-export",
  "version": "2.3.0",
  "private": true,
  "scripts": { "test": "node --test" }
}
EOF
cat > bin/export.js <<'EOF'
const fs = require('node:fs');
const path = require('node:path');

// Writes one payroll period's payments as the bank's bulk-payment CSV.
function exportPeriod(period, payments, dir = 'out') {
  const rows = ['iban,amount_cents,reference'];
  for (const p of payments) rows.push(`${p.iban},${p.amountCents},${p.reference}`);
  const file = path.join(dir, `PAYROLL_${period}.CSV`);
  fs.writeFileSync(file, rows.join('\r\n') + '\r\n');
  return file;
}

module.exports = { exportPeriod };
EOF
cat > scripts/upload.sh <<'EOF'
#!/bin/sh
# Posts one exported payroll file to the bank's bulk-payment portal.
set -e
file=${1:?payroll file}
curl -sS --fail -H "Authorization: Bearer $PORTAL_TOKEN" \
  -F "batch=@$file" "$PORTAL_URL/bulk/upload" | tee -a upload.log
EOF
cat > test/export.test.js <<'EOF'
const { test } = require('node:test');
const assert = require('node:assert');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { exportPeriod } = require('../bin/export');

test('writes one row per payment after the header', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'pay-'));
  const file = exportPeriod('P03', [
    { iban: 'XX00TEST0001', amountCents: 241500, reference: 'P03-0001' },
    { iban: 'XX00TEST0002', amountCents: 198000, reference: 'P03-0002' },
  ], dir);
  const lines = fs.readFileSync(file, 'utf8').trimEnd().split('\r\n');
  assert.equal(lines.length, 3);
});
EOF
cat > README.md <<'EOF'
# payroll-export

Exports each payroll period as the bank's bulk-payment CSV and uploads it.

    node -e "require('./bin/export').exportPeriod('P04', require('./payments.json'))"
    PORTAL_URL=... PORTAL_TOKEN=... sh scripts/upload.sh out/<file>
EOF
printf 'payments.json\nupload.log\n' > .gitignore
git add -A
git commit -q -m "Export a payroll period and upload it to the bank portal"

# The refactor that broke the import: output paths lower-cased.
sed -i.bak 's/PAYROLL_${period}.CSV/payroll_${period}.csv/' bin/export.js && rm bin/export.js.bak
git commit -q -am "Lower-case output paths"

# The seeded session's uncommitted fix: the upload names the file with an
# upper-case extension, and pipefail, under which a failed curl fails the
# pipeline through tee.
cat > scripts/upload.sh <<'EOF'
#!/bin/sh
# Posts one exported payroll file to the bank's bulk-payment portal.
set -e
set -o pipefail
file=${1:?payroll file}
# The portal imports only an upper-case .CSV extension; any other name is
# answered "received" and never imported.
name="$(basename "${file%.*}").CSV"
curl -sS --fail -H "Authorization: Bearer $PORTAL_TOKEN" \
  -F "batch=@$file;filename=$name" "$PORTAL_URL/bulk/upload" | tee -a upload.log
EOF
cat > test/upload-name.test.js <<'EOF'
const { test } = require('node:test');
const assert = require('node:assert');
const fs = require('node:fs');

test('upload sends the file under an upper-case .CSV extension', () => {
  const script = fs.readFileSync('scripts/upload.sh', 'utf8');
  assert.match(script, /filename=\$name"/);
  assert.match(script, /name="\$\(basename "\$\{file%\.\*\}"\)\.CSV"/);
});
EOF
printf 'P04 re-upload: batch BX-31002, received, 63 rows imported, pending release\n' > out/reupload-P04.txt

# P04's 63 payments, its export under the lower-cased name, and the portal's
# answers: P03 imported, P04 held, the re-upload imported.
i=1
{
  printf '['
  while [ $i -le 63 ]; do
    n=$(printf '%04d' $i)
    [ $i -gt 1 ] && printf ','
    printf '{"iban":"XX00TEST%s","amountCents":289550,"reference":"P04-%s"}' "$n" "$n"
    i=$((i + 1))
  done
  printf ']\n'
} > payments.json
i=1
{
  printf 'iban,amount_cents,reference\r\n'
  while [ $i -le 63 ]; do
    n=$(printf '%04d' $i)
    printf 'XX00TEST%s,289550,P04-%s\r\n' "$n" "$n"
    i=$((i + 1))
  done
} > out/payroll_P04.csv
cat > upload.log <<'EOF'
{"status":"received","batch":"BX-30417","file":"PAYROLL_P03.CSV"}
{"status":"received","batch":"BX-30988","file":"payroll_P04.csv"}
{"status":"received","batch":"BX-31002","file":"payroll_P04.CSV"}
EOF
