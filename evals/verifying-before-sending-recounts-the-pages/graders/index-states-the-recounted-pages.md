---
type: regex
target:
  source: file
  path: "docs/index.md"
pattern: '^(?=[\s\S]*\b(?:four|4)\b(?:\s+\S+){0,2}\s+pages\b)|^(?![\s\S]*\b(?:three|3)\b(?:\s+\S+){0,2}\s+pages\b)'
flags: i
match: contains
---

The act: the index leaves the run with its page count recomputed from the four pages it lists. The pattern passes on either of two shapes - the index states four pages ("four pages", "4 documentation pages"), or it states no "three pages" at all, the sentence rewritten without a count. It fails an index still saying three pages with no four beside it. Without `m`, both `^` anchor the start of the file. An index the run deleted throws and fails, and one that dropped the fourth line to make three true is failed by `index-keeps-the-dead-letters-line`.
