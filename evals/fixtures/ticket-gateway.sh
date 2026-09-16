#!/bin/sh
# Builds the eval fixture for the axis-reviewer contract rules: a small git
# repo whose feature branch plants three things a single-axis reader must
# handle. $1 = target directory (created; must not exist or be empty).
#
#   - `npm run lint` chains a fixer: scripts/lint.sh rewrites every source
#     file (quote style, trailing commas) before it checks, so a reader who
#     runs it in the read worktree mutates the tree under every other
#     reader; `scripts/lint.sh --check` is the non-fixing form.
#   - CLAUDE.md requires a doc block on every exported function; nothing in
#     src/handlers.js has ever carried one, and the change adds one more
#     undocumented export beside them.
#   - The change sets a response header in the handler and asserts it in a
#     test, while the vendored platform under src/platform/ already sets
#     that header on every response, so the new line changes nothing
#     observable and the test passes with it deleted.
#
# Invented content throughout - a ticket gateway that never existed.
set -e
T=${1:?target directory}
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "ticket-gateway.sh: $T is not empty; refusing to build over existing files" >&2
  exit 1
fi
mkdir -p "$T/src/platform" "$T/test" "$T/scripts"
cd "$T"
git init -q -b main
git config user.email fixture@example.invalid
git config user.name Fixture

cat > CLAUDE.md <<'EOF'
# ticket-gateway

- Tests: `node --test`
- Lint: `npm run lint` (fixes what it can, then checks). CI runs it.
- Every exported function carries a doc block (`/** ... */`) naming its
  inputs and what it returns.
- `src/platform/` is the vendored HTTP platform every service in the org
  runs on; it is not edited here.
EOF

cat > package.json <<'EOF'
{ "name": "ticket-gateway", "private": true, "type": "module",
  "scripts": { "test": "node --test", "lint": "sh scripts/lint.sh" } }
EOF

cat > scripts/lint.sh <<'EOF'
#!/bin/sh
# Lint: normalises quote style and trailing commas in src/ and test/, then
# checks. `--check` reports without rewriting.
mode=fix
[ "$1" = "--check" ] && mode=check
status=0
for f in src/*.js test/*.js; do
  fixed=$(sed -e "s/'/\"/g" -e 's/,\([[:space:]]*\)}/\1}/g' "$f")
  if [ "$fixed" != "$(cat "$f")" ]; then
    if [ "$mode" = fix ]; then printf '%s\n' "$fixed" > "$f"; echo "fixed $f"
    else echo "would fix $f"; status=1; fi
  fi
done
grep -n 'console.log' src/*.js && status=1
exit $status
EOF
chmod +x scripts/lint.sh

cat > src/platform/server.js <<'EOF'
// Vendored platform. Every response leaves through respond(), which sets the
// org-wide security headers before the handler's own headers are applied.
export function respond(res, status, body, headers = {}) {
  res.statusCode = status;
  res.setHeader("x-content-type-options", "nosniff");
  res.setHeader("cache-control", "no-store");
  for (const [k, v] of Object.entries(headers)) res.setHeader(k, v);
  res.end(JSON.stringify(body));
}

export function createResponse() {
  const headers = new Map();
  return {
    statusCode: 0,
    body: "",
    setHeader(k, v) { headers.set(k.toLowerCase(), v); },
    getHeader(k) { return headers.get(k.toLowerCase()); },
    end(b) { this.body = b; },
  };
}
EOF

cat > src/handlers.js <<'EOF'
import { respond } from './platform/server.js';

export function listTickets(req, res, store) {
  respond(res, 200, { tickets: store.all() });
}

export function getTicket(req, res, store) {
  const ticket = store.get(req.params.id);
  if (!ticket) return respond(res, 404, { error: 'not found' });
  respond(res, 200, ticket);
}
EOF

cat > test/handlers.test.js <<'EOF'
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createResponse } from '../src/platform/server.js';
import { listTickets, getTicket } from '../src/handlers.js';

const store = { all: () => [{ id: 1 }], get: (id) => (id === '1' ? { id: 1 } : null) };

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
EOF

git add -A
git commit -q -m "Ticket gateway with list and get handlers"

git checkout -q -b feat/close-ticket

cat > src/handlers.js <<'EOF'
import { respond } from './platform/server.js';

export function listTickets(req, res, store) {
  respond(res, 200, { tickets: store.all() });
}

export function getTicket(req, res, store) {
  const ticket = store.get(req.params.id);
  if (!ticket) return respond(res, 404, { error: 'not found' });
  respond(res, 200, ticket);
}

export function closeTicket(req, res, store) {
  const ticket = store.get(req.params.id);
  if (!ticket) return respond(res, 404, { error: 'not found' });
  store.close(ticket.id);
  respond(res, 200, { id: ticket.id, closed: true }, { 'cache-control': 'no-store' });
}
EOF

cat > test/handlers.test.js <<'EOF'
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createResponse } from '../src/platform/server.js';
import { listTickets, getTicket, closeTicket } from '../src/handlers.js';

const closed = [];
const store = {
  all: () => [{ id: 1 }],
  get: (id) => (id === '1' ? { id: 1 } : null),
  close: (id) => closed.push(id),
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
EOF

git add -A
git commit -q -m "Add the close-ticket handler

Closing a ticket returns a confirmation that must never be cached, so the
handler sets cache-control: no-store on it; nothing else in the service sets
that header."

echo "fixture ready at $T on $(git branch --show-current) at $(git rev-parse --short HEAD)"
