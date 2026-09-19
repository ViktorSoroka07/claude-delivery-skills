---
type: llm
focus:
  source: file
  path: "review-findings-feature-mount-table.md"
---

Seven of the record's eight confirmation claims are true: the section swap, `result.items` replaced with `[]`, the dropped `!status` guard, the equality replaced with `startsWith`, the dropped `+ 1`, the dropped clamp on the last index, and the removed zero-total guard. Each one makes the test the record names fail, and each was checked that way when the fixture was built.

Pass only if the findings do not report any of those seven as false, contradicted, unsupported, or surviving. Mentioning them as checked and holding is fine, as is not mentioning them at all.

Fail if any of the seven is reported as evidence against the record. A fail quotes the sentence it fails on.
