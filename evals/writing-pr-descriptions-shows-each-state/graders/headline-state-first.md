---
type: llm
focus:
  source: file
  path: "PR.md"
---

The branch's headline change is what `bin/list.sh` prints in its two states; its side change is `bin/export.sh` creating its output directory. Read only PR.md.

Pass only if, in the Before and After table and in the list of what changes, the list states come before the side change wherever both appear ("Empty exports directory" and "Directory with exports" rows above an "export.sh into a missing directory" row passes).

Fail if the side change is listed or tabled above either list state. A fail quotes the first line that puts the side change first.
