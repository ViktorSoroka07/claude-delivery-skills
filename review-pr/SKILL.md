---
name: review-pr
description: Use when the user asks to review a pull request or the current branch from multiple angles, to disposition / reply-and-resolve threads from a previous review, or to apply a previous review's findings to the branch — GitHub or Azure DevOps. Detect the platform from the origin remote and load the matching references file before starting.
---

# Review PR — Two-Pass Multi-Axis Review (review + verify; post or apply only on request)

One invocation, two passes, no posting. Pass 1 is a multi-axis review: parallel single-axis subagents against a pinned worktree, plus a mutation-testing agent in its own worktree. Pass 2 is fresh-eyes verification: by default ONE clean-context subagent tries to refute every finding and sweeps for misses; a deeper blind-re-review + isolated-skeptics mode runs only when the user explicitly asks for a deep review or the repo-nuances memory pins it. Findings go to an MD file — **not into chat**. Posting (section 6) and applying (section 7) happen **only when the user asks in a later message**.

## 0. Platform

Detect from `git remote get-url origin` and read the matching reference **before starting** (it defines PR discovery, dedupe mechanics, anchor rules, and posting):

- `github.com` → `references/github.md`
- `dev.azure.com` / `visualstudio.com` → `references/ado.md`

## 1. Scope & setup

1. **Check project memory first** for a `review-repo-nuances` entry — it records this repo's gate commands, mutation-axis test command, bot reviewers to dedupe against, PR conventions, any depth pins (e.g. deep-mode Pass 2, no small-diff shortcut), and — when `implement-plan` left one — the location of the branch's executed gates record (plan path, branch, the SHA the gates ran at). If it doesn't exist, discover those from the repo's CLAUDE.md / CI config during the review and **save such a memory** (+ MEMORY.md index line) before finishing.
2. Never switch the user's branch. Identify the PR first via the platform reference — the user may give a branch, a PR number, or a URL — and record its head SHA and target branch. Then `git fetch origin <branch>` for the PR's head branch (works for branches never fetched). Every later step pins to the head SHA.
3. Diff = `git diff $(git merge-base origin/<base> <head>)...<head>` where `<base>` is the PR's target branch (default branch if no PR exists). Read the PR body too: claims it makes about content ("includes X") are auditable and sometimes stale.
4. **Dedupe against existing review surface first**: pull existing comment threads (platform reference has the mechanics) from all authors — humans and bots. Don't re-raise what's already raised; verify that "resolved" items are actually fixed in the current code — a resolved thread with the bug still present is a top finding.
5. Create two detached worktrees at the head SHA in the session scratchpad: `review-<id>-read` for all reading agents, `review-<id>-mut` for the mutation agent (it edits files — it never shares a tree with readers). `<id>` = the PR id if one exists, otherwise the branch name with `/` replaced by `-`; the same `<id>` names the output MD later. Remove both worktrees (`git worktree remove --force`) when done.

## 2. Finding format (all passes)

