---
name: writing-pr-descriptions
description: Use when creating a pull request, writing or editing a PR title or description, when commits have landed on a branch whose PR description may no longer match — including "sync the PR description" and "update the PR body" asks — and when maintaining a living status comment on a PR or issue. GitHub and Azure DevOps.
---

# Writing PR Descriptions

## Overview

**Describe the diff, not the branch.** A PR description specifies the net delta between the target branch and the tip — the final state a reviewer or future reader needs — never the branch's internal history. The history (review rounds, fix-ups, rebases, draft phases) already lives in commits and review threads with better provenance; repeating it in the body duplicates a record the reader can get with attribution, while burying what they actually need and making the final state look shakier than it is.

## The contract

A description consists of, in order:

1. **Tracking link** — the work item / story / issue the PR closes, if one exists.
2. **What this changes** — grouped by net behavioral change (per file/area for docs and specs). Each item leads with the problem it solves, then the final behavior: "X failed / was missing / was hedged — it now does Y." Pull the "why" from commit-message bodies; the description curates them. Work outside the nominal scope gets its why-it-was-necessary stated up front, so the scope is legible.
3. **Not changed** — the deliberate scope boundary: what a reviewer might expect here that is intentionally untouched, and where it lives instead.
4. At most **one anchor fact** a reviewer may want to verify (e.g. "citations resolve against main since #N merged").

**References:** the description is read after the squash-merge, against a tree that keeps moving — anchor by what survives: file paths, symbol names, artifact ids, PR/issue numbers. Never bare line numbers (they drift silently), and never SHAs of the branch's own commits (the squash erases them as objects; GitHub renders a dead SHA as a 404). SHAs already merged on the target branch are stable and fine. (`writing-plan-docs`' reference rules own the general anchoring discipline; this paragraph carries the PR-body deltas.)

An existing body's section layout may stay — the contract governs content shape, not headings. Repo-specific templates win on structure; fill them with content shaped as above.

**Title:** the outcome of merging, phrased in the repo's own title convention — never process ("Address review comments", "Fixes after review"). Re-check the title on every sync; scope drifts.

## Syncing when commits land

1. Re-derive the net delta `<base>...tip`.
2. **Compose against the body as it is now, not a copy fetched earlier.** The description is a shared document: the author edits it, reviewers paste into it, bots append to it. An edit built on a stale copy silently discards whatever landed in between, and the write reports success either way — the loss shows up later, as content that was there and is gone. Fetch the live body immediately before writing, and carry an assertion across the edit over something the other party contributed — the count of embedded images, the presence of a marker block — so a clobber fails the write instead of shipping. This is also what makes a rewrite safe to attempt at all: without the assertion, "I preserved their content" is a hope, not a check.
3. **Re-fold** the affected sections to the new final state — rewrite in place.
4. Delete framing that stopped being true: draft/lifecycle lines, future tense ("will add"), pre-rebase mechanics, approval anchors.
5. Fixes to mistakes made on this same branch are not deltas — they appear nowhere.
6. Preserve bot-managed sections verbatim (everything from a bot marker such as a CodeRabbit release-notes comment onward — never edit or extend them).
7. Process rationale survives as at most one past-tense sentence, only if it still helps the current reviewers (e.g. why one reviewer went first).

## The author's reviewer-facing summary comment

The same contract governs the **author's** "changes since the last review pass" comment — and any other living status comment the author maintains, on an issue as much as a PR (distinct from review findings, which are the reviewer's and go inline). It is one living record, edited in place, never a stack: multiple summary comments accumulate over a PR's life and bury the one reviewers should read.

1. **At most one living summary comment at a time**, created on the first changes-since-review sync. Note its id.
2. **Every later update edits it in place:** fetch the current body and PATCH it back (GitHub: `gh api -X PATCH repos/{owner}/{repo}/issues/comments/<id>`; Azure DevOps: update the existing thread comment rather than posting a new thread), restructured to the current state. Stale "what changed last week" content is replaced, not appended to.
3. **A fresh comment only when a new review cycle explicitly begins** — then edit the superseded comment down to a one-line pointer to the new one.
4. **Replies on inline review threads are not summaries** — they stay on their threads.

## Common mistakes (each observed in practice)

| Wrong shape                                                                                                        | Correct shape                                                           |
|--------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------|
| "Addendum — round 2" / "Commits after the first review round" section appended                                     | Content folded into the scope sections it changes                       |
| In-branch bug fix narrated ("off-by-one introduced earlier, fixed in a1b2c3d")                                     | Absent — it is not a delta vs the base                                  |
| "(renamed from X during review)"                                                                                   | The final name, stated as the state of the world                        |
| Flat "what we did" bullets                                                                                         | Problem → final behavior, with the why                                  |
| "DRAFT for X's review" line surviving ready-for-review                                                             | One past-tense sentence, or nothing                                     |
| New bullet appended after the bot's release-notes marker                                                           | Bot tail byte-identical                                                 |
| "I already have the body — PATCH my version back"                                                                 | Fetch it again; assert their additions survived the edit                |
| `src/foo.ts:123` or an in-branch commit SHA cited *(observed in plan docs and review text — same drift mechanism)* | File + symbol name; the PR number or a SHA already on the target branch |
