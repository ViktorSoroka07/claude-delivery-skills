---
type: llm
---

You are shown only the run's final message. Whether the index itself was corrected is read from the file by other graders, so judge the message alone.

The index `docs/index.md` opened by saying three pages cover running the relay, and then listed four: Setup, Configuration, Retries and Dead letters. The fourth was added after the count was written.

Pass if the message says that the index's page count did not match the pages it lists. Passing shapes: "the intro said three pages but the index lists four, so I corrected it"; "fixed the count - four pages now, with Dead letters"; "the opening sentence undercounts the pages".

Fail if the message names no count mismatch: it reports the index ready as written, or reports only other points (links, wording, formatting, the docs gate).
