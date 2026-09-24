#!/bin/sh
# Builds the eval fixture for maintaining-project-memory's writer-side tests: a
# small shop repository into which the case's prompt has a session write one
# rule - run the browser suite before calling a change done, and never stop a
# running dev server to free its port for it - shaped so each test has
# something to act on:
#
# - the trigger: the prompt scopes the rule to "anything shoppers see", a
#   category the reader must judge a change into, while the README names the
#   directory holding everything the browser loads (`web/`);
# - the prohibition: the prompt forbids stopping the dev server and says to
#   run the suite with it left up, but not why that works; only
#   scripts/e2e.sh shows it - the suite starts a server of its own on a free
#   port - and neither the testing skill nor CLAUDE.md says so;
# - the placement: the prompt names the testing skill as the rule's home,
#   which CLAUDE.md, the file every session loads, reaches only by a pointer
#   for writing tests, while the rule fires when any change is finished.
#
# Nothing in the testing skill names `web/`, a port, or the dev server, so a
# grader reading that file reads what the run wrote there.
# $1 = target directory (created; must not exist or be empty).
#
# Invented content throughout - a shop and a team that never existed.
set -e
T=${1:?target directory}
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "storefront-rules.sh: $T is not empty; refusing to build a fixture over existing files" >&2
  exit 1
fi
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
mkdir -p "$T/web/pages" "$T/web/styles" "$T/web/scripts" "$T/api" "$T/jobs" "$T/e2e" "$T/test" \
  "$T/scripts" "$T/skills/testing" "$T/skills/release"
cd "$T"
git init -q -b main
git config user.email fixture@example.invalid
git config user.name Fixture
git config commit.gpgsign false

cat > README.md <<'EOF'
# storefront

The shop's site and the API behind it.

## Layout

- `web/` - the site: every page, style and script the browser loads, and the
  small server that serves them (`web/server.js`).
- `api/` - order totals and pricing, as plain functions the jobs call too.
- `jobs/` - the nightly workers; nothing they do is shown to a shopper.
- `e2e/` - the browser suite, run by `make e2e`.
- `test/` - unit tests, run by `make test`.
- `skills/` - how our sessions work here; `CLAUDE.md` points at them.

## Running it

`make dev` serves the site on http://localhost:8080 while you work on it.
EOF

cat > CLAUDE.md <<'EOF'
# Working in storefront

- Run `make test` before every commit; it takes about ten seconds.
- Money is whole cents everywhere; a float never holds a price.
- Releasing: follow `skills/release/SKILL.md`.
- Tests - which suite a test belongs in and how to write it:
  `skills/testing/SKILL.md`.
EOF

cat > Makefile <<'EOF'
.PHONY: dev test e2e

dev:
	PORT=8080 node --watch web/server.js

test:
	node --test 'test/*.test.js'

e2e:
	sh scripts/e2e.sh
EOF

cat > scripts/e2e.sh <<'EOF'
#!/bin/sh
# Runs the browser suite against a server of its own, on a free port, and
# stops that server afterwards.
set -e
port=$(node -e 'const s = require("net").createServer().listen(0, () => { console.log(s.address().port); s.close(); });')
PORT=$port node web/server.js &
server=$!
trap 'kill "$server" 2>/dev/null' EXIT
sleep 1
E2E_BASE_URL="http://localhost:$port" node --test 'e2e/*.test.js'
EOF

cat > web/server.js <<'EOF'
const http = require("http");
const fs = require("fs");
const path = require("path");

const root = __dirname;
const port = Number(process.env.PORT || 8080);

http
  .createServer((req, res) => {
    const name = req.url === "/" ? "pages/index.html" : req.url.replace(/^\/+/, "");
    const file = path.join(root, path.normalize(name));
    if (!file.startsWith(root)) {
      res.writeHead(403);
      return res.end();
    }
    fs.readFile(file, (err, body) => {
      if (err) {
        res.writeHead(404);
        return res.end("not found");
      }
      res.writeHead(200);
      res.end(body);
    });
  })
  .listen(port, () => console.log(`serving on http://localhost:${port}`));
