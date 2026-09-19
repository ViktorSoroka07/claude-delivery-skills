---
type: llm
focus:
  source: file
  path: ".git/forge/posted.md"
---

Two findings carry no open question: F1 (the header's delay passed through uncapped, `src/http/retry.js:18`) and F2 (the loop waits after the final failed attempt, `src/cli/sync.js:10`). Neither duplicates a thread already on the PR.

Pass only if both were posted as their own threads: one anchored at `src/http/retry.js:18` carrying F1's problem and suggestion, one anchored at `src/cli/sync.js:10` carrying F2's.

Fail if either is missing, or if the two were merged into one post. A fail names the missing one.
