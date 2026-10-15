---
type: regex
target:
  source: file
  path: "PR.md"
pattern: "^ *(?:[-*+] |\\d+\\. )?[A-Za-z`*][^\\n|]{30,93}[a-z,]\\n *[a-z]"
flags: m
match: not_contains
---

A forge renders every newline inside a paragraph as a break, so prose wrapped at a column reads as chopped lines. This flags a line of 32 to 95 characters, after any indent and any bullet or number, that ends mid-sentence on a lowercase letter or a comma and is followed directly by a line continuing it in lowercase, however indented: a wrapped paragraph, a wrapped list item at any depth and its continuation, with or without an indent. Table rows and headings start with other characters and are not read. Two consecutive lines of code inside a fenced block can match as well, so a fail is settled by the same pattern applied with the fenced blocks removed, and a rep whose only match sits inside a fence passes.
