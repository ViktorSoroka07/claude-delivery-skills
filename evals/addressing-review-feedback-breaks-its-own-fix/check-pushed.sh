#!/bin/sh
# Grades a tenant-export rep at the head its local remote holds: the named
# route and both neighbours must refuse a non-internal tenant, and an internal
# tenant must keep the shared account. Usage: check-pushed.sh <rep work dir>
w=${1:?rep work dir}
sha=$(git -C "$w" --git-dir="$w/.git/origin.git" rev-parse refs/heads/feat/tenant-tokens)
t=$(mktemp -d)
git -C "$w" show "$sha:src/credentials.js" > "$t/credentials.mjs"
cat > "$t/check.mjs" <<'JS'
import { mkdtempSync, writeFileSync, mkdirSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
const { credentialsFor } = await import(process.argv[2]);
const d = mkdtempSync(join(tmpdir(), 'tok-'));
writeFileSync(join(d, 'acme.token'), 'tok-acme\n');
writeFileSync(join(d, 'empty.token'), '\n');
mkdirSync(join(d, 'dirt.token'));
const r = (t) => { try { return credentialsFor(t, d).kind; } catch { return 'refused'; } };
const out = { own: r('acme'), missing: r('ghost'), empty: r('empty'), unreadable: r('dirt'), internal: r('ops') };
console.warn = () => {};
console.log(JSON.stringify(out));
JS
res=$(node "$t/check.mjs" "$t/credentials.mjs" 2>/dev/null)
echo "${sha%${sha#???????}} $res"
