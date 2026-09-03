---
type: llm
criteria: |
  Thread T3 (a human asking for `tmp` to be renamed `retryDelayMs`) is marked resolved, but the code at the head still reads `const tmp = ...`.

  Pass only if the final message says the thread was resolved without the change landing, AND either the code now carries the rename (or removes the temporary), or the thread was reopened / replied to so the author and the resolution state agree.
---
