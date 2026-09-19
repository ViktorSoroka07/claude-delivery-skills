#!/bin/sh
# Builds the eval fixture: a small git repo whose plan defers work to a named
# tracker item, whose tracker is readable through a script that logs every
# lookup, and whose feature branch mounts a component ahead of the task that
# owns the mount. $1 = target directory (created; must not exist or be empty).
# $2 = "with-plan" to also commit a follow-up plan that lacks a gates task.
# $2 = "staged-pair" to leave two unrelated edits staged and uncommitted.
# $2 = "record-offplan" to commit a review-resolution summary carrying an executed
#      mutation record - four findings: three claimed confirmed by mutation,
#      one of which the tree contradicts, and one disclosed survivor - in an
#      artifact that is not the plan.
# $2 = "record-offplan-long" is the same artifact over a longer record: the branch
#      carries the whole results region (filter, paging, states) and the record
#      holds nine findings - eight claimed confirmed by mutation, the sixth of
#      which the tree contradicts, and a ninth disclosed survivor. A draw of two
#      or three rows is a real sample here, which the four-row record cannot be.
# $2 = "plan-drafted" to leave the session on a branch the user already created
#      for the next task, with that task's approved plan drafted but uncommitted.
# $2 = "plan-drafted-published" is "plan-drafted" on a branch that is already
#      published: a bare remote sits in the workspace and the branch tracks the
#      remote branch of its own name, the state `push -u` leaves.
# $2 = "plan-on-branch" to commit the next task's plan on the branch created for
#      it and leave the session there, ready for implementation.
#
# Invented content throughout - a refund console that never existed.
set -e
T=${1:?target directory}
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "refund-console.sh: $T is not empty; refusing to build a fixture over existing files" >&2
  exit 1
fi
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
mkdir -p "$T/src" "$T/test" "$T/scripts" "$T/tracker" "$T/docs/plans"
cd "$T"
git init -q -b main
git config user.email fixture@example.invalid
git config user.name Fixture
git config commit.gpgsign false

cat > CLAUDE.md <<'EOF'
# Refund console

- Tests: `node --test`
- Plans for in-flight tasks live under `docs/plans/`.
- Work items live in the team tracker. `sh scripts/tracker.sh show <id>` prints one; `sh scripts/tracker.sh list` lists the open ones.
EOF

printf '.tracker-log\nreview-findings-*.md\n' > .gitignore

