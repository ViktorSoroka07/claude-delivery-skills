#!/bin/sh
# Self-tests for the repo-consistency gates (check-refs.sh + generate-inventory.sh).
# Each test builds a throwaway mini-plugin in mktemp and proves a planted break
# is caught and a clean tree passes. Run from anywhere inside the repo; exits
# non-zero on any FAIL.
# shellcheck disable=SC2016  # fixture printfs must write literal ${CLAUDE_PLUGIN_ROOT}
# and backticks into files, never expand them.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
fails=0

CHECK="$ROOT/scripts/check-refs.sh"

check() { # $1 = description, $2 = expected exit, $3 = actual exit
  if [ "$2" = "$3" ]; then
    echo "PASS: $1"
  else
    echo "FAIL: $1 (expected exit $2, got $3)"
    fails=$((fails+1))
  fi
}

mkplugin() { # a minimal valid plugin tree the checks accept
  P="$WORK/$1"
  mkdir -p "$P/skills/demo/references" "$P/agents" "$P/hooks" "$P/.claude-plugin"
  printf -- '---\nname: demo\ndescription: demo\n---\nSee references/how.md, `delivery-skills:demo`, and the `delivery-skills:helper` agent.\n' > "$P/skills/demo/SKILL.md"
  printf 'how\n' > "$P/skills/demo/references/how.md"
  printf 'agent\n' > "$P/agents/helper.md"
  printf '{"hooks":{"PostToolUse":[{"matcher":"Edit","hooks":[{"type":"command","command":"python3 \\"${CLAUDE_PLUGIN_ROOT}/hooks/h.py\\""}]}],"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"python3 \\"${CLAUDE_PLUGIN_ROOT}/hooks/h2.py\\""}]}]}}\n' > "$P/hooks/hooks.json"
  printf 'x\n' > "$P/hooks/h.py"
  printf 'y\n' > "$P/hooks/h2.py"
  printf '# Demo\n\nplugin - <!-- inventory -->one skills, one agent types, and two warn-only hooks<!-- /inventory --> - end. [link](skills/demo/SKILL.md)\n[ext](https://example.com/x) and prose with `](` then capture to `)` here.\n\n<!-- triggers -->\n<!-- /triggers -->\n' > "$P/README.md"
  printf '{\n  "name": "demo",\n  "description": "One skills, one agents, and one warn-only hooks that harden the path from idea to merged PR - tail."\n}\n' > "$P/.claude-plugin/plugin.json"
  printf '{\n  "name": "demo-mkt",\n  "description": "no counts here",\n  "plugins": [\n    {\n      "name": "demo",\n      "description": "One skills, one agents, and one warn-only hooks that harden the path from idea to merged PR."\n    }\n  ]\n}\n' > "$P/.claude-plugin/marketplace.json"
  ( cd "$P" && git init -q . && git config user.name T && git config user.email t@e.co && git add -A && git commit -qm init )
}

# 1. A clean tree passes.
mkplugin t1
sh "$CHECK" "$WORK/t1" >/dev/null 2>&1
check "clean tree passes check-refs" 0 $?

# 2. A SKILL.md naming a missing references file fails.
mkplugin t2
rm "$WORK/t2/skills/demo/references/how.md"
sh "$CHECK" "$WORK/t2" >/dev/null 2>&1
check "missing references file is caught" 1 $?

# 3. A delivery-skills:<name> with no skill dir or agent file fails.
mkplugin t3
printf 'Also `delivery-skills:ghost`.\n' >> "$WORK/t3/skills/demo/SKILL.md"
( cd "$WORK/t3" && git add -A && git commit -qm x )
sh "$CHECK" "$WORK/t3" >/dev/null 2>&1
check "unresolvable delivery-skills name is caught" 1 $?

# 4. A hooks.json command pointing at a missing file fails.
mkplugin t4
rm "$WORK/t4/hooks/h.py"
sh "$CHECK" "$WORK/t4" >/dev/null 2>&1
check "dangling hooks.json command path is caught" 1 $?

# 5. A relative markdown link with a missing target fails.
mkplugin t5
printf '\n[dead](skills/gone/SKILL.md)\n' >> "$WORK/t5/README.md"
( cd "$WORK/t5" && git add -A && git commit -qm x )
sh "$CHECK" "$WORK/t5" >/dev/null 2>&1
check "broken relative markdown link is caught" 1 $?

# 5b. Committed docs/ content full of example links and prose around "](
#     never fails class 4 - plan documents are excluded by design.
mkplugin t5b
mkdir -p "$WORK/t5b/docs/plans"
printf 'A plan. [dead](skills/gone/SKILL.md) and prose with `](` then capture to `)` inline.\n' > "$WORK/t5b/docs/plans/p.md"
( cd "$WORK/t5b" && git add -A && git commit -qm x )
sh "$CHECK" "$WORK/t5b" >/dev/null 2>&1
check "committed plan doc with example links passes" 0 $?

