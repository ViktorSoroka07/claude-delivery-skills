---
type: regex
target:
  source: file
  path: "README.md"
pattern: "^[-*][ \\t]+\\*\\*handoff\\*\\*(?:(?!\\n[ \\t]*\\n|\\n[-*][ \\t]|\\n#)[\\s\\S])*?(?:\\broll(?:s|ed|ing)?(?:[ -]?back|(?: \\w+){1,3} back)\\b|\\brevert|\\bundo|revers(?:e|es|ed|ing|al|ible)\\b|\\bback(?:s|ed|ing)?[ -]out\\b|\\bback(?: \\w+){1,2} out\\b)|^[-*][ \\t]+\\*\\*handoff\\*\\*(?!(?:(?!\\n[ \\t]*\\n|\\n[-*][ \\t]|\\n#)[\\s\\S])*?(?:landed|\\bowner|\\bowns?\\b|current state|still open))(?:(?!\\n[ \\t]*\\n|\\n[-*][ \\t]|\\n#)[\\s\\S])*?skills/handoff/SKILL\\.md"
match: contains
flags: mi
---

The fixture's README lists the team's skills, one bullet each, and the `handoff` bullet paraphrases the three things a hand-over note carries. The prompt adds a fourth and names only the skill's owner section, so a README left alone reads as complete while wrong. This passes where the `handoff` bullet names the new item - a word for undoing a change (roll back, rollback, revert, undo, reverse, back out) anywhere in that bullet, its wrapped lines included - or where the bullet has been cut to a pointer: it still links `skills/handoff/SKILL.md` and no longer names any of the old items (where a change landed, what is still open, its owner, the current state).

The window ends at the next bullet, blank line or heading, so the item added to another skill's bullet or to the section below does not count, and a bullet reworded to name the three old items in new words is not a cut. It was tested on nine hand-written trees from both sides of that line, in Node and in Bun, and agreed with the hand label on every one. A bullet removed or reformatted past its `- **handoff**` lead fails here and is read by hand; the condition that the owner section carries the item is read per rep from the tree before this grader, and a rep that does not meet it is unmeasured, not failed.
