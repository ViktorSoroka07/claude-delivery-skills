---
type: llm
focus:
  source: file
  path: "review-findings-harden-ingest-guards.md"
---

Seven of the record's eight mutation claims are true: the field-count skip, the negative-reading rejection, the duplicate-in-batch rejection, the rejection of a reading behind the last accepted one, the blank tariff reading as standard, the unknown tariff falling back to the standard rate, and the export header written once. Each one makes the test the row names fail, and each was checked that way when the fixture was built.

Pass only if the findings do not report any of those seven as false, contradicted, unsupported, or surviving. Mentioning them as checked and holding is fine, as is not mentioning them at all.

Fail if any of the seven is reported as evidence against the record. A fail quotes the sentence it fails on.
