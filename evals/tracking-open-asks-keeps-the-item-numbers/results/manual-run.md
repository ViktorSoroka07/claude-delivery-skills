# Runs

The case for the closing-table entry "A closing list's item numbers are
identifiers": when an item above a still-listed one leaves, renumbering from
one turns the requester's next answer by number into an answer to a
different question, with nothing to flag it.

## What the case stages

A sibling of `tracking-open-asks-rederives-the-closing-list`: the same
fixture variant (`export-cli.sh`'s `post-rename`) and the same seeded
conversation, built by that case's generator through this case's
`make-history.py`, which adds one row to the seeded closing table - a fourth
question that is the requester's, like the second: whether `--dry` stays
accepted as a hidden alias for one release. A change to the brief or the skill
stales both files at once, and the reference gate fails on either.

The prompt answers item 1 by number ("1 - the new order is fine"), where the
sibling answers item 2. Two of the requester's items then stay open, the
branch (2) and the alias (4), both below the gap item 1 leaves, with the other
team's clock question (3) between them - so a rep that drops the third, as
the record beside it says a rep should, still has two items, and the skill's
own rule makes them a numbered table. With the branch as the only open item,
as first drafted, the reps that re-derived the list correctly would have been
left one item, which the skill writes as a sentence with no number, and the
counted reps would have been the ones carrying the other team's question.

**The seeded conversation loads the skill** (the generator's second line
group: the Skill `tool_use`, its `tool_result` and the skill's body as the
`isMeta` user message, the body byte-identical to what a real load of the same
`SKILL.md` injects; the seed carries the fields the resume path reads, not
every field a recorded load writes). A fresh conversation has done that as its
first tool call since the brief's first-tool-call line; before this, the
replay's seeded turn made no call, and every resumed rep read the line as
spent and loaded nothing, so no rep of either replay case held the skill's
text.

## The probe: the seeded body reaches the model

One rep, no tools, this case's seeded file, `--model sonnet`, CLI 2.1.281,
$0.13. It answered `SEEDED-PRESENT`, `BRIEF-PRESENT`, named its first tool
`Skill`, counted the seeded table's four rows, and made no Skill call of its
own (`Skill called 0x`). Asked for the Reality cell of the red-flag row "I
asked that two messages ago", it quoted another row's instead, word for word:
"Un-ledgered deferral is how it drops. Write it down, then defer it" - a
sentence the skill's body holds and the brief, the README, CONTRIBUTING and
`CLAUDE.md` do not. **So the pre-registered quote grader failed, on the row
the model picked, while the question it was for is answered: a resume passes
the seeded `isMeta` body to the model.** Arrival in a round's reps is read
per rep: a final message treating item 1 as the column-order question can come
only from the seeded list, since the plan's own first step is something else.

## Graders

| Grader | Type | Reads | Role |
|---|---|---|---|
| `keeps-the-number`, `keeps-the-alias-number` | `regex`, final message | the branch numbered 2, the alias numbered 4 | screens for the act |
| `renumbered-from-one` | `regex`, final message, `not_contains` | the branch numbered 1 | screen for the failure |
| `says-which-item-left` | `llm`, final message | item 1 said to have left because it was answered | the wording's second clause, hand-graded in both arms |
| `changelog-cut-to-the-release`, `changelog-carries-the-rename` | `regex`, file | the asked work done | neighbours, verbatim from the sibling |
| `skill-was-invoked` | `tool_used`, with-only | a second load by the rep | indicator; arrival is the probe's and the hand read's |

The screens were tried on hand-written tables and numbered lists: kept 2-3-4,
kept 2-4 and a kept numbered list pass all three; renumbered 1-2 and 1-2-3
fail all three. Their known false keeps - item 1 kept as an answered row, a
quoted copy of the previous table, a renumbering that lands the branch on 2, a
line opening "2.4.0" - and their misses ("2 - ...", "Item 2:", a number
mid-sentence) are why the act is read by hand.

## Reading a rep, in both arms alike, before any verdict

1. **Arrival**: the final message treats item 1 as the column-order question.
2. **The condition**: the closing list carries both the branch question and
   the alias question, each with a number, and does not carry item 1 as a
   row. A rep that misses it is unmeasured on the act and replaced, at most two
   per arm.
3. **The act**, from the whole list: every number it uses is the number that
   item carried in the seeded list - 2 for the branch, 4 for the alias, 3 for
   the clock question where a rep carries it - and no item is renumbered.
   Each rep's reading is recorded before the screens' verdicts are read.

## The treated text

`skills/tracking-open-asks/SKILL.md`, the closing-table bullet's last
sentence, replaced:

> The numbers stay the same from message to message, gaps and all — an item
> that leaves keeps its number retired, a lone item keeps its number too, and
> the message after one leaves says in a line beside the list which numbers
> left and how — so the requester can answer "2: yes" without quoting
> anything, and an answer given by number reaches the question it was given
> to.

"A lone item keeps its number too" answers the sentence rule beside it (one
item is a sentence, which carries no number); "the message after one leaves"
bounds the line to the next message, so a closure already stated is not
restated; "beside the list" keeps the line out of the table, which the next
bullet says the item leaves. A clause on new items was drafted and dropped:
"retired" already keeps a number from reuse, and no case stages a new item.

**The arms**: `--ablation none --model sonnet --judge-model sonnet
--keep-temp` on CLI 2.1.281, the baseline from a detached worktree at the
commit carrying this case and the regenerated fixtures, the treated arm from a
worktree at the same commit with the sentence replaced and both `history.jsonl`
files regenerated there. Each tree's seeded body is confirmed by "gaps and
all" - in the treated seed only. The runs are copied in as
`round-F2@baseline.json` and `round-F2@kept-numbers.json`.

## The bars, fixed before any draw

- **The act row's tier is set on the baseline's first five measured reps**,
  on the skill text at that commit, which is the current sentence delivered by
  the seeded load - the question this case asks first. If fewer than five
  reps are measured after two replacements, no tier is set: the row is
  reported as a condition this case reaches too rarely, and no treated arm is
  bought.
  - **4-5/5 keep every number**: no treated arm. The current sentence binds
    once the skill is in context, and the entry is declined as delivered by
    the first-tool-call line, with no wording.
  - **0/5**: the treated arm's first five measured reps decide; it clears at
    4/5 or better.
  - **1/5**: it clears only at 5/5.
  - **2-3/5**: no treated arm inside batch 1's approval; the row is priced at
    the stop, with its ten-rep extension and bar (9/10 or better and five
    above the baseline's ten) fixed then, before any draw.
  - **A treated arm below its bar** is declined for this wording with its
    rate, the entry saying whether the gap fell below the floor; no further
    draws on that reading.
- **The second clause's row** (`says-which-item-left`) is hand-graded in both
  arms, since the wording changes how much a rep writes about what it judges,
  and is reported beside the act row; the wording lands or not on the act.
- **Neighbours**: a fall from 5/5 to 1/5 or lower, or from 4/5 to 0/5, is a
  cost the wording answers before it lands; smaller, watched. A clear here is
  also read against the fresh case, which every fresh rep's skill load reaches:
  five treated reps of `tracking-open-asks-closes-with-what-waits`, priced at
  the stop, before any landing.
- **Ceiling**: each arm about $0.90 with replacements, set above that on the
  invocation.
