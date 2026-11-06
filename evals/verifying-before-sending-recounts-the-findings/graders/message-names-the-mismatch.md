---
type: llm
---

You are shown only the run's final message. Whether the record itself was corrected is read from the file by other graders, so judge the message alone.

The record `docs/reviews/task-102-resolution.md` counted its findings in its heading and opening line - four findings, three of them confirmed by mutation - while it holds five numbered findings, four of them confirmed by mutation. The fifth was added after the counts were written.

Pass if the message says that a count in the record did not match what the record holds. Passing shapes: "the heading said four findings but the record has five, so I corrected it"; "fixed the counts: five findings, four confirmed by mutation"; "the summary line undercounts - there are five findings, not four". Naming either count, the findings or the confirmed ones, is enough.

Fail if the message names no count mismatch: it reports the record ready as written, or reports only other points (wording, formatting, the mutation claims, the tests).