EOF

cat > web/pages/index.html <<'EOF'
<!doctype html>
<html lang="en">
  <head><title>Storefront</title><link rel="stylesheet" href="/styles/site.css"></head>
  <body>
    <h1>Today's picks</h1>
    <ul id="products"></ul>
    <button data-add-to-cart>Add to cart</button>
    <a href="/pages/checkout.html">Checkout</a>
    <script src="/scripts/cart.js"></script>
  </body>
</html>
EOF

cat > web/pages/checkout.html <<'EOF'
<!doctype html>
<html lang="en">
  <head><title>Checkout</title><link rel="stylesheet" href="/styles/site.css"></head>
  <body>
    <h1>Checkout</h1>
    <form id="checkout"><button type="submit">Place order</button></form>
  </body>
</html>
EOF

cat > web/scripts/cart.js <<'EOF'
document.querySelectorAll("[data-add-to-cart]").forEach((button) => {
  button.addEventListener("click", () => {
    const count = Number(sessionStorage.getItem("cart") || 0) + 1;
    sessionStorage.setItem("cart", String(count));
  });
});
EOF

cat > web/styles/site.css <<'EOF'
body { font-family: system-ui, sans-serif; margin: 2rem; }
button { padding: 0.5rem 1rem; }
EOF

cat > api/orders.js <<'EOF'
function orderTotal(lines) {
  return lines.reduce((sum, line) => sum + line.unitCents * line.quantity, 0);
}

module.exports = { orderTotal };
EOF

cat > jobs/nightly-report.js <<'EOF'
const { orderTotal } = require("../api/orders");

function dailyRevenue(orders) {
  return orders.reduce((sum, order) => sum + orderTotal(order.lines), 0);
}

module.exports = { dailyRevenue };
EOF

cat > test/orders.test.js <<'EOF'
const test = require("node:test");
const assert = require("node:assert");
const { orderTotal } = require("../api/orders");

test("order total sums every line", () => {
  assert.strictEqual(orderTotal([{ unitCents: 250, quantity: 2 }, { unitCents: 100, quantity: 1 }]), 600);
});
EOF

cat > e2e/checkout.test.js <<'EOF'
const test = require("node:test");
const assert = require("node:assert");

const base = process.env.E2E_BASE_URL;

test("checkout page offers to place the order", async () => {
  const page = await (await fetch(`${base}/pages/checkout.html`)).text();
  assert.match(page, /Place order/);
});
EOF

cat > skills/testing/SKILL.md <<'EOF'
---
name: testing
description: Use when writing or changing tests - which suite a test belongs in, how to name it, and what it may depend on.
---

# Testing

## Which suite

- **Unit tests** (`test/`, `make test`) cover a function or a module with no
  network and no server. Most tests belong here.
- **Browser tests** (`e2e/`, `make e2e`) cover a shopper's path through the
  shop: browsing, adding to the cart, checking out. Add one only for a path a
  unit test cannot reach.

## Writing a test

- Name it for the behaviour - `order total sums every line`, not
  `test_total_2`.
- A test builds its own data; it never depends on another test's leftovers or
  on the order the suite runs in.
- A flaky test is fixed or deleted the day it is seen, never retried into
  passing.
EOF

cat > CHANGELOG.md <<'EOF'
# Changelog

- 2 March 2026 - Checkout page shows the order total before payment.
EOF

cat > skills/release/SKILL.md <<'EOF'
---
name: release
description: Use when cutting a release of the shop - the changelog, the tag and the deploy.
---

# Release

1. Every change since the last tag is merged to `main`, and `make test` passes
   there.
2. Add the changelog entry to `CHANGELOG.md`: one line per change, newest
   first, dated with the day, month and year.
3. Tag `main` as `vYYYY.MM.DD` and push the tag; the deploy starts from it.
4. Watch the first ten minutes of checkout traffic on the dashboard before
   calling the release done.
EOF

git add -A
git commit -q -m "Start the storefront with its site, API and team skills"
echo "built storefront-rules fixture in $T"
