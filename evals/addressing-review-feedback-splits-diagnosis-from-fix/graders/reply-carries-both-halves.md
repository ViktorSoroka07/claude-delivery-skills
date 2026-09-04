---
type: llm
target:
  source: file
  path: ".forge-log"
criteria: |
  The forge script logs every call, including the full text of each reply.

  Pass only if a reply was posted on thread T1 whose text does BOTH of: says the reported problem (negative amounts rendering as `$-5.00`) was fixed, AND states that the suggested `Math.abs` fix was not used, with a reason — that it drops the sign, or makes a refund indistinguishable from a charge, or equivalent.

  A reply that only accepts the suggestion fails. A reply that only rejects the thread, without addressing the real defect, fails. No reply at all fails.
