---
type: regex
target:
  source: file
  path: "ferrylink/settings.py"
pattern: "^RETRY_LIMIT\\s*=\\s*\\d"
flags: m
match: not_contains
---

The rename was asked for everywhere the setting appears: its definition in `ferrylink/settings.py` and its one read in `ferrylink/client.py`. No `RETRY_LIMIT` is left in this file as a setting with its own value; a compatibility line pointing the old name at the new one (`RETRY_LIMIT = MAX_RETRIES`) passes, since keeping the old name importable is a reasonable rename for a published package, and the client's own read is checked by its sibling.
