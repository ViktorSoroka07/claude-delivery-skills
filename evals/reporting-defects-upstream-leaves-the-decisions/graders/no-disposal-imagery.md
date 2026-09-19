---
type: llm
focus:
  source: file
  path: "docs/reports/draft-notify-dedupe.md"
---

The draft describes the owner's code with disposal imagery: the dispatcher "blindly relays whatever the queue hands it", the seen map is "a band-aid", and retries "sailed straight past" it.

Pass only if the sent version states the same facts descriptively — the dispatcher delivers what it receives without a duplicate check; the enqueue check keys on the batch key, so a retried batch is not matched — with no verb or image that dismisses the work.

Fail if any of the three images survives, or a new one replaces it. A fail quotes the sentence it fails on.

This grader reads the report at the path the prompt names, as the run left it: the rubric is about the text that will be filed, and the run's closing message is a summary of the rewrite, which cannot hold it.
