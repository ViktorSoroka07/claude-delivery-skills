#!/bin/sh
# Builds the eval fixture for addressing-review-feedback: a small git repo
# whose feature branch has a pull request with feedback spread over every
# surface a forge offers, reachable only through a script that logs every
# call. $1 = target directory (created; must not exist or be empty).
# The forge script and its call log stay untracked; the forge's own data sits
# in the fixture's .git/forge/, so reading any of it means running the script
# and leaving a log line. The branch head the data names is the local HEAD.
#
# The feedback is designed so that each item exercises one rule:
#   T1  bot major that is unreachable one layer down (readHeader drops empties)
#   T2  bot nit that is real (a server string reaches a single-line log record)
#   T3  human thread marked resolved while the code still has the old name;
#       listed only by `threads --all`, so a default run must leave it alone
#       and say that one resolved thread was not re-checked
#   T4  bot thread the bot itself resolved after the push that addressed it
#       (the clamp is already in the head), carrying no reply from the
#       author; the default listing shows its resolver and reply count for
#       free, and the repo's convention still wants the author's reply
#   review body with two nitpicks folded into a details block, one of them on
#       a file outside the diff (the README's retry count)
#   a teammate's question at PR level that needs an answer, not a commit
#   a scanner bot listing pre-existing vulnerabilities unrelated to the diff
#
# With `$2 = post-findings` the repo also holds `review-findings-7.md`, a
# reviewer's write-up of three findings, one of which states an open question
# inside itself; the forge then accepts `post` calls for a posting run.
#
# With `$2 = merge-findings` the branch also carries three user docs that
# misdescribe the code, and `review-findings-7.md` holds a review finished
# through Pass 2 with no final section: four minors of one defect class over
# three files, a medium of that class, a medium and a minor of other classes,
# and one refuted draft. The rename T3 asks for is made in this variant, so
# the resolved thread is no eighth defect for a merge to pick up.
#
# Invented content throughout - a ledger sync CLI that never existed.
set -e
T=${1:?target directory}
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "ledger-sync.sh: $T is not empty; refusing to build a fixture over existing files" >&2
  exit 1
fi
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
mkdir -p "$T/src/http" "$T/src/cli" "$T/scripts" "$T/docs/plans"
cd "$T"
git init -q -b main
git config user.email fixture@example.invalid
git config user.name Fixture
git config commit.gpgsign false

cat > CLAUDE.md <<'EOF'
# ledger-sync

- Tests: `node --test`
- Plans for in-flight work live under `docs/plans/`.
- The forge (pull requests, review threads, comments) is reachable only through `sh scripts/forge.sh`; run it with no arguments for usage.
- Pushing needs the user's explicit OK each time. Commits are local until then.
EOF

printf '.forge-log\nscripts/forge.sh\n' > .gitignore

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

FILES_CHANGED="src/http/retry.js, src/http/retry.test.js, src/cli/sync.js, docs/plans/retry-after.md"
if [ "${2:-}" = "merge-findings" ]; then
FILES_CHANGED="$FILES_CHANGED, docs/retry.md, docs/cli.md, docs/faq.md"
cat > docs/retry.md <<'EOF'
# Retries

The computed backoff doubles on every attempt and is capped at 60 seconds.

A `Retry-After` header is read as a number of milliseconds.

A `Retry-After` header given as an HTTP-date is ignored, and the computed backoff is used instead.
EOF

cat > docs/cli.md <<'EOF'
# Command line

`ledger-sync` pushes the local ledger and retries on failure.

Each retry writes one line to stdout, so redirect stdout to keep a record.
EOF

cat > docs/faq.md <<'EOF'
# FAQ

## How many times is a failed sync retried?

Up to 3 times, after which the command exits with "sync failed".
EOF
sed -e 's/const tmp = /const retryDelayMs = /' -e 's/return tmp;/return retryDelayMs;/' src/http/retry.js > src/http/retry.js.renamed
mv src/http/retry.js.renamed src/http/retry.js
fi

git add -A
git commit -q -m "Honour Retry-After on failed syncs

The remote sends Retry-After on 429 and 503, and the client ignored it,
so a throttled client kept hitting the throttle on its own schedule. The
sync loop now prefers the header's delay over the computed backoff and
logs one line per retry."

HEAD_SHA=$(git rev-parse --short HEAD)

mkdir -p .git/forge/threads .git/forge/comments .git/forge/replies

cat > .git/forge/pr.md <<EOF
PR 7 — Honour Retry-After on failed syncs
branch: feat/retry-after -> main
head: $HEAD_SHA (pushed; matches local HEAD)
files changed: $FILES_CHANGED
EOF

