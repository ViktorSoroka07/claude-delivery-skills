---
type: regex
pattern: "(?i)reviewer|after the demo|as requested|per (our|the) discussion|while (I was )?in there|also (fixed|tightened|touches|updated)"
match: not_contains
---

The prompt hands the agent a story: who asked, when, and what else got done on the way. None of it belongs in the message. The last message quotes the commit bodies, so the patterns are checked there.
