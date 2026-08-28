---
name: writing-code-comments
description: Use when writing or editing code and a comment is about to be added — new modules, bug-fix rounds, review-fix rounds, test files — and when auditing a diff's comments (your own or a delegate's) before commit.
---

# Writing Code Comments

The default for new code is **zero comments**, applied at write-time. Write one only after a real debugging session, review, or incident exposes a genuinely non-obvious gotcha — never preemptively for an imagined confused reader. The self-test: was *I* personally confused by this code in this session, or am I imagining a hypothetical reader? Imaginary — delete before the edit ships. This skill is the default bar `delegating-to-subagents`' diff audit checks against when the repo states none of its own.

Two pressures defeat this rule in practice, and both have a counter:

- **The fresh-bug-context temptation.** Fixing a finding, the urge is to write a fat explanatory comment while the context is fresh and "clean it up later". The later audit is the same self-test available now — and post-hoc stripping costs a second commit and a second review. One real review-fix cycle explained the same distinction six different ways across six files — roughly a hundred lines the author then asked to have removed. The cheapest edit is the one never written.
- **The new-module vacuum.** A new file has no surrounding style to restrain the JSDoc reflex, so every export gets a block. The default for a new module is still zero — the names are the spec. The one exception is matching existing file style: when every sibling in the file already carries a structured block, the new entry carries one too. Style earns the comment; a blank file does not.

Before any comment on code that has tests: **does a test already lock this in?** A test asserting the invariant IS the deviation-prevention mechanism; the comment adds nothing it can enforce.

## The shape, when one is earned

One to two lines, present tense, structured as **invariant + cost of violating it**: state what is true of the code now, then what breaks without it.

- ❌ (invented) "Each retry re-reads the live status and previously this captured the mid-loop override state, causing invalid self-transitions on later iterations, so we pin it here first." 
- ✅ (invented) "Pinned before the loop: live status flips mid-iteration, so reading it for the rollback target captures the wrong state."

Never historical or before/after framing — "used to fail", "tightened to require", "without this change", "would otherwise show". Narrative rots as the code evolves and duplicates what commit messages and test labels already record with provenance. The self-test: would the comment still be accurate after a refactor that preserves the invariant? If not, it narrates a fix, not the code. Before committing, grep the draft diff for "otherwise", "used to", "without this", "would" — each hit is a candidate.

## The tense test for future-work markers

Whether a "may need doing later" marker belongs in code is decided by grammatical tense, not subject matter:

- **Future-conditional — don't write it.** "When X gains a timeout, revisit this." A to-do disguised as documentation: it rots, and it only reaches someone already reading that line.
- **Present-indicative — allowed if non-obvious.** "Nothing else times out today." A current constraint that stops being written the moment it stops being true.

Same subject, opposite verdicts. Corollary: don't file an issue for it either — an issue is a commitment to do work, and a constraint that may never need action is not deferred work.

## When the fact is load-bearing, make it executable

Purely subtractive rules keep getting violated, because when a fact genuinely matters, "don't write it" offers no sanctioned home. The escape hatch neither keeps nor deletes the comment — it converts it (examples invented):

| The comment says | Make it |
|---|---|
| `assertEquals(total, 175) // 100 base + 50 surcharge + 25 fee` | `assertEquals(total, 100 + 50 + 25)` — the arithmetic is the expression |
| a preamble: "this fixture is deliberately not the default" | `assertNotEquals(FIXTURE, DEFAULT)` — an assertion that *fails* when broken; the preamble does not |
| "42 here is the retry ceiling" | a named constant |

If none of the three fit, the fact was not load-bearing — delete it.

## Facts whose source of truth lives elsewhere

Never bake into a comment a value that moves independently of it — a model name or version behind a role ("the synthesizer seat"), a default id, a port, a path. The real value lives in config or a constant, with a type-check or test guarding it; the comment has nothing guarding it and silently drifts. The tell: catching yourself *updating* a name inside a comment to match a config change — the fix is deleting the name from the comment, not bumping it. Describe the role, never the current occupant.

## A comment that excuses the design means the design is wrong

The strongest tell that a comment should not exist: it argues that something slightly-off is acceptable — "which is immaterial here", "harmless because", "acceptable since". That comment is a confession, not documentation. Fix the code so the argument is unnecessary: one fix summed two overlapping counts and carried three lines explaining why the double-count didn't matter to a threshold check; changing the parameter from a count to a boolean removed both the over-count and the comment — the code became correct instead of defensibly incorrect.

## Tests

A well-named test case is the spec; the assertions are the mechanism. Preambles ("Locks in…", "Mirrors the contract of…") and inline narration of a single assertion add prose to something already stated executably. The bug a regression test prevents is recorded in the test name and the commit — not in a paragraph above the test.

## Red flags

| Thought                                              | Reality                                                                        |
|------------------------------------------------------|---------------------------------------------------------------------------------|
| "I'll write it now and clean it up later"            | Later is a second commit and a second review. The self-test works now          |
| "A future reader might be confused here"             | Were *you* confused, this session? Imagined confusion earns no comment         |
| "It's a new file, it needs documentation"            | The vacuum is the trap. Names are the spec; zero is still the default          |
| "The comment explains the bug this prevents"         | The test name and commit already do, with provenance. State the invariant only |
| "This fact really matters"                           | Then make it executable — expression, assertion, or named constant             |
| "I'll note which model/version this defaults to"     | Nothing guards a comment. Name the role; the config owns the occupant          |
| "The double-count is harmless, I'll explain why"     | An excuse-comment is a confession. Change the design instead                   |
