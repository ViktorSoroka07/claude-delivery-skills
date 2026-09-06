---
name: reporting-defects-upstream
description: Use when filing a defect, a data point or an improvement request into a system another team owns — a shared pipeline, a platform, an internal tool, a library — that they did not ask you to review; and when reviewing such a report before it is sent.
---

# Reporting Defects Upstream

A review is invited: someone put a change in front of you and asked what is wrong
with it. A report filed into another team's system is not. Nobody asked, the owner
reads it as a verdict on work they chose, and the same sentence that reads as
diligence in a review reads as a stranger grading them.

Everything true in the report stays. What changes is standing: you are describing
a system you use and they own, so the report supplies evidence and the owner keeps
every decision that follows from it.

Two sibling skills fire on the same send, one axis each: `verifying-before-sending`
owns whether the claims are true, and `writing-for-audiences` owns whether the prose
fits its reader. This skill owns whether the report is yours to make in that shape.

**Boundary against `review-pr`:** that skill governs findings on a change you were
asked to review, where its "issues only, no praise" is right — the author knows what
works and praise is padding. Here it inverts, for the reason in the next section.

## State the true proportion, which is accuracy and not manners

A report that lists only failures implies the system mostly fails. When it does not,
that is a false statement about size, and the owner is right to discount the whole
report for it. So the opening carries the real share: what the system got right,
measured the same way as what it got wrong.

This is not an instruction to open with something nice. Flattery and a made-up
positive are the same defect as an overstated failure — both misdescribe the system.
Where nothing worked, say that; where three of four categories were clean and one
was noise, the report says so and is stronger for it, because it has just
demonstrated that its numbers are worth trusting.

The test: **could the owner learn the size of the problem from your first paragraph,
and would that estimate survive reading the rest?**

The sample matters as much as the count. Reviewed work is a biased sample — its
defects are the only ones anyone has looked for — so a report built from the
best-documented cases indicts whoever was most diligent, or whoever happened to
be reviewed. State the failure class generically rather than through the cases
that surfaced it; put every defect count beside the coverage that produced it
(five defects across the four changes reviewed, of forty), or the count reads as
a quality signal when it is an attention signal; and never assert how the work in
a shared repository was produced — by a person or by a tool — from its shape.

## Decisions that belong to the owner

These are the ones that survive editing, because none of them contain a rude word.

- **Never price their work.** "This is a recombination of parts you already have,
  not new machinery" is an estimate of effort in a codebase you do not maintain.
  State what exists that looks reusable, and hand the sizing back explicitly.
- **Never rank their priorities.** A heading like "why this is worth fixing rather
  than working around" settles the question before the owner has read the argument.
  Give the consequence and the frequency; the ranking is theirs.
- **Suggestions are options, not instructions.** "Move the check into the creation
  step" is an order; "one option would be to move the check into the creation step"
  is the same engineering with the decision left where it belongs.
- **Do not assert safety in their codebase.** "So it is safe to apply everywhere"
  is a claim only the owner can make. Say what the change would not affect, and let
  them conclude.

## Where the edge actually is

Word-level tone checks pass over all of the above, which is why a scan for rude
vocabulary is not the review. It does catch a second, cheaper class worth removing:
verbs and images that dismiss the owner's work rather than describe it — output that
"went in the bin" rather than "was declined", a component that "posts whatever comes
back" rather than "posts what it receives without a duplicate check", a feature that
is "decorative" rather than "unusable by the people it is offered to". Same fact,
none of the disposal imagery.

Run both passes. The vocabulary one is mechanical; the decisions one requires
re-reading each sentence and asking whose call it takes.

**A word list built from the slips you already found will keep missing the one you
have not.** Assembling it from your own draft's known offenders turns the pass into a
re-check of solved problems: it fires on the two images you had already noticed and
walks past the third, because the list encodes your blind spot rather than the
category. Scan for the category — words that rate the work instead of describing it —
and treat any hit list as a prompt to re-read, never as a clearance.

**The title is the surface that repeats.** A body is read once; its title is re-read
in every list, notification and search result the owner sees for the life of the item.
A judgment word survives longest exactly where it does the most damage, and a pass
that checks the body and forgets the title will leave it there — which is the common
shape of this failure, because the body is where the editing attention goes.

## Shape

- **One mechanism per report.** Two defects that share a root but need different
  fixes are two reports that cross-reference, not one long one. The owner triages
  and schedules them separately, and a bundle forces them to split it by hand.
- **When one report is split out of another, its evidence moves with it.** Leaving
  the diagnosis in both is worse than never splitting: the two copies drift as soon
  as either is edited, each carrying equal authority, and the parent now reads as
  partly about the child's subject, so it gets routed to whoever owns that instead
  of whoever owns the parent's. The parent keeps a pointer and the one sentence
  saying why it still stands without the child.
- **Evidence before diagnosis before suggestion.** What you observed, then where in
  their code it appears to come from, then what might be done. An owner who
  disagrees with the diagnosis can still use the evidence.
- **Hedge the diagnosis, not the evidence.** You read their code from outside:
  "where it looks like it comes from" is honest and costs nothing, while a hedged
  observation ("we may have seen some duplicates") wastes the one thing you have
  that they do not.
- **Quote their own code and comments back** as the anchor, not your paraphrase of
  it. A contradiction between two parts of their system is best shown by putting
  the two next to each other.
- **Say what you want.** A report that ends without an ask leaves the owner guessing
  whether it is a bug, a request, or a complaint.

## Red flags

| Thought | Reality |
|---|---|
| "Findings only — praise is padding" | True for an invited review. Here, omitting what works misstates the size |
| "I'll open with something positive to soften it" | Flattery is the same defect as an overstated failure. Give the real proportion |
| "This should be a quick change for them" | You do not maintain it. Name what looks reusable, hand back the sizing |
| "Explaining why it matters more than the workaround" | That is their ranking to make. Give consequence and frequency |
| "Move the check into X" | An order to a peer. "One option would be to move…" |
| "The tone scan came back clean" | It only reads words. The riskiest sentences take a decision, politely |
| "My word list found nothing" | A list built from slips you already caught encodes your blind spot. Scan the category |
| "The body reads well now" | The title is what repeats in every list. Check it last, and check it separately |
| "Both problems have the same root, so one report" | Different fixes, different tickets. They triage separately |
| "I split it out and cross-referenced both" | Did the evidence move, or is it in both? Two copies drift, and triage routes the parent wrong |
| "I'll soften the observation so it lands better" | Hedge the diagnosis. The observation is the part they cannot get themselves |