GEN="$ROOT/scripts/generate-inventory.sh"

# 6. The generator rewrites a stale count from the tree, and the result is
#    valid JSON.
mkplugin t6
mkdir -p "$WORK/t6/skills/extra"
printf -- '---\nname: extra\ndescription: Use when extra things happen\n---\nbody\n' > "$WORK/t6/skills/extra/SKILL.md"
sh "$GEN" "$WORK/t6" >/dev/null 2>&1
check "generator run succeeds on a stale tree" 0 $?
grep -q 'Two skills, one agent,' "$WORK/t6/.claude-plugin/plugin.json"
check "plugin.json count regenerated with per-count plurals" 0 $?
grep -q 'two hooks' "$WORK/t6/.claude-plugin/plugin.json"
check "hooks counted from hooks.json entries" 0 $?
grep -q 'two skills, one agent type,' "$WORK/t6/README.md"
check "README marker region regenerated with per-count plurals" 0 $?
python3 -c "import json;json.load(open('$WORK/t6/.claude-plugin/plugin.json'));json.load(open('$WORK/t6/.claude-plugin/marketplace.json'))"
check "surgered manifests still parse as JSON" 0 $?

# 6b. The trigger index is built from each skill's own description: the "Use
#     when " opener is dropped so the table header completes the sentence, and
#     a description that does not open that way is carried through whole.
grep -q '| extra things happen | \[`extra`\](skills/extra/SKILL.md) |' "$WORK/t6/README.md"
check "trigger row drops the Use-when opener" 0 $?
grep -q '| demo | \[`demo`\](skills/demo/SKILL.md) |' "$WORK/t6/README.md"
check "trigger row without the opener is carried through whole" 0 $?
grep -q 'Reach for it when | Skill' "$WORK/t6/README.md"
check "trigger table carries its header" 0 $?

# 7. The generator is idempotent: a second run succeeds and changes nothing.
#    The exit-code check keeps this group from passing vacuously when the
#    generator is missing entirely.
( cd "$WORK/t6" && git add -A && git commit -qm gen )
sh "$GEN" "$WORK/t6" >/dev/null 2>&1
check "second generator run exits 0" 0 $?
( cd "$WORK/t6" && git diff --quiet )
check "second generator run is a no-op" 0 $?

# 7b. A hand-edit inside a marker region is drift, and the generator is what
#     reverts it - the region carries the skill's words, never an editor's.
( cd "$WORK/t6" && sed 's/| extra things happen |/| an editor made this up |/' README.md > R && mv R README.md )
sh "$GEN" "$WORK/t6" >/dev/null 2>&1
grep -q 'an editor made this up' "$WORK/t6/README.md"
check "hand-edited trigger text is regenerated away" 1 $?

# 7c. Missing trigger markers fail loudly, the same as the inventory markers.
mkplugin t7c
sed 's/<!-- triggers -->//;s/<!-- \/triggers -->//' "$WORK/t7c/README.md" > "$WORK/t7c/R"
mv "$WORK/t7c/R" "$WORK/t7c/README.md"
sh "$GEN" "$WORK/t7c" >/dev/null 2>&1
check "missing trigger markers fail the generator" 1 $?

# 8. Prose outside the canonical statements is never touched.
grep -q 'no counts here' "$WORK/t6/.claude-plugin/marketplace.json"
check "top-level marketplace description untouched" 0 $?

# 9. The count guard: a tree whose canonical anchors are missing fails
#    loudly instead of splicing the wrong text.
mkplugin t9
sed 's/<!-- inventory -->//;s/<!-- \/inventory -->//' "$WORK/t9/README.md" > "$WORK/t9/README.tmp"
mv "$WORK/t9/README.tmp" "$WORK/t9/README.md"
sh "$GEN" "$WORK/t9" >/dev/null 2>&1
check "missing markers fail the generator" 1 $?

# 10. The trigger index follows the catalog's order when the README carries
#     one, so the table groups the way the prose does.
mkplugin t10
mkdir -p "$WORK/t10/skills/extra"
printf -- '---\nname: extra\ndescription: Use when extra things happen\n---\nbody\n' > "$WORK/t10/skills/extra/SKILL.md"
printf '\n## What each skill solves\n\n### Kind A\n\n**[`extra`](skills/extra/SKILL.md) - extra.**\n\n### Kind B\n\n**[`demo`](skills/demo/SKILL.md) - demo.**\n\n## After\n' >> "$WORK/t10/README.md"
sh "$GEN" "$WORK/t10" >/dev/null 2>&1
check "generator succeeds with a catalog present" 0 $?
[ "$(grep -o '\[`[a-z]*`\](skills' "$WORK/t10/README.md" | head -2 | tr -d '\n')" = '[`extra`](skills[`demo`](skills' ]
check "trigger rows follow the catalog order, not the alphabet" 0 $?

