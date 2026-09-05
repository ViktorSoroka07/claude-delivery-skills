# Manual runs

`claude plugin eval` is enabled as a command but gated at run time: it prints
"`plugin eval` is currently in early access" and exits 0 without running. The
case was therefore run by the hand procedure in CONTRIBUTING's "Testing a
wording change": ten isolated fixtures per run, verified byte-identical by
hash, five subagents per arm on sonnet.

Arms differ only in the contract. Baseline received the task and no contract,
which models the trigger not firing and matches the runner's own no-plugin
ablation. Treatment was told to read and follow SKILL.md.

Two runs were needed. The first tested the rule as prose; the second tested it
after the sweep was restated as a required slot, against a grader rewritten to
score the slot rather than a passing mention.

## Results

| Grader | run 1 base | run 1 treat | run 2 base | run 2 treat |
|---|---|---|---|---|
| G1 folds the correction | 4/5 | 5/5 | 1/5 | 5/5 |
| G2 every restatement | 5/5 | 5/5 | 5/5 | 5/5 |
| G3 sibling artifacts | 0/5 | 2/5 | 0/5 | 5/5 * |

\* Under the committed criteria, which require the request description to be
accounted for even though it does not exist in the fixture, treatment scores
1/5. Under what the rule actually says, which is that the line names the
artifacts where the claim *is* stated, it scores 5/5. Both numbers are real and
they measure different things; see "The rule is looser than its grader" below.

## The structural form works

Restating the sweep as a filled-in line moved it from 2/5 to 5/5. Every
treatment run in the second pass produced the line unprompted, named the commit
body as still carrying the retracted claim, declined to rewrite it, and offered
the command instead. One went further and flagged that other files in the
repository were unchecked, which is the rule generalizing past the three
artifacts it enumerates.

Prose asking for the same behavior produced it twice in five, under
instruction to follow the skill. That is the gap between asking for an element
and requiring it.

## The two runs disagree about the baseline, and the cause is the harness

Baseline G1 fell from 4/5 to 1/5 between runs, and the sole remaining pass came
from an agent that reported seeing an unrelated project directory mid-task, so
it is discounted.

The dispatch brief changed between runs: the hand-off item went from "two
sentences" to "a short note". That is not neutral. A two-sentence cap leaves no
room to narrate a correction, so the agent folds it and moves on; room to
explain invites the explanation, and having explained the correction the agent
keeps a section for it. Four of five second-run baselines kept one, three of
them retitled with the narration intact inside, one verbatim. Two said they
kept it "for transparency".

**A wording change justified by one arm's pass rate is only as good as that
arm's variance, and nothing in this procedure measures variance.** The first
run's baseline was read as evidence that the fold rule was redundant. Under a
brief that does not cap the hand-off, the baseline fails that grader four times
in five.

## The rule is looser than its grader

The grader requires every sibling artifact to carry a disposition, including
one that does not exist in the fixture, on the reasoning that a run which never
mentions the request description cannot be shown to have searched for it. The
rule only says the line is valid once all three have been searched, and an
absent artifact would never appear in a list of places the claim is stated.

One run in five closed that gap on its own, writing that there is no PR or
remote so the third artifact does not apply. It is achievable; the rule does
not currently ask for it.

## Not tested by either run

The trigger. The skill was passed to the treatment arm by file path rather than
by reverting the installed copy, so whether the widened `description:` causes
the skill to be discovered for a findings document is unmeasured. That is the
question the trigger change exists to answer.

## Grader note

Mechanical scoring was wrong in both runs and in opposite directions. In the
first it failed four runs the criteria pass, searching for "attempt" where the
documents wrote "includes retries". In the second it passed three runs the
criteria fail, its narration pattern missing the form "an earlier pass over
this data read the field and reported X". Every flagged match, and every clean
result, has to be read. The criteria file is the grader; a script over it is a
convenience that drifts from it in whichever direction its author was not
worried about.
