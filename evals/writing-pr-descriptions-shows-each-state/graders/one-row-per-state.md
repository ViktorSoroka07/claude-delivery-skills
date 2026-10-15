---
type: llm
focus:
  source: file
  path: "PR.md"
---

The branch changes what `bin/list.sh` prints in two states: an exports directory with nothing in it, and one holding exports. Read only PR.md.

Pass only if it has a table setting the earlier behaviour against the later one - its columns headed Before and After, Old and New, Was and Now or the like - with a row for the empty directory and a separate row for a directory holding exports, each row with an earlier and a later cell saying what that state printed or prints: the output itself, or a sentence saying what it shows ("prints nothing" | "`No exports yet - run bin/export.sh ...`" is an empty-state row).

Fail if there is no such table, if the two states share one row, or if either state has no row. A fail quotes the row it fails on, or says which state has none.
