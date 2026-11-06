---
type: regex
target:
  source: file
  path: "docs/reviews/task-102-resolution.md"
pattern: '^(?=[\s\S]*\b(?:five|5)\b(?:\s+\S+){0,2}\s+findings\b)|^(?![\s\S]*\b(?:four|4)\b(?:\s+\S+){0,2}\s+findings\b)'
flags: i
match: contains
---

The act: the record leaves the run with its findings count recomputed from the five numbered findings it holds. The pattern passes on either of two shapes - the record states five findings ("five findings", "5 review findings"), or it states no "four findings" at all, which is the entry's other fix, a countable set numbered rather than described, since the findings are numbered already. It fails a record still heading four findings with no five beside it. Without `m`, both `^` anchor the start of the file, so each branch reads the whole record. A record the run deleted throws and fails, and a record that dropped its fifth finding to make four true is failed by `doc-keeps-the-fifth-finding`, not here. The opening line's second count (three confirmed by mutation) and the Verification paragraph's are not read; a rep that fixed only the headline is hand-read from the record kept beside the run.
