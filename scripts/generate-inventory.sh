#!/bin/sh
# Regenerates the canonical component-inventory statements (README marker
# region, plugin.json description, marketplace.json plugin description) from
# the tree, so the counts are never hand-written. String surgery only - a
# json round-trip is not byte-stable against this repo's compact formatting.
# Optional $1 = tree root. CI pairs this with 'git diff --exit-code'.
set -u
ROOT=${1:-$(cd "$(dirname "$0")/.." && pwd)}
exec python3 - "$ROOT" <<'PYEOF'
import json
import os
import re
import sys

root = sys.argv[1]

WORDS = {1: "one", 2: "two", 3: "three", 4: "four", 5: "five", 6: "six",
         7: "seven", 8: "eight", 9: "nine", 10: "ten", 11: "eleven",
         12: "twelve", 13: "thirteen", 14: "fourteen", 15: "fifteen",
         16: "sixteen", 17: "seventeen", 18: "eighteen", 19: "nineteen",
         20: "twenty"}


def word(n):
    return WORDS.get(n, str(n))


skills = sorted(d for d in os.listdir(os.path.join(root, "skills"))
                if os.path.isfile(os.path.join(root, "skills", d, "SKILL.md")))
agents = sorted(f for f in os.listdir(os.path.join(root, "agents"))
                if f.endswith(".md"))
with open(os.path.join(root, "hooks", "hooks.json")) as fh:
    hooks_cfg = json.load(fh)
hooks = sum(len(m.get("hooks", []))
            for ev in hooks_cfg.get("hooks", {}).values() for m in ev)

def noun(n, singular):
    return "%s %s%s" % (word(n), singular, "" if n == 1 else "s")


def description(name):
    """The skill's own trigger sentence. Read from the file rather than
    restated, so the index below carries the owner's words and cannot drift
    from them."""
    path = os.path.join(root, "skills", name, "SKILL.md")
    with open(path) as fh:
        for line in fh:
            if line.startswith("description:"):
                return line[len("description:"):].strip()
    sys.exit("skills/%s/SKILL.md: no description: line in frontmatter" % name)


def trigger_row(name):
    d = description(name)
    prefix = "Use when "
    trigger = d[len(prefix):] if d.startswith(prefix) else d
    return "| %s | [`%s`](skills/%s/SKILL.md) |" % (trigger, name, name)


s, a, h = len(skills), len(agents), hooks


def surgery(path, pattern, replacement, validate_json):
    p = os.path.join(root, path)
    with open(p) as fh:
        text = fh.read()
    new, n = re.subn(pattern, replacement, text)
    if n != 1:
        sys.exit("%s: expected exactly 1 canonical statement, found %d" % (path, n))
    if new != text:
        with open(p, "w") as fh:
            fh.write(new)
        print("regenerated: %s" % path)
    if validate_json:
        with open(p) as fh:
            json.load(fh)


surgery(
    "README.md",
    r"<!-- inventory -->.*?<!-- /inventory -->",
    "<!-- inventory -->%s, %s, and %s<!-- /inventory -->"
    % (noun(s, "skill"), noun(a, "agent type"), noun(h, "hook")),
    False,
)
surgery(
    ".claude-plugin/plugin.json",
    r'"description": "[^"]*merged PR[^"]*"',
    json.dumps("description") + ": " + json.dumps(
        "%s, %s, and %s that harden the path "
        "from idea to merged PR - plans ground-truthed before building, tests "
        "proven able to fail, subagent output treated as claims, outbound "
        "text verified before it ships."
        % (noun(s, "skill").capitalize(), noun(a, "agent"), noun(h, "hook"))),
    True,
)
surgery(
    ".claude-plugin/marketplace.json",
    r'"description": "[^"]*merged PR[^"]*"',
    json.dumps("description") + ": " + json.dumps(
        "%s, %s, and %s that harden the path from idea to merged PR."
        % (noun(s, "skill").capitalize(), noun(a, "agent"), noun(h, "hook"))),
    True,
)
def catalog_order(names):
    """The README's catalog groups the skills by kind; the trigger index
    follows that order so adjacent rows are related, and a skill the catalog
    does not mention fails here rather than landing at the end unnoticed. A
    README with no catalog section keeps the alphabetical order."""
    with open(os.path.join(root, "README.md")) as fh:
        text = fh.read()
    m = re.search(r"(?ms)^## What each skill solves\n(.*?)(?=^## )", text)
    if not m:
        return names
    listed = []
    for n in re.findall(r"\*\*\[`([a-z0-9-]+)`\]", m.group(1)):
        if n not in listed:
            listed.append(n)
    missing = [n for n in names if n not in listed]
    if missing:
        sys.exit("README.md: the catalog under '## What each skill solves' "
                 "does not name: %s" % ", ".join(missing))
    return [n for n in listed if n in names]


rows = "\n".join(trigger_row(n) for n in catalog_order(skills))
surgery(
    "README.md",
    r"(?s)<!-- triggers -->.*?<!-- /triggers -->",
    lambda m: "<!-- triggers -->\n\n| Reach for it when | Skill |\n|---|---|\n%s\n\n<!-- /triggers -->" % rows,
    False,
)
print("inventory: %d skills, %d agents, %d hooks" % (s, a, h))
PYEOF
