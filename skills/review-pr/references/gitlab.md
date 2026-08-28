# GitLab mechanics

Earned from a real MR review on a self-hosted instance. Items marked **not yet
exercised** are documented from the official API shape but have not been proven
against a live MR — verify on first use and update this file.

## MR discovery & pinning

- `glab` is the transport (`glab auth status` shows the host login; `glab api` for everything the porcelain lacks). Project paths in API URLs are URL-encoded: `projects/group%2Fsubgroup%2Frepo/...`.
- From an MR iid: `glab mr view <iid>` (title, state, branches, url). The API MR object (`glab api "projects/<enc>/merge_requests/<iid>"`) carries the pinning fields: `sha` (head), and `diff_refs` — `{base_sha, start_sha, head_sha}` — which is **exactly the trio every positioned comment requires**. Record all three; `sha` equals `diff_refs.head_sha`, and a local `git fetch origin <source_branch>` must land on it.
- Re-resolve `sha` at posting time; a changed head means re-validating anchors first.
- Diff = `GET .../merge_requests/<iid>/diffs`: one entry per file with `old_path`/`new_path`, `new_file`/`renamed_file`/`deleted_file` flags, and a unified `diff` string with `@@` hunks — the anchor-computation source. Local `git diff <base_sha>...<head_sha>` matches it.

## Dedupe source

`GET .../merge_requests/<iid>/discussions` (paginate — default page size 20). **Filter system notes**: entries with `notes[].system: true` are activity ("mentioned in issue …"), not review comments — the porcelain's "comments: 0" and the API's discussion count disagree because of them. `individual_note: true` marks a plain note; `false` marks a resolvable thread.

## Anchor rules (position object)

Positioned comments take a `position` object: `position_type: "text"`, the `diff_refs` trio (`base_sha`, `start_sha`, `head_sha`), `old_path` AND `new_path` (set both even when unchanged), plus line fields by case:

- **Added line** (including any line of a new file): `new_line` only.
- **Unchanged context line**: BOTH `old_line` and `new_line` — one alone fails. Verified: a comment 19 lines below the nearest change anchored correctly with both set.
- **Deleted line**: `old_line` only (not yet exercised).

**TRAP (learned from a real MR review): form-encoded `position[...]` fields are silently dropped.** A draft note POSTed with `-f 'position[new_line]=…'`-style fields is created successfully with every position field null — it would publish as an unanchored MR-level comment, and nothing errors. Send the payload as a JSON body instead (`glab api -X POST … -H 'Content-Type: application/json' --input payload.json`) with `position` as a real nested object. Build payloads as files, never inline shell strings.

## Posting

- One finding = one resolvable thread: `POST .../merge_requests/<iid>/discussions` with `{body, position}` (JSON body per the trap above). The response's `notes[0].position` echoes the anchor — **verify it is non-null before counting the post as anchored**, and confirm `resolvable: true`. `type: "DiffNote"` confirms a diff-anchored note.
- **There is no batched review submission.** Like ADO and unlike GitHub, each posted discussion is visible and notifies immediately — there is no one-submission packaging of threads.
- **Staged mode exists via draft notes** (closer to GitHub PENDING than ADO's nothing): `POST .../merge_requests/<iid>/draft_notes` with the same `{note, position}` shape — author-only until published; `GET`/`DELETE .../draft_notes/<id>` verified. Publishing (`POST .../draft_notes/<id>/publish` per note, `POST .../draft_notes/bulk_publish` for all) is **not yet exercised** — verify before promising the user a staged review.
- Thread bodies: severity header (`**Major — title**`, minors `**Nit — …**`), then `Problem:` / `Suggestion:` per the SKILL's format rules.

## Suggestion blocks

- The fenced ```` ```suggestion ```` block is GitLab-native in note bodies — **verified end-to-end on a live MR**: a block on an unchanged-line anchor rendered the Apply button and applied cleanly as a single one-line commit to the source branch, with the commit message user-editable at apply time. GitLab also has a **range extension** GitHub lacks: ```` ```suggestion:-N+M ```` replaces from N lines above to M lines below the anchored line (**not yet exercised**).
- **REST does not serialize suggestion state**: the notes/discussions responses carry no `suggestions` field at all, so the API cannot confirm a block parsed as appliable — the Apply button on the MR page is the confirmation. Anchor the comment to the exact replaced line; a suggestion on a wrong anchor applies to the wrong lines, same as the other platforms.

## Reply & resolve (thread disposition, later)

- Resolve state reads back via the discussions API: `notes[].resolved` plus `resolved_by` (verified after a real resolve — done in the UI; performing the resolve via `PUT .../discussions/<discussion_id>?resolved=true` is not yet exercised). Reply shape (`POST .../discussions/<discussion_id>/notes` with `{body}`) is also not yet exercised.
- **A normal push does not invalidate existing threads** (verified): after the author pushed a new commit, the earlier thread kept its `position.head_sha` pinned to the head it was created against and stayed live — GitLab anchors each thread to its own diff version. The re-verify-before-posting rule still applies to NEW comments, which must carry the current `diff_refs`.
- The disposition rule is the same as everywhere: verify the fix landed in the code at the new head (`git show <new_head>:<path>`), never just that the thread shows resolved.

## Not yet exercised — summary

Deleted-line anchors; draft-note publish/bulk_publish; the suggestion range syntax (```` ```suggestion:-N+M ````); performing resolve and reply via the API; force-push (as opposed to a normal push) behavior. Each is a first-use verification, not settled knowledge.
