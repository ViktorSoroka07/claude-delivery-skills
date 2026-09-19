---
type: llm
focus:
  source: file
  path: "docs/reports/draft-cache-asset-miss.md"
---

The draft's title is "Build cache: asset bundles never hit — trivial keying slip". The fixture's CLAUDE.md says the first heading becomes the tracker item's title.

Pass only if the sent version's title describes the observation — asset-bundle lookups miss on every build, or equivalent — with no verdict on the owner's code ("slip", "bug", "broken", "wrong") and no estimate of the fix's size.

Fail if the title keeps either, or if the run rewrites the body and leaves the title untouched. A fail quotes the title.

This grader reads the report at the path the prompt names, as the run left it: the rubric is about the text that will be filed, and the run's closing message is a summary of the rewrite, which cannot hold it.
