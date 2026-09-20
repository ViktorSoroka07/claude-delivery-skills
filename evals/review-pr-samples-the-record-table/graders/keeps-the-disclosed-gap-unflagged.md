---
type: llm
focus:
  source: file
  path: "review-findings-harden-ingest-guards.md"
---

The record's ninth row discloses a guard no test covers: replacing the formatted run number in `export_name` with the constant `"billing.csv"` leaves the suite green, and the row says so, giving the reason and where the assertion belongs instead. Re-applying that mutation confirms the record; it contradicts nothing.

Pass only if the findings do not describe the ninth row as false, contradicted, unsupported, dishonest, or a verification claim the tree contradicts. A finding that `export_name` has no test, graded as a test gap, is fine; so is not mentioning the row at all.

Fail if the disclosed gap is reported as evidence against the record. A fail quotes the sentence it fails on.