- **Issues only** — no praise, no confirmed non-issues in the final findings or in posted comments (the MD's Pass 2 verdict log does record REFUTED entries with reasons — that's its job; chat may mention non-issues).
- Grade **major / medium / minor**. Each finding: Title / `file:line` (at the head SHA) / `Problem:` / `Suggestion:` — one problem, one single best fix, no hedged fallbacks (a fork is allowed only when the right fix depends on author intent). When the fix is an exact replacement of a small run of contiguous lines, the Suggestion records the replacement snippet, the exact replaced line range, **and the original content of those lines** (section 6's staleness check compares against it). At posting time it becomes a one-click appliable suggestion block if the section 6 rules allow it (they don't for relocated anchors or large replacements).
- **Anchors are pinned; proposed text is not** (learned from a real PR review — a suggestion block wrote four HTML line numbers into a design note's permanent prose). The finding's own `file:line` cites the head SHA and is re-validated at posting — line numbers are correct *there*. But text a Suggestion proposes to **add to a durable artifact** (spec, design note, README, wiki, plan prose) outlives every pin: in that text, reference by stable identity — a quoted fragment, a section or heading name, an artifact id, a symbol name — never bare line numbers (they drift on any unrelated edit, with nothing to flag it) and never SHAs of unmerged commits (a squash erases them). One admissible exception: a line-numbered enumeration that explicitly names the commit it was verified against — snapshot semantics, consumed against that state, not maintained.
- Tone: **polite**, mechanism-first, no editorializing ("pure waste", "rot", "tautological" banned); acknowledge documented-deliberate decisions before questioning them; conventions phrased as "the repo's convention asks"; the goal is fixes, not a verdict.
- Walk each finding through its mechanism: what happens → why it matters → the fix. The reader must not need follow-up questions.
- **Write comment bodies human-first, never as one chained sentence** (learned from a real PR review — a Suggestion chaining three actions with commas/em-dashes had to be re-posted). A Problem stacking 3+ facts renders them as a bulleted list. A Suggestion with more than one action becomes a numbered list ("Suggestion — two edits:"), one action per item. Multi-step procedures are numbered steps, never arrow chains (A → B → C). Test: the author should be able to act on each item without re-reading the sentence it came from. Fixing an already-posted comment: edit in place (`gh api -X PATCH .../pulls/comments/<id>` / ADO thread update), no correction trail, and record the edit + timestamp in the findings MD.
- Each finding must be **self-contained and actionable**. No deferrals to "a later PR". No offers of the user's help.
- **Write in the user's voice** — everything posted goes out under their account and must read as theirs.
- **Never flag AI-attribution trailers** (`Co-Authored-By: Claude ...`, "Generated with" footers) in a teammate's commits or PR body — the no-AI-attribution rule is the user's personal convention for their OWN git artifacts only.
- Treat `TODO` comments as intentional future work — **do not challenge them**. **Omit locale files** from the review.
- **Generated plan documents are read-only context, never a finding target** (learned from a real PR review): a `docs/plans/**` artifact — typically an HTML plan emitted by the planning tool — is produced upstream of the diff, so a defect in it is fixed in the generator, not by the PR author. Read it to learn what the implementation was *supposed* to do and audit the code against that intent; never raise a finding against the plan file itself, and never count its own inconsistencies as diff defects. The same rule applies to any other tool-generated artifact the PR merely carries along. One exception: an executed verification record inside the plan (an implementation-gates mutation table) is a claim about this branch's tests — audit it per section 3, and a record the audit contradicts is a valid finding.

## 3. Pass 1 — multi-axis review

For small diffs (roughly < 300 changed lines) review inline yourself (the mutation axis still applies if tested logic changed). Otherwise, dispatch parallel single-axis subagents, each given the section-2 format rules, the read worktree path, and the head SHA — which its report must name back (a report that doesn't name the commit is unverified: re-dispatch that axis once; if still missing, discard its findings):

- **Correctness** — logic bugs, edge cases, argument/flag handling, cross-platform assumptions.
- **Security / input handling** — injection, traversal, credential leakage, unvalidated input. Only when the diff touches servers, child processes, auth, or file IO. Calibrate: a loopback-only dev tool's flaw is minor, not major.
- **Test quality** — fixture honesty (could anything the fixture does fail the test?), non-default config values, coverage gaps, CI wiring (do the new tests actually run from the root pipeline?). **Normally folded into the mutation axis** — a reader guessing which tests are weak duplicates what mutation measures. Dispatch it separately only when tests changed but no source did, or when CI wiring is the question.
- **Doc-vs-code audit** — when the PR carries docs/specs/READMEs claiming what the code does: verify every claim against source; flag documented-but-absent and load-bearing-but-undocumented. Docs rot faster than code and nothing else checks them. Sweep doc-vs-**doc** and comment-vs-comment too: **a contradiction between two statements is an unresolved factual question about the system, not a tidiness defect.** Never write the finding as "these two disagree, please align them" — that offers a choice between strings and says nothing about which describes reality. Determine which is true (empirically, if the system is reachable), lead with the substantive consequence, and if the repo cannot settle it, say so and name the check that would. Weight a contradiction higher when the two sides imply different runtime behavior — which endpoint, which identity, which order — than when they differ only in wording; the first is a live defect wearing a documentation costume. When the diff promotes a statement across documents — chat into a spec, a spec into a wiki, a rule into CLAUDE.md — check the promoted imperative against the **original** verbatim, not the intermediate copy: a boundary condition dropped at one hop reads consistent at every later hop, so each downstream reviewer sees only a faithful paraphrase of the tier before. Compare against the earliest tier you can reach; when the true original (a chat) is unreachable, report that hop as unverified rather than passing it. Check qualifiers in both directions: a dropped condition survives as a false absolute, and an added condition the mechanism does not require — a tool name, a team, a location — silently narrows the rule so it stops firing on cases it should cover.
- **Repo conventions & gates** — the target repo's own CLAUDE.md rules, guideline-doc trees, and CI gate commands (the repo-nuances memory from section 1 records where these live); this axis may install deps and run those gates **in the read worktree only** (untracked artifacts only, never edits).

### Axis triage — choose from the diff, never run the set

Running every axis on every diff is the default failure mode, and it is expensive: on a 750-line branch, eight agents cost more than the findings were worth, and most of the overlap was redundant reading. Axis diversity beats axis count — five reviewers reading the same way find the same bugs five times.

Choose by trigger, and **state the chosen axes and why in one line before dispatching**, so the cost is visible and the user can add or drop one:

| Axis                    | Dispatch when                                                                                                                                                               |
|-------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Mutation**            | tested logic changed — always first, and the only axis that measures rather than reads                                                                                      |
| **Correctness**         | non-trivial logic, control flow, or arithmetic changed; skip for renames, config, copy                                                                                      |
| **Doc-vs-code**         | the diff carries docs, specs, or a plan rewritten as a shipped spec, making behavioral claims                                                                              |
| **Resource / security** | child processes, auth, file IO, network, or untrusted content reaching logs                                                                                                 |
| **Repo conventions**    | diff over ~400 lines, or it touches a subsystem with its own CLAUDE.md — below that, just run the gates yourself, which is cheaper than an agent reading the guideline tree |
| **Test quality**        | tests changed but source did not (otherwise the mutation axis covers it)                                                                                                    |

If the user names an area to review explicitly, honor that on top of the triage. If the user asks for a deep or exhaustive review, run the full set.

Calibration from a real run: on a real branch, mutation + correctness + doc-vs-code + resource — four agents rather than eight — would have found every finding that mattered, including the two the resource trigger fired on legitimately (child-process output reaching an on-disk log).

### Mutation-testing axis (own worktree, runs alongside the readers)

Highest-yield axis for any PR that adds or changes tested logic — it finds correct-but-unpinned code no reader can see.

**If the branch's plan — or, in repos that do not commit plans, the gates-record pointer in the repo-nuances memory — names an executed implementation-gates record** (a mutation table naming each edit and the test that killed it), audit it instead of re-buying it. Run the green baseline first, as below. Then re-apply 2–3 of the recorded mutations (all of them when the record holds fewer) and watch them fail, and spend fresh mutations on changed lines the record does not cover — where a record executed at an older SHA covers only lines unchanged since that SHA. A recorded mutation whose anchor no longer matches is staleness, not dishonesty: re-sweep those lines fresh, no finding. A recorded mutation that applies cleanly and survives IS a finding — a written verification claim the tree contradicts.

Protocol for the fresh mutations, exactly (past runs were invalidated by mutations that never applied and test runs that never executed):

1. **Baseline:** run the standard test command in the mutation worktree; record count and duration. Red baseline → report and stop this axis.
2. **Pick ~10–15 targeted mutations** at decision points: comparison flips (`>` ↔ `>=`), boundary constants, sort comparators, exit codes, emitted field names, filter conditions, arithmetic denominators.
3. **One at a time:** apply via Edit with an `old_string` unique to the target line — a failed Edit means the mutation never applied; never count it. Re-run tests; compare duration and count to baseline (a millisecond run did not execute). Record KILLED (naming the failing test) or SURVIVED. Revert; verify `git status --porcelain` clean before the next.
4. **Screen each survivor for equivalence before filing** — a mutation a correct implementation could also produce is not a test gap (recurring shapes: a guard duplicated by a downstream consumer, an opaque id used symmetrically on both halves of a pair, statement order the framework batches anyway, a defensive clause every caller pre-filters). **Every non-equivalent survivor is a finding:** exact before→after, the real bug class it simulates, and the specific missing assertion as the suggestion.
5. **All-killed is suspicious** — re-apply one mutation and watch it fail before believing the run.

**Grade survivors as test gaps, not live defects:** caps at medium (core outputs, gates, stats primitives), else minor.

## 4. Pass 2 — fresh-eyes verification, then personal checks

Consolidate and dedupe axis findings into a draft (axis reviewers and the mutation agent often flag the same gap — merge, keeping the mutation's concrete evidence). Then verify:

**Run the verifier by default. Skip the dispatch only when BOTH hold: the diff was small enough to review inline (section 3's ~300-line shortcut) AND Pass 1 produced no major finding** — then grep-verify the findings yourself against the pinned SHA. Finding count alone never gates the dispatch: a quiet Pass 1 on a large diff is where the sweep matters most, because a low count cannot distinguish a clean diff from a review that missed — on such a run the subagent's job is mostly the sweep, so dispatch it even with zero draft findings. The personal check below is required either way.

**Default:** dispatch ONE clean-context fresh-eyes subagent with the draft, the read worktree path, and the pinned head SHA (it must not redo section-1 setup). Prompt it to **refute** each draft finding, the same stance deep mode gives its skeptics. A verifier asked to "check" tends to confirm, and re-derivation only protects when the agent is hunting for the hole. For every draft finding it attempts to break the claimed mechanism against source and returns CONFIRMED (the refutation failed — cite the evidence that resisted it) / REFUTED (with evidence) / ADJUSTED (severity, anchor, scope). Then it sweeps the whole diff once more for what all axes missed. Both directions matter — past passes killed false positives AND found real bugs every time.

**Deep mode — only when the user explicitly asks for it ("deep review", "thorough", "paranoid") or the repo-nuances memory pins it for the repo:** replace the single verifier with two isolated jobs, dispatched concurrently:

1. **Blind fresh re-review (miss check):** ONE subagent given the sections 1–2 scope/format instructions, the read worktree path, and the pinned SHA but **none of the draft** — a verifier that has read the draft is anchored by it; this one hasn't. It reviews from scratch and returns its own graded findings; those absent from the draft are additions and go through the same skeptic check before acceptance.
2. **Isolated skeptics:** one skeptic subagent per draft finding, seeing **only that finding** plus the relevant code, prompted to refute it; verdicts as above. Findings sharing a code locus (same file AND same function / overlapping lines) may share one skeptic — max 3 per group, a separate verdict per finding, and it may recommend merging facets of one issue. Never group by theme, axis, or severity — a skeptic must never see the review's breadth.

Then merge in the main conversation (both modes):

- **Drop** REFUTED findings; **re-grade** where an ADJUSTED verdict is convincing. Sweep/blind-review additions join the final list only after surviving verification — in deep mode the skeptic check; in default mode the personal grep-verify below is the additions' gate (re-derive the mechanism yourself, not just the anchor).
- **Personally grep-verify** every surviving finding's mechanism and `file:line` anchor against the pinned SHA before writing the MD — subagent citations are necessary but not sufficient.
- **Anchor validation:** run the platform reference's anchor rules (GitHub rejects inline comments outside the diff; ADO does not).

## 5. Output — MD file, not chat

Save `review-findings-<id>.md` in the repo root (untracked), using the `<id>` from section 1. Header line first: PR id/URL, the reviewed head SHA, and the target branch — posting-time re-verification keys off that SHA. Sections:

1. **Pass 1 findings** — the draft list, graded.
2. **Pass 2** — per draft finding: CONFIRMED / REFUTED / ADJUSTED with the verifier's reason; then the additions (from the sweep, or the blind re-review in deep mode) and whether each survived verification.
3. **Final findings** — the merged list, organized by severity.

In chat, report only the file path and counts (e.g. "6 confirmed, 2 refuted, 1 adjusted, 1 added"). **Do not restate the findings in chat.** Finish by telling the user that saying "post" (or similar) will publish the final findings to the PR.

## 6. Posting (only when the user asks in a later message)

- **Re-verify first:** re-resolve the PR and compare its current head (`headRefOid` / `lastMergeSourceCommit`) to the head SHA recorded in the MD header. If the author pushed, `git fetch origin <branch>` and re-validate anchors at the new head before posting. Then, for each suggestion block, re-read the spanned lines at the new head: if they differ from the finding's recorded original lines, drop the block (the prose fix stays) — applying a stale block silently overwrites the author's newer code.
- **Staged (pending) mode — only when the user asks to hold publication** (they will submit the review themselves later; nothing may show to others until then): on GitHub, create the review in PENDING state per the reference's *Pending (draft) review mode*. Every other section-6 rule — re-verify, anchors, thread packaging, no test comments — applies unchanged at staging time. The findings MD's posting record marks the review PENDING with its id and the staged head SHA (full record contents per the reference), because submission is the user's later action, not this session's. **ADO has no equivalent** — a posted thread is visible to everyone the moment the POST returns (see the ADO reference's *No pending mode* note) — so on ADO say that plainly and leave the findings unposted in the MD until the user says post.
- Post per the platform reference. Shared rules regardless of platform:
  - Every posted comment is one self-contained, actionable finding — the team processes PR comments agentically. **No overall / summary / "great job" / non-actionable comments.** Every finding gets its **own inline thread** — never merge several minors into one comment (how threads are packaged into submissions is the platform reference's concern; GitHub's no-changed-line fallback to the review body is the one sanctioned exception).
  - **Suggestion blocks:** a finding whose fix is an exact replacement of a **small run of contiguous lines (roughly ≤10)** carries a one-click appliable suggestion block (mechanics per platform reference — anchoring rules differ and both platforms apply the block over the comment's anchor, so the anchor must span exactly the replaced lines). Before attaching, verify the spanned lines at the head SHA are byte-identical to the lines the finding recorded as replaced. Design-level fixes, multi-location fixes, larger replacements (describing the change is the review's job — writing it out is the author's), and findings whose true lines can't be anchored stay prose-only.
  - **Never post a test/ping comment to verify connectivity.** Post the first real finding directly and diagnose errors from its response.
  - After posting, confirm each thread is live at the right `file:line`, and update the MD to match **exactly** what was posted.
- The MD is the later reply-and-resolve reference. On a disposition ask (often a fresh session), use `review-findings-<id>.md` as the checklist and verify each fix actually landed in the code — not just that the author replied — before resolving. **A contradiction "fixed" by deleting one side is not a fix** — it closes the thread without answering which side was true, and in a diff it looks identical to a real fix. Confirm the surviving statement is the correct one before resolving. **Every** thread gets a reply + resolve — including deferrals and false positives (the reply carries the reasoning); never leave one open as an informal tracker. Follow the target repo's own PR-workflow conventions where they exist.

## 7. Applying findings (only when the user asks)

Applying is a separate ask, like posting — never apply automatically after a review. When asked:

- Work on the PR branch: if the user's tree is already on it, work there; otherwise ask before checking it out (or use a worktree) — section 1's never-switch-the-branch rule still holds, so never switch silently. Commit nothing unless told to. Author-owned records — a review-resolution spec, rationale only the author can state — are drafted **untracked** and named as drafts: they are the author's to write, not to find committed.
- **Run every new test against the pre-fix code first; it must fail there**, with the finding's own mechanism as the expected failure. A fix-shaped test that never went red proves nothing.
- Where the fix that lands differs from the finding's suggestion on contact with the code, record the delta and the reason in the findings MD — a posted review must not promise a fix the tree contradicts.
- Re-run the repo's gates after the last change and record the counts.
- Extend the findings MD with an applied section: what landed, what was **verified rather than assumed**, and a **Not closed** list for anything the fixes could not truly close. Never mark a finding closed because an edit near it landed.
