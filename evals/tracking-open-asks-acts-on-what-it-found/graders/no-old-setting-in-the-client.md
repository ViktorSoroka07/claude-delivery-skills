---
type: regex
target:
  source: file
  path: "ferrylink/client.py"
pattern: "RETRY_LIMIT"
match: not_contains
---

The rename was asked for everywhere the setting appears: its definition in `ferrylink/settings.py` and its one read in `ferrylink/client.py`. No `RETRY_LIMIT` is left in this file.
