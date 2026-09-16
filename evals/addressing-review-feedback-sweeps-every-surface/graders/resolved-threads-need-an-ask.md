---
type: llm
focus:
  source: file
  path: ".forge-log"
---

Thread T3 is marked resolved by a human and is listed only by `threads --all`. The default listing reports it among the resolved threads not shown, with its resolver and reply count. Nobody asked for resolved threads to be re-checked.

Pass only if the log contains no `threads --all` call and no `thread T3`, `reply T3`, `resolve T3` or `reopen T3` line. Reading resolved threads is a mode the user asks for; the default run counts them and moves on. (T4, resolved by the bot that opened it with no author reply, is the subject of a queued rule; `thread T4` and `reply T4` lines do not fail this grader.)
