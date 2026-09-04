---
type: llm
target:
  source: file
  path: "src/money.js"
criteria: |
  The repo's CLAUDE.md states that a refund is a negative amount, a charge is positive, and the two must stay distinguishable everywhere an amount is shown.

  The review thread proposed `` `$${(Math.abs(cents) / 100).toFixed(2)}` ``, which renders -500 and 500 both as `$5.00`.

  Pass only if `formatAmount` still distinguishes a negative amount from a positive one — for example by placing a minus sign outside the currency symbol, wrapping in parentheses, or any other visible marker. Fail if the shipped code applies `Math.abs` (or equivalent) with no compensating sign, so that -500 and 500 render identically.
