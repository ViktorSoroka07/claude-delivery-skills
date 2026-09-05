# Manual run

`claude plugin eval` is enabled as a command but gated at run time: it prints
"`plugin eval` is currently in early access" and exits 0 without running. The
case was therefore run by the hand procedure in CONTRIBUTING's "Testing a
wording change": ten isolated fixtures, verified byte-identical by hash, five
subagents per arm on sonnet.

Arms differ only in the contract. Baseline received the task and no contract,
which models the trigger not firing and matches the runner's own no-plugin
ablation. Treatment was told to read and follow the edited SKILL.md.

## Result

| Grader | baseline | treatment |
|---|---|---|
| G1 folds the correction | 4/5 | 5/5 |
| G2 every restatement, including the two derived | 5/5 | 5/5 |
| G3 sweeps the commit body | 0/5 | 2/5 |

## The baseline does not fail on G1 or G2

CONTRIBUTING's stopping rule applies: with no contract at all, the model finds
the self-contradiction and folds it. One baseline run left the correction
section standing verbatim; the rest removed it, and two retitled it into a
statement of fact rather than deleting it, which is a better fold than the rule
asks for. One baseline run derived the reasoning unprompted, that a document
never sent has no earlier claim to retract, only a wrong draft to fix.

**The fold bullet is redundant against this baseline.**

## G3 discriminates but its wording is not binding

Nothing in the baseline arm mentioned that the pre-existing commit body carries
the retracted figure. Two treatment runs did, both declining to rewrite it and
naming the decision as the author's, which is the behavior the rule asks for.

Three treatment runs did not, **while under instruction to follow the skill**,
so 2/5 is an upper bound on compliance rather than a discovery rate. By
CONTRIBUTING's reading, reps disagreeing on the shape of the output means the
wording is not binding.

The restraint half of G3 passed 10/10 and discriminates nothing: no run was
tempted to rewrite history, so that clause is untested rather than confirmed.

## What the result implies for the wording

The sweep asks for an element to be added to output the agent already produces,
and `writing-skills` matches that failure to a structural form, a required slot
in the template, and names prose reminders as the wrong form for it. The sweep
is currently prose. Restating it as a required slot, where the hand-off names
which sibling artifacts carry the claim and what was done about each, is a
different edit from the one this run tested.

## Not tested by this run

The trigger. The skill was passed to the treatment arm by file path rather than
by reverting the installed copy, so whether the widened `description:` causes
the skill to be discovered for a findings document is unmeasured. That is the
question the trigger change exists to answer.

## Grader note

The mechanical proxy written to score G2 failed four runs that the criteria
pass. It searched for the word "attempt" to detect a qualified figure, and the
documents wrote "includes retries" and "raw log count". Every flagged match has
to be read by hand, as CONTRIBUTING says. The criteria file is the grader; a
script over it is a convenience that can drift from it.
