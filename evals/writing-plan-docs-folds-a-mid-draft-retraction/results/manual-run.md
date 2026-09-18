# Manual runs

`claude plugin eval` was gated at run time when this case was written: it
printed "`plugin eval` is currently in early access" and exited 0 without
running. The case was therefore run by the hand procedure in CONTRIBUTING's
"Testing a wording change": ten isolated fixtures per run, verified
byte-identical by hash, five subagents per arm on sonnet.

Arms differ only in the contract. Baseline received the task and no contract,
which models the trigger not firing and matches the runner's own no-plugin
ablation. Treatment was told to read and follow SKILL.md.

Three runs were made. The first tested the rule as prose; the second tested it
after the sweep was restated as a required slot, against a grader rewritten to
score the slot rather than a passing mention; the third tested the rule as it
now stands — a line per sibling artifact, absent ones included — with the
contract pasted into the brief in full, treatment arm only, five fixtures
verified identical by hash.

## Results

| Grader | run 1 base | run 1 treat | run 2 base | run 2 treat | run 3 treat |
|---|---|---|---|---|---|
| G1 folds the correction | 4/5 | 5/5 | 1/5 | 5/5 | 5/5 |
| G2 every restatement | 5/5 | 5/5 | 5/5 | 5/5 | 5/5 |
| G3 sibling artifacts | 0/5 | 2/5 | 0/5 | 1/5 * | 5/5 |

\* Five in five produced the line, named the commit body and declined to rewrite
it. One in five also accounted for the request description that does not exist
in this fixture, which the grader required and the rule at the time did not. The
rule was then tightened to a line per artifact, so the two agree, and run 3
scores that form.

## The structural form works

Restating the sweep as a filled-in line moved the commit-body disposition
from 2/5 to 5/5; the per-artifact line scored 1/5 before the rule asked for
it and 5/5 once it did. In run 3 every report carried the four lines under
the rule's own labels, named the pre-existing commit as still carrying the
claim, offered the reword command without running it, and stated that no
request description exists; the reflog of every fixture shows no amend or
rebase. Every
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

## The rule was looser than its grader, and has been tightened

The grader required every sibling artifact to carry a disposition, including
one that does not exist in the fixture, on the reasoning that a run which never
mentions the request description cannot be shown to have searched for it. The
rule only said the line is valid once all three had been searched, and an
absent artifact would never appear in a list of places the claim is stated.

One run in five closed that gap on its own, writing that there is no PR or
remote so the third artifact does not apply. It was achievable before the rule
asked for it, which is why the rule now asks: the slot is a line per artifact,
and an absent artifact still gets its line.

## Not tested

Run 3's baseline. The third run had no no-contract arm; its baseline for G3
is run 2's treatment score of 1/5 against the same grader, on the rule before
the per-artifact form.

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

## Through the runner

One run of `claude plugin eval` on this case, three runs per arm, the
runner's own arms (no plugin, the plugin) and its default judge. The prompt
names no skill, so the plugin arm tests the trigger as well as the rules.

| Grader | No plugin | Plugin |
|---|---|---|
| finds-every-restatement | 0/3 | 2/3 |
| folds-the-correction-into-the-text | 0/3 | 1/3 |
| sweeps-the-commit-body | 0/3 | 1/3 |

Every plugin-arm verdict was re-read by hand against the document the run
left behind, and the judge agrees with the hand grade on all nine. One run
folded the correction, swept all four restatements and enumerated the three
sibling artifacts. One corrected all four figures and the headroom
conclusion but kept the correction section with its narration standing
("my earlier reading of the run log was wrong"), which is the fail the first
grader is for. One left the document untouched, reported the contradiction
in chat and asked which figure to trust — a run that diagnosed correctly and
delivered nothing.

**The number is a floor, not the rule's pass rate.** The hand runs above
score 5/5 on a treatment arm that was told to read the contract; here the
skill has to fire on its own, and the runner keeps no transcript, so whether
the two failing runs ever loaded it cannot be read from what it kept. A
`tool_used: Skill` grader marked `arm: with-only` would separate a rule that
was not followed from a rule that was never loaded, and this case has none.

The no-plugin arm fails every grader in every run, which is what makes the
case worth its cost: the behaviour is absent without the plugin, not merely
inconsistent with it.
