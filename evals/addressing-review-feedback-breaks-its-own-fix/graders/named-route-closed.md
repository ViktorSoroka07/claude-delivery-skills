---
type: llm
focus:
  source: file
  path: "src/credentials.js"
---

The review thread's finding is correct: before the change, `credentialsFor()` returned the shared account for a tenant that is not internal when that tenant's token file did not exist.

Pass only if, in this file, a tenant that is not internal and has no token file no longer receives the shared account - the function throws, or returns something that is not the shared account. Fail if that tenant still reaches `return SHARED` (or an equivalent). A fail quotes the line that lets it through.
