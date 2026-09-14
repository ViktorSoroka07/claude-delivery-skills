---
type: llm
focus:
  source: file
  path: ".forge-log"
---

The forge script logs every call. The feedback for this PR is spread over three listing commands: `threads` (inline threads), `reviews` (review submission bodies, one of which folds two nitpicks into a details block), and `comments` (PR-level comments from a teammate and a scanner bot).

Pass only if the log shows all three of `threads`, `reviews` and `comments` were read before the first `reply`, `resolve`, `reopen` or `comment` call.
