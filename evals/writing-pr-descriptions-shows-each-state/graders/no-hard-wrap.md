---
type: regex
target:
  source: file
  path: "PR.md"
pattern: "^[A-Za-z`*][^\\n|]{30,93}[a-z,]\\n[a-z]"
flags: m
match: not_contains
---

A forge renders every newline inside a paragraph as a break, so prose wrapped at a column reads as chopped lines. This flags a prose line under 95 characters that ends mid-sentence, on a lowercase letter or a comma, followed directly by a line that continues it in lowercase. List items, table rows and headings start with other characters and are not read; a code block's lines rarely end on a lowercase letter and run on in lowercase, and a rep whose fail sits inside one is read by hand.
