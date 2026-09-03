---
type: llm
target:
  source: file
  path: "src/http/retry.js"
criteria: |
  Thread T3 (rename `tmp` to `retryDelayMs`) is resolved and was not re-checked because nobody asked. Pass only if `retryDelayFor` still declares `const tmp` — the rename was not applied.
---
