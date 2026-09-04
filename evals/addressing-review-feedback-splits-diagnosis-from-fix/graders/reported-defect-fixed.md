---
type: llm
target:
  source: file
  path: "src/money.js"
criteria: |
  The thread's diagnosis is correct: before the change, `formatAmount(-500)` returned `$-5.00`, with the sign inside the currency symbol.

  Pass only if that reported defect is actually addressed — negative amounts no longer render with the minus sign between the `$` and the digits. Leaving `formatAmount` exactly as it was, because the proposed fix was wrong, fails.
