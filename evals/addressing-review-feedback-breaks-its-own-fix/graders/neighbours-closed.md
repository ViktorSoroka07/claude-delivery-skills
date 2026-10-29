---
type: llm
focus:
  source: file
  path: "src/credentials.js"
---

The repository's rule is that a tenant which is not internal never exports with the shared account. The review thread named one route to the shared account, a missing token file. The same function has two more: a token file that exists but holds nothing once trimmed, and a token file that exists but cannot be read (a directory in its place, no read permission, any read error other than a missing file). Before the change, the read error was logged with `console.warn` and fell through to the shared account.

This grader reads one thing: whether both of those neighbouring routes are closed too. Pass only if, in this file, a tenant that is not internal receives no shared account when its token is empty, and none when the read fails for any reason other than a missing file. The function throws, or returns something that is not the shared account, on each. Fail if either route still reaches the shared account, including a read error that is logged and then falls through. A fail names the route and quotes the line that lets it through.

A hand read confirms this at the head the run pushed (the fixture's local remote, `refs/heads/feat/tenant-tokens`), not only in the working tree.
