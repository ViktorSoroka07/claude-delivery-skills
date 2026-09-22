# Manual runs

**No rep has been run.** The case is built and its graders are tested against
hand-written messages; what follows is what it stages, what each grader reads,
and the rules for reading a first run. The baseline read is a separate
decision.

## What it stages

The rule under test is not in the skill yet. It is the queued entry about a
closing-ledger item carried forward from the previous message and never
re-tested against the rule that admitted it: once an item belonging to someone
else enters the list, editing the list each round rather than deriving it
afresh keeps it there indefinitely, and the drift is silent because a requester
cannot tell that an item is not theirs and answers from what they do know.

Every other case in this suite is a single prompt, so no rep reaches a second
closing round and both arms would score alike for a reason having nothing to do
with the wording. This case seeds the first round instead of hoping for it.
`context.history_file` is `--resume <path>`: the three lines in
`history.jsonl` - the plugin's session brief as the attachment a recorded
session writes, one user turn, one assistant turn - reach the run as its own
earlier turns. The seeded assistant turn closes with a table of three items
said to wait on the requester, and the prompt asks for a second closing list.
The condition is staged by construction, so every rep starts from it.

The third row is the defect, and it is the only one the fixture carries:

| # | The seeded list asks | Whose it is |
|---|---|---|
| 1 | Must the legacy column order be kept? | The requester's, unanswered |
| 2 | May the merged scratch branch be deleted? | The requester's - answered in the prompt |
| 3 | Is the timestamp column exported as UTC or converted to local time? | The upstream team's, raised on their tracker |

The tree says so in two places a run that re-derives will read:
`docs/upstream/booked-at-timezone.md`, committed as the durable record of where
the question was raised, and the last line of `docs/plans/export-columns.md`,
which names the same owner. Both say in as many words that it is not the
requester's call. Nothing in the prompt points at either: a run that carries
the previous list forward and edits it never opens them, which is the whole
mechanism.

The prompt answers item 2 and asks for changelog work. That gives the case
three things at once: an item that must leave the list because it was answered,
an act to grade (the branch deletion), and work whose result is in the tree
rather than in the reply.

## The fixture

`evals/fixtures/export-cli.sh`, variant `post-rename` - the same tree as the
sibling case `tracking-open-asks-closes-with-what-waits`, left as the seeded
exchange left it: the rename and the version done and **uncommitted**, because
the seeded requester asked for a diff rather than a commit, and the changelog
untouched. The upstream note and the plan's third line are committed, being a
record older than the session. The scratch branch is merged, so `git branch -d`
succeeds on it.

## What each grader reads

| Grader | Type | What it is for |
|---|---|---|
| `not-theirs-item-off-the-list` | llm | The deciding one: the upstream question is not put to the requester to answer |
| `owner-item-still-listed` | llm | Its pair: the genuinely open owner question is restated as the question |
| `answered-item-off-the-list` | llm | The neighbour: an answered item leaves the list |
| `no-carried-row-in-the-table` | regex | The mechanical screen over the deciding condition |
| `changelog-cut-to-the-release` | regex | The work landed in the tree, not only in the reply |
| `changelog-carries-the-rename` | regex | The other half of the work |
| `answered-item-acted-on` | tool_used | The answered item was acted on - and the replay reached the model |
| `skill-was-invoked` | tool_used, `arm: with-only` | The trigger fired, and the skill's own text was loaded |

**The deciding grader is judged, not a `not_contains` on the item's literal.**
That was the shape this case was planned with, and it scores the wrong thing:
the skill's own rule says an item leaving the list is stated rather than
dropped in silence, so a run that behaves correctly may well name the upstream
question while saying it has left the list and why. A pattern on the literal
fails exactly those runs, and it fails them hardest in the arm that behaves.
What has to be read is whether the question stands in the closing list as
something the requester is asked to answer, and the boundary between a row and
a sentence about a row is not one a pattern reaches. The regex beside it is
scoped to a table row for the dominant shape and is a screen, not the verdict.

**Read the carry-forward rate over the reps that produced a list at all.** A
final message with no closing list passes the deciding grader for a reason that
has nothing to do with ownership; `owner-item-still-listed` is what separates
the two, and the sibling case measured the plugin arm closing with its list in
two runs of three. A rep that fails the pair is a rep the list rule did not
bind, and it says nothing about carrying forward.

**A rep that fails `answered-item-acted-on` is read before it is counted.**
"2 is a yes" resolves only against the seeded list, so a run that never
received the earlier turns cannot know what was answered - and its other
graders would then be scoring a single-prompt case. Where the trace shows the
run had no earlier list, the replay did not reach it: the rep is unmeasured and
replaced, the way a curtailed rep is, rather than counted as a fail.

## Unverified, and what answers it

**Whether a resume re-renders the seeded brief into the run's context.** The
`SessionStart` hook does not fire it - the matcher is `startup|clear|compact`,
and a resume is neither - so the fixture carries the brief as the
`hook_additional_context` attachment a recorded session writes, with the
`rendered` system-reminder beside it, both copied from a real transcript's
shape. The probe that established the replay measured a run answering that the
brief was absent, but that probe predates the attachment line in the generator,
so it says nothing about a fixture that carries one. Two things answer it in
the first reps: `skill-was-invoked`, since the brief is what sends a session to
the skill, and a hand read of the first rep's draw. The skills stay advertised
by their own descriptions either way, which is the other route in.

**The arm without the plugin receives the brief too.** The fixture is a case
input and the arm is a plugin choice, so a two-arm release baseline resumes the
same file in both arms and hands the plugin's always-on text to the arm that is
supposed to be without it. This case's ablation row therefore understates the
plugin and must not be read as a retirement signal. It costs the wording round
nothing: there both arms hold the plugin, and the brief is identical in each.

**What the fixture freezes.** `history.jsonl` carries the brief as it stood
when it was generated. `make-history.py` beside it reads `hooks/session-brief.md`
at build time and is deterministic, so regenerating it and finding no diff is
the staleness check - run it after any change to the brief.

## Not tested here

That an item left on a default is said to have been; that the numbers stay the
same from message to message, which this case's answered item makes moot; and
the consequence columns, which the sibling case measures and which no run in
either arm has yet passed.
