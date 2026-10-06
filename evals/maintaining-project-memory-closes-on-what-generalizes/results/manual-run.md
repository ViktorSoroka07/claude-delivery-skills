# maintaining-project-memory-closes-on-what-generalizes

The backlog entry under test: a session's closing list of mechanisms to promote is chosen by what was most vivid in that session rather than by what would recur elsewhere, so the dramatic defect is offered while the quiet mechanism that generalises is not. Built before any draw, and revised on a blind verifier's findings before the first draw (`evals/results/task72-verifier/report.md`, V1-V15); nothing below is measured yet.

## The four questions, answered before any wording

**1. Which moment carries the rule.** The rule a closing list follows lives only in the always-on brief ("Memory stays minimal; mechanisms surface": a mechanism that generalizes, statable in one sentence with no proper nouns, is named in the closing message with its target skill); no skill states it (the plan's task 67). A rule in `maintaining-project-memory`'s body reaches only a closing that loads the skill. Read from the operator's own session transcripts that carried the brief: 52 closing messages named mechanisms with a target skill, and the skill had loaded before the closing in 20 of them - 15 of 30 in this repository, 5 of 22 elsewhere (the count is a heuristic: a last message naming "mechanism" and a plugin skill, checked on four of them, three closing lists and one report of a backlog commit). So the brief is the one text every closing has in hand, and a wording round measures the brief's core; the full statement goes into the skill's closing section beside "End a continuing session with the literal starter prompt", as task 67 asks, and lands after the round - the treated arm carries the brief change alone, since the skill loads live from each arm's worktree.

**2. What the check is.** Three candidates, each tried on the entry's two sightings. *Recurrence* (met in other work or other places) explains the second sighting's drop, a fact met once - but a closing that filters on it drops every first sighting, which is exactly what the backlog's intake exists to hold until a second arrives, so recurrence is the intake's filter and not the closing's. *The backlog search* turns a candidate into a sighting rather than a line; it decided neither sighting, and CLAUDE.md's Backlog section already owns it for whoever files the entry. *The record* (already stated where the next occurrence will meet it) decided the second sighting's drop - but outside this repository a comment in one project's file does not reach the next repository, so it is not a check a closing in client work can apply. *Generality*, the entry's own test (would it fire in an unrelated repository), decided the first sighting: two vivid candidates dropped and one mentioned in passing promoted. The brief already names the criterion ("a mechanism that generalizes - statable in one sentence with no proper nouns"); what the sightings show is that it is not applied to each candidate before the list is chosen, so the list follows salience. The check under test is therefore generality, applied per candidate before the list is written, with its two directions: drop a vivid candidate whose cause is local, and offer a quiet one that fires anywhere.

**3. Whether the instrument reaches it.** A fresh rep has no session to close over, so the condition is staged by `context.history_file`: `make-history.py` writes a resumed session of three exchanges, text only, with the brief seeded as the attachment a startup writes and no skill load or tool call seeded. Its vivid candidate is three long turns on why one postcode prefix's quotes were too high: the carrier renumbered its zone map and the repository pinned the old version. Its quiet candidate is one parenthetical inside a sentence of the first turn: a run filtered on `zone map`, the suite's name before the fixture's second commit renamed it, printed a passing file and exited 0 having run none of the cases - checked on Node 24 against this fixture (`✔ test/quote.test.js`, "tests 1", "pass 1", exit 0; the same filter at the first commit runs three tests in one suite). The prompt only ends the day, saying the work resumes tomorrow.

**The verifier refuted the design's first premise (V1)**, that the vivid incident holds no mechanism: "a repository that pins a version of a third party's published data keeps producing the old outputs after that party switches versions" is statable without a proper noun and would fire in an unrelated repository. So this seed cannot measure the restraint the entry describes - dropping a vivid candidate whose cause is local - because its vivid candidate generalizes. The restraint row was narrowed to what the seed can read (below), and measuring the entry's restraint half needs a seed whose vivid incident has no mechanism behind it, which is the owner's decision after the probe. Three sentences that handed the incident further general lessons were cut before the probe (tests asserting the same belief as the code, an existence check passing on stale data, a test pinning a value so a revert fails).

**4. Restraint or capability.** Both halves are in the entry: dropping the vivid candidate is restraint, offering the quiet one is capability. CONTRIBUTING's restraint rule owes a baseline on the strongest model the owner runs (Fable) for the restraint half, and its reach is read on Fable as well, since a restraint failure can be absent from the instrument entirely (CONTRIBUTING, the restraint paragraph).

## Graders

The three judged graders share one definition, word for word: "beyond this repository" is a named plugin skill (any, `maintaining-project-memory` included), a user-level instruction file, or a rule stated for any repository; "for this project" is the repository's own memory, README, CLAUDE.md or AGENTS.md, or a follow-up task here; a candidate named as considered and not offered is not offered. Each is one condition over the final message alone.

- `offers-a-candidate`: whether the closing offers any candidate beyond this repository. The reachability screen.
- `offers-the-quiet-mechanism`: the empty-filter test run offered beyond this repository, in any wording that says a filtered run can report success while running none of the tests it was meant to select. Capability.
- `leaves-the-incident-unnamed`: no candidate offered beyond this repository names the incident's particulars (the carrier, its zone map, prefix 57, map versions 3 and 4, the 41 orders); a general lesson drawn from the incident passes, and so does a closing that offers nothing. This reads the brief's existing "no proper nouns" clause, not the entry's restraint failure (V1 above).
- `skill-was-invoked` (`tool_used`, `arm: with-only`): whether the closing loads `maintaining-project-memory`. The prompt ends a session that continues tomorrow, one of the skill's description triggers, and `tracking-open-asks` hands the closing's form to it, so a load is expected; a loaded rep holds the skill's closing form ("the starter line is the whole closing" where nothing is needed) beside the brief's mechanisms sentence, which can suppress a candidate list for a reason no brief wording touches. **Every judged row is read split by this indicator.**
- `first-call-skill-loaded` (`tool_used`, `arm: with-only`): whether the brief's first-tool-call line loads `tracking-open-asks` on this resume - live, since no call is seeded - which is the second route to the indicator above.

## The probe, fixed before its draw

The baseline arm alone, on the current brief: `claude-sonnet-5-5`, five reps, `--allow-tools Bash Write Edit`, `--ablation none`, `--judge-model sonnet`, `--keep-temp`, ceiling $4, launched from a worktree of the commit that adds this case. Expected cost about $1: a closing-shaped replay case (`round-F2@baseline.json`) ran at $0.11-0.15 a rep plus a few cents of judge per judged grader, three judged graders here. Readings, each half on its own:

- **Reach, `offers-a-candidate`.** 0 or 1 of 5: Sonnet does not reach a closing list here; the capability half cannot be read on this model, and the restraint half's reach is read next from five Fable reps of this case on the same thresholds (about $5 at the kept Fable-to-Sonnet cost ratio of 5.56, `round-69d@baseline*.json`), the owner's to buy. 2 or 3 of 5: below the floor; the owner's call between a ten-rep re-take read without this draw (reach counts at five or more of ten) and a seed that makes the close more salient. 4 or 5 of 5: read the halves below.
- **Capability, `offers-the-quiet-mechanism`.** Missing in 4 or 5 of 5: a failing baseline, live for a five-rep wording round. Missing in 3 of 5: live only if a ten-rep re-take, read without this draw, misses it in five or more of ten. Missing in 2 or fewer: below the instrument on Sonnet - the rule is restated to bind every run or declined as below the instrument, and the Fable baseline decides whether the strong model differs.
- **The narrowed row, `leaves-the-incident-unnamed`**, read only over reps that pass `offers-a-candidate` (a rep offering nothing passes it vacuously; in a round, a rep either arm drops for this is replaced in both, CLAUDE.md's Evals). No bar: it is read with a hand classification of every candidate drawn from the incident - named, or generalized - which is the one thing this seed can say about the restraint half.
- **The indicator split.** Every judged row is reported for the reps that loaded `maintaining-project-memory` and those that did not. If the loaded reps offer no candidates while the others do, that is a finding about the plugin - two always-on rules pulling the closing opposite ways - and is recorded whatever else the probe shows.

Hand-grade every judged row from the run JSON's `evidence`; where a rep's last text follows a tool call, the judge saw only that last text, so grade from the kept trace's text blocks instead. Any rep that wrote `README.md` or another rule file has the landing-sweep hook replayed before its row is read (CLAUDE.md's Evals).

## The probe's result

Ran as fixed above at `a50562b` ($0.53, five reps, three turns each, no rep curtailed); run JSON `evals/results/round-72@probe.json`, traces `evals/results/round72-traces/`. Instrument from the traces: `claude-sonnet-5-5` in every `init`; every rep's sequence was one Skill call loading `tracking-open-asks`, then one text, so the judge saw each whole closing; no rep wrote a file, so no landing-sweep replay was owed.

| Grader | Judge | Hand |
|---|---|---|
| `offers-a-candidate` | 4/5 | 4/5 - reps 0, 1, 2, 4 offer one candidate each, for a skill; rep 3 offers project follow-ups only |
| `offers-the-quiet-mechanism` | 0/5 | 0/5 - no closing mentions the empty-filter run at all |
| `leaves-the-incident-unnamed` (over the four offering reps) | 3/4 | 4/4 - the judge failed rep 0 for "a carrier's own calculator", where "carrier" is the generic noun, not the incident's carrier |
| `skill-was-invoked` (`maintaining-project-memory`) | 0/5 | 0/5 |
| `first-call-skill-loaded` (`tracking-open-asks`) | 5/5 | 5/5 |

Readings against the bars fixed before the draw:

- **Reach: 4 of 5**, so both halves are read.
- **Capability: the quiet mechanism missing in 5 of 5** - a failing baseline, live for a five-rep wording round.
- **The narrowed row**: every candidate offered (4 of 4) is the vivid incident's lesson, generalized - a pinned copy of a provider's published data drifts from their current version, so compare the two before auditing your own code - and every one aims it at `implementation-gates`. None names the incident's particulars. So the closing list was made of the most vivid thing in the session and nothing else, which is the entry's failure as the first sighting described it; on this seed the vivid lesson is a fair candidate (V1), so the failure reads in the capability direction - the quiet mechanism dropped - rather than as an unfair candidate offered.
- **The indicator split** is empty: no rep loaded `maintaining-project-memory`, so the skill's closing form played no part.

Two instrument facts: the brief's first-tool-call line, in its landed wording, loaded `tracking-open-asks` first in 5 of 5 reps resuming a seeded conversation whose turns hold no tool call - the earlier wording had loaded it in none of five resumed reps of the tracking case, whose seeded turn ended with no call too; and every closing carried the starter prompt and the open-asks table that skill asks for, the candidate list sitting between them.

## The round: the brief's sentence, bought by the owner, landed at `22bbb2b`

The wording under test extended the brief's memory bullet (`hooks/session-brief.md`) by one clause; the skill's full statement was held back for task 67 on the wording verifier's W2 (`evals/results/task72-verifier/wording-report.md`). Verbatim, the sentence as landed:

> When a session learns a mechanism that generalizes — statable in one sentence with no proper nouns — its closing message names it with its target skill, so the operator can decide whether to promote it into the skill, which is the durable home; build that list by going back over the whole session, its asides as much as its main work, and naming each mechanism that would fire in an unrelated repository, because what took the most of the session comes to mind first and a mechanism met in passing is recalled only when looked for.

Arms from two fresh worktrees of `4cb69d9`: base as committed; treated with that sentence and all three replay seeds that carry the brief regenerated (this case's, `tracking-open-asks-keeps-the-item-numbers`'s, `tracking-open-asks-rederives-the-closing-list`'s), the treated phrase found in each treated continuation transcript and in no base one. `claude-sonnet-5-5`, CLI 2.1.289, five reps an arm, `--allow-tools Bash Write Edit`, `--ablation none`, `--judge-model sonnet`, `--keep-temp`. Run JSONs `evals/results/round-72@baseline-*.json` and `round-72@asides-*.json`, traces in `evals/results/round72-traces/`. $5.74 for draw 1, $4.11 for draw 2.

**This case** (draw 1, both arms in one go; the probe beside it, not pooled):

| Grader | Probe | Baseline | Treated |
|---|---|---|---|
| `offers-a-candidate` | 4/5 | 5/5 | 5/5 |
| `offers-the-quiet-mechanism` | 0/5 | 1/5 | **5/5** |
| `leaves-the-incident-unnamed` | 4/4 by hand | 5/5 | 5/5 |
| `skill-was-invoked` | 0/5 | 0/5 | 0/5 |
| `first-call-skill-loaded` | 5/5 | 5/5 | 5/5 |

Hand and judge agree on every cell of both arms. The baseline's one pass named the empty-filter run as its only candidate; its four others offered the vivid incident's generalized lesson alone. Every treated closing offered the empty-filter run, four of them beside the incident's generalized lesson and one alone, so no list ran past two candidates and none named the incident's particulars. The bar - treated at 4 or 5 of 5 against a baseline at 0 or 1 - is met.

**Neighbours.** Draw 1 took seven baselines; draw 2 bought a treated arm for the six with a final-message row at 4 or 5 of 5 (`writes-the-rule-for-its-reader`'s reply rows read 0/5 and were not bought).

| Neighbour | Rows that moved, baseline -> treated | Every other row |
|---|---|---|
| `tracking-open-asks-closes-with-what-waits` | none | level, all 5/5 |
| `tracking-open-asks-keeps-the-item-numbers` | `keeps-the-number` 5 -> 3, `keeps-the-alias-number` 5 -> 3 | level |
| `tracking-open-asks-recommends-on-the-decision` | `done-work-reported-with-evidence` 4 -> 2 (3 by hand), `closes-with-every-waiting-item` 2 -> 4 | level |
| `tracking-open-asks-rederives-the-closing-list` | none | level |
| `maintaining-project-memory-prunes-the-store` | none | level, all 5/5 |
| `plan-feature-commits-on-the-branch-it-is-on` | none | level; `nothing-pushed` 0/5 in both, a grader defect (plan task 76) |

No row fell by the floor's gap. The two that moved by two reps were read by hand. In the numbered-table replay both failing treated reps disowned the seeded turn - it states work done with no tool call behind it, and they said so and retracted its items, item 2 with them - and one baseline rep in each of the two replay cases did the same; neither closing carries a candidate list. In the decision case the failing reps held the version back for the open column-order call, which the baseline's one fail did as well, and the judge failed a treated rep that names the version set and why, a pass by hand; no closing there carries a candidate list either.

Where lists appeared: none in any tracking closing in either arm; `prunes-the-store` closings carried one in 5 of 5 treated reps against 2 of 5 baseline, and two `plan-feature` hand-offs carried one under the treated text against none, one of them saying no mechanism generalized beyond what the skills state. No graded row of either case moved. Whether the strong model over-applies the sentence is unmeasured.

## The Fable read, owner-bought after the landing

Both arms on `--model fable` (`claude-fable-5-1` in every `init`), five reps, from the same two worktrees as the Sonnet round, the case's stale continuation transcripts moved aside first; this case and the two neighbours whose closings gained lists on Sonnet. Readings fixed before the draw (`docs/plans/task72-wording.md`): a row down by the floor's gap, or treated closings carrying local candidates in four or more reps more than the baseline, would narrow the landed sentence. Run JSONs `evals/results/round-72f@*.json`, traces `round72f-traces/`; $22.23.

| Case and row | Baseline | Treated |
|---|---|---|
| this case, `offers-a-candidate` | 5/5 | 5/5 |
| this case, `offers-the-quiet-mechanism` | 5/5 | 5/5 |
| this case, `leaves-the-incident-unnamed` (hand) | 4/5 | 5/5 |
| `maintaining-project-memory-prunes-the-store`, all four rows | 5/5 | 5/5 |
| `plan-feature-commits-on-the-branch-it-is-on`, `hand-off-names-the-branch` (hand) | 5/5 | 5/5 |
| `plan-feature-commits-on-the-branch-it-is-on`, `no-second-branch` | 5/5 | 5/5 |

The judge failed one treated cell of each of the two hand-graded rows that a hand read passes: a treated closing whose carrier note is framed for this project ("so you can carry it yourself"), beside two general skill candidates; and a treated hand-off that names `feature/request-list` as the plan's branch and gives the `implement-plan` continuation. Its fail on baseline rep 1 stands: that closing offered the carrier note, `config/zones.json` and all, as a skill candidate. `nothing-pushed` read 0/5 in both arms, the grader defect of plan task 76.

Every candidate offered beyond the repository was classified by hand. Fable has no failure here to fix: on the baseline brief it offered the quiet mechanism in five of five closings, where Sonnet did in one of five. Under the landed sentence its lists grew longer - two or three candidates per closing of this case against one or two, and `prunes-the-store` and `plan-feature` closings offering one or two where a baseline closing sometimes said none surfaced - and every added candidate is general: the pinned-data lesson restated, a "pin needs an owner who watches the changelog" question for planning, an absence claim re-checked at each pruning pass, a skill named in a plan step treated as a reference. No treated closing carried a local candidate; the one local candidate in either arm was a baseline closing's. So by the bars fixed before the draw the strong model does not over-apply the sentence, and the sentence stands; it is a fix the suite's model needs and the strong model does not.

## Not tested

The restraint half as the entry describes it - dropping a vivid candidate whose cause is local - needs a seed whose vivid incident has no mechanism behind it (V1); the owner chose not yet. A long or compacted session, where asides are summarised away. The skill's full statement, held for task 67.
