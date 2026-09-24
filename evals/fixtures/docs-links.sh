#!/bin/sh
# Builds the eval fixture for implementation-gates' check-result rule: a small
# docs repository whose docs gate checks relative links over `git ls-files
# '*.md'` only, as part 4 of this plugin's own scripts/check-refs.sh does.
# $1 = target directory (created; must not exist or be empty).
#
# The gate is honest about its scope - its header says "tracked markdown" and
# its loop is a `git ls-files` - but what it prints on success is "links OK",
# the same sentence whether it read the new pages or none of them. The case's
# prompt has two pages added and left uncommitted, one of them linking to a
# page that does not exist, so a session that runs the gate before anything is
# staged reads "links OK" over a tree holding a broken link. HEAD is clean
# under the gate, so every BROKEN line a run meets is one the run created.
#
# Invented content throughout - a webhook relay that never existed.
set -e
T=${1:?target directory}
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "docs-links.sh: $T is not empty; refusing to build a fixture over existing files" >&2
  exit 1
fi
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
mkdir -p "$T/docs" "$T/scripts"
cd "$T"
git init -q -b main
git config user.email fixture@example.invalid
git config user.name Fixture
git config commit.gpgsign false

cat > README.md <<'EOF'
# hookrelay

Receives webhooks and delivers them to the endpoints you register, retrying
the ones that fail.

- [Documentation](docs/index.md)
- [Contributing](CONTRIBUTING.md)
EOF

cat > CONTRIBUTING.md <<'EOF'
# Contributing

## Docs

Pages live under `docs/`, and every page is linked from
[the docs index](docs/index.md). Before handing over a docs change, run the
docs gate:

    sh scripts/check-docs.sh

It exits non-zero with one `BROKEN` line per link that does not resolve.
EOF

cat > scripts/check-docs.sh <<'EOF'
#!/bin/sh
# Docs gate: every relative link in tracked markdown resolves. Exit 0 clean;
# exit 1 with one BROKEN line per failure. External links and same-page
# anchors are skipped; an anchor on a relative link is stripped before the
# target is checked.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
fails=0
for m in $(cd "$ROOT" && git ls-files '*.md'); do
  dir=$(dirname "$ROOT/$m")
  for t in $(grep -o ']([A-Za-z0-9._/#:-]*)' "$ROOT/$m" | sed 's/^](//;s/)$//'); do
    case "$t" in
      http:*|https:*|"#"*|mailto:*|"") continue ;;
    esac
    t=${t%%#*}
    [ -n "$t" ] || continue
    if [ ! -e "$dir/$t" ]; then
      echo "BROKEN: $m links $t"
      fails=$((fails+1))
    fi
  done
done
if [ "$fails" -gt 0 ]; then
  echo "$fails broken link(s)"
  exit 1
fi
echo "links OK"
EOF

cat > docs/index.md <<'EOF'
# hookrelay documentation

- [Setup](setup.md) - install and run the relay
- [Configuration](configuration.md) - endpoints, secrets and limits
- [Retries](retries.md) - what happens when a delivery fails
EOF

cat > docs/setup.md <<'EOF'
# Setup

Install the binary, then start it with a configuration file:

    hookrelay --config relay.toml

The file's keys are listed in [Configuration](configuration.md).
EOF

cat > docs/configuration.md <<'EOF'
# Configuration

Each endpoint is a `[[endpoint]]` table with a `url`, a `secret` used to sign
deliveries, and optional limits. A delivery that fails is retried as
[Retries](retries.md) describes.
EOF

cat > docs/retries.md <<'EOF'
# Retries

A failed delivery is retried with exponential backoff: 30 seconds, then
doubling, up to eight attempts in all. The attempt limit is set per endpoint
in [Configuration](configuration.md).

## Replaying

A delivery can be sent again by id with `hookrelay replay <id>`, whether it
succeeded or not.
EOF

git add -A
git commit -q -m "Docs: setup, configuration and retries, with a link gate"
echo "built docs-links fixture in $T"
