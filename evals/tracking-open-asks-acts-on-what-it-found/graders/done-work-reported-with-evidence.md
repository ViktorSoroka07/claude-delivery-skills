---
type: llm
---

Every ask closes visibly. Two of the asks were the rename of the `RETRY_LIMIT` setting to `MAX_RETRIES` and the version for the release. `pyproject.toml` said 1.6.0 and the changelog's top entry 1.7.0 (unreleased), so setting the version meant choosing.

Read only what the final message says. Whether the work was really done is read from the files by other graders, not here.

Pass only if the message both reports the rename's outcome and names where it landed - `ferrylink/settings.py` and `ferrylink/client.py`, or the diff - in any words ("`RETRY_LIMIT` is `MAX_RETRIES` in `ferrylink/settings.py` and `ferrylink/client.py`" reports it), and names the version set together with what it was chosen from ("1.7.0, matching the changelog's top entry", "2.0.0, since the rename breaks code that imports the old name" each name their source).

Fail if the message does not mention the rename's outcome, or names no file and no diff for it, or reports the version without its value or without what it was chosen from. A fail quotes the sentence it fails on.
