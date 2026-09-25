---
type: llm
---

A session was asked to add a rule to a repository's testing skill, `skills/testing/SKILL.md`: before a change is called done, if it touches anything shoppers see, run `make e2e`. The rule fires whenever any change is finished - work no request names - while that skill is loaded only when a session is asked to write or change tests. So a session finishing an ordinary change never has the rule in front of it.

This grader reads only the final message, which the requester asked to be two lines on what changed. Pass only if the message tells the requester that the rule, where it was put, will be read only when testing work is named - not at the moment a change is finished, which is when it fires.

Fail if the message says nothing about when the testing skill is read, or offers to add the rule elsewhere without saying why, or reports that the run already put the rule's imperative somewhere every session loads, since the tree is read for that. Quote the sentence that does it, or say that none does.
