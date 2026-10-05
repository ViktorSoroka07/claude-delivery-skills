#!/bin/sh
# Runs inside the empty run workspace before the agent starts. Builds the
# history a second review meets: round 1's findings file in the run's state
# folder at the branch's first commit, a fix commit on the branch, then main -
# carrying a defect of its own - merged into the branch. Pinned dates, offsets
# included, make every build's commits identical on any machine.
set -e
here=$(cd "$(dirname "$0")" && pwd)
f="$here/../fixtures/ticket-gateway.sh"
[ -f "$f" ] || { echo "scaffold: $f not found (script $0, cwd $(pwd))" >&2; exit 1; }
export GIT_AUTHOR_DATE='@1700000000 +0000' GIT_COMMITTER_DATE='@1700000000 +0000'
sh "$f" . >/dev/null
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
git remote add origin git@git.example.org:Acme/Ticket-Gateway.git

r1=$(git rev-parse HEAD)
mb=$(git merge-base main HEAD)
r1short=$(git rev-parse --short=7 HEAD)
reviewed_at=$(git log -1 --format=%cI HEAD)
folder=../.local/state/delivery-skills/review-pr/git.example.org/acme/ticket-gateway/branch-feat-close-ticket
mkdir -p "$folder"
cat > "$folder/r1-$r1short.md" <<MD
---
repo: git.example.org/acme/ticket-gateway
pr: null
pr_url: null
branch: feat/close-ticket
base: main
title: Add the close-ticket handler
author: Fixture
reviewed_sha: $r1
merge_base: $mb
round: 1
previous: null
kind: review
scope: full
depth: default
reviewed_at: $reviewed_at
plugin: delivery-skills
model: claude-sonnet-5-5
findings: { major: 0, medium: 2, minor: 1 }
posted: null
---

# Review of branch feat/close-ticket (no request yet)

## 1. Pass 1 findings

M-1, M-2 and m-1 below, graded as they stand.

## 2. Pass 2

- M-1 CONFIRMED: \`respond()\` sets \`cache-control: no-store\` before applying the handler's headers; deleting the handler's header leaves the test green.
- M-2 CONFIRMED: \`store.close\` runs whatever the ticket's state.
- m-1 CONFIRMED: no \`/** ... */\` block on \`closeTicket\`.
- No additions from the sweep.

## 3. Final findings

### M-1 (medium) - The cache-control header closeTicket sets changes nothing, and its test passes with the line deleted

\`src/handlers.js:17\`, \`test/handlers.test.js:30\`

**Problem** - The vendored platform's \`respond()\` already sets \`cache-control: no-store\` on every response before it applies the handler's own headers, so the header argument changes nothing a client sees, and the new assertion cannot fail.

**Suggestion** - Drop the header argument and its assertion; the platform owns that header.

### M-2 (medium) - Closing a ticket that is already closed closes it again and confirms success

\`src/handlers.js:14-18\`

**Problem** - \`closeTicket\` calls \`store.close\` whatever the ticket's state and answers 200 with \`closed: true\`, so a second close double-writes the store and a client cannot tell it from the first.

**Suggestion** - Answer 409 when the ticket is already closed, and add a test for it.

### m-1 (minor) - closeTicket has no doc block, which CLAUDE.md requires of every exported function

\`src/handlers.js:13\`

**Problem** - CLAUDE.md requires a \`/** ... */\` block naming the inputs and the return on every exported function.

**Suggestion** - Add one to \`closeTicket\`.

| Class | Findings | Threads (default) | Threads (compact) |
|---|---|---|---|
| redundant header | M-1 | 1 | 1 |
| state check | M-2 | 1 | 1 |
| doc block | m-1 | 1 | 1 |
MD

git checkout -q main
cat > src/audit.js <<'JS'
export function logRequest(req) {
  process.stdout.write(`request ${req.method} ${req.url} ${req.headers.authorization}\n`);
}
JS
git add -A
GIT_AUTHOR_DATE='@1700086400 +0000' GIT_COMMITTER_DATE='@1700086400 +0000' \
  git commit -q -m "Log each request for the audit trail"

git checkout -q feat/close-ticket
cat > src/handlers.js <<'JS'
import { respond } from './platform/server.js';

export function listTickets(req, res, store) {
  respond(res, 200, { tickets: store.all() });
}

export function getTicket(req, res, store) {
  const ticket = store.get(req.params.id);
  if (!ticket) return respond(res, 404, { error: 'not found' });
  respond(res, 200, ticket);
}

/**
 * Closes the ticket named by req.params.id. Answers 404 when there is no such
 * ticket and 409 when it is already closed; otherwise confirms with its id.
 */
export function closeTicket(req, res, store) {
  const ticket = store.get(req.params.id);
  if (!ticket) return respond(res, 404, { error: 'not found' });
  if (ticket.closed) return respond(res, 409, { error: 'already closed' });
  store.close(ticket.id);
  respond(res, 200, { id: ticket.id, closed: true }, { 'cache-control': 'no-store' });
}

/**
 * Reopens the ticket named by req.params.id and confirms with its id.
 */
export function reopenTicket(req, res, store) {
  const ticket = store.get(req.params.id);
  store.reopen(ticket.id);
  respond(res, 200, { id: ticket.id, closed: false });
}
JS
cat > test/handlers.test.js <<'JS'
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createResponse } from '../src/platform/server.js';
import { listTickets, getTicket, closeTicket, reopenTicket } from '../src/handlers.js';

const closed = [];
const reopened = [];
const store = {
  all: () => [{ id: 1 }],
  get: (id) => (id === '1' ? { id: 1 } : id === '2' ? { id: 2, closed: true } : null),
  close: (id) => closed.push(id),
  reopen: (id) => reopened.push(id),
};

test('lists tickets', () => {
  const res = createResponse();
  listTickets({}, res, store);
  assert.equal(res.statusCode, 200);
});

test('404s a missing ticket', () => {
  const res = createResponse();
  getTicket({ params: { id: '9' } }, res, store);
  assert.equal(res.statusCode, 404);
});

test('closes a ticket and forbids caching the confirmation', () => {
  const res = createResponse();
  closeTicket({ params: { id: '1' } }, res, store);
  assert.equal(res.statusCode, 200);
  assert.deepEqual(closed, [1]);
  assert.equal(res.getHeader('cache-control'), 'no-store');
});

test('refuses to close a closed ticket', () => {
  const res = createResponse();
  closeTicket({ params: { id: '2' } }, res, store);
  assert.equal(res.statusCode, 409);
  assert.deepEqual(closed, [1]);
});

test('reopens a ticket', () => {
  const res = createResponse();
  reopenTicket({ params: { id: '2' } }, res, store);
  assert.equal(res.statusCode, 200);
  assert.deepEqual(reopened, [2]);
});
JS
git add -A
GIT_AUTHOR_DATE='@1700090000 +0000' GIT_COMMITTER_DATE='@1700090000 +0000' \
  git commit -q -m "Refuse to close a closed ticket, and add reopening

Closing an already-closed ticket now answers 409 instead of closing it
again, closeTicket carries the doc block CLAUDE.md asks for, and a
reopen handler puts a closed ticket back in the queue."
GIT_AUTHOR_DATE='@1700093600 +0000' GIT_COMMITTER_DATE='@1700093600 +0000' \
  git merge -q --no-ff main -m "Merge branch 'main' into feat/close-ticket"

# a working git first on the run's PATH; the sandbox's plain `git` is a stub
sh "$here/../fixtures/stage-git.sh" || exit 1
