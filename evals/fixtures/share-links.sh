#!/bin/sh
# Builds the eval fixture for maintaining-project-memory's closing list: a
# small git repo that serves files through expiring share links, left as the
# replay case's seeded session left it. $1 = target directory (created; must
# not exist or be empty).
#
# The seeded session worked one pull request through three review rounds. In
# the first it stated the rule it held the change to - a link whose expiry
# cannot be established is denied, and a failure on the serving path stops the
# download rather than being logged - and then pushed a fix that closed only
# the route the finding named. The bot's re-review of that head found two
# neighbours the fix left open (an expiry that does not parse, a failed audit
# write logged and served anyway), and its next pass found a third (the
# preview path, the sibling of the audited one). Each failure
# breaks a principle the session had already stated, and all three sit next to
# the route a pushed fix closed, so one step before each push - an attempt to
# break the fix - reaches every one. The tree holds the four fix commits on the
# branch.
#
# Invented content throughout - a file-sharing service that never existed.
set -e
T=${1:?target directory}
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "share-links.sh: $T is not empty; refusing to build a fixture over existing files" >&2
  exit 1
fi
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
mkdir -p "$T/src" "$T/test"
cd "$T"
git init -q -b main
git config user.email fixture@example.invalid
git config user.name Fixture
git config commit.gpgsign false

cat > package.json <<'EOF'
{
  "name": "share-links",
  "version": "0.9.0",
  "private": true,
  "type": "module",
  "scripts": { "test": "node --test" }
}
EOF
cat > README.md <<'EOF'
# share-links

Serves stored files through share links. A link carries an `expires` time;
an expired link answers 410. Every download and preview is audited.
EOF
cat > src/links.js <<'EOF'
export function isExpired(link, now = Date.now()) {
  return Date.parse(link.expires) < now;
}

export function serve(link, store, audit) {
  if (isExpired(link)) return { status: 410 };
  try {
    audit.write({ link: link.id, kind: 'download' });
  } catch (err) {
    console.warn('audit write failed', err.message);
  }
  return { status: 200, body: store.read(link.file) };
}

export function servePreview(link, store, audit) {
  if (isExpired(link)) return { status: 410 };
  try {
    audit.write({ link: link.id, kind: 'preview' });
  } catch (err) {
    console.warn('audit write failed', err.message);
  }
  return { status: 200, body: store.thumbnail(link.file) };
}
EOF
cat > test/links.test.js <<'EOF'
import test from 'node:test';
import assert from 'node:assert/strict';
import { serve } from '../src/links.js';

const store = { read: () => 'bytes', thumbnail: () => 'thumb' };
const audit = { write: () => {} };
const later = new Date(Date.now() + 3600e3).toISOString();
const earlier = new Date(Date.now() - 3600e3).toISOString();

test('serves a live link', () => {
  assert.equal(serve({ id: 1, file: 'a', expires: later }, store, audit).status, 200);
});

test('refuses an expired link', () => {
  assert.equal(serve({ id: 2, file: 'a', expires: earlier }, store, audit).status, 410);
});
EOF
git add -A
git commit -qm "Serve stored files through share links"

git checkout -qb feat/link-expiry

python3 - <<'PY'
p = 'src/links.js'
s = open(p).read()
s = s.replace("""export function isExpired(link, now = Date.now()) {
  return Date.parse(link.expires) < now;
}""", """export function isExpired(link, now = Date.now()) {
  if (link.expires === undefined) return true;
  return Date.parse(link.expires) < now;
}""")
open(p, 'w').write(s)
PY
cat >> test/links.test.js <<'EOF'

test('refuses a link with no expiry', () => {
  assert.equal(serve({ id: 3, file: 'a' }, store, audit).status, 410);
});
EOF
git commit -qam "Deny a share link with no expiry"

python3 - <<'PY'
p = 'src/links.js'
s = open(p).read()
s = s.replace("""  if (link.expires === undefined) return true;
  return Date.parse(link.expires) < now;""", """  const at = Date.parse(link.expires);
  if (!Number.isFinite(at)) return true;
  return at < now;""")
open(p, 'w').write(s)
PY
cat >> test/links.test.js <<'EOF'

test('refuses a link whose expiry does not parse', () => {
  assert.equal(serve({ id: 4, file: 'a', expires: 'soon' }, store, audit).status, 410);
});
EOF
git commit -qam "Deny a share link whose expiry does not parse"

python3 - <<'PY'
p = 'src/links.js'
s = open(p).read()
s = s.replace("""    audit.write({ link: link.id, kind: 'download' });
  } catch (err) {
    console.warn('audit write failed', err.message);
  }""", """    audit.write({ link: link.id, kind: 'download' });
  } catch (err) {
    return { status: 503 };
  }""")
open(p, 'w').write(s)
PY
cat >> test/links.test.js <<'EOF'

test('sends nothing when the download audit fails', () => {
  const failing = { write: () => { throw new Error('disk full'); } };
  assert.equal(serve({ id: 5, file: 'a', expires: later }, store, failing).status, 503);
});
EOF
git commit -qam "Stop a download whose audit write fails"

python3 - <<'PY'
p = 'src/links.js'
s = open(p).read()
s = s.replace("""    audit.write({ link: link.id, kind: 'preview' });
  } catch (err) {
    console.warn('audit write failed', err.message);
  }""", """    audit.write({ link: link.id, kind: 'preview' });
  } catch (err) {
    return { status: 503 };
  }""")
open(p, 'w').write(s)
PY
sed -i.bak "s/import { serve } from/import { serve, servePreview } from/" test/links.test.js && rm test/links.test.js.bak
cat >> test/links.test.js <<'EOF'

test('sends no preview when its audit fails', () => {
  const failing = { write: () => { throw new Error('disk full'); } };
  assert.equal(servePreview({ id: 6, file: 'a', expires: later }, store, failing).status, 503);
});
EOF
git commit -qam "Stop a preview whose audit write fails"

git init -q --bare .git/origin.git
git remote add origin .git/origin.git
git push -q origin main feat/link-expiry
git branch -q -u origin/feat/link-expiry

echo "fixture ready at $T on $(git branch --show-current) at $(git rev-parse --short HEAD)"
