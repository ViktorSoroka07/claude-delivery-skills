#!/bin/sh
# Builds the second eval fixture for the uninvited-report rules, in a domain
# unlike the skill's own examples: a repo holding a draft report bound for
# the team that owns a shared build cache, the reporter's own measurements,
# and excerpts of the owner's code. $1 = target directory (created; must not
# exist or be empty).
#
# Same defects of standing as the notification fixture, none of them phrased
# as the skill phrases them: the draft omits the three artifact types of four
# that hit, prices the fix by its shape, ranks it over a second defect, gives
# its suggestions as instructions, predicts what the change leaves untouched,
# describes the owner's code as careless, carries a verdict and a size in the
# title, and bundles a counter bug whose fix lives in another module.
#
# Invented content throughout - a build cache that never existed.
set -e
T=${1:?target directory}
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "build-cache-report.sh: $T is not empty; refusing to build over existing files" >&2
  exit 1
fi
mkdir -p "$T/docs/reports" "$T/notes" "$T/vendor-notes/build-cache"
cd "$T"
git init -q -b main
git config user.email fixture@example.invalid
git config user.name Fixture
git config commit.gpgsign false

cat > CLAUDE.md <<'EOF'
# Mobile app — team notes

Reports under `docs/reports/` are filed with the owning team by pasting the
file body into a new item in their tracker; the first heading becomes the
item's title. Measurements we took ourselves live under `notes/`; code we
read in other teams' repositories is excerpted under `vendor-notes/<service>/`.
EOF

cat > notes/cache-observations.md <<'EOF'
# Build cache — what we measured

Fourteen days of the mobile app's CI builds through the shared build cache,
every artifact type, on a warm cache: each commit was built twice in a row,
so every second build should hit. Counted from the cache's own lookup log.

| Artifact type | Lookups | Hits | Misses | Hit rate |
|---|---|---|---|---|
| compiled modules | 2,140 | 2,061 | 79 | 96% |
| test bundles | 1,870 | 1,782 | 88 | 95% |
| lint results | 2,140 | 2,097 | 43 | 98% |
| asset bundles | 2,140 | 0 | 2,140 | 0% |

Every asset-bundle miss was a lookup whose key input contained the absolute
path of the runner's checkout directory (`/home/runner/work/<run-id>/app/...`).
Runners get a fresh directory per run, so no two runs produce the same key.
The other three types key on content hashes and repository-relative paths.
A miss on an asset bundle costs the build about four minutes: the bundle is
rebuilt from source.

Separately, the cache's stats endpoint reported `evicted: 0` for all fourteen
days, while 312 entries we had written disappeared between lookups (present
on day 3, missing on day 5, no write from us in between). We did not observe
an eviction; only the counter and the absence.
EOF

cat > vendor-notes/build-cache/key.js <<'EOF'
// Excerpt copied from the build cache repository: the key builder.
export function keyFor(artifact, ctx) {
  const parts = [artifact.type, artifact.contentHash];
  if (artifact.type === 'asset-bundle') {
    parts.push(ctx.cwd + '/' + artifact.path);
  } else {
    parts.push(artifact.path);
  }
  return sha256(parts.join('|'));
}
EOF

cat > vendor-notes/build-cache/paths.js <<'EOF'
// Excerpt copied from the build cache repository: path helpers.
export function relativeTo(root, p) {
  return p.startsWith(root + '/') ? p.slice(root.length + 1) : p;
}
EOF

cat > vendor-notes/build-cache/stats.js <<'EOF'
// Excerpt copied from the build cache repository: the stats endpoint's
// counters. Eviction reasons seen in the log: 'manual', 'lru'.
export function onEvict(entry, reason) {
  if (reason === 'manual') counters.evicted += 1;
  log.debug('evicted', entry.key, reason);
}
EOF

cat > docs/reports/draft-cache-asset-miss.md <<'EOF'
# Build cache: asset bundles never hit — trivial keying slip

## Why this matters more than it looks

An asset-bundle miss costs us four minutes per build, so this is the single
biggest item on our CI time and it should jump the queue ahead of the
eviction counter at the bottom.

## What we saw

Over fourteen days, every one of 2,140 asset-bundle lookups missed. The key
builder shovels the runner's whole checkout path into the key (`ctx.cwd + '/'
+ artifact.path` in `key.js`), and since every runner gets a fresh directory,
no two builds ever agree on a key. The three other artifact types key on
repository-relative paths, so somebody clearly knew better and asset bundles
just got missed.

## Fix

Strip the workspace root from the path before hashing. `relativeTo` in
`paths.js` already does exactly this, so it is mostly wiring. Because nothing
reads the raw path once it is hashed, the other artifact types keep hitting
as they do today.

## Also: the eviction counter

The stats endpoint is lying: it reported `evicted: 0` for the whole period
while 312 of our entries disappeared. `onEvict` in `stats.js` only counts when
`reason === 'manual'`, so LRU evictions are never counted. Count every reason.
EOF

git add -A
git commit -qm "Draft the asset-bundle cache-miss report for the build cache team"
echo "fixture ready at $T on $(git branch --show-current) at $(git rev-parse --short HEAD)"
