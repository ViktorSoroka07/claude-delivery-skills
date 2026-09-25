#!/bin/sh
# Read-only reference-integrity gate. Verifies that the tree's internal
# references resolve: references/*.md named by skills, delivery-skills:<name>
# mentions, hooks.json command paths, relative markdown links, and each replay
# case's history.jsonl against what its generator builds from the tree. Exit 0
# clean; exit 1 with one BROKEN line per failure. Optional $1 = tree root.
# shellcheck disable=SC2013  # word-splitting the $(grep) and $(git ls-files)
# loops is intended: grep tokens are spaceless by their charsets, and tracked
# paths in this repo contain no whitespace.
set -u
ROOT=${1:-$(cd "$(dirname "$0")/.." && pwd)}
fails=0

broken() {
  echo "BROKEN: $1"
  fails=$((fails+1))
}

# 1. references/*.md named by each SKILL.md exist beside it.
for f in "$ROOT"/skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  d=$(dirname "$f")
  for r in $(grep -o 'references/[A-Za-z0-9._-]*\.md' "$f" | sort -u); do
    [ -f "$d/$r" ] || broken "$f names $r"
  done
done

# 2. delivery-skills:<name> mentions resolve to a skill dir or an agent file.
for n in $(grep -rhoI 'delivery-skills:[a-z][a-z-]*' "$ROOT/skills" "$ROOT/agents" "$ROOT/hooks" "$ROOT/README.md" 2>/dev/null | sed 's/^delivery-skills://' | sort -u); do
  [ -d "$ROOT/skills/$n" ] || [ -f "$ROOT/agents/$n.md" ] || broken "delivery-skills:$n resolves to nothing"
done

# 3. hooks.json command paths exist.
for c in $(grep -o '{CLAUDE_PLUGIN_ROOT}[^"\\ ]*' "$ROOT/hooks/hooks.json" | sed 's|^{CLAUDE_PLUGIN_ROOT}/||'); do
  [ -f "$ROOT/$c" ] || broken "hooks.json command $c"
done

# 4. Relative links in tracked markdown resolve. docs/ is excluded (plan
#    documents carry fenced example links that resolve nowhere), and so is
#    each eval case's prompt.md, whose links name files in the fixture the
#    run is handed rather than in this tree. The target charset admits only
#    path-like tokens, so prose and inline code around a "](" never produce
#    a match.
for m in $(cd "$ROOT" && git ls-files '*.md' ':!docs/*' ':!evals/*/prompt.md'); do
  dir=$(dirname "$ROOT/$m")
  for t in $(grep -o ']([A-Za-z0-9._/#:-]*)' "$ROOT/$m" | sed 's/^](//;s/)$//'); do
    case "$t" in
      http:*|https:*|"#"*|mailto:*|"") continue ;;
    esac
    t=${t%%#*}
    [ -n "$t" ] || continue
    [ -e "$dir/$t" ] || broken "$m links $t"
  done
done

# 5. Each replay case's history.jsonl is byte-identical to what its
#    make-history.py builds from the tree now, the brief and the skill it
#    seeds included.
BUILT=$(mktemp)
trap 'rm -f "$BUILT"' EXIT
for g in "$ROOT"/evals/*/make-history.py; do
  [ -f "$g" ] || continue
  h=$(dirname "$g")/history.jsonl
  if ! python3 "$g" "$BUILT" >/dev/null 2>&1; then
    broken "${g#"$ROOT"/} fails to build"
  elif ! cmp -s "$BUILT" "$h"; then
    broken "${h#"$ROOT"/} is stale - run: python3 ${g#"$ROOT"/}"
  fi
done

if [ "$fails" -gt 0 ]; then
  echo "$fails broken reference(s)"
  exit 1
fi
echo "references OK"
