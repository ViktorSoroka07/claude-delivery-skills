---
type: regex
target: last_message
pattern: "^\\|[ \\t]*\\d+[ \\t]*\\|[^\\n]*\\|[ \\t]*(?![ \\t])(?!\\**(?:[Tt]aken|[Ww]aits)\\b)[^|\\n]*[^\\s|][^|\\n]*\\|[ \\t]*$"
flags: m
match: not_contains
---

Every numbered row of the closing table opens its last cell, what happens if no answer comes, with Taken where the recommended answer is what happens without one, or with Waits where it is not, so the requester can tell at a glance whether staying silent takes the recommendation. This fails on any numbered row whose last cell opens with another word, bold allowed around either. It counts only on reps that pass `waiting-items-in-a-numbered-table`, since a message with no numbered table passes it with no cell read. A numbered table of the work done above the waiting one fails it on its own rows, which no kept message did (one of 145 held two numbered tables, both of waiting items); such a fail is read by hand.
