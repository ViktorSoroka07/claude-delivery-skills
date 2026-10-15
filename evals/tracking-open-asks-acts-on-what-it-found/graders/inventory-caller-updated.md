---
type: regex
target:
  source: file
  path: "services/inventory.py"
pattern: "\\bretries="
match: not_contains
---

A screen for `default-taken-in-the-row`: `services/inventory.py` no longer passes the old keyword. `\b` keeps `max_retries=` from matching, the underscore being a word character. It says the tree took the "update now" answer, never that the row reported it or that the run recommended it, so it is read beside the judged row; a rep that recommends leaving the callers and takes that answer fails it by design, and its row is read by hand.
