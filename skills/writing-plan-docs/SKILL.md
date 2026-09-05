---
name: writing-plan-docs
description: Use when creating, rewriting, or syncing a document a reader will later consult for current state, whether a plan or spec (docs/plans or equivalent), a findings or analysis report, or a research write-up. Triggers at feature start, when implementation ships, after a merge with the target branch, after review fixes land, and whenever a later finding overturns a conclusion the same document already states.
---

# Writing plan docs

A plan document has exactly two lifecycle stages, and each stage has one job:

1. **Before implementation**, it is a plan: context, phased steps, files to touch, verification loops. Checkboxes are scaffolding.
2. **Once the work ships, it is rewritten as the specification of what landed** — as the last step before offering merge/PR, not after. Strip every checkbox, re-tense to what shipped, record what was verified and what was not. The pre-implementation sections (phases, file lists) need not survive.

Everything below applies to the shipped-spec stage, which is where the failures happen.

The two-stage lifecycle is plan-specific. **The next section is not: it governs any document a reader consults for current state**, including a findings report, an analysis write-up or a research note, none of which has an implementation to ship.

## The doc describes the destination, never the route

The reader is someone consulting the spec later — not the reviewer of this branch. Anything that only makes sense relative to an earlier state of the branch is history, and history's home is git, the PR threads, and pinned-SHA records:

- **No deviation or divergence lists.** A decision made during review is written as the intent, in the section it belongs to — "the panel renders X" — never as "changed from the mock" or "intentional divergence". A settled decision written as drift reads as an unresolved defect.
- **No review-round narration.** "A review produced N findings", "round 2 fixed…", "was X until PR #N changed it" — all deleted. What a review taught folds into the spec as a plain requirement; a superseded mechanism is described only in its current form. If the finding's outcome is worth reading later, it belongs in the PR description or the review's own findings file.
- **No revision sections and no sibling plan files.** One plan per PR, edited inline; no `## Revision — <date>` blocks, no "Update:" callouts, no before/after comparisons. If a choice needs justification, the justification lives in that section's prose as the reason for the current design.
- **Superseded content is replaced, not annotated.** Update the Decisions list to the decision that holds; never append the new bullet beside the stale one.

## Retracted claims: a required line in the hand-off

When the rewrite retracts a claim the document previously stated, the hand-off that offers the merge or PR carries this line, filled in:

    Retracted: <the claim>. Also stated in: <artifact> (<what was done>); ...

Fill it by searching each artifact below for the claim's own terms. Recalling where the claim was stated is what leaves copies standing, and the document is the only one a working-tree sweep reaches.

| Artifact | How it is corrected |
|---|---|
| The document | An ordinary edit |
| The commit message body | A history rewrite, which is the author's call, never the session's |
| The pull or merge request description | An edit to the live description |

`Also stated in: nothing else` is a valid line only once all three have been searched. Where the correction needs published history rewritten, prepare it, verify the tree is unchanged against the pre-rewrite commit, and hand the author the command instead of running it. (learned from a real analysis document)

## Verification record: outcomes, not snapshots

- **State that each gate passed; never volatile counts.** "4535 tests passed" goes stale the moment any test lands anywhere in the repo, and every later sync pays to refresh a number nobody consumes. Write "every package suite green". Counts are allowed only in point-in-time artifacts pinned to a commit and consumed against that state — a review findings file, a PR description — not in the living spec.
- **The mutation table is the exception that earns its rows.** A table of "mutation → test that kills it" is an executed gates record that later reviews audit by re-applying rows, so it must stay current: every row must name code that still exists, anchored by code identity (the expression mutated), never line numbers. When a mechanism is replaced, replace its rows with the pins that hold now — do not keep rows for deleted code and do not narrate which round added which row.
- **Record what was NOT verified** and the concrete reason, stated so a reader can run the missing check — an honest gap beats an implied pass.

## Sections that decay on every sync

Re-check these whenever the branch merges its target or the upstream scope shifts:

- **Out of scope / Still open:** an upstream change can narrow, answer, or reshape an item. Restate each with its current boundary condition (e.g. "the upstream rework narrows this — it now only bites at a configured cap of 1"), or delete it if answered. An out-of-scope list that no longer matches the engine misleads exactly the person deciding what to do next.
- **Background/terminology:** definitions of the surrounding system drift when the system is restructured under the branch. The background must describe the engine the code merges into, without naming which PR restructured it.
- **Claims about names and calls:** a renamed function ("the cleanup calls terminate()") or a removed field referenced in prose is a doc-vs-code defect; fix the prose to the current identifier.

## References

A plan is read at implementation time — and the spec long after — against a tree that has moved since it was written, so every reference must resolve *then*, not just now. Anchor to what survives edits and is self-validating (the reader greps it and confirms the site): symbol names, unique string fragments, headings, file paths.

- **Repo-relative links only** — no `/Users/...` or machine paths (they 404 on the host).
- **Never bare line numbers** — they drift the moment any unrelated edit lands; where a symbol alone is ambiguous, keep the symbol and add `≈line` beside it.
- **Never SHAs of the branch's own commits** — a squash-merge erases them as objects, so they render as 404s; describe the change or cite the PR number instead (SHAs already on the target branch are stable and fine).
- Don't commit generated design exports (e.g. a minified single-file HTML); cite the artifact by name instead.
- Artifacts that serve the operator rather than the deliverable — a personal-skill edit, a local draft, session working files — stay out of project commits and tickets unless explicitly requested: settle each new artifact's home (tracked, locally ignored, or a personal repo) before the commit that would sweep it in.
- A deferral that is this PR's debt goes in the plan doc; a pre-existing repo condition goes to its own issue — unless the author directs otherwise.
