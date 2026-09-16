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

## Medium — real, narrower, or partly covered

- A review bot can resolve its own thread the moment a later push addresses it, before the author has replied, so a disposition pass that selects unresolved threads skips it and the reply the repo's reply-then-resolve convention still requires is never written; the listing's resolver and reply count identify such a thread without reading it, and the rule needs a shape that sends the reader to that one thread and no other — three wordings tested on the forge fixture each made the weaker model reply on it in five of five reps and each also made it read the human-resolved thread beside it (four of five) or edit that thread's code (one to three of five), which the same case forbids. → addressing-review-feedback
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
- An instruction file that ships inside the repository cannot explain a local-only exclusion by naming what it hides, because the explanation publishes exactly what the exclusion withholds; state the rule with its subject removed — that some files there are untracked deliberately and are never force-added — so the guidance survives without the content. → writing-for-audiences, audience gate
- A heading that states a count is an unverified claim about the body beneath it, and prose carries a wrong one indefinitely while a numbered list contradicts its own heading on sight; recompute every self-describing count from the artifact before the text leaves, and number a countable set rather than describing it. → verifying-before-sending
- A change that closes more than one tracker item is described one section per item, each with its own what-changed and not-changed, because a reader who arrives from one item must find its slice without reading the other's, and a single merged list makes every bullet look like it belongs to both. → writing-pr-descriptions
- A behavior change with a visible surface ships its description with one visible placeholder per screenshot, each named for the state it shows, and the screenshots reach the author as files to drop in, saved outside any temporary directory the harness may clear before they act, because no forge API uploads an image into a description and an unfilled placeholder is what stops the description from quietly shipping without them. → writing-pr-descriptions
- A change that makes a swallowed failure visible draws a review finding about the recovery path for that failure, which existed unchanged before the change; the reply names the evidence that the state predates it (a test or fixture that exercised it, the code path's age), scopes the recovery as its own item, and states which sub-case the change did make recoverable, because a reviewer reading only the diff sees the failure and the missing retry appear together. → addressing-review-feedback
- A test or coverage run started while the user's own push is in flight in the same checkout shares its build outputs with the pre-push hook and produces spurious failures on either side; never run the suite while a push is running. → implementation-gates
- A design that stops and asks the user when an automated step hits an ambiguity is wrong when the system can always produce a result and a later review step already judges every result; the stop adds a state, a button and a prompt the user must learn, while a flag on the result that names what to check keeps the flow moving and puts the judgement where it already happens. → plan-feature, design review
- A short reply can flip a standing rule when it is read as answering the wrong thread; when a reply could change a rule, ask which ask it answers before acting on it. → tracking-open-asks
- A confirmed mechanism is not a confirmed consequence: a finding names the failure the mechanism produces, and when the code path shows the worst case is waste rather than breakage, the grade follows the consequence. → review-pr, grading

## Declined, with the reason

- Widening a field to optional wakes a dormant optional-chain equality (`a?.x === y` holds when both are undefined). Tested on a fixture: the weaker model caught it unaided in every rep, so a sentence adds nothing.
- Passing the reading axes' predicted survivors to the mutation agent. The control mutation is already the agent's last step; the rest needs a multi-agent fixture to test and did not earn it.
- Tracker edit-history mechanics for a negative claim. The trap is already in verifying-before-sending; the API call is a lookup a session can make.
- Posting-script encoding traps. The content read-back already catches the outcome.
- History sanitizing as a skill. CONTRIBUTING's domain.
- Filing a new index line under its heading rather than at the file's end. Tested on a fixture: the weaker model filed it under the matching heading unaided in every rep, so a sentence adds nothing.
- Reading a survived row in a mutation record as the author's disclosed gap rather than a contradicted claim. Tested on the record fixture with a disclosed survivor: the weaker model kept it unflagged unaided in every rep (five hand runs and one runner run), so a sentence adds nothing.
- Re-running the check behind a convention recorded from absence, and re-running the duplicate test at close-out. Tested on the memory-store fixture with a "no CI" entry the checkout had since falsified: the weaker model checked it against the checkout and deleted it as answered by the repo, unaided, in five of five reps.
- A decision request stating the capability requirements the dependent work relies on. Tested on the report fixture with an options section carrying risks only: the weaker model pulled both requirements from the notes and set them beside the options, unaided, in five of five reps.
- An absence claim that must reach beneath the framework to the runtime platform. Tested on a fixture whose vendored platform already sets the header a change adds: the weaker model's correctness axis found the platform's line, called the change unobservable and the test tautological, unaided, in five of five reps.
