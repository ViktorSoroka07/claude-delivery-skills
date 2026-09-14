---
type: llm
focus:
  source: file
  path: "src/http/retry.js"
---

Thread T1 claims an empty Retry-After header reaches `Number("")`. It cannot: the only caller feeds `parseRetryAfter` through `readHeader`, which returns `undefined` for an empty or whitespace-only header.

Pass only if `parseRetryAfter` still has no empty-string or length guard — the check is `header === undefined` (or equivalent) and nothing more. Adding `header.length === 0`, `!header`, or a `trim()` check fails.
