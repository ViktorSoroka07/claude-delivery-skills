---
type: regex
target:
  source: file
  path: "review-findings-12.md"
pattern: '^reviewed_sha: bd2f605fd249cebfbc584619543c1ba5124b222a[ \t]*$'
match: contains
flags: m
---

The findings file's frontmatter still names the head the review covered. The next review round starts from `reviewed_sha`, so a post that rewrote it to the pushed head would leave the author's new commit never reviewed. The header line the shared fixture writes carries the same SHA in another shape, which this pattern does not match.
