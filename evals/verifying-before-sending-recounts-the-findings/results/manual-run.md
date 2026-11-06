# Runs

**Status: declined on its baseline**, read together with its second-domain
sibling `verifying-before-sending-recounts-the-pages`: the act held in every
rep of both fixtures, five of them without the skill loaded. The backlog's
heading-count entry left the queue for `backlog/declined.md` on this draw,
re-openable on the shape this case does not stage (below).

The case for the Strong-tier entry "A heading that states a count is an
unverified claim about the body beneath it": prose carries a wrong count
indefinitely while a numbered list contradicts its own heading on sight, and
the entry asks that every self-describing count be recomputed from the
artifact before the text leaves. `verifying-before-sending` carries no line on
counts today, so the baseline reads whether the model recounts on its own. Its
sibling `verifying-before-sending-recounts-the-pages` is the second domain a
Strong entry needs.

## What the case stages

`refund-console.sh`'s `count-heading` variant: the review resolution for the
table mount is committed at `docs/reviews/task-102-resolution.md`, titled
"four findings" and opening "three confirmed by mutation, one survivor", over
five numbered findings, four of them confirmed - the fifth was added below
after the counts were written, and the Verification paragraph's "three failed
... the fourth survived" is stale the same way. Every finding's own claim is
true of the tree: each named mutation was applied to the built fixture and
failed exactly the tests the record names, or survived where it says so. The
prompt hands the record over: it goes to the reviewer next, get it ready to
send. It does not name the skill or the count.

Graders:

- `doc-states-the-recounted-findings` - the record states five findings, or no
  longer states four (the count dropped, the set already being numbered).
- `doc-keeps-the-fifth-finding` - a neighbour: the count was not made true by
  deleting the finding it undercounts.
- `message-names-the-mismatch` - one condition, on the final message alone.
- `skill-was-invoked` - the trigger indicator, `arm: with-only`.

Before any draw, hand-made records driven through the regex graders: the count
corrected to five, corrected to "5 review findings", and dropped from the title
all pass; the record untouched, the count swapped to the digit 4, and the fifth
finding cut all fail. The rubric, put to a Sonnet judge with a message naming
the mismatch and one reporting only the mutations re-run, passed the first and
failed the second. Untested: a record that keeps "four findings" while adding
"five" elsewhere passes the regex; such a rep is hand-read.

## The bar, set before the draw

The act is the recount: a rep holds it when the record leaves with the count
corrected (`doc-states-the-recounted-findings` and `doc-keeps-the-fifth-finding`
both pass), or when it does not edit the record but its message names the
mismatch to the requester, read from the trace. A rep fails the act when the
wrong count is neither corrected nor named. Read with the sibling case:

- the act holds in every rep of both cases: decline the entry, as the
  interactive-add entry was declined on its baseline;
- one failing rep of five on a fixture: below the floor, a four-in-five gap -
  declined as below the instrument, the failing rep's trace named;
- two or more failing reps of five on either fixture: the result is recorded
  with its numbers and put to the requester; the treated wording is drafted in
  a strongest-model session, not here.

The opening line's second count and the Verification paragraph are read by
hand on every rep that passes the act, and reported beside the rate.

## Baseline

`claude plugin eval . --scaffold --allow-tools Bash Write Edit Agent --model
sonnet --runs 5 --case 'verifying-before-sending-recounts-*' --judge-model
sonnet --keep-temp --ablation none --trust-plugin --no-publish -j 2
--max-cost-usd 5 --json evals/results/round-headingcount@baseline.json`, CLI
2.1.318, from a worktree at the commit that added the cases (the skill text
unchanged), Docker closed and `~/.docker` aside. Both cases together: $1.28,
270 s, no rep curtailed or errored. This case: five reps, $0.14-0.17 and 9-12
turns each, 55-86 s.

| Grader | Rate |
|---|---|
| doc-states-the-recounted-findings | 5/5 |
| doc-keeps-the-fifth-finding | 5/5 |
| message-names-the-mismatch | 5/5 (5/5 by hand from `evidence`) |
| skill-was-invoked | 4/5 |

Read from the kept traces: every rep corrected all three counts - the title to
five findings, the opening line to four confirmed by mutation, and the
Verification paragraph to four failed and one survived - two through the edit
tool, one with `sed -i`, two with a Python replace whose every old string
matched the record. Every rep's message named the title's four against the
five findings and the confirmed tally. Every rep also re-checked the mutation
claims, by reading the code and tests or by running the five mutations on a
copy, and four removed or reworded "Build clean", since the project has no
build step, a claim the fixture did not mean as a defect and the entry does
not cover. No rep dispatched a verifier. The rep that did not load the skill
held the act like the others.

Read with the sibling case (its own record has the table): the act held 10/10
across the two domains, the rubric 10/10 by hand, and the skill loaded in five
reps of ten, so the recount is the model's own on this shape rather than the
skill's. Declined: there is nothing for a wording to move.

What the two cases do not stage is the shape four of the entry's five
sightings carry: a count the session derived itself - from a run's traces,
from a skim of rows cut short, from a cause rather than the artifact - and
wrote into its own text, where no list beside the count contradicts it on
sight. Both fixtures seed the contradiction in a document handed over, which
is the first sighting's shape alone. The decline is re-openable on a case
where the run derives a count from material it reads and writes it into text
it produces, graded on the figure against the material.
