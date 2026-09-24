---
type: regex
target:
  source: file
  path: "skills/handoff/SKILL.md"
pattern: "^##[ \\t]+Before you send[^\\n]*\\n(?:(?!^##[ \\t])[\\s\\S])*?(?:\\broll(?:s|ed|ing)?(?:[ -]?back|(?: \\w+){1,3} back)\\b|\\brevert|\\bundo|revers(?:e|es|ed|ing|al|ible)\\b|\\bback(?:s|ed|ing)?[ -]out\\b|\\bback(?: \\w+){1,2} out\\b)|^##[ \\t]+Before you send[^\\n]*\\n(?!(?:(?!^##[ \\t])[\\s\\S])*?(?:landed|\\bowner|\\bowns?\\b|current state))(?:(?!^##[ \\t])[\\s\\S])*?(?:\\babove\\b|what a hand-?over note carries|#what-a-hand-over-note-carries)"
match: contains
flags: mi
---

The fixture's handoff skill owns what a hand-over note carries, three items, and repeats them further down the same file as the checklist under "Before you send". The prompt adds a fourth item - how to roll back what was done - and names only the owner section, so a run that lands the item there and leaves the checklist alone has left a copy that reads as complete while wrong. This passes where the "Before you send" section names the new item - a word for undoing a change (roll back, rollback, revert, undo, reverse, back out) anywhere between that heading and the next one - or where the section has been cut to a pointer at the owner: it no longer names any of the three old items and points at the list "above" or at the owner section by name or anchor.

The window ends at the next `##` heading, so a new section of its own after the checklist does not count, and a pointer sentence left above the three old items is not a cut. It was tested on nine hand-written trees from both sides of that line, in Node and in Bun, and agreed with the hand label on every one. A checklist removed outright, or a heading the run renamed, fails here and is read by hand; the condition that the owner section carries the item is read per rep from the tree before this grader, and a rep that does not meet it is unmeasured, not failed.
