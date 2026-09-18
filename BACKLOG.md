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

- A committed credential is a "rotate" finding, never a "remove" one — history keeps the value reachable on every branch that contains the commit. → review-pr
- A rule that binds a dispatched reviewer does not bind the orchestrator when it does the same work itself: on a diff small enough to review inline, three reviews in ten ran the repo's fixing lint in the tree they were reading, though the conventions axis is told to use the non-fixing form; the gate rule belongs to whoever runs the gate, stated where the inline path reads it. → review-pr, the inline path of Pass 1 (test on the axis fixture with the lint-log grader; baseline 3 of 5 clean)
- An audit that re-applies two or three rows of a written verification record takes them off the top unless told how to draw them, and one audit in five sampled two of four rows and missed the contradicted one; the sample is drawn from across the record, each row alone against a green baseline, and a passing sample says nothing of the rows it did not touch. → review-pr, record audit (test on the record fixture with the contradicted-claim grader)
- A short reply can flip a standing rule when it is read as answering the wrong thread; when a reply could change a rule, ask which ask it answers before acting on it. → tracking-open-asks

## Medium — real, narrower, or partly covered

- A review bot can resolve its own thread the moment a later push addresses it, before the author has replied, so a disposition pass that selects unresolved threads skips it and the reply the repo's reply-then-resolve convention still requires is never written; the listing's resolver and reply count identify such a thread without reading it, and the rule needs a shape that sends the reader to that one thread and no other — three wordings tested on the forge fixture each made the weaker model reply on it in five of five reps and each also made it read the human-resolved thread beside it (four of five) or edit that thread's code (one to three of five), which the same case forbids. → addressing-review-feedback
- A spec's out-of-scope deferral binds only while the sentence justifying it holds; a change that removes the precondition is no longer covered by the deferral. → review-pr
- A generated artifact unchanged after a source edit is not evidence regeneration failed; confirm what the generator embeds from that source before reporting a missed sync. → review-pr, doc-vs-code axis
- When a message and the document it cites ship together, every figure and status the two share is checked to match; pushback is answered from the document. → verifying-before-sending
- A tool that sets a repo-local git identity for its own commits leaves it in place for everyone; check the repo-local identity before a session's first commit. → implement-plan
- In teaching or lesson code the comments are the deliverable, beside the line each explains; this inverts the zero-comment default. → writing-code-comments, as a boundary
- A policy hook that swallows its dependency's failure as "nothing found" fails open; enforcement code blocks on any setup error and fails open only on a positive allow-list of transient signatures. → no home yet; a candidate for a skill on writing enforcement hooks
- Prose cross-references no tool checks dangle silently when a change renumbers or removes sections; grep inbound citations before merging such a change. → review-pr, doc-vs-doc
- A tracker item's state lags work that lands through a path the tracker does not sync back; read the item's links before treating an untouched state as no work done. → landing-merged-work
- A containment query that matches nothing still exits successfully, so a check chained on its exit status reports a commit as pushed when no remote holds it; read the output, not the status. → addressing-review-feedback, reply timing
- A heading that states a count is an unverified claim about the body beneath it, and prose carries a wrong one indefinitely while a numbered list contradicts its own heading on sight; recompute every self-describing count from the artifact before the text leaves, and number a countable set rather than describing it. → verifying-before-sending
- A change that closes more than one tracker item is described one section per item, each with its own what-changed and not-changed, because a reader who arrives from one item must find its slice without reading the other's, and a single merged list makes every bullet look like it belongs to both. → writing-pr-descriptions
- A behavior change with a visible surface ships its description with one visible placeholder per screenshot, each named for the state it shows, and the screenshots reach the author as files to drop in, saved outside any temporary directory the harness may clear before they act, because no forge API uploads an image into a description and an unfilled placeholder is what stops the description from quietly shipping without them. → writing-pr-descriptions
- A change that makes a swallowed failure visible draws a review finding about the recovery path for that failure, which existed unchanged before the change; the reply names the evidence that the state predates it (a test or fixture that exercised it, the code path's age), scopes the recovery as its own item, and states which sub-case the change did make recoverable, because a reviewer reading only the diff sees the failure and the missing retry appear together. → addressing-review-feedback
- A design that stops and asks the user when an automated step hits an ambiguity is wrong when the system can always produce a result and a later review step already judges every result; the stop adds a state, a button and a prompt the user must learn, while a flag on the result that names what to check keeps the flow moving and puts the judgement where it already happens. → plan-feature, design review
- A confirmed mechanism is not a confirmed consequence: a finding names the failure the mechanism produces, and when the code path shows the worst case is waste rather than breakage, the grade follows the consequence. → review-pr, grading
- A file-writing tool can turn an escape sequence in a posting script into the character it names, and the content read-back cannot see it, because the corruption happens before the payload is built and the stored text then matches the sent text exactly; the script asserts that no invisible or control characters are in any body before it sends. → review-pr, posting reference (distinct from the declined encoding-traps entry, whose outcome the read-back does catch)
- A proposed value judged against the values a codebase already uses is supported only by the precedents that serve the same purpose, because a raw tally across fields holding names, record descriptions and user-typed explanations reads as either no convention or the most common number, while grouping the fields by what they hold shows which precedent applies; group by purpose before comparing values. → implementation-gates, evidence for a claimed value
- A memory entry passes the duplicate test only at the moment it is written, and shipped code that absorbs the procedure it documents turns it into a stale duplicate with no signal, because the merge touches no memory file; the close-out re-runs that test against the entries the merged work touches and cuts each back to the residue the code cannot report. → maintaining-project-memory (not yet tested: the fixture has no entry that merged code made redundant)
- A file an outside party can read never names who made a mistake, narrates a correction done on someone's behalf, or explains a local-only exclusion by naming what it hides, because the explanation publishes what the exclusion withholds and the record of an action belongs in the tracker; state such a rule with its subject removed. → writing-for-audiences, audience gate
- Prose that outlives the moment it was written carries identifiers, never point-in-time states, and a file path cited in an already-sent message cannot be repaired, so a rename needs a citation sweep that includes sent messages, and an id stays true while a sealed "still open" rots. → writing-plan-docs

## Declined, with the reason

- Widening a field to optional wakes a dormant optional-chain equality (`a?.x === y` holds when both are undefined). Tested on a fixture: the weaker model caught it unaided in every rep, so a sentence adds nothing.
- Passing the reading axes' predicted survivors to the mutation agent. The control mutation is already the agent's last step; the rest needs a multi-agent fixture to test and did not earn it.
- Tracker edit-history mechanics for a negative claim. The trap is already in verifying-before-sending; the API call is a lookup a session can make.
- Posting-script encoding traps. The content read-back already catches the outcome.
- History sanitizing as a skill. CONTRIBUTING's domain.
- Filing a new index line under its heading rather than at the file's end. Tested on a fixture: the weaker model filed it under the matching heading unaided in every rep, so a sentence adds nothing.
- Reading a survived row in a mutation record as the author's disclosed gap rather than a contradicted claim. Tested on the record fixture with a disclosed survivor: the weaker model kept it unflagged unaided in every rep (five hand runs and one runner run), so a sentence adds nothing.
- Re-running the check behind a convention recorded from absence. Tested on the memory-store fixture with a "no CI" entry the checkout had since falsified: the weaker model checked it against the checkout and deleted it as answered by the repo, unaided, in five of five reps.
- A decision request stating the capability requirements the dependent work relies on. Tested on the report fixture with an options section carrying risks only: the weaker model pulled both requirements from the notes and set them beside the options, unaided, in five of five reps.
- An absence claim that must reach beneath the framework to the runtime platform. Tested on a fixture whose vendored platform already sets the header a change adds: the weaker model's correctness axis found the platform's line, called the change unobservable and the test tautological, unaided, in five of five reps.
- Snapshotting the memory store around harness runs. A procedure for the operator, not a rule a session negotiates: no fixture can show the weaker model failing without it.
- Passing platform and slug explicitly behind an SSH host alias. A lookup for the platform reference, not a judgement; one line there when it is next touched.
- A deny rule matching anywhere in a compound command. The harness's own behaviour, recorded where the operator configures it; a skill cannot teach it and no fixture holds it.
- Never running the suite while a push is in flight. No fixture can hold a push in flight for a run to collide with, so the sentence cannot be tested; the trap stays in the operator's own notes.
- Verifying placement through the per-comment endpoint when the per-review listing returns null fields. A lookup for the platform reference, not a judgement; one line there when it is next touched.