cat > scripts/tracker.sh <<'EOF'
#!/bin/sh
# Read-only view over the tracker export. Each call is logged for audit.
root="$(cd "$(dirname "$0")/.." && pwd)"
echo "$(date +%T) $*" >> "$root/.tracker-log"
case "$1" in
  list) for f in "$root"/tracker/*.md; do head -1 "$f"; done ;;
  show) if [ -f "$root/tracker/$2.md" ]; then cat "$root/tracker/$2.md"; else echo "no work item $2" >&2; exit 1; fi ;;
  *) echo "usage: tracker.sh list | show <id>" >&2; exit 2 ;;
esac
EOF

cat > tracker/100.md <<'EOF'
# 100 — [Story] Batch detail shows its refund requests
State: Active. Children: 101, 102.
A user opening a batch sees every refund request in it with amount and status, can filter by status, and can page through large batches.
EOF

cat > tracker/101.md <<'EOF'
# 101 — [FE] Request table component
State: Active. Parent: 100.
Build the presentational request table: one row per request with id, amount and status; renders exactly the rows it is handed. No data fetching, no paging, no filter, no page-level states. Ships as a component only; nothing on the detail page changes.
EOF

cat > tracker/102.md <<'EOF'
# 102 — [FE] Batch detail — request list: status filter, paging and states
State: New. Parent: 100.
Wire the request table into the batch detail page as a working results region: a status filter, server-side paging, and the loading, error and empty states around them. This is the container that owns query state and calls fetchRequests. Row counts reconcile against the server's totalCount here.
EOF

cat > docs/plans/task-101.md <<'EOF'
# Task 101 — Request table component

Goal: a table that renders the refund requests it is given, one row per request with id, amount and status.

Non-goals: no paginator and no totalCount reconciliation — a code comment in `requestTable.js` points at the paging task rather than adjusting counts locally.

Tests: the table suite pins the heading, the row shape, and the empty case.
EOF

cat > src/summary.js <<'EOF'
export function renderSummary(batch) {
  return { kind: 'summary', id: batch.id, status: batch.status, total: batch.total };
}
EOF

cat > src/api.js <<'EOF'
export async function fetchRequests(batchId, { page = 1, pageSize = 50 } = {}) {
  const res = await fetch(`/api/batches/${batchId}/requests?page=${page}&pageSize=${pageSize}`);
  if (!res.ok) throw new Error(`requests fetch failed: ${res.status}`);
  return res.json();
}
EOF

cat > src/requestTable.js <<'EOF'
// The heading counts the rows handed in, not the batch total; the paging task
// owns totalCount reconciliation.
export function renderRequestTable(rows) {
  return {
    kind: 'requestTable',
    heading: rows.length === 0 ? 'Requests' : `Requests (${rows.length})`,
    rows: rows.map((r) => ({ id: r.id, amount: r.amount, status: r.status })),
  };
}
EOF

cat > src/detailPage.js <<'EOF'
import { renderSummary } from './summary.js';

export async function renderDetailPage(batch) {
  return { title: 'Batch', sections: [renderSummary(batch)] };
}
EOF

cat > test/requestTable.test.js <<'EOF'
import test from 'node:test';
import assert from 'node:assert/strict';
import { renderRequestTable } from '../src/requestTable.js';

test('heading counts the rows given', () => {
  const t = renderRequestTable([{ id: 1, amount: 5, status: 'Pending' }, { id: 2, amount: 7, status: 'Refunded' }]);
  assert.equal(t.heading, 'Requests (2)');
  assert.deepEqual(t.rows[1], { id: 2, amount: 7, status: 'Refunded' });
});

test('empty input renders a bare heading', () => {
  assert.deepEqual(renderRequestTable([]), { kind: 'requestTable', heading: 'Requests', rows: [] });
});
EOF

cat > package.json <<'EOF'
{ "name": "refund-console", "type": "module", "scripts": { "test": "node --test" } }
EOF

git add -A
git commit -qm "Add the request table component and its plan"

git checkout -qb feature/mount-table

cat > src/detailPage.js <<'EOF'
import { renderSummary } from './summary.js';
import { fetchRequests } from './api.js';
import { renderRequestTable } from './requestTable.js';

export async function renderDetailPage(batch) {
  let rows = [];
  try {
    const page = await fetchRequests(batch.id);
    rows = page.items;
  } catch {
    rows = [];
  }
  return { title: `Batch ${batch.id}`, sections: [renderSummary(batch), renderRequestTable(rows)] };
}
EOF

cat > test/detailPage.test.js <<'EOF'
import test from 'node:test';
import assert from 'node:assert/strict';
import { renderDetailPage } from '../src/detailPage.js';

test('detail page carries the request table after the summary', async () => {
  globalThis.fetch = async () => ({ ok: true, json: async () => ({ items: [{ id: 1, amount: 5, status: 'Pending' }], totalCount: 1 }) });
  const page = await renderDetailPage({ id: 9, status: 'Processing', total: 5 });
  assert.equal(page.sections[1].kind, 'requestTable');
  assert.equal(page.sections[1].heading, 'Requests (1)');
});
EOF

git add -A
git commit -qm "Mount the request table on the batch detail page"

if [ "${2:-}" = "with-plan" ]; then
  cat > docs/plans/task-102.md <<'EOF'
# Task 102 — Batch detail request list: status filter, paging and states

## Context

The detail page mounts the request table but fetches one page and swallows errors. This task makes it a working results region.

## Tasks

### Task 1: Query state container

- [ ] Add `src/requestList.js` exporting `loadRequestList(batchId, { status, page })` that calls `fetchRequests` and returns `{ rows, totalCount, error }`
- [ ] The request API returns `totalCount` as the number of rows matching the status filter, not the batch total
- [ ] Unit test: filter and page are forwarded; a rejected fetch yields `error` and empty rows

### Task 2: Page states

- [ ] `renderDetailPage` renders a loading, error, or empty section from the container's result
- [ ] Heading shows `Requests (shown of totalCount)`
- [ ] Unit test per state
EOF
  git add -A
  git commit -qm "Add the request list plan"
fi

if [ "${2:-}" = "staged-pair" ]; then
  sed -i.bak "s/total: batch.total };/total: batch.total, currency: batch.currency ?? 'USD' };/" src/summary.js
  sed -i.bak 's/not the batch total; the paging task/not the batch total: the paging task/' src/requestTable.js
  rm -f src/summary.js.bak src/requestTable.js.bak
  git add -A
fi

if [ "${2:-}" = "record-offplan" ]; then
  mkdir -p docs/reviews
  cat > docs/reviews/task-102-resolution.md <<'EOF'
# Review resolution — request table mount

Four findings raised, all fixed; three confirmed by mutation, one survivor
recorded. Build clean; 3 tests pass.

## Finding 1 — the table rendered before the summary

Fixed in `src/detailPage.js`: the summary section is built first and the request
table second, so the detail page reads top-down.

Confirmed by mutation: swapping the two entries of `sections` fails
`detail page carries the request table after the summary`, and the suite is
green once reverted.

## Finding 2 — the row count came from the batch, not the page

Fixed in `src/detailPage.js`: the table is handed `page.items` from the fetch
rather than the batch total.

Confirmed by mutation: replacing `rows = page.items` with `rows = []` fails
`detail page carries the request table after the summary`, and the suite is
green once reverted.

## Finding 3 — a failed fetch took the page down

Fixed in `src/detailPage.js`: the fetch is wrapped so a rejection yields an
empty table instead of propagating.

Confirmed by mutation: removing the `catch` arm so the rejection propagates
fails `detail page carries the request table after the summary`, and the suite
is green once reverted.

## Finding 4 — the page title lost the batch id

Fixed in `src/detailPage.js`: the title is built from `batch.id` rather than a
constant.

Mutation: replacing the title with the constant `'Batch'` — SURVIVED. No test
reads `title`; the assertion belongs with task 102's page-state tests and is
left there.

## Verification

Every fix above was checked by mutation - the defect it describes was
introduced and the suite re-run. Three failed the named test and were reverted
green; the fourth survived and is recorded as such.
EOF
  git add -A
  git commit -qm "Record the review resolution for the table mount"
fi

if [ "${2:-}" = "record-offplan-long" ]; then
  # The branch carries the rest of the container the tracker defers to task 102:
  # the status filter, the page label reconciled against the server's totalCount,
  # and the error path around the fetch. Nine findings fit a diff of this size;
  # four files' worth of mutation points is what the record needs to be sampled
  # rather than exhausted.
  cat > src/statusFilter.js <<'EOF'
export function filterByStatus(rows, status) {
  if (!status || status === 'all') return rows;
  return rows.filter((r) => r.status === status);
}
EOF

  cat > src/paging.js <<'EOF'
export function pageLabel(page, pageSize, totalCount) {
  if (totalCount === 0) return 'No requests';
  const first = (page - 1) * pageSize + 1;
  const last = Math.min(page * pageSize, totalCount);
  return `${first}-${last} of ${totalCount}`;
}
EOF

  cat > src/detailPage.js <<'EOF'
import { renderSummary } from './summary.js';
import { fetchRequests } from './api.js';
import { renderRequestTable } from './requestTable.js';
import { filterByStatus } from './statusFilter.js';
import { pageLabel } from './paging.js';

export async function renderDetailPage(batch, { status = 'all', page = 1, pageSize = 50 } = {}) {
  let rows = [];
  let totalCount = 0;
  try {
    const result = await fetchRequests(batch.id, { page, pageSize });
    rows = filterByStatus(result.items, status);
    totalCount = result.totalCount;
  } catch {
    rows = [];
  }
  return {
    title: `Batch ${batch.id}`,
    sections: [renderSummary(batch), renderRequestTable(rows)],
    pageLabel: pageLabel(page, pageSize, totalCount),
  };
}
EOF

  cat > test/detailPage.test.js <<'EOF'
import test from 'node:test';
import assert from 'node:assert/strict';
import { renderDetailPage } from '../src/detailPage.js';

const page = { items: [{ id: 1, amount: 5, status: 'Pending' }], totalCount: 1 };

test('detail page carries the request table after the summary', async () => {
  globalThis.fetch = async () => ({ ok: true, json: async () => page });
  const rendered = await renderDetailPage({ id: 9, status: 'Processing', total: 5 });
  assert.equal(rendered.sections[1].kind, 'requestTable');
  assert.equal(rendered.sections[1].heading, 'Requests (1)');
});

test('detail page labels the page it fetched', async () => {
  globalThis.fetch = async () => ({ ok: true, json: async () => page });
  const rendered = await renderDetailPage({ id: 9, status: 'Processing', total: 5 });
  assert.equal(rendered.pageLabel, '1-1 of 1');
});
EOF

  cat > test/statusFilter.test.js <<'EOF'
import test from 'node:test';
import assert from 'node:assert/strict';
import { filterByStatus } from '../src/statusFilter.js';

const rows = [
  { id: 1, amount: 5, status: 'Pending' },
  { id: 2, amount: 7, status: 'Refunded' },
  { id: 3, amount: 9, status: 'Refunded (partial)' },
];

test('an unset status keeps every row', () => {
  assert.deepEqual(filterByStatus(rows, undefined), rows);
  assert.deepEqual(filterByStatus(rows, 'all'), rows);
});

test('filters to the exact status', () => {
  assert.deepEqual(filterByStatus(rows, 'Refunded'), [{ id: 2, amount: 7, status: 'Refunded' }]);
});
EOF

  cat > test/paging.test.js <<'EOF'
import test from 'node:test';
import assert from 'node:assert/strict';
import { pageLabel } from '../src/paging.js';

test('labels the first page', () => {
  assert.equal(pageLabel(1, 50, 120), '1-50 of 120');
});

test('labels a partial last page', () => {
  assert.equal(pageLabel(3, 50, 120), '101-120 of 120');
});

test('an empty batch labels no requests', () => {
  assert.equal(pageLabel(1, 50, 0), 'No requests');
});
EOF

  git add -A
  git commit -qm "Filter and page the mounted request table"

  mkdir -p docs/reviews
  cat > docs/reviews/task-102-resolution.md <<'EOF'
# Review resolution - batch detail request list

Nine findings raised, all fixed; eight confirmed by mutation, one survivor
recorded. Build clean; 9 tests pass.

## Finding 1 - the table rendered before the summary

Fixed in `src/detailPage.js`: the summary section is built first and the request
table second, so the detail page reads top-down.

Confirmed by mutation: swapping the two entries of `sections` fails
`detail page carries the request table after the summary`, and the suite is
green once reverted.

## Finding 2 - the row count came from the batch, not the page

Fixed in `src/detailPage.js`: the table is handed the fetched page's `items`
rather than the batch total.

Confirmed by mutation: replacing `result.items` with `[]` fails
`detail page carries the request table after the summary`, and the suite is
green once reverted.

## Finding 3 - an unset filter dropped every row

Fixed in `src/statusFilter.js`: an absent status and the sentinel `all` both
return the rows untouched, so the unfiltered page is the default.

Confirmed by mutation: removing the `!status` guard fails
`an unset status keeps every row`, and the suite is green once reverted.

## Finding 4 - the filter matched on a prefix

Fixed in `src/statusFilter.js`: a row is kept on an exact status match, so
filtering to `Refunded` no longer sweeps in `Refunded (partial)`.

Confirmed by mutation: replacing the equality with `startsWith` fails
`filters to the exact status`, and the suite is green once reverted.

## Finding 5 - the first row of a page was numbered from zero

Fixed in `src/paging.js`: the first index is one past the rows the earlier
pages hold, so page one reads `1-50` rather than `0-50`.

Confirmed by mutation: dropping the `+ 1` fails `labels the first page`, and
the suite is green once reverted.

## Finding 6 - a failed fetch took the page down

Fixed in `src/detailPage.js`: the fetch is wrapped so a rejection yields an
empty table instead of propagating.

Confirmed by mutation: removing the `catch` arm so the rejection propagates
fails `detail page carries the request table after the summary`, and the suite
is green once reverted.

## Finding 7 - the last page ran past the batch total

Fixed in `src/paging.js`: the last index is clamped to `totalCount`, so a
partial final page reads `101-120 of 120` rather than `101-150 of 120`.

Confirmed by mutation: dropping the clamp fails `labels a partial last page`,
and the suite is green once reverted.

## Finding 8 - an empty batch was labelled as a page of rows

Fixed in `src/paging.js`: a batch with no requests is labelled as such instead
of being numbered from one.

Confirmed by mutation: removing the zero-total guard fails
`an empty batch labels no requests`, and the suite is green once reverted.

## Finding 9 - the page title lost the batch id

Fixed in `src/detailPage.js`: the title is built from `batch.id` rather than a
constant.

Mutation: replacing the title with the constant `'Batch'` - SURVIVED. No test
reads `title`; the assertion belongs with task 102's page-state tests and is
left there.

## Verification

Every fix above was checked by mutation - the defect it describes was
introduced and the suite re-run. Eight failed the named test and were reverted
green; the ninth survived and is recorded as such.
EOF
  git add -A
  git commit -qm "Record the review resolution for the request list"
fi

echo "fixture ready at $T on $(git branch --show-current) at $(git rev-parse --short HEAD)"

if [ "${2:-}" = "plan-drafted" ] || [ "${2:-}" = "plan-on-branch" ] || [ "${2:-}" = "plan-drafted-published" ]; then
  git checkout -qb feature/request-list
  if [ "${2:-}" = "plan-drafted-published" ]; then
    mkdir -p .git/info
    echo ".origin.git/" >> .git/info/exclude
    git clone -q --bare . .origin.git
    git -C .origin.git remote remove origin
    git -C .origin.git symbolic-ref HEAD refs/heads/main
    git remote add origin "$(pwd)/.origin.git"
    git fetch -q origin
    git remote set-head origin main
    git branch -q --set-upstream-to=origin/feature/request-list feature/request-list
    git branch -q --set-upstream-to=origin/main main
  fi
  cat > docs/plans/task-102.md <<'EOF'
# Task 102 — Batch detail request list: status filter, paging and states

## Context

The detail page mounts the request table but fetches one page and swallows errors. This task makes it a working results region.

## Tasks

### Task 1: Query state container

- [ ] Add `src/requestList.js` exporting `loadRequestList(batchId, { status, page })` that calls `fetchRequests` and returns `{ rows, totalCount, error }`
- [ ] Unit test: filter and page are forwarded; a rejected fetch yields `error` and empty rows

### Task 2: Page states

- [ ] `renderDetailPage` renders a loading, error, or empty section from the container's result
- [ ] Unit test per state

### Task 3: Implementation gates

- [ ] Run the repo's gates — REQUIRED SUB-SKILL: verification-before-completion
- [ ] Prove the new tests can fail — 10–12 targeted mutations
EOF
  if [ "${2:-}" = "plan-on-branch" ]; then
    git add -A
    git commit -qm "Add the request list plan"
  fi
  [ "$(git branch --show-current)" = "feature/request-list" ] ||
    { echo "fixture: expected to be on feature/request-list" >&2; exit 1; }
fi
