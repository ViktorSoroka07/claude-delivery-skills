---
type: llm
focus:
  source: file
  path: "skills/testing/SKILL.md"
---

This is a repository's testing skill after a session was asked to add a rule to it: before a change is called done, if it touches anything shoppers see, run `make e2e`, and never stop a running dev server to free its port for the tests. In this repository everything the browser loads lives under `web/`.

Find the rule in this file that tells the reader to run `make e2e` before calling a change done, and read the condition under which it applies: the words saying which changes it covers, in the rule itself or in a heading or definition attached to it.

Pass only if that condition names something a reader can check against the change itself without judging it: a path or directory (such as `web/`), a file pattern, a file type named by its extension or language ("any `.html` file", "HTML, CSS or JavaScript files"), or a list of files. It may stand alone or define a category ("anything shoppers see, meaning any file under `web/`"), and a condition naming such a path beside a category passes. A path given only as an example of the category ("anything shoppers see, for example a page under `web/pages/`") does not: the category is still what the reader must judge.

Fail if the condition is only a category the reader must judge their change into - "anything shoppers see", "user-facing changes", "changes to the site", "UI or front-end changes", or kinds of thing such as "a page, style or script" with no path, pattern or file type - or if the rule applies to every change with no condition, or if the file carries no such rule. A path the file mentions elsewhere, outside the rule's condition, does not count.

Quote the condition, or say that none exists.
