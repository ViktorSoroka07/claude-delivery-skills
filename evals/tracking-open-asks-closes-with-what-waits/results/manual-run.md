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
`claude -p` for turn one, `claude -p --resume <session id>` for turn two.

## One turn: the committed prompt

The prompt the runner can run compresses the situation into one message, and
has the requester say they know about the two questions and will get to them.

| Grader | Baseline | First wording | Restated wording |
|---|---|---|---|
| closes-with-every-waiting-item | 0/5 | 2/5 | 2/5 |
| says-what-each-blocks-and-the-default | 0/5 | 2/5 | 2/5 |
| rename-done-in-the-script | 5/5 | 5/5 | 5/5 |
| rename-done-in-both-places | 5/5 | 5/5 | 5/5 |
| done-work-reported-with-evidence | 5/5 | 4/5 | 4/5 |

The restated wording says an acknowledgement is not an answer and that a
reference is not the list; it moved nothing. Where the requester has said in
the same message that they know, three sessions in five still close with
"still waiting on you: the column order and the old branch" and no
questions. This case therefore fails in the treatment arm by design of its
prompt, and is the measure of the limit, not of the rule. The
done-work misses are one session per arm that did not set the version and
asked instead.

The fixture's first draft planted the release version as a third waiting
item. The changelog already names the next version, every baseline session
set it without asking, and the graders were rewritten around the two items
that do wait.

## Not tested

The items' exit: that an answered item leaves the list, and that one
proceeded on its default is said to have been.
