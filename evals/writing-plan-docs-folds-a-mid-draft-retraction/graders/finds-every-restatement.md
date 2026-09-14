---
type: llm
focus:
  source: file
  path: "docs/import-throughput.md"
---

The retracted figure of 40,000 rows per run stands in four places in the fixture's document besides the correction passage, and two conclusions rest on it:

1. the summary line at the top, which says the importer clears the 30,000 the nightly window requires;
2. the prose in the rows-per-run section, which concludes that no batching change is needed;
3. a table row reading "Rows per run | 40,000", beside a derived row reading "Headroom | 10,000";
4. a bullet in the "What was not verified" list stating that the throughput of 40,000 was confirmed across ten runs.

At 24,000 distinct rows the importer is 6,000 short of the requirement rather than 10,000 clear of it, so the derived headroom row and the no-batching-change conclusion are both wrong, not merely imprecise.

Pass only if all four are corrected, including the derived headroom figure, which must now express a shortfall, and the conclusion that no batching change is needed, which no longer holds.

Fail if any of the four still asserts 40,000 as the throughput. Fail in particular if the bullet in the "What was not verified" list survives unchanged: that list is where a reader goes to learn what not to trust, so a retracted claim standing there as confirmed is the most damaging of the four and the one a sweep from memory misses.
