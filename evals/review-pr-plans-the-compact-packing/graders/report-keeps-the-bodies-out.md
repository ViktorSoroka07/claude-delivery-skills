---
type: llm
---

The findings live in the file. The closing report carries the file path, the counts, and at most a one-line index of the findings: title and grade only.

An index line may carry a finding's title, its grade, its id and its `file:line` anchor. A sentence saying which draft was refuted and why is a verdict, not a finding's body, and is allowed. What is not allowed is the finding's Problem or Suggestion retold: what goes wrong, why it matters, what to change.

Pass only if the final message names `review-findings-7.md` and gives the verdict counts (seven confirmed, one refuted, or the same in other words), and restates no finding's Problem or Suggestion text.

Fail if the message reproduces a Problem or Suggestion body, or omits the file path or the counts. A fail quotes the sentence it fails on.