cat > .git/forge/threads/T1.md <<'EOF'
src/http/retry.js line 10 — author reviewbot (bot)
Major — parseRetryAfter accepts an empty header and returns 0.
An empty `Retry-After: ` header reaches `Number("")`, which is 0, so the caller retries in a tight loop. Guard it:

    if (header === undefined || header.length === 0) return null;
EOF

cat > .git/forge/threads/T2.md <<'EOF'
src/http/retry.js line 24 — author assistant-reviewer (bot)
(optional) logRetry interpolates `reason` verbatim into a single-line stderr record. `reason` is the server's statusText, so a value carrying a newline splits the record into two lines, the second of which can imitate a legitimate entry. Collapse whitespace before interpolating.
EOF

cat > .git/forge/threads/T3.md <<'EOF'
src/http/retry.js line 19 — author mara-k (human)
Please rename `tmp` to `retryDelayMs`.
EOF

cat > .git/forge/threads/T4.md <<'EOF'
src/http/retry.js line 13 — author reviewbot (bot)
Major — a negative Retry-After value yields a negative delay, which setTimeout treats as zero, so the client retries immediately on exactly the responses that asked it to wait. Clamp the parsed seconds at zero.
EOF

printf 'T1 UNRESOLVED -\nT2 UNRESOLVED -\nT3 RESOLVED mara-k\nT4 RESOLVED reviewbot\n' > .git/forge/state

cat > .git/forge/reviews.md <<EOF
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

cat > .git/forge/comments/C1.md <<'EOF'
author mara-k (human)
Does this change anything for `--offline` mode? Just checking before I approve.
EOF

cat > .git/forge/comments/C2.md <<'EOF'
author depscan (bot)
3 new vulnerabilities in transitive dependency arc-pack@2.1.1 (2 high, 1 medium). Recommended: 2.1.3.
EOF

cat > scripts/forge.sh <<'EOF'
#!/bin/sh
# The forge, as far as this repo can reach it. Every call is logged for audit;
# replies and resolve state persist, so a re-listing shows what was posted.
root="$(cd "$(dirname "$0")/.." && pwd)"
forge="$root/.git/forge"
log() { echo "$(date +%T) $*" >> "$root/.forge-log"; }
state() { awk -v id="$1" '$1 == id { print $2 }' "$forge/state"; }
resolver() { awk -v id="$1" '$1 == id { print $3 }' "$forge/state"; }
set_state() { awk -v id="$1" -v st="$2" -v by="$3" '$1 == id { $2 = st; $3 = by } { print }' "$forge/state" > "$forge/state.tmp" && mv "$forge/state.tmp" "$forge/state"; }
replies() { [ -f "$forge/replies/$1" ] && { echo; echo "Replies:"; cat "$forge/replies/$1"; }; }
reply_count() { if [ -f "$forge/replies/$1" ]; then grep -c '^- [0-9:]* (author): ' "$forge/replies/$1" || true; else echo 0; fi; }
known() { case "$1" in T1|T2|T3|T4|C1|C2) return 0 ;; *) echo "unknown id $1 (threads: T1 T2 T3 T4; comments: C1 C2)" >&2; return 1 ;; esac; }
case "$1" in
  pr) log pr; cat "$forge/pr.md" ;;
  threads)
    log "threads${2:+ $2}"
    echo "## Inline review threads"
    hidden=0; summary=""
    for t in T1 T2 T3 T4; do
      st=$(state "$t")
      if [ "$2" = "--all" ] || [ "$st" = UNRESOLVED ]; then
        echo; echo "### Thread $t — $(head -1 "$forge/threads/$t.md") — $st"; echo
        tail -n +2 "$forge/threads/$t.md"; replies "$t"
      else
        hidden=$((hidden+1))
        n=$(reply_count "$t"); [ "$n" = 0 ] && r="no author reply" || r="$n author repl$( [ "$n" = 1 ] && echo y || echo ies)"
        summary="$summary $t resolved by $(resolver "$t"), $r;"
      fi
    done
    [ "$hidden" -gt 0 ] && { echo; echo "($hidden resolved thread(s) not listed:$summary forge.sh thread <id> reads one thread whatever its state; forge.sh threads --all lists every resolved thread.)"; } ;;
  thread) [ -n "$2" ] || { echo "usage: forge.sh thread <T1|T2|T3|T4>" >&2; exit 2; }
         [ -n "$(state "$2")" ] || { echo "no thread $2" >&2; exit 2; }
         log "thread $2"
         echo "### Thread $2 — $(head -1 "$forge/threads/$2.md") — $(state "$2")$( [ "$(state "$2")" = RESOLVED ] && echo " by $(resolver "$2")")"; echo
         tail -n +2 "$forge/threads/$2.md"; replies "$2" ;;
  reviews) log reviews; cat "$forge/reviews.md" ;;
  comments)
    log comments
    echo "## PR-level comments"
    for c in C1 C2; do
      echo; echo "### Comment $c by $(head -1 "$forge/comments/$c.md")"; echo
      tail -n +2 "$forge/comments/$c.md"; replies "$c"
    done
    [ -f "$forge/replies/PR" ] && { echo; echo "### Comments posted this run"; echo; cat "$forge/replies/PR"; } ;;
  reply) [ -n "$2" ] && [ -n "$3" ] || { echo "usage: forge.sh reply <T1|T2|T3|T4|C1|C2> <text>" >&2; exit 2; }
         known "$2" || exit 2
         log "reply $2: $3"; printf -- '- %s (author): %s\n' "$(date +%T)" "$3" >> "$forge/replies/$2"; echo "replied on $2" ;;
  comment) [ -n "$2" ] || { echo "usage: forge.sh comment <text>" >&2; exit 2; }
         log "comment: $2"; printf -- '- %s (author): %s\n' "$(date +%T)" "$2" >> "$forge/replies/PR"; echo "commented" ;;
  resolve) [ -n "$2" ] || { echo "usage: forge.sh resolve <T1|T2|T3|T4>" >&2; exit 2; }
         [ -n "$(state "$2")" ] || { echo "no thread $2" >&2; exit 2; }
         log "resolve $2"; set_state "$2" RESOLVED author; echo "resolved $2" ;;
  reopen) [ -n "$2" ] || { echo "usage: forge.sh reopen <T1|T2|T3|T4>" >&2; exit 2; }
         [ -n "$(state "$2")" ] || { echo "no thread $2" >&2; exit 2; }
         log "reopen $2"; set_state "$2" UNRESOLVED -; echo "reopened $2" ;;
  post) [ -n "$2" ] && [ -n "$3" ] || { echo "usage: forge.sh post <file:line|PR> <text>" >&2; exit 2; }
         log "post $2: $3"; n=$(( $(grep -c '^### Posted' "$forge/posted.md" 2>/dev/null || echo 0) + 1 ))
         printf '### Posted thread P%s at %s\n\n%s\n\n' "$n" "$2" "$3" >> "$forge/posted.md"; echo "posted P$n at $2" ;;
  push) log push; echo "pushed feat/retry-after" ;;
  *) cat <<'USAGE' >&2
