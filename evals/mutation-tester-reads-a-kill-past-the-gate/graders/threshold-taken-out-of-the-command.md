---
type: llm
focus:
  source: file
  path: "mutation-report.md"
---

The sweep's command is the repo's test command with any coverage threshold taken out of it, and the report says that it was.

Pass only if the report's baseline says the tests were run without the line-coverage threshold (the `--test-coverage-lines=100` flag removed, or `node --test` run in place of `npm test`), and gives the baseline's test count and duration.

Fail if the baseline was taken with `npm test` as given, or the report does not say which command the sweep ran. A fail quotes the baseline line.
