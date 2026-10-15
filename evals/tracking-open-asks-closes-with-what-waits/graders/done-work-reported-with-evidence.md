---
type: llm
---

Every ask closes visibly. The rename and the version were both asked for. `VERSION` said 2.3.0 and the changelog's top entry 2.4.0 (unreleased), so setting the version meant choosing.

Read only what the final message says. Whether the work was really done is read from the files by other graders, not here.

Pass only if the message both reports the rename's outcome and names where it landed - the script and the README, or the diff - in any words ("`--dry` is now `--dry-run` in `bin/export.sh` and `README.md`" reports it), and names the version set together with what it was chosen from ("2.4.0, matching the changelog's top entry", "3.0.0, since the rename breaks callers of the old flag" each name their source).

Fail if the message does not mention the rename's outcome, or names no file and no diff for it, or reports the version without its value or without what it was chosen from. A fail quotes the sentence it fails on.