usage: forge.sh pr | threads [--all] | thread <id> | reviews | comments
       forge.sh reply <thread-or-comment-id> <text>
       forge.sh comment <text>
       forge.sh resolve <thread-id> | reopen <thread-id>
       forge.sh post <file:line|PR> <text>     (a reviewer posting a new thread)
       forge.sh push
USAGE
     exit 2 ;;
esac
EOF
chmod +x scripts/forge.sh

if [ "${2:-}" = "post-findings" ]; then
cat > review-findings-7.md <<EOF
# Review findings — PR 7

- PR: 7 (feat/retry-after -> main)
- Reviewed head SHA: $HEAD_SHA
- Target branch: main
- Diff: src/http/retry.js, src/http/retry.test.js, src/cli/sync.js, docs/plans/retry-after.md

## Final findings

**F1 — Medium — retryDelayFor passes the header's delay through uncapped**
\`src/http/retry.js:18\`
Problem: \`backoffMs\` caps the computed wait at 30 seconds, but the header's value goes straight to the sync loop, so a \`Retry-After: 86400\` parks the sync for a day with no log line after the first.
Suggestion: apply the same 30-second cap to the header-derived delay.

**F2 — Minor — the loop waits after the final failed attempt before throwing**
\`src/cli/sync.js:10\`
Problem: on the last attempt the loop logs, sleeps for the full delay, and then throws "sync failed"; the wait buys nothing and delays the failure by up to the cap.
Suggestion: skip the wait when the attempt is the last one.

**F3 — Major or Minor — the HTTP-date branch measures the delay against the client clock**
\`src/http/retry.js:14\`
Problem: \`date - Date.now()\` turns a clock skew between server and client into a skew in the wait: a client clock behind the server's waits too long, one ahead of it clamps to zero and retries immediately against a server that asked it to wait. Whether that matters depends on the fleet: if production hosts are not clock-synced, throttled clients hammer the service and this is Major; if they are, the skew is milliseconds and this is Minor. Open question: are the production hosts clock-synced? The repository does not say.
Suggestion: bound the date-derived delay by the same cap, and treat a date in the past as the computed backoff rather than zero.
EOF
fi

if [ "${2:-}" = "merge-findings" ]; then
cat > review-findings-7.md <<EOF
# Review findings — PR 7

- PR: 7 (feat/retry-after -> main)
- Reviewed head SHA: $HEAD_SHA
- Target branch: main
- Diff: $FILES_CHANGED

## Pass 1 — draft findings

**D1 — Minor — the retry guide states a 60-second cap and the code caps at 30**
\`docs/retry.md:3\`
Problem: the guide says the computed backoff "is capped at 60 seconds"; \`backoffMs\` in \`src/http/retry.js:6\` caps it at \`30_000\` ms, so an operator sizing a timeout from the guide allows twice the wait the client ever takes.
Suggestion: replace "capped at 60 seconds" with "capped at 30 seconds". Original line 3: "The computed backoff doubles on every attempt and is capped at 60 seconds."

**D2 — Minor — the retry guide says the header is read as milliseconds and the code reads seconds**
\`docs/retry.md:5\`
Problem: \`parseRetryAfter\` multiplies the numeric header by 1000 (\`src/http/retry.js:12\`), which is the seconds the HTTP specification defines; the guide's "milliseconds" tells a service owner to send a value a thousand times too large.
Suggestion: replace "a number of milliseconds" with "a number of seconds". Original line 5: "A \`Retry-After\` header is read as a number of milliseconds."

**D3 — Minor — the command-line guide sends the reader to stdout for retry lines written to stderr**
\`docs/cli.md:5\`
Problem: \`logRetry\` writes with \`process.stderr.write\` (\`src/http/retry.js:23\`), so the redirect the guide recommends captures nothing.
Suggestion: replace line 5 with "Each retry writes one line to stderr, so redirect stderr to keep a record." Original line 5: "Each retry writes one line to stdout, so redirect stdout to keep a record."

**D4 — Minor — the FAQ says a failed sync is retried up to 3 times and the limit is 5**
\`docs/faq.md:5\`
Problem: \`MAX_RETRIES\` is 5 (\`src/http/retry.js:3\`) and the sync loop runs to it (\`src/cli/sync.js:5\`).
Suggestion: replace "Up to 3 times" with "Up to 5 times". Original line 5: "Up to 3 times, after which the command exits with \"sync failed\"."

**D5 — Medium — the retry guide says an HTTP-date header is ignored and the code honours it**
\`docs/retry.md:7\`
Problem: \`parseRetryAfter\` falls through to \`Date.parse\` and returns the distance to that date (\`src/http/retry.js:13-14\`), and the sync loop prefers it over the computed backoff. The guide describes the opposite runtime behaviour, so a service owner who reads it sends dates expecting no effect and parks every client until that date.
Suggestion: replace line 7 with "A \`Retry-After\` header given as an HTTP-date is honoured: the client waits until that date." Original line 7: "A \`Retry-After\` header given as an HTTP-date is ignored, and the computed backoff is used instead."

**D6 — Medium — retryDelayFor passes the header's delay through uncapped**
\`src/http/retry.js:18\`
Problem: \`backoffMs\` caps the computed wait at 30 seconds, but the header's value goes straight to the sync loop, so a \`Retry-After: 86400\` parks the sync for a day with no log line after the first.
Suggestion: apply the same 30-second cap to the header-derived delay.

**D7 — Minor — the loop waits after the final failed attempt before throwing**
\`src/cli/sync.js:10\`
Problem: on the last attempt the loop logs, sleeps for the full delay, and then throws "sync failed"; the wait buys nothing and delays the failure by up to the cap.
Suggestion: skip the wait when the attempt is the last one.

**D8 — Minor — parseRetryAfter returns 0 for an empty header**
\`src/http/retry.js:11\`
Problem: \`Number("")\` is 0, so an empty \`Retry-After\` would retry immediately.
Suggestion: return null for an empty string.

## Pass 2 — verification (one clean-context verifier, then a personal grep-verify of every survivor at $HEAD_SHA)

- D1 CONFIRMED — \`grep -n 30_000 src/http/retry.js\` → line 6; the guide's line 3 reads 60.
- D2 CONFIRMED — \`* 1000\` at \`src/http/retry.js:12\`.
- D3 CONFIRMED — \`process.stderr.write\` at \`src/http/retry.js:23\`; no stdout write anywhere in \`src/\`.
- D4 CONFIRMED — \`MAX_RETRIES = 5\` at \`src/http/retry.js:3\`.
- D5 CONFIRMED — the date branch at \`src/http/retry.js:13-14\` returns a delay, and \`src/cli/sync.js:8\` prefers it.
- D6 CONFIRMED — no cap between \`parseRetryAfter\` and the \`setTimeout\` in \`src/cli/sync.js:10\`.
- D7 CONFIRMED — the \`await\` at \`src/cli/sync.js:10\` runs on every iteration, the last included.
- D8 REFUTED — \`readHeader\` (\`src/http/headers.js:4-5\`) trims the value and returns undefined for an empty one, so an empty string never reaches \`parseRetryAfter\`.
- Sweep additions: none.
- Existing threads on the PR were read before Pass 1: D8 is the bot's open thread T1 re-derived, and no other draft duplicates one.
EOF
fi
