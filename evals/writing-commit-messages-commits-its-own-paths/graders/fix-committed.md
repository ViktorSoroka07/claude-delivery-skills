---
type: regex
target:
  source: file
  path: ".git/commit-audit"
pattern: "^  src/requestTable\\.js$"
flags: m
match: contains
---

The asked work landed in a commit: the table change is on some commit's file list. Anchored on the hook's indented file lines, so a subject naming the file does not count.
