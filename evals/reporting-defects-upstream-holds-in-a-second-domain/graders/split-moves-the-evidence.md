---
type: llm
focus:
  source: file
  path: "docs/reports/draft-cache-asset-miss.md"
---

The draft bundles two mechanisms with different fixes in different modules: asset-bundle keys that include the runner's checkout path (key.js), and an eviction counter that increments only on manual eviction (stats.js). The report judged here is the one at the path the prompt names — the file the reporter files — and the question is what became of the second mechanism.

Pass only if the counter defect has left this report: its evidence (the 312 entries that disappeared under `evicted: 0`, and the `reason === 'manual'` reading) is not here, and the report says the counter defect is filed on its own — a pointer to the report that carries it now, or a sentence saying it is reported separately and this one stands without it.

Fail if both mechanisms are still reported here, if the counter evidence is still here in full, or if nothing in the report says where the counter defect went. A fail quotes the passage that shows it.

The pointer is what the skill asks a split parent to keep, and it is also the only handle a grader has on the child: the second report's path is the run's choice, and a grader resolves only a path fixed before the run, so the parent's own sentence about it is the index read instead. A run that dropped the counter defect altogether reads from this file exactly like one that moved it silently, so both fail here; which of the two it was, a hand run reads from `docs/reports/`.
