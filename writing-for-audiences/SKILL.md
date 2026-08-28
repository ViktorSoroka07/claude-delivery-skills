---
name: writing-for-audiences
description: Use when writing prose a specific person or audience will read, act on, or hear — a report, a deck or speech, teaching material, an explanation, a message — and when a reader signals they did not understand ("what is this number of?", "explain it in simpler terms", "I don't get what you mean").
---

# Writing for Audiences

Two failure modes, both invisible to the writer: prose the reader **cannot use** (wrong register, numbers without bases, mechanics instead of meaning) and prose the reader **should not have** (internal detail carried past its boundary). Both survive self-review, because the writer reads with their own context and their own entitlements.

Three skills fire at the send moment, one axis each: `verifying-before-sending` owns whether the claims are true, and this skill owns whether the prose serves and fits its reader.

**When a reader signals non-understanding, the failure is the level the explanation was pitched at, not the reader's attention.** Re-explain the mechanism from its concepts in plain language; do not repeat the same sentence slower.

## Match the register to the reader

- **Plain words over idioms.** An idiom costs a non-native reader a re-read and translates badly out loud; real corrections have flagged phrases as mild as "in earnest" and "one-and-done". Jargon is replaced by the concrete action it stands for.
- **Terms of art defined at first use** — in a deliverable, a reader should never need a follow-up question to act on it.
- **Text that will be spoken must survive being spoken:** one-breath sentences, no constructions the speaker will stumble on.
- **An analogy earns its keep on a genuinely complex mechanism** — and gets dropped the moment the reader waves it off. The analogy serves the reader, not the explanation.

## Every number carries its base — and its conditions

A figure without its base is noise the reader must interrogate: "40%" invites "of what?" — write "40% of new signups" (invented). Two further rules the base rule implies:

- **Numbers measured under different conditions are not one comparison.** Two services' error rates — one measured with retries enabled, one without (invented) — presented side by side manufacture a ranking the data does not support. Report them separately, each with its measurement conditions named.
- **A derived number leaks what its parts conceal.** If one component must stay private, check that no published total lets a reader recover it by subtraction.

## The audience gate — strip what the reader is not entitled to

Every artifact written for a surface others can see is scoped to that audience before it leaves. What crosses the boundary: facts, scope, asks. What does not: internal file paths and record identifiers, tooling and vendor names the audience has no reason to learn, personal scheduling, routing and escalation strategy, severity framing, and third parties' verbatim private words — those get paraphrased, and audited by extracting every quoted span, not by one pattern search.

- **Re-derive the text for the audience; never condense the internal version.** Condensing carries internals along — one task description condensed from an internal backlog delivered a responsiveness complaint, escalation framing, and a named escalation target onto a shared board. Writing fresh from "what does this reader need" does not.
- **A mundane internal choice, written down, can read as strategy.** An ordinary staffing arrangement documented as "X is deliberately not told" turned logistics into apparent secrecy. If an aside is incidental to the document's subject, it does not belong in the document — state the operational fact (a date, an owner) without narrating who gets told what.
- **Edits reduce the surface; they do not unsend.** Shared platforms keep history, so the gate applies at creation time, not as cleanup.

## Meaning over mechanics

For a non-implementer audience, every highlight is an action and what it bought the reader — never process detail ("merged", "suite green", "standard upgrade pattern"), which reads as noise to anyone who cannot act on it. And when your text sits alongside companion surfaces — another presenter's section, a linked document — **reference and attribute rather than re-announce**: duplicated content forces the audience to sit through it twice and drifts against the original.

## Format for actual use

Ask how the text will be consumed and shape it for exactly that:

- **Copied** — no formatting gutters (quote markers, table pipes) the user must strip before pasting.
- **Spoken** — breath-length sentences, no parentheticals.
- **Skimmed** — the point first; an ask never trails a long paragraph, because the trailing clause is what skimming skips.
- **Decoded** — a figure or diagram carries its own legend; a reader with no context must be able to say what each element means.

## Red flags

| Thought                                          | Reality                                                                     |
|--------------------------------------------------|------------------------------------------------------------------------------|
| "The percentage is obvious from context"         | The reader asks "of what?" — name the base in the sentence                  |
| "These two numbers belong in one table"          | Different measurement conditions make it a false comparison. Separate, with conditions |
| "I'll condense the internal write-up for them"   | Condensing carries internals along. Re-derive from what this reader needs   |
| "It's only visible to teammates"                 | Entitlement is per-audience, not internal-vs-external. Scope it anyway      |
| "I'll clean the shared copy up afterwards"       | History keeps the original. The gate applies at creation time               |
| "The reader will ask if they don't understand"   | A re-ask is the failure signal, and most readers won't ask — define terms up front |
| "The detail proves we did the work"              | A non-implementer reads mechanics as noise. Action → what it bought them    |
