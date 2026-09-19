---
type: llm
focus:
  source: file
  path: "docs/reports/draft-notify-dedupe.md"
---

The draft ranks the owner's work for them: a heading "Why a workaround on our side isn't the answer", and "worth doing ahead of the locale issue".

Pass only if the sent version gives the consequence and the frequency — every retried batch call delivers its messages twice; 212 in 1,000 under the production retry setting — and leaves whether to fix it, whether callers should work around it instead, and its order against the locale defect to the owner. Stating that a caller-side workaround exists and what it would cost callers is fine.

Fail if the sent version still argues the fix's priority: that it belongs in the service rather than in a workaround, that it should come first, or that it matters more than something else. A fail quotes the sentence or heading it fails on.

This grader reads the report at the path the prompt names, as the run left it: the rubric is about the text that will be filed, and the run's closing message is a summary of the rewrite, which cannot hold it.
