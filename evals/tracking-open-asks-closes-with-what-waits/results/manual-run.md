# Manual runs

Fixtures from `evals/fixtures/export-cli.sh`, fresh headless Sonnet sessions,
five per arm. The baseline arm is the skill and the session brief before the
rule; the treatment arm has the section in the skill and its pointer in the
brief. No run in either arm loaded the skill: the rule reached the sessions
through the brief alone, which is why it has a line there.

## Two turns: the situation the rule is for

Turn one asks for the plan's two blocked items and tells the session to ask
rather than guess; every session in both arms asked its two questions and
stopped. Turn two, in the same session: "I will come back to those", then an
unrelated rename. Graded on turn two's reply.

| Turn two's reply | Baseline | Treatment |
|---|---|---|
| closes with both questions restated | 0/5 | 5/5 |
| says what each blocks | 0/5 | 2/5 |
| says what happens without an answer | 0/5 | 0/5 |
| rename done in the script and the README | 5/5 | 5/5 |

Every baseline reply reported the rename and ended; the two questions asked
one message earlier are nowhere in it. Every treatment reply ended with both
questions, worded so they can be answered from that message alone. The
consequence columns did not carry over: sessions that gave them in turn one
dropped them in turn two. The rule binds on restating and not yet on the
consequence.

The runner has no second turn, so this table is a hand result only:
`claude -p` for turn one, `claude -p --resume <session id>` for turn two. The
two prompts were not kept word for word; the paragraph above is what they
said, and a repeat starts from it.

## One turn, with the requester's acknowledgement: the limit

The prompt first committed compressed the situation into one message and had
the requester say they know about the two questions and will get to them:
"Picking this back up. I know you asked me two things last time, the column
order and the old branch; they're written down in
`docs/plans/export-columns.md` and I still haven't decided, I'll get to them.
Meanwhile, two things: rename the `--dry` flag to `--dry-run` everywhere it
appears, and set the version for the release. Don't commit, I'll look at the
diff."

| Grader | Baseline | First wording | Restated wording |
|---|---|---|---|
| closes-with-every-waiting-item | 0/5 | 2/5 | 2/5 |
| says-what-each-blocks-and-the-default | 0/5 | 2/5 | 2/5 |
| rename-done-in-the-script | 5/5 | 5/5 | 5/5 |
| rename-done-in-both-places (the README; now rename-done-in-the-readme) | 5/5 | 5/5 | 5/5 |
| done-work-reported-with-evidence | 5/5 | 4/5 | 4/5 |

The restated wording says an acknowledgement is not an answer and that a
reference is not the list; it moved nothing. Where the requester has said in
the same message that they know, three sessions in five still close with
"still waiting on you: the column order and the old branch" and no
questions. Under that prompt the case fails in the treatment arm by design,
and the table measures the limit, not the rule: a case at 2/5 with the rule
in place cannot go red when the rule regresses.

The restated wording was measured in the brief, the only copy a session
read, and is cut from it: it moved nothing and every session start paid for
it. The skill keeps the same two clauses, since they state a boundary of its
own rule and no run loaded the skill to test them either way.

The done-work misses are in the two treatment columns alone, one session
each, which asked which version to set instead of setting it; the baseline
has none. A rule about asking can induce exactly that, and one run in five
is also within what five reps cannot tell from noise. No transcript line
was recorded that settles which; the grader is scored in every later run of
the case.

## One turn: the committed prompt since

The committed prompt no longer has the requester acknowledge the two
questions: it names the plan file, which records both as asked with no
answer yet, and asks for the rename and the version. The rubrics changed
with it: the second fails a reply that gives what an item blocks without
what happens if no answer comes, which the two-turn table shows is the
common shape, and the script's rename is read as the new flag present and
the old flag absent anywhere in the file, whatever the quoting. No hand run
has been made on this prompt.

The fixture's first draft planted the release version as a third waiting
item. The changelog already names the next version, every baseline session
set it without asking, and the graders were rewritten around the two items
that do wait.

## Not tested

The items' exit: that an answered item leaves the list, and that one
proceeded on its default is said to have been.
