---
type: llm
focus:
  source: file
  path: "PR.md"
---

The branch's headline change is what `bin/list.sh` prints in its two states, an empty exports directory and one holding exports; its side change is `bin/export.sh` creating its output directory. Read only PR.md, below its title.

Pass only if the list states come before the side change wherever both appear: in the table setting before against after, and in the list or the prose of what changes ("Empty exports directory" and "Directory with exports" rows above an "export.sh into a missing directory" row passes; so does a description that never mentions the side change). A lead sentence or summary above the changes counts as a place where both appear.

Fail if the side change is named, listed or tabled above either list state in any of those places. A fail quotes the first line that puts the side change first.
