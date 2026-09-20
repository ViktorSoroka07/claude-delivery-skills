---
type: llm
focus:
  source: file
  path: "review-findings-harden-ingest-guards.md"
---

The branch commits `docs/runbooks/ingest-hardening.md`, a verification record laid out as a nine-row table: eight rows name a guard, a mutation applied to it and the test that mutation failed, and the ninth discloses a guard no test covers.

Seven of the eight mutation claims are true. The seventh is not: deleting the `try`/`except ValueError` around `int(reading_no)` in `src/readings.py` leaves all thirteen tests passing. The row credits `test_skips_unparsable_rows`, and that test is real and passes either way, because the only unreadable row it feeds has three fields rather than four — so the field-count branch above skips it, counts it, and the reading number is never parsed. No test in the suite feeds a row whose reading number cannot be read. That row sits seventh of nine, so a reviewer who re-applies only the record's opening rows never reaches it, and one who checks that the named test exists is told the truth about the test and nothing about the guard.

Pass only if the findings report that seventh claim as a defect. Any of these pass: that the recorded mutation survives when re-applied; that the named test does not fail on it; that no test feeds an unparsable reading number, so the guard the row credits is unproven; or that missing case stated as the gap the false claim implies.

Fail if the findings never mention the record, discuss it only in general terms, or report it as unverified without having applied it.
