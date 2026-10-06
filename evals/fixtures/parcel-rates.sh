#!/bin/sh
# Builds the eval fixture for maintaining-project-memory's closing list: a
# small git repo that quotes parcel prices from a carrier's zone map, left as
# the replay case's seeded session left it. $1 = target directory (created;
# must not exist or be empty).
#
# The seeded session met two things worth weighing for promotion:
#   - the vivid one: quotes went wrong for days because the carrier renumbered
#     its zones and the repo pinned the old map. Its cause is one carrier's
#     data change, though a general lesson can be drawn from it (a pinned copy
#     of published data goes stale). The tree shows it: the map moved from
#     version 3 to 4, uncommitted, and a re-quote list of 41 orders sits
#     untracked under out/.
#   - the quiet one: the test suite's describe block was renamed, so a run
#     filtered by the old name matched no test, and the runner still printed a
#     passing file and exited 0. Only a parenthetical of the seeded session
#     mentions it; the tree shows the rename as its second commit.
#
# Invented content throughout - a carrier and a pricing tool that never existed.
set -e
T=${1:?target directory}
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "parcel-rates.sh: $T is not empty; refusing to build a fixture over existing files" >&2
  exit 1
fi
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
mkdir -p "$T/lib" "$T/config" "$T/test" "$T/out"
cd "$T"
git init -q -b main
git config user.email fixture@example.invalid
git config user.name Fixture
git config commit.gpgsign false

cat > package.json <<'EOF'
{
  "name": "parcel-rates",
  "version": "1.4.0",
  "private": true,
  "scripts": { "test": "node --test" }
}
EOF
cat > lib/quote.js <<'EOF'
const zones = require('../config/zones.json');

// Price in cents for a parcel of `kg` to postcode prefix `prefix`.
function quote(kg, prefix) {
  const zone = zones.prefixes[prefix];
  if (zone === undefined) throw new Error(`no zone for prefix ${prefix}`);
  const band = zones.bands[zone];
  return band.base + Math.ceil(kg) * band.perKg;
}

module.exports = { quote };
EOF
cat > test/quote.test.js <<'EOF'
const { describe, it } = require('node:test');
const assert = require('node:assert');
const { quote } = require('../lib/quote');

describe('zone map', () => {
  it('prices a 2 kg parcel to a zone 1 prefix', () => {
    assert.equal(quote(2, '10'), 590);
  });
  it('prices a 2 kg parcel to a zone 5 prefix', () => {
    assert.equal(quote(2, '63'), 1130);
  });
  it('rejects an unknown prefix', () => {
    assert.throws(() => quote(1, '99'));
  });
});
EOF
cat > config/zones.json <<'EOF'
{
  "carrier": "halvard",
  "map_version": 3,
  "prefixes": { "10": 1, "21": 2, "34": 3, "46": 4, "57": 5, "63": 5, "78": 6 },
  "bands": {
    "1": { "base": 450, "perKg": 70 },
    "2": { "base": 520, "perKg": 85 },
    "3": { "base": 610, "perKg": 95 },
    "4": { "base": 700, "perKg": 115 },
    "5": { "base": 790, "perKg": 170 },
    "6": { "base": 880, "perKg": 190 }
  }
}
EOF
cat > README.md <<'EOF'
# parcel-rates

Quotes parcel prices from the carrier's published zone map
(`config/zones.json`). Run the tests with `npm test`.
EOF
git add -A
git commit -q -m "Quote from zone map version 3"

# The suite renamed, so a run filtered on its old name matches no test.
cat > test/quote.test.js <<'EOF'
const { describe, it } = require('node:test');
const assert = require('node:assert');
const { quote } = require('../lib/quote');

describe('tariff zones', () => {
  it('prices a 2 kg parcel to a zone 1 prefix', () => {
    assert.equal(quote(2, '10'), 590);
  });
  it('prices a 2 kg parcel to a zone 5 prefix', () => {
    assert.equal(quote(2, '63'), 1130);
  });
  it('rejects an unknown prefix', () => {
    assert.throws(() => quote(1, '99'));
  });
});
EOF
git commit -q -am "Name the quote suite for the tariff it covers"

# The seeded session's work, left uncommitted as the owner asked: the new map,
# a test pinning the prefix that moved, and the re-quote list.
cat > test/quote.test.js <<'EOF'
const { describe, it } = require('node:test');
const assert = require('node:assert');
const { quote } = require('../lib/quote');

describe('tariff zones', () => {
  it('prices a 2 kg parcel to a zone 1 prefix', () => {
    assert.equal(quote(2, '10'), 590);
  });
  it('prices a 2 kg parcel to a zone 5 prefix', () => {
    assert.equal(quote(2, '63'), 1130);
  });
  it('prices a 2 kg parcel to prefix 57, zone 4 since map 4', () => {
    assert.equal(quote(2, '57'), 930);
  });
  it('rejects an unknown prefix', () => {
    assert.throws(() => quote(1, '99'));
  });
});
EOF
cat > config/zones.json <<'EOF'
{
  "carrier": "halvard",
  "map_version": 4,
  "prefixes": { "10": 1, "21": 2, "34": 3, "46": 4, "57": 4, "63": 5, "78": 6 },
  "bands": {
    "1": { "base": 450, "perKg": 70 },
    "2": { "base": 520, "perKg": 85 },
    "3": { "base": 610, "perKg": 95 },
    "4": { "base": 700, "perKg": 115 },
    "5": { "base": 790, "perKg": 170 },
    "6": { "base": 880, "perKg": 190 }
  }
}
EOF
{
  echo "order,prefix,kg,quoted_cents,correct_cents,refund_cents"
  i=1
  while [ "$i" -le 41 ]; do
    echo "PR-$((4100 + i)),57,2,1130,930,200"
    i=$((i + 1))
  done
} > out/requote-41.csv
