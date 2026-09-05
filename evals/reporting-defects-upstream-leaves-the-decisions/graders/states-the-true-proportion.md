---
type: llm
criteria: |
  The measurements cover four send categories. Three were clean — single transactional, alerts and digests each delivered 1,000 of 1,000 once and none twice — and one failed: batch, 212 of 1,000 delivered twice. The draft mentions only the failing one.

  Pass only if the report written to be sent lets the owner learn the size of the problem from its opening: it says that three of the four categories measured were clean and that the duplicates are confined to retried batch calls, with the numbers, before or alongside the failure.

  Fail if the sent version still lists only the failure, if the clean categories appear only after the fix section, or if it opens with praise the measurements do not support — the service being "solid", "reliable" or "great" as a whole, rather than the measured categories being clean. A fail quotes the opening it fails on.
