---
name: explaining-changes-visually
description: Use when the requester asks for a visual or a page that explains what a piece of work fixed, built or found in simple terms — "make me a visual of what we fixed", "explain this to my team", "something I can show at the meeting", "explain it in plain words with pictures" — so they can retell it without the session.
argument-hint: "[the change: a PR, issues, a branch] [the audience]"
license: MIT
---

# Explaining Changes Visually

A page a requester can open at a meeting and retell from, without the session. The test is the retelling: someone who never saw the work reads the page once and can explain what was wrong, for whom, and what is true now. Pictures serve that test; they never replace the plain words.

**Untested.** This skill landed without the baseline eval CONTRIBUTING asks of a new skill; its entry in `BACKLOG.md` holds the test still owed. Treat its wording as a first draft until that run exists.

`writing-for-audiences` owns the register; `verifying-before-sending` owns the claims. This skill owns the page's shape.

## Plain words first

The page is written for the requester's team, not for the engineers who built the change:

- **The short version is a story with labelled lines**, one bold label each: what the system does, what went wrong, what it cost the person, what is true now. No mechanism in this section.
- **Every word the screen or the log shows gets translated** in a section of its own, as a quoted first-person sentence and what it means for the person: a status reading "aborted" is *"Something stopped me before I finished."* A code, a status, a symbol such as "≥" each get one.
- **A card per change: its title is the symptom as the person met it**, its Before and Now are what they saw and see, with the real numbers from the run. File paths, function names and wire terms stay out of the cards; where a reader will ask how, the answer goes in the questions section.
- **The questions section answers what the audience will ask back**, each with its evidence: a scope decision, something left out on purpose, a difference between two cases that looks arbitrary.
- **The glossary defines every term the page uses**, the product's own names included. A term defined nowhere is the sentence the reader gets stuck on.

## Pictures where the change is a structure

Draw only what a sentence cannot carry:

- **One diagram of the flow** the person's request passes through, with a lettered marker under the stage each change lands in; the letters match the cards' tags.
- **A small picture inside a card whose before-and-after is a structure**: rows that count or do not toward a total, a grid with a column that should not exist, a step that moved. Two sentences describing a grid are slower to read than the grid. A change that is a sentence (a clearer message) stays a sentence.

## Build it

1. Collect the facts from the record — the PR or issues, the commits, any live run's evidence — before writing; a claim with no source is not on the page.
2. Copy [`template.html`](template.html) and fill it: it carries the palette (light and dark), the reading column, the diagram, the card, picture, question and glossary styles. Replace every `{{…}}`; delete a section that has nothing to say rather than filling it.
3. Open the page in a browser before handing it over, at a desktop width and a phone width: every diagram label inside its box, no section overflowing sideways, each picture's numbers matching its card's text.
4. Deliver it as a local file. Publish it only when the requester asks.
