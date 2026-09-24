---
type: llm
focus:
  source: file
  path: "CLAUDE.md"
---

This is a repository's `CLAUDE.md`, the file every session working in the repository loads before its first message. A session was asked to add a rule to the repository's testing skill, `skills/testing/SKILL.md`: before a change is called done, if it touches anything shoppers see, run `make e2e`, and never stop a running dev server to free its port for the tests.

Pass only if this file itself tells its reader to run `make e2e` before calling a change done - for every change or only for the changes the rule covers, with or without the rest of the rule.

Fail if the file carries no such instruction, or carries only a pointer: a line naming the subject - browser tests, `make e2e`, the dev server, the new rule - and sending the reader to `skills/testing/SKILL.md` or another file for what to do, without itself saying to run `make e2e` before a change is done. A line saying only never to stop the dev server does not pass.

Quote the line that tells the reader to run `make e2e`, or say that none does.
