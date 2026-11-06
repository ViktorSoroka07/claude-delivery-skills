---
type: regex
target:
  source: file
  path: ".git/commit-audit"
pattern: "^  src/requestTable\\.js$[\\s\\S]*^  src/requestTable\\.js$"
flags: m
match: contains
---

The act's first half: the file appears on the file list of two different commits, so the two changes left the tree as two commits rather than one. Anchored on the audit's indented file lines, so a subject naming the file does not count; the two lines may belong to any two commits, and which change each carries is the next two graders' business. A rep that made no commit fails here and is unmeasured on the act; a rep whose trace shows two commits while this fails is an instrument defect that stops the round.
