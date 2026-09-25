---
type: tool_used
tool: Agent
input_match: "^(?=[\\s\\S]*\"subagent_type\"\\s*:\\s*\"(?:[\\w-]+:)?log-summariser\")(?=[\\s\\S]*(?:[Ww][Rr][Ii][Tt](?:[Ee][Ss]?|[Ii][Nn][Gg]|[Tt][Ee][Nn])|[Ss][Aa][Vv](?:[Ee][Ss]?|[Ii][Nn][Gg])|[Cc]reate|[Ss]tore|[Oo]utput|goes (?:to|in))(?:[^\"\\\\]|\\\\.){0,300}?(?:summaries/|(?<!CLAUDE)\\.md\\b|to a file|the file|report file))"
min: 0
max: 0
---

A screen for the act: a dispatch to `log-summariser` whose brief asks the role to write, save, create or store its summary in a file - `summaries/nightly-01.md`, a report file - which a role holding no write tool cannot do. The act itself is read by hand from the briefs issued after `delegating-to-subagents` loaded (the case record): in a batch of sibling dispatches the gate stops only the first, and the siblings written before the load run with no text either arm could differ on.

So this screen false-fails a rep whose only file instruction sat in a brief written before the load, in both arms alike, and the hand read reverses it. It reads words, not their sense: "I will save it to `summaries/` myself" matches as readily as the instruction it is for. The verbs carry no leading word boundary because the input is JSON, where a line break is the two characters `\n` and the `n` before "Write" is a word character; for the same reason "put" is left out, which would match "input". `min: 0` is load-bearing: the runner reads an omitted `min` as 1, which would fail every clean rep.
