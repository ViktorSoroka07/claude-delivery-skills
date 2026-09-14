# Backlog

Mechanisms learned in real work that have not yet been re-derived into a
skill. Each entry is one sentence with no proper nouns — what goes wrong and
why — and names the skill it is aimed at. An entry leaves this file in the
commit that promotes it (re-derived per CONTRIBUTING, never pasted) or
declines it; a declined entry moves to the last section with its reason, so
it is not queued twice. A review-pr or agent-contract change runs the wording
test first, and a baseline that already passes means decline, not land.

Nothing here is pre-approved; the tiers are the maintainer's current read.

## Strong — prevents a real failure, general

- Reading a test run needs two signals, not one: a tally line can print on failure and a zero-test run exits green, while a coverage gate or tooling error exits non-zero with no failing assertion; a kill is a non-zero failure count AND the failure signal. → implementation-gates
- A mutation sweep runs the bare test runner, never a command that also enforces a coverage threshold: the mutation lowers coverage and the gate reports a false kill. → implementation-gates
- A survivor found against a scoped test subset is not a finding until the full suite confirms it; a value the scoped area exports may be pinned elsewhere. → implementation-gates
- A filter whose parameter is silently ignored returns the whole population and is indistinguishable from a real count; every count-bearing query gets one impossible-value control call before its number is used. → implementation-gates, Gate 2
- A committed credential is a "rotate" finding, never a "remove" one — history keeps the value reachable on every branch that contains the commit. → review-pr
- A repo's lint script that chains fixers mutates the tree while a reader agent runs it; run each check in its non-fixing form in the read worktree. → review-pr, repo-conventions axis
- A pre-commit hook that stashes and restores the tree can delete untracked files, so the review's findings file in the repo root can vanish on the author's next commit; decide where the file lives. → review-pr, output location (a design decision, not a sentence)
- A convention recorded from observed absence ("only these statuses exist", "no PR route") expires silently when the repo adds the thing; record the check that established it and re-run the check, not the conclusion. → maintaining-project-memory
- A ticket asking another team for a decision states the capability requirements the dependent work relies on, not only the risks, or the decider optimises the only dimension shown. → reporting-defects-upstream
- An assertion that an event did not occur passes silently when its observation window closes before the action runs or when its matcher has quietly stopped matching, so the window covers the whole action and any guard proving the matcher still fires observes an event the system under test produced, never a literal restated in the test. → implementation-gates
- A written convention cited against a change is measured against the surrounding file first: where the neighbouring code has never followed it, the gap is the repo's own drift and filing it as this change's defect asks one author to be the first to comply. → review-pr, repo-conventions axis
- A branch created from a remote ref inherits that ref as its upstream, so a later plain push from it lands on the remote's default branch; create it with `--no-track` (or unset the upstream afterwards) and, when the user pushes themselves, hand over an explicit `push -u origin <name>` and confirm the branch shows no upstream before handing over. → finishing-a-development-branch, landing-merged-work
- "Ready to push" is a done-claim whose only evidence is the pre-push chain run on the final committed tree with a clean status, from the repo root, with its last line quoted; a gate that ran before the last edit or from a subdirectory, a hook that ran on an earlier commit, or a push the harness denied is not that evidence, and the user pushing into a failure is the symptom. → implementation-gates
- Outward-facing output is published only once every dispatched agent has reported: confirm none is still running rather than watching the one whose result you happen to be waiting for, because work you dispatched yourself is part of the job and a closing report that lands after the conclusion means the conclusion was premature. → verifying-before-sending, review-pr posting
- A finding that states an open question inside itself is a signal to hold, never a disclaimer that licenses publishing, because the pending answer can invert its grade and consequence after the author has already read it; the honesty of the caveat is what makes it look publishable. → review-pr, posting reference
- A surviving mutation means either the assertions are weak or the code has no observable effect, and only deleting the feature outright separates the two — so where a change's effect is asserted indirectly, one mutation removes the whole registration or call site, and a suite still green proves the assertions pass with the feature absent. → implementation-gates
- A claim that nothing already supplies the behaviour a change adds is an absence claim about every layer beneath the one enumerated, and stopping at the framework's own packages leaves the runtime platform underneath unchecked — where a built-in already setting that behaviour makes the new code's effect unobservable and the test asserting it tautological. → review-pr, absence-claim rule

## Medium — real, narrower, or partly covered

