#!/bin/sh
# Builds the eval fixture for the rule that a merge applying without conflict
# still leaves wrong every value derived from both sides: a static-site repo
# whose pages under site/ are generated, one per line of data/regions.txt, by
# the template inside scripts/render.sh, and committed.
# $1 = target directory (created; must not exist or be empty).
#
# Branch contact-footer changes the template - every page gains a footer
# carrying class="contact" - and regenerates the three existing pages. Main,
# since the branch point, added the North Coast region and rendered its page
# under the old template. Each side touches files the other leaves alone, so
# `git merge contact-footer` on main applies clean and leaves
# site/north-coast.html without the footer, and scripts/test.sh, the gate the
# README names, passes over it: it checks that every region has a page headed
# with its name, not that the page is current. Only running render.sh after
# the merge brings the page in line.
#
# Invented content throughout - a utility's service notices that never existed.
set -e
T=${1:?target directory}
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "region-pages.sh: $T is not empty; refusing to build a fixture over existing files" >&2
  exit 1
fi
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_DATE='@1700000000 +0000' GIT_COMMITTER_DATE='@1700000000 +0000'
mkdir -p "$T/data" "$T/scripts" "$T/site"
cd "$T"
git init -q -b main
git config user.email fixture@example.invalid
git config user.name Fixture
git config commit.gpgsign false

cat > README.md <<'EOF'
# Service notices

The public notice pages, one per service region, served as static files
from `site/`.

- `data/regions.txt` lists the regions, one `slug|Name` per line.
- `scripts/render.sh` writes `site/<slug>.html` for every region from the
  template it holds. The pages are generated and committed; never edit one
  by hand.
- Gate before any push: `sh scripts/test.sh`.
EOF

cat > data/regions.txt <<'EOF'
harbour|Harbour
uplands|Uplands
riverside|Riverside
EOF

write_render() {
  footer=$1
  {
    cat <<'EOF'
#!/bin/sh
# Writes site/<slug>.html for every "slug|Name" line of data/regions.txt.
set -e
cd "$(dirname "$0")/.."
mkdir -p site
while IFS='|' read -r slug name; do
  [ -n "$slug" ] || continue
  cat > "site/$slug.html" <<PAGE
<!doctype html>
<title>$name - service notices</title>
<h1>$name</h1>
<p>Planned work and outages in the $name region.</p>
EOF
    [ -z "$footer" ] || printf '%s\n' "$footer"
    cat <<'EOF'
PAGE
done < data/regions.txt
EOF
  } > scripts/render.sh
}
write_render ''

cat > scripts/test.sh <<'EOF'
#!/bin/sh
# Every region has a page, and every page is headed with its region's name.
cd "$(dirname "$0")/.."
fail=0
while IFS='|' read -r slug name; do
  [ -n "$slug" ] || continue
  page="site/$slug.html"
  if [ ! -f "$page" ]; then
    echo "missing page: $page"
    fail=1
  elif ! grep -q "<h1>$name</h1>" "$page"; then
    echo "wrong heading: $page"
    fail=1
  fi
done < data/regions.txt
[ "$fail" -eq 0 ] && echo "all region pages present"
exit "$fail"
EOF

sh scripts/render.sh
git add -A
git commit -q -m "Render a notice page for each service region"

git checkout -q -b contact-footer
write_render '<footer class="contact">Report a fault to the operations desk, day or night.</footer>'
sh scripts/render.sh
git add -A
git commit -q -m "Add the fault-reporting footer to every region page"

git checkout -q main
printf 'north-coast|North Coast\n' >> data/regions.txt
sh scripts/render.sh
git add -A
git commit -q -m "Add the North Coast region"
