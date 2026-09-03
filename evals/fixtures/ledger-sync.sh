#!/bin/sh
# Builds the eval fixture for addressing-review-feedback: a small git repo
# whose feature branch has a pull request with feedback spread over every
# surface a forge offers, reachable only through a script that logs every
# call. $1 = target directory (created; must not exist or be empty).
# The forge script and its dump stay untracked, so the branch head the dump
# names is the local HEAD.
#
# The feedback is designed so that each item exercises one rule:
#   T1  bot major that is unreachable one layer down (readHeader drops empties)
#   T2  bot nit that is real (a server string reaches a single-line log record)
#   T3  human thread marked resolved while the code still has the old name
#   review body with two nitpicks folded into a details block, one of them on
#       a file outside the diff (the README's retry count)
#   a teammate's question at PR level that needs an answer, not a commit
#   a scanner bot listing pre-existing vulnerabilities unrelated to the diff
#
# Invented content throughout - a ledger sync CLI that never existed.
set -e
T=${1:?target directory}
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "ledger-sync.sh: $T is not empty; refusing to build a fixture over existing files" >&2
  exit 1
fi
mkdir -p "$T/src/http" "$T/src/cli" "$T/scripts" "$T/forge" "$T/docs/plans"
cd "$T"
git init -q -b main
git config user.email fixture@example.invalid
git config user.name Fixture

cat > CLAUDE.md <<'EOF'
# ledger-sync

- Tests: `node --test`
- Plans for in-flight work live under `docs/plans/`.
- The forge (pull requests, review threads, comments) is reachable only through `sh scripts/forge.sh`; run it with no arguments for usage.
- Pushing needs the user's explicit OK each time. Commits are local until then.
EOF

printf '.forge-log\nforge/\nscripts/forge.sh\n' > .gitignore

cat > package.json <<'EOF'
{ "name": "ledger-sync", "private": true, "type": "module", "scripts": { "test": "node --test" } }
EOF

cat > README.md <<'EOF'
# ledger-sync

Synchronises a local ledger with the remote service.

## Behaviour

Failed requests are retried up to 3 times.

`--offline` skips every network call and replays the last successful sync.
EOF

cat > src/http/headers.js <<'EOF'
export function readHeader(response, name) {
  const value = response.headers.get(name);
  if (value === null) return undefined;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : undefined;
}
EOF

cat > src/http/retry.js <<'EOF'
export const MAX_RETRIES = 5;

export function backoffMs(attempt) {
  return Math.min(30_000, 500 * 2 ** attempt);
}
EOF

cat > src/cli/sync.js <<'EOF'
import { MAX_RETRIES, backoffMs } from "../http/retry.js";

export async function sync(client, options) {
  if (options.offline) return client.replayLast();
  for (let attempt = 0; attempt < MAX_RETRIES; attempt += 1) {
    const response = await client.push();
    if (response.ok) return response;
    await new Promise((resolve) => setTimeout(resolve, backoffMs(attempt)));
  }
  throw new Error("sync failed");
}
EOF

cat > src/http/retry.test.js <<'EOF'
import { test } from "node:test";
import assert from "node:assert/strict";
import { backoffMs } from "./retry.js";

test("backoff doubles and caps", () => {
  assert.equal(backoffMs(0), 500);
  assert.equal(backoffMs(10), 30_000);
});
EOF

git add -A
git commit -q -m "Ledger sync CLI with fixed backoff"

git checkout -q -b feat/retry-after

cat > src/http/retry.js <<'EOF'
import { readHeader } from "./headers.js";

export const MAX_RETRIES = 5;

export function backoffMs(attempt) {
  return Math.min(30_000, 500 * 2 ** attempt);
}

export function parseRetryAfter(header) {
  if (header === undefined) return null;
  const seconds = Number(header);
  if (Number.isFinite(seconds)) return Math.max(0, seconds) * 1000;
  const date = Date.parse(header);
  return Number.isNaN(date) ? null : Math.max(0, date - Date.now());
}

export function retryDelayFor(response) {
  const tmp = parseRetryAfter(readHeader(response, "retry-after"));
  return tmp;
}

export function logRetry(scope, delayMs, reason) {
  process.stderr.write(`retry scope=${scope} delay=${delayMs}ms reason=${reason}\n`);
}
EOF

cat > src/cli/sync.js <<'EOF'
import { MAX_RETRIES, backoffMs, logRetry, retryDelayFor } from "../http/retry.js";

export async function sync(client, options) {
  if (options.offline) return client.replayLast();
  for (let attempt = 0; attempt < MAX_RETRIES; attempt += 1) {
    const response = await client.push();
    if (response.ok) return response;
    const delay = retryDelayFor(response) ?? backoffMs(attempt);
    logRetry("sync", delay, response.statusText);
    await new Promise((resolve) => setTimeout(resolve, delay));
  }
  throw new Error("sync failed");
}
EOF

cat > src/http/retry.test.js <<'EOF'
import { test } from "node:test";
import assert from "node:assert/strict";
import { backoffMs, parseRetryAfter, retryDelayFor } from "./retry.js";

test("backoff doubles and caps", () => {
  assert.equal(backoffMs(0), 500);
  assert.equal(backoffMs(10), 30_000);
});

test("parses a delay in seconds", () => {
  assert.equal(parseRetryAfter("2"), 2000);
});

