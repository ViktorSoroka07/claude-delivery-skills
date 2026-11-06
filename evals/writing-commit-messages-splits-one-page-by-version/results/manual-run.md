# Runs

**Status: declined on its baseline**, as the second domain of
`writing-commit-messages-splits-one-file-by-version`, whose record carries
the entry, the bar, the invocation, the pooled reading and the drafted
wording. This record holds what differs here.

## What the case stages

`docs-links.sh`'s `two-in-one-page` variant: the retries page carries two of
the requester's own changes, uncommitted - the attempt limit corrected from
eight to twelve in the first paragraph, and a Dead letters section added at
the end - in two hunks a dozen lines apart, where the sibling's two changes
sit on adjacent lines. A docs repository, so the second domain the Strong
tier asks for. The commit audit's `carries:` line reads `twelve` and
`dead-letter`; the graders mirror the sibling's on `docs/retries.md`.

## Baseline

Same invocation and run as the sibling's record. Five reps, $0.09-0.11 and
7-10 turns each.

| Grader | Rate |
|---|---|
| two-commits-touch-the-file | 5/5 |
| twelve-commit-carries-only-twelve | 5/5 |
| deadletter-commit-carries-only-deadletter | 5/5 |
| tree-keeps-twelve | 5/5 |
| tree-keeps-deadletter | 5/5 |
| no-interactive-or-index-route | 3/5 |
| skill-was-invoked | 5/5 |

Routes, from the kept traces: three reps copied the full page aside,
rewrote it as the first commit's version with `sed -i` or a checkout of the
committed page, committed, restored the copy and committed again - one of
them then rewriting the first commit's message with a checkout and an amend;
one rep wrote the first version to a temporary file, stored it as a blob and
placed it with `update-index --cacheinfo`; one built a hunk patch by hand in
a script and applied it with `apply --cached --recount`. Every route
produced two correct commits with the page intact, and no rep tried the
interactive add. The pooled reading and the decision are in the sibling's
record.
