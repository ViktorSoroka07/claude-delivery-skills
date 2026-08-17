---
name: writing-pr-descriptions
description: Use when creating a pull request, writing or editing a PR title or description, or when commits have landed on a branch whose PR description may no longer match — including "sync the PR description" and "update the PR body" asks. GitHub and Azure DevOps.
---

# Writing PR Descriptions

## Overview

**Describe the diff, not the branch.** A PR description specifies the net delta between the target branch and the tip — the final state a reviewer or future reader needs — never the branch's internal history. The history (review rounds, fix-ups, rebases, draft phases) already lives in commits and review threads with better provenance; repeating it in the body duplicates a record the reader can get with attribution, while burying what they actually need and making the final state look shakier than it is.

## The contract

A description consists of, in order:

1. **Tracking link** — the work item / story / issue the PR closes, if one exists.
2. **What this changes** — grouped by net behavioral change (per file/area for docs and specs). Each item leads with the problem it solves, then the final behavior: "X failed / was missing / was hedged — it now does Y." Pull the why from commit-message bodies; the description curates them. Work outside the nominal scope gets its why-it-was-necessary stated up front, so the scope is legible.
3. **Not changed** — the deliberate scope boundary: what a reviewer might expect here that is intentionally untouched, and where it lives instead.
4. At most **one anchor fact** a reviewer may want to verify (e.g. "citations resolve against main since #N merged").

An existing body's section layout may stay — the contract governs content shape, not headings. Repo-specific templates win on structure; fill them with content shaped as above.

**Title:** the outcome of merging, phrased in the repo's own title convention — never process ("Address review comments", "Fixes after review"). Re-check the title on every sync; scope drifts.

## Syncing when commits land

1. Re-derive the net delta `<base>...tip`.
2. **Re-fold** the affected sections to the new final state — rewrite in place.
3. Delete framing that stopped being true: draft/lifecycle lines, future tense ("will add"), pre-rebase mechanics, approval anchors.
4. Fixes to mistakes made on this same branch are not deltas — they appear nowhere.
5. Preserve bot-managed sections verbatim (everything from a bot marker such as a CodeRabbit release-notes comment onward — never edit or extend them).
6. Process rationale survives as at most one past-tense sentence, only if it still helps the current reviewers (e.g. why one reviewer went first).

## Common mistakes (each observed in practice)

| Wrong shape | Correct shape |
|---|---|
| "Addendum — round 2" / "Commits after the first review round" section appended | Content folded into the scope sections it changes |
| In-branch bug fix narrated ("off-by-one introduced earlier, fixed in a1b2c3d") | Absent — it is not a delta vs the base |
| "(renamed from X during review)" | The final name, stated as the state of the world |
| Flat "what we did" bullets | Problem → final behavior, with the why |
| "DRAFT for X's review" line surviving ready-for-review | One past-tense sentence, or nothing |
| New bullet appended after the bot's release-notes marker | Bot tail byte-identical |
