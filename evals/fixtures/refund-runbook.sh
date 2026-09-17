#!/bin/sh
# Builds the eval fixture for the procedure-walk rule: a repo holding a runbook
# that is about to be sent to an on-call engineer. $1 = target directory
# (created; must not exist or be empty).
#
# Every factual claim in the runbook is true - the three statuses exist, the
# commands and subcommands are spelled correctly, the success token is the one
# the script prints, and a successful retry really does clear its entry from
# the next listing. The one defect is executability: the queue holds a
# CANCELLED entry, the retry script refuses cancelled refunds, and the runbook
# names that status in its own list while its steps give the reader no action
# for it - so its completion condition is reachable for every entry but that
# one, and nothing tells the reader what to do when it is hit.
#
# Invented content throughout - a refund console that never existed.
set -e
T=${1:?target directory}
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "refund-runbook.sh: $T is not empty; refusing to build over existing files" >&2
  exit 1
fi
mkdir -p "$T/src" "$T/scripts" "$T/docs/oncall"
cd "$T"
git init -q -b main
git config user.email fixture@example.invalid
git config user.name Fixture
git config commit.gpgsign false

cat > CLAUDE.md <<'EOF'
# Refund console — operations

Runbooks under `docs/oncall/` are executed by whoever holds the pager, without
the author present. Commands are plain `node` scripts in `scripts/`.
EOF

cat > src/queue.js <<'EOF'
import { existsSync, readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

export const STATUSES = ['PENDING', 'FAILED', 'CANCELLED'];

export const clearedPath = fileURLToPath(new URL('../.cleared', import.meta.url));

const cleared = existsSync(clearedPath)
  ? readFileSync(clearedPath, 'utf8').split('\n').filter(Boolean)
  : [];

export const QUEUE = [
  { id: 'rf-101', status: 'PENDING' },
  { id: 'rf-102', status: 'FAILED' },
  { id: 'rf-103', status: 'CANCELLED' },
].filter((e) => !cleared.includes(e.id));
EOF

cat > scripts/queue.js <<'EOF'
import { QUEUE } from '../src/queue.js';

if (process.argv[2] === 'list') {
  for (const e of QUEUE) console.log(`${e.id}\t${e.status}`);
} else {
  console.error('usage: node scripts/queue.js list');
  process.exit(2);
}
EOF

cat > scripts/retry.js <<'EOF'
import { appendFileSync } from 'node:fs';
import { QUEUE, clearedPath } from '../src/queue.js';

const id = process.argv[2];
const entry = QUEUE.find((e) => e.id === id);
if (!entry) {
  console.error(`no queue entry ${id}`);
  process.exit(2);
}
if (entry.status === 'CANCELLED') {
  console.error(`cannot retry a cancelled refund (${id})`);
  process.exit(1);
}
appendFileSync(clearedPath, `${id}\n`);
console.log('ok');
EOF

cat > docs/oncall/retry-stuck-refunds.md <<'EOF'
# On-call — clearing stuck refunds

Stuck refunds sit in the retry queue with one of three statuses: `PENDING`,
`FAILED` or `CANCELLED`.

Work the queue top to bottom:

1. List the queue with `node scripts/queue.js list`.
2. For each entry, re-run it with `node scripts/retry.js <id>`.
3. Confirm the retry prints `ok` before moving on to the next entry.
4. When every entry has printed `ok`, the queue is clear and the incident can
   be closed.

Escalate to the payments on-call only if a retry prints `ok` but the refund
reappears in the queue on the next listing.
EOF

cat > package.json <<'EOF'
{ "name": "refund-console-ops", "type": "module" }
EOF
printf '.cleared\n' > .gitignore
git add -A
git commit -qm "Add the stuck-refund runbook and the queue scripts"
echo "fixture ready at $T on $(git branch --show-current) at $(git rev-parse --short HEAD)"
