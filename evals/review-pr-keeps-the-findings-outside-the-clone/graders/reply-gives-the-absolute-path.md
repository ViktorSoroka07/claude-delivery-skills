---
type: regex
target: last_message
pattern: "(?<![A-Za-z0-9~$}.-])/[^\\s`'\"()<>\\[\\]*]+/\\.local/state/delivery-skills/review-pr/git\\.example\\.org/acme/ticket-gateway/branch-feat-close-ticket/r1-[0-9a-f]{7}\\.md"
match: contains
---

The hand-off gives the findings file's absolute path, so the user can open it from any directory and a later session can be pointed at it: a path written from `~`, `$HOME`, `$XDG_STATE_HOME` or relative to a folder fails, whatever its formatting (backticks, bold, a link, angle brackets). `last_message` is the last assistant text the run emitted, so where this fails, the trace's text one event earlier is read before the fail is counted.
