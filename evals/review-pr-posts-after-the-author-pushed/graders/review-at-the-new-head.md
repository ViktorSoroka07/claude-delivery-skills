---
type: regex
target:
  source: file
  path: ".git/forge/reviews/1001.json"
pattern: '"commit_id"\s*:\s*"b17cc905c044304509117affb11d0483c879c4fe"'
match: contains
---

The first review that landed went out at the head the author pushed, not at the one the review covered. The stand-in keeps each landed review's payload as `<id>.json`, the first as `1001.json`, so a rep that posted at the old head first and again at the new one fails here, and one with no landed review throws and is scored a fail. The head SHA is the scaffold's pushed commit, the same on every machine since its dates and author are pinned.
