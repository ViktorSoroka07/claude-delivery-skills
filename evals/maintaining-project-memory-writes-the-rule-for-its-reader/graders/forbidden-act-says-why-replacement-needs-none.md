---
type: llm
focus:
  source: file
  path: "skills/testing/SKILL.md"
---

This is a repository's testing skill after a session was asked to add a rule to it: before a change is called done, if it touches anything shoppers see, run `make e2e`, and never stop a running dev server to free its port for the tests - run `make e2e` with the server left up. A reader who believes the browser tests need the dev server's port (8080) stops the server anyway unless the rule tells them why they need not. In this repository `make e2e` starts a server of its own on a free port for each run.

Pass only if the rule that forbids stopping the dev server tells the reader what `make e2e` itself runs on that makes the dev server's port unneeded: that it starts or runs a server of its own ("its own copy of the site"), or that it picks a free port or a port of its own. The reason counts where it is given with the prohibition - in its sentence, its bullet or its paragraph; a fact about the suite's server stated elsewhere in the file, such as in a list of the suites, does not.

Fail if the file forbids stopping the dev server and says to run `make e2e` with it up, but says nothing about the server or port `make e2e` uses. That includes a file stating only the harm stopping the server does, and one asserting only that the two can run together ("it runs fine alongside the dev server", "they don't conflict", "there is no need to free the port", "it doesn't use port 8080") without saying what `make e2e` runs on instead. Fail too if the file carries no such prohibition.

Quote the sentence that says what `make e2e` runs on, or say that none does.
