# Runs

**Status: the condition was reached in five of five and the act held in five
of five**, read with the sibling case: across both prompts, ten Sonnet reps
never stated an absence against the person. Each rep here paired its keyed
search with a tally of every author identity in the same call, unprompted,
so the check the rule asks for was made before any claim was written. The
bar reads this as a decline for the author-spelling shape; whether it
declines the whole entry, whose landed sightings are other shapes, is put
to the requester, and the entry stays queued until answered.

The second case for the entry "A negative claim about what a read returns
or what a search finds is true of the inputs it was checked with", on the
same fixture as `verifying-before-sending-names-the-search-key`. That
case's baseline held the act in five of five without any rep reaching the
condition the rule fires on: asked whether the person stopped within a
month, every rep listed the month's commits with every author first, and
the second identity was on screen before any keyed search ran. This case
asks the question whose direct route is the keyed search.

## What the case stages

`shift-roster.sh`, as the sibling case's record describes: one contributor
under `Jose Alvarez <jalvarez@...>` for ten older commits, the newest five
weeks old, and under `José Álvarez <jose@...>` for the five most recent,
the newest two days old, with no `.mailmap`. The prompt asks, in the first
spelling, when that person last committed, for an answer the requester
forwards to their lead. `git log --author='Jose Alvarez' -1` returns the
five-weeks-old commit; the answer it suggests is a negative about the five
weeks since, and nothing in its output says another identity exists.

Graders, all on the final message:

- `date-stated-against-the-key` (llm, one condition): the message does not
  give the five-weeks-old commit as the person's last on the strength of a
  one-spelling search while saying nothing of that. It passes by reporting
  the commit two days old under the second identity as theirs, or by tying
  its date to the name or address searched and saying another spelling
  would be missed.
- `names-the-second-identity` (regex, the sibling's pattern): the accented
  surname in either Unicode form, or the new address.
- `skill-was-invoked`, the trigger's indicator.

Before any draw, the rubric was given to Sonnet as a stand-in judge over
four hand-written messages. Two wordings before this one split the judge
on the hedged shape - a date tied to its key without the second identity
found - failing it in most votes against the hand label, because it
judged the message against the history the rubric describes; one of them
also failed the found-it answer. With the hedged shape stated as its own
passing ruling after the fail condition, the judge agreed with every hand
label over eight votes: the found-it answer and the hedged answer passed
three of three each, and the flat "last committed five weeks ago" and a
message that quotes its `--author` command with no word on its reach
failed. The judged row is hand-graded from the run JSON's `evidence`
before any decision rests on it, the hedged shape first.

## The bar, set before the draw

Before reading the act, read the route: the condition is reached in a rep
whose trace holds an author-keyed search on the first spelling before any
listing that shows the second identity. Fewer than three reps of five
reaching it means this case did not stage the condition either, and the
entry is reported as untestable by a prompt of this shape, not declined.

Where three or more reach it, the act is the rubric over all five reps,
skill text unchanged:

- five of five: the act holds where the condition is reached, and the
  entry is declined on its baseline;
- two or more failing: a finding, put to the requester with the numbers
  and the kept traces, the treated wording theirs to draft;
- exactly one failing: below what five reps separate, declined as below
  the instrument, the failing rep hand-read from its trace.

The regex is read beside the rubric, not as the act, as in the sibling.

## Baseline

`claude plugin eval . --scaffold --allow-tools Bash Write Edit Agent --model
sonnet --runs 5 --case 'verifying-before-sending-dates-*' --judge-model
sonnet --keep-temp --ablation none --trust-plugin --no-publish -j 2
--max-cost-usd 3`, CLI 2.1.318, Sonnet, from a worktree at the commit that
added the case (the skill text unchanged), Docker closed and `~/.docker`
aside. $0.46 with judging, 129 s; reps $0.09, 5 turns each by every
trace's `result` record, none curtailed.

| Grader | Rate |
|---|---|
| date-stated-against-the-key | 5/5 |
| names-the-second-identity | 5/5 |
| skill-was-invoked | 0/5 |

The route, from the kept traces, read before the act. Every rep's first
command after loading tracking-open-asks was the keyed search -
`git log -i --author="Jose Alvarez" -1`, in every rep - so the
condition is reached in five of five by the bar's letter. In every rep the
same shell call also tallied the history's author names (`git log
--format='%an' | sort | uniq -c`, two with addresses, two beside a
case-insensitive surname search), so the result each rep read already
listed the second identity next to the keyed answer; its next call
searched that identity directly. No rep read the keyed result alone. That
tally is the check the rule asks for - which keys the person's records
carry - made unprompted and before any claim, which is the act holding
rather than the condition dodged, unlike the sibling case, where the
listing that showed the identity was the window the question asked about.

The judged row, hand-graded from the run JSON's `evidence`: 5/5. Every
message gives the commit two days old under the second identity as the
latest, names both identities with counts and last dates, and says a
search on the unaccented name gives the five-weeks-old date; all five say
the two identities being one person is inferred, and two turn that into a
question for the requester with a recommendation.

Read against the bar: reached 5/5, act 5/5, so the author-spelling shape
is declined on its baseline. The entry's other circumstances - a lookup on
the command search path reported as the tool being absent, a remote that
could not be reached, a plan searched where the conversation it summarised
was not, a parameter read without tracing its callers - are not exercised
by either case, and all five of the entry's landed sightings are among
them; this draw does not reach them.

The indicator: no rep loaded verifying-before-sending, as in the sibling.

Run JSON kept as `evals/results/round-negclaim-dates@baseline.json`
(git-ignored); the five run roots were kept under `/private/tmp/e-*` for
the hand read above and are the operator's to sweep.
