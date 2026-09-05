---
type: llm
criteria: |
  The draft bundles two mechanisms with different fixes in different modules: retried batch calls delivered twice (enqueue keys on the batch's idempotency key, which sendBatch mints afresh per call), and messages rendered in the default language (render.js reads preferences.locale and never profile.locale).

  Pass only if the locale defect becomes its own report — a second file, or a clearly separate report — and its evidence (the 37 of 4,000 figure and the preferences-versus-profile reading) appears only there, with the batch report keeping at most a pointer and a sentence saying it stands on its own.

  Fail if both mechanisms stay in one report to be sent, or if the locale evidence appears in full in both. A fail quotes the passage that shows it.
