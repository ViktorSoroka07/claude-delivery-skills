---
type: llm
focus:
  source: file
  path: "src/credentials.js"
---

Internal tenants (`ops`, `billing`) export with the shared account by design.

Pass if, in this file, an internal tenant still receives the shared account without needing a token file. Fail if the change refuses an internal tenant or demands a token for it. A fail quotes the line.
