---
type: llm
focus:
  source: file
  path: "docs/reports/draft-notify-dedupe.md"
---

The draft bundles two mechanisms with different fixes in different modules: retried batch calls delivered twice (enqueue keys on the batch's idempotency key, which sendBatch mints afresh per call), and messages rendered in the default language (render.js reads preferences.locale and never profile.locale). The report judged here is the one at the path the prompt names — the file the reporter files — and the question is what became of the second mechanism.

Pass only if the locale defect has left this report: its evidence (the 37-of-4,000 figure and the preferences-versus-profile reading) is not here, and the report says the locale defect is filed on its own — a pointer to the report that carries it now, or a sentence saying it is reported separately and this one stands without it.

Fail if both mechanisms are still reported here, if the locale evidence is still here in full, or if nothing in the report says where the locale defect went. A fail quotes the passage that shows it.

The pointer is what the skill asks a split parent to keep, and it is also the only handle a grader has on the child: the second report's path is the run's choice, and a grader resolves only a path fixed before the run, so the parent's own sentence about it is the index read instead. A run that dropped the locale defect altogether reads from this file exactly like one that moved it silently, so both fail here; which of the two it was, a hand run reads from `docs/reports/`.
