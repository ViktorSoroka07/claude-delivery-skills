---
name: verifying-before-sending
description: Use when factual text is about to leave the workspace for someone else's surface — a message a teammate will act on, a comment on another person's PR or work item, instructions another engineer will build against, spec or wiki content other teams read — and earlier, before drafting such text at all.
---

# Verifying Before Sending

Code has gates; outward-bound prose usually has none — and its recipient acts on it without you present. The failure class this skill exists for: **text that reads fine and is wrong.** A blind verification pass once corrected four claims in a document that had already passed self-review — one flatly wrong, one too broad, one refuted, one attributed to the wrong test — and found a defect that would have failed every run of a process another engineer was about to build on. Three of the corrections were in text headed for surfaces other people build from.

Two neighbors own adjacent ground: review of *code* is review-pr's (and a repo's own review skills'), and a plan or spec's claims about outside systems are implementation-gates' Gate 2. This skill is for the prose around and beyond those: messages, comments on others' work, hand-off instructions, the spec's own sentences other teams will read. At the send moment itself, two siblings carry the other axes — `writing-for-audiences` (does the prose fit the reader); this skill owns whether the claims are true.

## Build the fact table before writing

Most defects in factual text trace to writing against incomplete facts — each review round then discovers one more missing column, and each fix round injects new errors. So invert the order: **before drafting, run one source sweep that enumerates the complete inventory in scope** — every item the text will make claims about, with the properties it will claim.

Then, for a send whose recipient will act on it, keep a claim-to-source table in the local draft file: one row per factual claim, naming the file and line that backs it. Mark any row with no backing; keep an unbacked claim only deliberately, and say in the local file where it came from instead. The table never ships with the text.

The table catches a class prose review misses. Reading a draft checks whether each sentence is *true*; asking where each claim is verifiable checks whether the text is *complete* — whether the recipient can act on it without you present. Under-specification and dropped qualifiers survive the first check and fail the second. One audited draft that "read fine" named one location where the source names two, overstated a finding's scope, and omitted the two places a find-and-replace must *not* touch.

## Pass 1 — the blind pass

Verify the claims **from a fresh context that has not seen the reasoning that produced them.** A verifier given the argument re-confirms it; a verifier given only the claims checks them.

- Hand over the claims, not the argument: numbered, each with its cited location, phrased neutrally, with an instruction to open the source rather than trust the citation.
- **Name the weakest claims and say why they are weak** ("rests on a grep of one directory", "this negative was read from a single function"). The strongest findings come from the claims flagged as shaky.
- **No crib sheet.** A ground-truth briefing transmits the author's own errors; the strongest verifier derives the facts from source. Graduated escalation — self-review, then checklist, then briefed reviewer — wastes rounds finding subsets of what the blind no-crib design finds at once.
- Split disjoint claim sets across verifiers rather than duplicating "check this document".

**What comes back is itself a set of claims** — delegating-to-subagents owns that rule; two instances specific to verifiers. Verify findings at source before adopting: in one round the verifier's central negative claim was refuted while three of its four findings held. And a verifier's *suggested fix* is a claim too: walk every prescribed behavior through both the healthy and the failure scenario before adopting it. One adopted-verbatim suggestion inverted on exactly the cases it was meant to guard — for those, zero matches was the healthy state, and the fix alerted continuously on a working system.

## Two traps to check by name

1. **Never assert absence from a truncated result.** A grep piped through `head` returned ten unrelated matches and was read as "the string does not appear" — the lines that mattered were below the cut. If the claim is "X is not in the source", re-run without the truncation.
2. **A negative claim needs the whole call path, not one function.** "This endpoint checks nothing about session state" came from reading a single validator; the entry point carried the check one delegation away. Same family: the wrong test, the right field on the wrong object.

## Pass 2 — the delta check, then stop

After fixing pass 1's findings against the fact table with minimal edits, run one **scoped delta check of only the changed sentences** — not a full re-review. Late-round defects are almost entirely *fix-injected*: in one long exercise, an entire round's findings were regressions introduced by the previous round's fixes, so the delta is where the remaining risk lives.

**Two autonomous passes is the cap.** A pass that found and fixed N defects is evidence of high defect density, not of a clean residual — but iterating until an empty pass does not self-terminate on dense factual text; observed over seven rounds, findings declined in severity and never reached zero. So: fix what the delta check finds if trivial; otherwise report it with an explicit residual-risk statement and hand the continue-or-stop decision to the requester. Never convert "declining severity" into "clean". This section owns the two-pass protocol; plan-feature's plan review and review-pr's fresh-eyes pass are its applications.

**Name the warrant, not the feeling.** Every confidence claim states what was checked and by what method — "every value compared against the source that produces it" — never how done it feels. Two reports sound equally confident while one rests on a checkable property and the other on having-looked; the reader cannot tell them apart unless the warrant is explicit. If the stopping rule has not been met, say so instead of projecting closure.

**Scale to blast radius.** Three tiers:

- **Text other people build from** — specs, hand-off instructions, wiki upstreams — gets the full protocol: fact table, claim-to-source table, blind pass, delta check.
- **An ordinary message the recipient will act on** gets the claim-to-source table and one ordinary review; buy the blind pass only when a load-bearing claim is shaky.
- **Text nobody acts on** — status notes, FYIs — gets a normal read and nothing more.

A scheduled human review with domain context substitutes for machine passes — don't buy a pass that duplicates a review already on the calendar.

## Red flags

| Thought                                     | Reality                                                                     |
|---------------------------------------------|------------------------------------------------------------------------------|
| "I already reviewed this myself"            | The author's context re-confirms the author's reasoning. The pass must be blind |
| "The draft reads fine"                      | Reading checks truth. The claim-to-source table checks completeness          |
| "The grep found nothing, so it's absent"    | If the output was truncated, absence was never tested                        |
| "The guard function doesn't check it"       | A negative claim needs the whole call path                                   |
| "Brief the verifier so it's efficient"      | The briefing transmits your errors. Hand claims, not the argument            |
| "The verifier suggested it, apply it"       | A fix is a claim. Walk it through the healthy *and* the failure scenario     |
| "Three passes found things — one more"      | Two autonomous passes, then report residual risk and hand over the decision  |
| "I'm confident it's correct now"            | Name what was checked and how, or the confidence is a feeling                |