# 10b. A skill the catalog does not name fails the generator instead of
#      landing at the end of the table unnoticed.
mkdir -p "$WORK/t10/skills/orphan"
printf -- '---\nname: orphan\ndescription: Use when orphaned\n---\nbody\n' > "$WORK/t10/skills/orphan/SKILL.md"
sh "$GEN" "$WORK/t10" >/dev/null 2>&1
check "a skill missing from the catalog fails the generator" 1 $?

# 11. The eval-trend fold. Each case writes a throwaway results directory and
#     reads back the one line the rule under test decides.
TREND="$ROOT/scripts/eval-trend.py"

mkres() { # $1 = directory under $WORK to build a run corpus in
  R="$WORK/$1"
  mkdir -p "$R"
  python3 - "$R" <<'PYEOF'
import json, os, sys
out = sys.argv[1]

def run(judge, version, cases, plugin="delivery-skills"):
    return {"schemaVersion": 1, "partial": False,
            "suite": {"judgeModel": judge, "ablation": "with-without",
                      "plugins": [{"name": plugin, "version": version}]},
            "cases": cases}

def rep(graders, error=None, skipped=False):
    return {"error": error, "skippedPaidGraders": skipped, "graders": graders}

def g(name, passed, scored=True, expl=""):
    return {"name": name, "passed": passed, "scored": scored, "explanation": expl}

def case(name, w, wo):
    return {"name": name, "arms": {"with": w, "without": wo}}

files = {
    # an earlier release where the grader held
    "old": run("sonnet", "1.0.0", [case("case-a",
        [rep([g("keeps-the-thing", True)]) for _ in range(3)],
        [rep([g("keeps-the-thing", False)]) for _ in range(3)])]),
    # the next release: the grader slid, one run was curtailed, one grader was
    # skipped at the cost ceiling, and one is an arm-only indicator
    "new": run("sonnet", "1.1.0", [case("case-a",
        [rep([g("keeps-the-thing", True)]),
         rep([g("keeps-the-thing", False)]),
         rep([g("keeps-the-thing", False)]),
         rep([g("keeps-the-thing", False)], error="exit 1: Reached maximum number of turns (30)"),
         rep([g("keeps-the-thing", False, expl="skipped: cost ceiling")], skipped=True),
         rep([g("indicator", True, scored=False)])],
        [rep([g("keeps-the-thing", False)]) for _ in range(3)])]),
    # graded by the default judge, so not comparable with the rows above
    "default": run(None, "1.1.0", [case("case-a",
        [rep([g("keeps-the-thing", True)])], [rep([g("keeps-the-thing", True)])])]),
    # a judge-calibration probe: another plugin, another case
    "probe": run("sonnet", "0.0.1", [case("probe",
        [rep([g("x", True)])], [rep([g("x", False)])])], plugin="judge-calibration-probe"),
    # flags skipped graders but carries no marker on any of them
    "quiet": run("sonnet", "1.1.0", [case("case-b",
        [rep([g("y", False)], skipped=True)], [rep([g("y", False)])])]),
}
for name, data in files.items():
    with open(os.path.join(out, name + ".json"), "w") as fh:
        json.dump(data, fh)
PYEOF
  python3 "$TREND" --dir "$R" > "$R/out.txt" 2>&1
}

mkres t11
check "eval-trend runs over a corpus" 0 $?

grep -Eq '1\.1\.0 +1/3 +0/3 +\+33 +-67' "$WORK/t11/out.txt"
check "a grader that slid between releases shows the drop" 0 $?

grep -q '2 unmeasured' "$WORK/t11/out.txt"
check "a curtailed run and a ceiling-skipped grader are unmeasured, not failed" 0 $?

grep -q 'indicator' "$WORK/t11/out.txt"
check "an arm-only indicator is left out of the fold" 1 $?

grep -q 'default.json .*judged by the default judge' "$WORK/t11/out.txt"
check "a default-judged run is excluded by name and reason" 0 $?

grep -q 'probe.json .*not this suite' "$WORK/t11/out.txt"
check "a run of another plugin is excluded" 0 $?

grep -q 'WARNING:.*no grader carries the skip marker' "$WORK/t11/out.txt"
check "a skip the marker no longer matches warns instead of counting" 0 $?

echo
if [ $fails -eq 0 ]; then
  echo "ALL PASS"
  exit 0
fi
echo "$fails test(s) failing"
exit 1