- Compound mutations are split, since a kill proves some operand is pinned, never all; a mutation that fails to compile is evidence in neither direction and is restated until it builds. → implementation-gates
- Negative-space properties (a key that must be absent, a value that must be undefined, attributes on a hand-rolled region) are a survivor class to probe by name; a component test can satisfy a coverage gate without the wiring executing. → implementation-gates, survivor table
- A spec's out-of-scope deferral binds only while the sentence justifying it holds; a change that removes the precondition is no longer covered by the deferral. → review-pr
- A generated artifact unchanged after a source edit is not evidence regeneration failed; confirm what the generator embeds from that source before reporting a missed sync. → review-pr, doc-vs-code axis
- When a message and the document it cites ship together, every figure and status the two share is checked to match; pushback is answered from the document. → verifying-before-sending
- A headless sub-agent can write into the operator's real persistent memory and the write survives the session being killed; snapshot and restore that store around harness runs. → delegating-to-subagents
- When the remote uses an SSH host alias, platform and slug cannot be parsed from the URL and must be passed to the platform CLI explicitly. → review-pr, platform step
- A tool that sets a repo-local git identity for its own commits leaves it in place for everyone; check the repo-local identity before a session's first commit. → implement-plan
- In teaching or lesson code the comments are the deliverable, beside the line each explains; this inverts the zero-comment default. → writing-code-comments, as a boundary
- A file in a repository an outside party can read never names who made a mistake or narrates corrections done on someone's behalf; the record of an action goes to the tracker. → writing-for-audiences, audience gate
- A policy hook that swallows its dependency's failure as "nothing found" fails open; enforcement code blocks on any setup error and fails open only on a positive allow-list of transient signatures. → no home yet; a candidate for a skill on writing enforcement hooks
- Prose cross-references no tool checks dangle silently when a change renumbers or removes sections; grep inbound citations before merging such a change. → review-pr, doc-vs-doc
- A tracker item's state lags work that lands through a path the tracker does not sync back; read the item's links before treating an untouched state as no work done. → landing-merged-work
- A file path cited in an already-sent message cannot be repaired, so a rename needs a citation sweep that includes sent messages, not only the repo. → writing-plan-docs
- Write identifiers, never point-in-time states, into prose that outlives the moment; an id stays true while "still open" sealed beside it rots. → writing-plan-docs
- A permission deny rule matches anywhere in a compound shell command, so chaining a denied command after an allowed one kills both; run the allowed step in its own call. → no home yet; a harness trap
- A containment query that matches nothing still exits successfully, so a check chained on its exit status reports a commit as pushed when no remote holds it; read the output, not the status. → addressing-review-feedback, reply timing
- A green pipeline says the suite passed, not that the change's new tests ran — a shard filter, a path glob, or a spec file outside the selected set drops them with no signal — so execution is confirmed by finding each new test's own name in the run log before its assertions are trusted. → implementation-gates
- A memory entry passes the duplicate test only at the moment it is written, and shipped code that absorbs the procedure it documents turns it into a stale duplicate with no signal, because the merge touches no memory file; the close-out re-runs that test against the entries the merged work touches and cuts each back to the residue the code cannot report. → maintaining-project-memory
- An instruction file that ships inside the repository cannot explain a local-only exclusion by naming what it hides, because the explanation publishes exactly what the exclusion withholds; state the rule with its subject removed — that some files there are untracked deliberately and are never force-added — so the guidance survives without the content. → writing-for-audiences, audience gate
- A heading that states a count is an unverified claim about the body beneath it, and prose carries a wrong one indefinitely while a numbered list contradicts its own heading on sight; recompute every self-describing count from the artifact before the text leaves, and number a countable set rather than describing it. → verifying-before-sending
- A change that closes more than one tracker item is described one section per item, each with its own what-changed and not-changed, because a reader who arrives from one item must find its slice without reading the other's, and a single merged list makes every bullet look like it belongs to both. → writing-pr-descriptions
- A behavior change with a visible surface ships its description with one visible placeholder per screenshot, each named for the state it shows, and the screenshots reach the author as files to drop in, saved outside any temporary directory the harness may clear before they act, because no forge API uploads an image into a description and an unfilled placeholder is what stops the description from quietly shipping without them. → writing-pr-descriptions
- A change that makes a swallowed failure visible draws a review finding about the recovery path for that failure, which existed unchanged before the change; the reply names the evidence that the state predates it (a test or fixture that exercised it, the code path's age), scopes the recovery as its own item, and states which sub-case the change did make recoverable, because a reviewer reading only the diff sees the failure and the missing retry appear together. → addressing-review-feedback
- A mutation that fails more tests than there are assertions targeting the mutated behaviour may be failing them through an unrelated crash rather than through any assertion, so a kill is attributed by reading the failing test names and the error, never by the count alone. → implementation-gates

## Declined, with the reason

- Widening a field to optional wakes a dormant optional-chain equality (`a?.x === y` holds when both are undefined). Tested on a fixture: the weaker model caught it unaided in every rep, so a sentence adds nothing.
- Passing the reading axes' predicted survivors to the mutation agent. The control mutation is already the agent's last step; the rest needs a multi-agent fixture to test and did not earn it.
- Tracker edit-history mechanics for a negative claim. The trap is already in verifying-before-sending; the API call is a lookup a session can make.
- Posting-script encoding traps. The content read-back already catches the outcome.
- History sanitizing as a skill. CONTRIBUTING's domain.
- Filing a new index line under its heading rather than at the file's end. Tested on a fixture: the weaker model filed it under the matching heading unaided in every rep, so a sentence adds nothing.
