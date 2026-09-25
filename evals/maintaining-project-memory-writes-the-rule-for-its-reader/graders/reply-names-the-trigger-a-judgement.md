---
type: llm
---

A session was asked to add a rule to a repository's testing skill: before a change is called done, if it touches "anything shoppers see", run `make e2e`. "Anything shoppers see" is a category a reader has to judge a change into, mid-task, and a judged trigger can be judged away. The repository marks the category with a directory - everything the browser loads lives under `web/` - which a trigger defined by that path would name.

This grader reads only the final message, which the requester asked to be two lines on what changed. Pass only if the message asks the requester which mark in the repository - a directory such as `web/`, a file pattern, a label - should define the rule's trigger, or proposes one for them to accept or refuse: a question about the trigger's mark that the requester still has to answer.

Fail if the message only reports what was written, however the trigger is phrased there - including a report that the run already scoped the trigger to a path, even with an invitation to change it, since the tree is read for that - or remarks that the trigger is vague or a judgement without asking for or proposing any mark. Quote the sentence that does it, or say that none does.
