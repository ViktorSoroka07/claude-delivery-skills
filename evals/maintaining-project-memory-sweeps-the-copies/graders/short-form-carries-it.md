---
type: regex
target:
  source: file
  path: "CLAUDE.md"
pattern: "^[-*][ \\t]+(?:(?!\\n[ \\t]*\\n|\\n[-*][ \\t]|\\n#)[\\s\\S])*?hand-?(?:over|off)(?:(?!\\n[ \\t]*\\n|\\n[-*][ \\t]|\\n#)[\\s\\S])*?(?:\\broll(?:s|ed|ing)?(?:[ -]?back|(?: \\w+){1,3} back)\\b|\\brevert|\\bundo|revers(?:e|es|ed|ing|al|ible)\\b|\\bback(?:s|ed|ing)?[ -]out\\b|\\bback(?: \\w+){1,2} out\\b)|^[-*][ \\t]+(?:(?!\\n[ \\t]*\\n|\\n[-*][ \\t]|\\n#)[\\s\\S])*?(?:\\broll(?:s|ed|ing)?(?:[ -]?back|(?: \\w+){1,3} back)\\b|\\brevert|\\bundo|revers(?:e|es|ed|ing|al|ible)\\b|\\bback(?:s|ed|ing)?[ -]out\\b|\\bback(?: \\w+){1,2} out\\b)(?:(?!\\n[ \\t]*\\n|\\n[-*][ \\t]|\\n#)[\\s\\S])*?hand-?(?:over|off)"
match: contains
flags: mi
---

The fixture's `CLAUDE.md`, the file every session in the repository loads first, carries a one-bullet short form of what a hand-over note carries, with a pointer to the skill for the full rule. The prompt adds a fourth item and names only the skill's owner section, so a short form left alone is the copy a reader relies on without opening the owner, reading as complete while wrong. This passes only where one bullet names both a hand-over (or handoff) and the new item - a word for undoing a change (roll back, rollback, revert, undo, reverse, back out) - in either order, its wrapped lines included. A short form cut to a pointer at the skill fails: its readers do not open the owner, which is why it is a short form.

The window ends at the next bullet, blank line or heading, so the item added to another bullet (the dates rule, a new bullet about shipping behind flags) does not count. It was tested on nine hand-written trees from both sides of that line, in Node and in Bun, and agreed with the hand label on every one. A short form reworded so that no bullet names a hand-over fails here and is read by hand; the condition that the owner section carries the item is read per rep from the tree before this grader, and a rep that does not meet it is unmeasured, not failed.
