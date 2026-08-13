# GitHub mechanics

## PR discovery & pinning

- From a branch: `gh pr list --head <branch> --json number,title,baseRefName,headRefOid,body`. From a PR number or URL: `gh pr view <n> --json number,title,headRefName,baseRefName,headRefOid,body` (`headRefName` is the branch to fetch). Record `headRefOid` — every step pins to it. `baseRefName` is the diff base.
- If no PR exists for the branch, say so in chat and review against the default branch; re-run discovery at posting time — a PR may have been opened since.
- At posting time, re-resolve the PR and confirm its current `headRefOid` still equals the head SHA recorded in the findings MD.

## Dedupe source

Pull existing threads via GraphQL `reviewThreads` (with author + path + isResolved) from all authors — humans, coderabbitai, claude.

## Anchor validation (required before output)

Every inline comment must land on an added/changed diff line or GitHub **422s the whole submission**. New files are safe; for modified files parse `git diff -U0 <base>...<head>` hunks and confirm each line. A finding on an unchanged line → anchor to the nearest changed line in the same file, stating the true `file:line` in the comment body and marking the finding **relocated** in the findings MD (a relocated anchor can never carry a suggestion block — see Suggestion blocks); only when the file has no changed lines at all does the finding go in the review body instead.

## Posting

- **ONE review submission** carrying all findings as separate resolvable inline threads (one notification, not N comments): build `{commit_id, event, body, comments: [{path, line, side: "RIGHT", body, start_line?, start_side?}]}` (the two optional fields only on multi-line suggestion comments) as a JSON file (via script — never inline shell strings with markdown) and `gh api repos/<owner>/<repo>/pulls/<n>/reviews --input payload.json`.
- Thread bodies: severity header (`**Medium — title**`), minors prefixed `**Nit — ...**`, then `Problem:` / `Suggestion:`.
- **Write commit SHAs bare — never in backticks.** GitHub autolinks a bare SHA in PR/issue bodies and comments; backticks make it inert code text, which defeats the reason for citing it. Applies to every GitHub-rendered surface (thread replies, review bodies, PR descriptions, issue comments). File paths, identifiers and commands still take backticks.
- **Event: COMMENT by default — APPROVE only if the user says "approve" in so many words.** COMMENT reviews get **no framing body**: submit `"body": ""` (`body` is documented required for COMMENT; empty is accepted at creation — the 422 applies to editing a body empty later). The one case `body` carries text on a COMMENT review: findings whose file has no changed lines (the anchor-validation fallback) — then it contains exactly those findings, nothing else. The approve variant (user-requested only): body = one-line "OK to merge once each thread is adjusted or answered" + compressed severity roll-up + fix-rather-than-wave-off call-out for security/authz items only; check reviewer != PR author first.

## Suggestion blocks (one-click appliable fixes)

When a finding's fix is an exact replacement of contiguous lines (SKILL section 6 defines when), end the comment body with a fenced ```` ```suggestion ```` block — GitHub renders a "Commit suggestion" button:

- The block replaces the comment's **entire anchored line range**: single-line → the `line`; multi-line → also set `start_line` and `start_side: "RIGHT"`, and the block replaces `start_line`..`line` inclusive. Anchor exactly the replaced lines — no more, no less; content = the complete replacement lines with exact indentation.
- **Never combine a suggestion with the nearest-changed-line fallback anchor** — the applied suggestion commits over whatever lines the comment sits on, so a relocated anchor rewrites the wrong code. If the true lines aren't all in the diff, post the finding without the block (fix stays in prose).
- Deleted (LEFT-side) lines can't take suggestions. An empty block means "delete the anchored lines".
- Replacement text containing a triple-backtick fence → widen the suggestion fence to four backticks (````` ````suggestion `````).
- Suggestion blocks only work in inline review comments — never in the review body.

## Reply & resolve (thread disposition, later)

- Reply: `gh api repos/<owner>/<repo>/pulls/<n>/comments/<comment_id>/replies -f body='...'` (`<comment_id>` = the thread's first comment).
- Resolve is **GraphQL-only** — REST cannot do it: `gh api graphql -f query='mutation { resolveReviewThread(input: {threadId: "<node_id>"}) { thread { isResolved } } }'`, with thread node IDs taken from the same `reviewThreads` query used for dedupe.

## API traps (learned the hard way)

- A submitted review can **never be deleted**, and its body can never be emptied (422 on empty/whitespace) — only replaced. If the user wants no body, it must be right at submission time.
- `PUT .../reviews/{id}` edits the body; `PUT .../reviews/{id}/dismissals` withdraws an approval keeping all threads — but **dismissal locks the body against all further edits** (REST and GraphQL both fail with a misleading "missing body" 422). Finalize the body BEFORE dismissing.
- An inline comment on a line outside the diff fails the entire submission with 422.
- **A 502 on `POST .../reviews` does NOT mean the submission failed** — with a large payload the review is often created and submitted anyway. Before ANY retry, list the PR's reviews filtered to the user's login and count the new review's comments; a blind retry double-posts an unremovable review. A 502'd review may also never reach `latestReviews` (the derived index the PR page's Reviewers sidebar renders), leaving it invisible on github.com despite existing — remedy: submit a second minimal review with the same event, no comments, and the body exactly "See inline review threads above." (the one sanctioned *framing* body — a comment-less review 422s on an empty body); it re-indexes the user's review state while the threads stay on the first review. (`reviewDecision` empty/null just means the repo has no required-review branch protection — not a symptom.)
