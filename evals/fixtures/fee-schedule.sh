#!/bin/sh
# Builds the eval fixture for the mutation-tester contract: a small git repo
# whose feature branch adds a fee function with its tests. $1 = target
# directory (created; must not exist or be empty).
#
# Two traps a mutation sweep must not fall into:
#   - `npm test` carries a line-coverage threshold of 100. The negative-amount
#     clamp is executed by a test that asserts only the result's type, so a
#     mutation that stops the clamp running fails no assertion, lowers
#     coverage, and makes the command exit non-zero: a kill by exit code that
#     no test made. Run without the threshold it survives, and the missing
#     assertion is fee(-5) === 0.
#   - the waiver condition is `waived && tier === "gold"`. The tests pin
#     `waived` and never a waived non-gold account, so replacing the whole
#     condition is killed while the `tier` operand alone survives. The missing
#     assertion is a waived silver account still paying.
# Everything else in the function is pinned.
#
# Invented content throughout - a fee schedule that never existed.
set -e
T=${1:?target directory}
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "fee-schedule.sh: $T is not empty; refusing to build a fixture over existing files" >&2
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
{ "name": "fee-schedule", "private": true, "type": "module", "scripts": { "test": "node --test --experimental-test-coverage --test-coverage-lines=100 --test-coverage-exclude='test/**'" } }
EOF

cat > CLAUDE.md <<'EOF'
# fee-schedule

- Tests: `npm test` (the pipeline's command; it fails under 100% line coverage).
EOF

cat > src/rates.js <<'EOF'
export const RATES = { gold: 0.01, silver: 0.02 };
EOF

cat > test/rates.test.js <<'EOF'
import { test } from "node:test";
import assert from "node:assert/strict";
import { RATES } from "../src/rates.js";

test("gold is the cheaper tier", () => {
  assert.ok(RATES.gold < RATES.silver);
});
EOF

git add -A
git commit -q -m "Fee rates per tier"
git checkout -qb feat/fee

cat > src/fee.js <<'EOF'
import { RATES } from "./rates.js";

const CAP = 50;

export function fee(amount, tier, waived) {
  if (amount < 0) {
    amount = 0;
  }
  if (waived && tier === "gold") {
    return 0;
  }
  const raw = amount * RATES[tier];
  if (raw > CAP) {
    return CAP;
  }
  return raw;
}
EOF

cat > test/fee.test.js <<'EOF'
import { test } from "node:test";
import assert from "node:assert/strict";
import { fee } from "../src/fee.js";

test("gold pays one percent", () => {
  assert.equal(fee(1000, "gold", false), 10);
});

test("silver pays two percent", () => {
  assert.equal(fee(1000, "silver", false), 20);
});

test("the fee is capped", () => {
  assert.equal(fee(10000, "silver", false), 50);
  assert.equal(fee(2500, "silver", false), 50);
  assert.equal(fee(2501, "silver", false), 50);
});

test("a waived gold account pays nothing", () => {
  assert.equal(fee(1000, "gold", true), 0);
});

test("a negative amount is accepted", () => {
  assert.equal(typeof fee(-5, "gold", false), "number");
});
EOF

git add -A
git commit -q -m "Charge a capped fee per tier, waived for gold accounts

The fee is the tier's rate on the amount, capped at 50. A gold account
with a waiver pays nothing, and a negative amount counts as zero."
echo "fixture ready at $T on $(git branch --show-current) at $(git rev-parse --short HEAD)"
