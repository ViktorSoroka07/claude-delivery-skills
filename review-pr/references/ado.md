# Azure DevOps mechanics

## PR discovery & pinning

- Derive org/project/repo from the `origin` remote. Shapes: `https://dev.azure.com/<org>/<project>/_git/<repo>`; SSH `git@ssh.dev.azure.com:v3/<org>/<project>/<repo>`; legacy `https://<org>.visualstudio.com/<project>/_git/<repo>` (the `--org` URL `https://dev.azure.com/<org>` works for legacy orgs too).
- From a branch: `az repos pr list --org "https://dev.azure.com/<org>" --project "<project>" --repository "<repo>" --source-branch <branch> --status active`. From a PR id or URL: `az repos pr show --id <n> --org "https://dev.azure.com/<org>"` (gives `sourceRefName`, `targetRefName`, `lastMergeSourceCommit`). If no active PR exists, say so in chat and review against the default branch (resolve the id again at posting time). If several are active, pick the one targeting the default branch and mention the choice in chat. Record the source-branch head SHA — every step pins to it.

## Dedupe source

Pull existing threads: `GET .../pullRequests/<id>/threads?api-version=7.1` (author + `threadContext.filePath` + status). Include bot authors.

## Anchor validation

ADO accepts inline threads on any line of the right-side file — no changed-line restriction. Still verify the `file:line` exists at the head SHA.

## Auth

Use the ADO PAT in `$AZURE_DEVOPS_EXT_PAT` via Basic auth: `curl -u ":$AZURE_DEVOPS_EXT_PAT"`. The `az rest` / AAD-token route is often rejected for tenant-mismatched orgs (returns a sign-in page) — prefer the PAT. Keep the PAT out of any echoed output.

## Posting

- Post each final finding as its **own inline comment thread** anchored to the exact `file:line`, left **active/unresolved**. (A suggestion thread spans its replaced range instead; its `file:line` for post-verification is `rightFileStart.line`.)
- Thread content markdown: severity header (`**Medium — title**`), minors prefixed `**Nit — ...**`, then `Problem:` / `Suggestion:`. Repo-relative `filePath` with a leading `/`.
- Post an inline thread (`POST .../pullRequests/<id>/threads?api-version=7.1`) with body:

  ```json
  {
    "comments": [{ "parentCommentId": 0, "content": "<markdown>", "commentType": 1 }],
    "status": 1,
    "threadContext": {
      "filePath": "/<repo-relative-path>",
      "rightFileStart": { "line": <line>, "offset": 1 },
      "rightFileEnd": { "line": <line>, "offset": 2 }
    }
  }
  ```

  `status: 1` = active; `commentType: 1` = text; set `rightFileStart.line` / `rightFileEnd.line` to the finding's line, keeping the template's offsets (1 and 2) — a minimal anchor on that line. **Exception:** a comment carrying a suggestion block must use the span anchor from the Suggestion-blocks section instead — the minimal anchor breaks Apply.
- After posting, GET the threads endpoint and confirm each created thread is **live (not deleted)** at the right `file:line`.
- **`threadContext` is immutable after creation** (learned from a real PR review): a `PATCH` carrying a corrected `threadContext` returns **200 with the span unchanged** — silently, so the response looks like success. Get the span right the first time; verify every suggestion block's end offset *before* posting. If a posted block's span turns out wrong, the fix is to PATCH the comment content and demote the fence from ```` ```suggestion ```` to ```` ```tsx ```` (the prose fix survives) — an Apply over a wrong span corrupts the file, which is worse than no Apply.
- **A thread `PATCH` that omits `status` clears it** — the thread comes back with `status: None` and stops rendering as active. After any thread-level PATCH, re-`PATCH` `{"status":"active"}` and re-assert it.

## Suggestion blocks (one-click appliable fixes)

When a finding's fix is an exact replacement of contiguous lines (SKILL section 6 defines when), end the comment content with the same fenced ```` ```suggestion ```` block GitHub uses — ADO renders an "Apply changes" button that stages the replacement for a commit to the source branch.

- **Apply replaces exactly the character span in `threadContext`.** The minimal anchor above (offsets 1 and 2) would splice the replacement into the first character of one line and leave the rest of the old code in place. A suggestion thread must span the full replaced lines:

  ```json
  "threadContext": {
    "filePath": "/<repo-relative-path>",
    "rightFileStart": { "line": <first replaced line>, "offset": 1 },
    "rightFileEnd": { "line": <last replaced line>, "offset": <end offset — the command below prints it> }
  }
  ```

  Compute the end offset without needing a worktree (posting is often a fresh session after the review worktrees were removed) — `git show` takes the path **without** the leading slash `filePath` uses, and BSD `awk length()` counts bytes (overshooting on any non-ASCII line, locale or not), so use python:

  ```
  git show <headSHA>:<path-no-leading-slash> | python3 -c "import sys; line=sys.stdin.buffer.read().decode().split('\n')[<last>-1].rstrip('\r'); print(len(line.encode('utf-16-le'))//2+1)"
  ```

  Offsets are character positions as ADO's .NET/browser stack counts them (UTF-16 code units — identical to code points except for emoji); the `rstrip` keeps a CRLF terminator outside the span.
- Right side only — suggestions can't anchor to the left/original side (no changed-line restriction, as ever).
- Block content = the complete replacement for the spanned lines, exact indentation. Replacement text containing a triple-backtick fence → widen the suggestion fence to four backticks (````` ````suggestion `````).
- GitHub's empty-block-deletes-lines rule is GitHub-only: the ADO span excludes the last line's trailing newline, so an empty block would leave a blank line behind — keep pure-deletion fixes prose-only.

## No pending / draft comment mode

ADO has no equivalent of GitHub's PENDING review: a thread is visible to everyone the moment the POST returns, comments cannot be staged or batched for a later one-shot submission, and the review model is immediate threads plus a vote (Approve / Approve with suggestions / Wait for author / Reject). ADO's "draft" is a PR-level state (the PR isn't ready for review), not a comment state. When the user asks to hold publication (submit later themselves, keep review activity invisible for now): post nothing, say explicitly that ADO cannot stage comments, and leave the findings in `review-findings-<id>.md` — the posting session, on the user's word, is the moment they become visible.

## Reply & resolve (thread disposition, later)

- Reply: `POST .../pullRequests/<id>/threads/<threadId>/comments?api-version=7.1` with `{ "parentCommentId": <first comment id>, "content": "<markdown>", "commentType": 1 }`.
- Resolve: `PATCH .../pullRequests/<id>/threads/<threadId>?api-version=7.1` with `{ "status": "fixed" }` — use `"wontFix"` for deferrals and `"closed"` for false positives, matching the reply's reasoning.