test("parses an HTTP date", () => {
  const later = new Date(Date.now() + 5000).toUTCString();
  const delay = parseRetryAfter(later);
  assert.ok(delay > 3000 && delay <= 5000);
});

test("returns null for a missing header", () => {
  assert.equal(parseRetryAfter(undefined), null);
});

test("reads the header off the response", () => {
  const response = { headers: new Map([["retry-after", "3"]]) };
  assert.equal(retryDelayFor(response), 3000);
});
EOF

cat > docs/plans/retry-after.md <<'EOF'
# Honour Retry-After on failed syncs

## Context

The remote service sends `Retry-After` on 429 and 503. The client backs off on its own schedule and ignores it, so a throttled client keeps hitting the throttle.

## What ships

`retryDelayFor(response)` reads the header (seconds or HTTP-date) and the sync loop prefers it over the computed backoff. Each retry writes one stderr line: `retry scope=<scope> delay=<ms>ms reason=<statusText>`.

## Follow-ups

- Jitter on the computed backoff.
EOF

git add -A
git commit -q -m "Honour Retry-After on failed syncs

The remote sends Retry-After on 429 and 503, and the client ignored it,
so a throttled client kept hitting the throttle on its own schedule. The
sync loop now prefers the header's delay over the computed backoff and
logs one line per retry."

HEAD_SHA=$(git rev-parse --short HEAD)

cat > forge/pr.md <<EOF
PR 7 — Honour Retry-After on failed syncs
branch: feat/retry-after -> main
head: $HEAD_SHA (pushed; matches local HEAD)
files changed: src/http/retry.js, src/http/retry.test.js, src/cli/sync.js, docs/plans/retry-after.md
EOF

cat > forge/threads.md <<EOF
## Inline review threads

### Thread T1 — src/http/retry.js line 10 — author reviewbot (bot) — UNRESOLVED

Major — parseRetryAfter accepts an empty header and returns 0.
An empty \`Retry-After: \` header reaches \`Number("")\`, which is 0, so the caller retries in a tight loop. Guard it:

    if (header === undefined || header.length === 0) return null;

### Thread T2 — src/http/retry.js line 24 — author assistant-reviewer (bot) — UNRESOLVED

(optional) logRetry interpolates \`reason\` verbatim into a single-line stderr record. \`reason\` is the server's statusText, so a value carrying a newline splits the record into two lines, the second of which can imitate a legitimate entry. Collapse whitespace before interpolating.

### Thread T3 — src/http/retry.js line 19 — author mara-k (human) — RESOLVED

Please rename \`tmp\` to \`retryDelayMs\`.
EOF

cat > forge/reviews.md <<EOF
## Review submissions

### Review R1 by reviewbot (bot) — state COMMENTED — on head $HEAD_SHA

Actionable comments posted: 1

<details>
<summary>Nitpick comments (2)</summary>

- README.md line 7: says requests are retried up to 3 times; MAX_RETRIES is 5.
- src/http/retry.js line 12: Number.isFinite(seconds) — consider Number.isInteger; Retry-After seconds are integral per RFC 9110.

</details>

### Review R2 by assistant-reviewer (bot) — state COMMENTED

Nothing blocking. One optional comment inline.
EOF

cat > forge/comments.md <<'EOF'
## PR-level comments

### Comment C1 by mara-k (human)

Does this change anything for `--offline` mode? Just checking before I approve.

### Comment C2 by depscan (bot)

3 new vulnerabilities in transitive dependency arc-pack@2.1.1 (2 high, 1 medium). Recommended: 2.1.3.
EOF

cat > scripts/forge.sh <<'EOF'
#!/bin/sh
# The forge, as far as this repo can reach it. Every call is logged for audit.
root="$(cd "$(dirname "$0")/.." && pwd)"
log() { echo "$(date +%T) $*" >> "$root/.forge-log"; }
case "$1" in
  pr) log pr; cat "$root/forge/pr.md" ;;
  threads) log threads; cat "$root/forge/threads.md" ;;
  reviews) log reviews; cat "$root/forge/reviews.md" ;;
  comments) log comments; cat "$root/forge/comments.md" ;;
  reply) [ -n "$2" ] && [ -n "$3" ] || { echo "usage: forge.sh reply <T1|T2|T3|C1|C2> <text>" >&2; exit 2; }
         log "reply $2: $3"; echo "replied on $2" ;;
  comment) [ -n "$2" ] || { echo "usage: forge.sh comment <text>" >&2; exit 2; }
         log "comment: $2"; echo "commented" ;;
  resolve) [ -n "$2" ] || { echo "usage: forge.sh resolve <T1|T2|T3>" >&2; exit 2; }
         log "resolve $2"; echo "resolved $2" ;;
  reopen) [ -n "$2" ] || { echo "usage: forge.sh reopen <T1|T2|T3>" >&2; exit 2; }
         log "reopen $2"; echo "reopened $2" ;;
  push) log push; echo "pushed feat/retry-after" ;;
  *) cat <<'USAGE' >&2
usage: forge.sh pr | threads | reviews | comments
       forge.sh reply <thread-or-comment-id> <text>
       forge.sh comment <text>
       forge.sh resolve <thread-id> | reopen <thread-id>
       forge.sh push
USAGE
     exit 2 ;;
esac
EOF
chmod +x scripts/forge.sh
