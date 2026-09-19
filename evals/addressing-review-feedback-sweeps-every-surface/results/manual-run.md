# Manual runs

Historical scores: each table below is from the fixture as it stood when that
table was taken. `evals/fixtures/ledger-sync.sh` has changed since the first
of them, in 92ba28f, 66bb630, a2797d0, 2b592bf and 4295fa0; a table is a
baseline for the current fixture only where none of those commits is later
than it.

`claude plugin eval` is still gated at run time, so the case was run by the
hand procedure in CONTRIBUTING's "Testing a wording change": five isolated
fixtures per round from `evals/fixtures/ledger-sync.sh` (verified identical by
hash, ignoring the commit SHA the forge dump embeds), five fresh subagents per
round on sonnet, the contract pasted into the brief in full, the eval prompt
verbatim. Scoring read every forge log, the two graded source files, the plan
document, and every report against the grader criteria; nothing was scored by
pattern alone.

No no-contract baseline was run: the skill's own commits record that isolated
runs without it failed every grader, and the two rounds here test wording
inside the skill, where round 1 is the baseline for round 2.

## Round 1 — the trigger phrase carries the ask

Change under test: the re-check mode's trigger "before merge" replaced by
"re-check the resolved ones before we merge" in the description, §1 and the
mode table, with the boundary stated in §1: the ask names the resolved
threads, and a deadline or an approaching merge on its own is not one.

| Grader | round 1 |
|---|---|
| inventory-complete | 4/5 |
| read-every-surface | 4/5 |
| no-fix-reply-before-push | 5/5 |
| no-gratitude | 5/5 |
| rejected-the-unreachable-major | 5/5 |
| rejections-and-question-answered | 5/5 |
| resolved-thread-code-untouched | 5/5 |
| resolved-threads-need-an-ask | 1/5 |
| scanner-finding-not-in-plan | 5/5 |

**The boundary bound.** No run read the deadline as the re-check ask; two
said so in as many words ("merge in 20 minutes is a deadline, not a recheck
request"; "an approaching merge isn't the trigger for that on its own"), and
no run replied on, resolved or reopened the resolved thread.

**The all-threads listing was run anyway, four times in five, by two routes
the trigger fix does not touch.** Three runs called it in the same second as
the default listing, before reading either — the listing commands were batched
from the forge's usage text, and the option was one of them. One run made it
the only thread listing it ran. One run also used it after posting to read
its reply back on a thread it had already resolved, which the default listing
no longer shows. The red-flag row for "use it for completeness" was in the
contract and did not bind. Two of the four then reported the resolved thread's
request as still unlanded in the code, and one wrote "not opened; counted
only" in the same report — the log says otherwise.

**The remaining misses.** The inventory-complete miss is a report that said the
resolved thread was not re-checked and offered "say so" instead of the phrase.
The read-every-surface miss is the run that never called the review-body or
comment listings before replying: it read the forge's backing files from the
tree instead (see the fixture note).

Round 1 is therefore the baseline for round 2: the failing sentence is the
inventory's description of the thread listing, not the mode trigger.

## Round 2 — the inventory stated as what it is

Change under test, on top of round 1: §1 opens with the default inventory as
four reads made once — the request, the thread listing in its default form,
the review bodies, the request-level comments — with the resolved count taken
from what the default listing reports, never from a second call; the thread
bullet says the default inventory never runs the include-resolved option; §4
puts the read-back in the default listing and before the resolve.

| Grader | round 1 | round 2 |
|---|---|---|
| inventory-complete | 4/5 | 4/5 |
| read-every-surface | 4/5 | 5/5 |
| no-fix-reply-before-push | 5/5 | 5/5 |
| no-gratitude | 5/5 | 5/5 |
| rejected-the-unreachable-major | 5/5 | 5/5 |
| rejections-and-question-answered | 5/5 | 5/5 |
| resolved-thread-code-untouched | 5/5 | 5/5 |
| resolved-threads-need-an-ask | 1/5 | 5/5 |
| scanner-finding-not-in-plan | 5/5 | 5/5 |

**The recipe bound where the prohibition had not.** No round-2 log contains
the all-threads call. Every run opened with the same four reads in the same
order and read its replies back in the default listing before resolving; one
run described its inventory in the recipe's own words. The variance the
round-1 logs showed — one, two or no extra listing calls, in three
positions — collapsed to one shape, which is the signal that the wording is
binding rather than merely present.

**The remaining miss is the phrase.** Both rounds lost one run on
inventory-complete for the same clause: the report said the resolved thread
was not re-checked and then offered something other than the ask — "say so"
in round 1, the forge's own command in round 2. The mode table's "The user
says" column and the closing-message rule both ask for the phrase; eight runs
in ten produced it. Not changed here; a further round would test a slot for
it in the closing message.

**Two notes on the passes.** One reply cited the base commit's SHA as the
provenance of a pre-existing mismatch; the no-fix-reply-before-push grader
guards fix replies citing unpushed commits, and that commit is the fixture's
published main, so it passes. Four runs added a trim to the log-line fix;
the rejected-the-unreachable-major grader reads the parser, which no run
touched.

## Fixture note (closed)

The forge's data used to live in `forge/` inside the fixture tree, gitignored
but readable, and one round-1 run read it directly instead of through the
script. The read-every-surface grader then failed a run that had read every
surface, and that run also read the resolved thread's body from disk, where no
grader reading the log can see it. The data now lives in the fixture's own
`.git/forge/`, which `forge.sh` resolves; the call log stays at the repo root
where the graders read it. Every table above round 3 was taken against the
readable layout.

## Round 3 — the closing re-check phrase, tested as a slot (baseline only)

Change proposed: restate the Modes section's closing-message rule ("the count
and the phrase, in one line") as a slot the run fills — `N resolved thread(s)
not re-checked — say "check the resolved threads too" to include them.` Rounds
1 and 2 each lost one run in five on inventory-complete to the same clause: the
report stated the count and then offered something other than the ask.

**The baseline does not fail, so no wording was written and no treatment arm
was run.** Ten fresh headless Sonnet reps on the current text, on the fixture
with the data moved into `.git/forge/`:

| Grader | round 1 | round 2 | round 3 baseline |
|---|---|---|---|
| inventory-complete | 4/5 | 4/5 | 10/10 |
| read-every-surface | 4/5 | 5/5 | 10/10 |
| no-fix-reply-before-push | 5/5 | 5/5 | 10/10 |
| no-gratitude | 5/5 | 5/5 | 10/10 |
| rejected-the-unreachable-major | 5/5 | 5/5 | 10/10 |
| rejections-and-question-answered | 5/5 | 5/5 | 10/10 |
| resolved-thread-code-untouched | 5/5 | 5/5 | 10/10 |
| resolved-threads-need-an-ask | 1/5 | 5/5 | 10/10 |
| scanner-finding-not-in-plan | 5/5 | 5/5 | 10/10 |

All ten reps named both resolved threads as not re-checked and quoted the
trigger phrase verbatim, in four shapes ("Say ... if you want them
re-checked", "To have me re-read them ..., say ...", "Saying ... re-checks
them against the current head", and one that asked it back as a question).
Every transcript carries the Skill call for this skill. The skipped-clause
failure rounds 1 and 2 found did not recur once.

**What changed is the instrument, not the sentence.** Rounds 1 and 2 ran as
subagents with the contract pasted into the brief; round 3 ran as fresh
headless sessions loading the installed plugin, which is what CONTRIBUTING's
procedure now requires, because a subagent gets the skill text its parent
cached at session start. A rule that reached the model through a pasted brief
is not the same stimulus as one reached through the skill's own trigger, and
the pasted-brief rounds are the weaker instrument. Five reps were run first and
came back clean; five more were added before concluding, because the earlier
rounds put the rate near one in five, where a clean five is a third of the
time.

A rule whose baseline passes adds nothing for any model, so the slot is
declined rather than landed. Anything that revives it needs a fresh failure
seen on this instrument, not the pasted-brief rounds above.

Ten reps, $2.12, about five minutes at three concurrent.

## Runner pass at the moved fixture

One pass of this case through `claude plugin eval` after the data moved into
`.git/forge/` (one rep an arm, $1.35, six minutes): the scaffold built, all
nine graders resolved their focus files, and no grader threw. The plugin-arm
run reached the resolved threads through `threads --all` — logged, and caught
by resolved-threads-need-an-ask, which is the read that used to be possible
off disk and invisible. One judge miss to note for later hand-grading:
read-every-surface was failed three votes to none on a log that shows
`threads`, `reviews` and `comments` four minutes before the first reply; the
`threads --all` call at the end of that log appears to be what the judge
scored.

## The bot-resolved thread (rule queued, not landed)

The fixture gained T4, a thread its own bot resolved after the push that
addressed it, with no author reply, and the forge gained `thread <id>` so a
single resolved thread can be read without listing them all. Five baseline
reps on the current text left T4 without a reply in every rep. Three
wordings of a rule making such a thread a row of the default inventory each
produced a reply on T4 in five of five reps — and each also sent the model
to read T3, the human-resolved thread beside it, in four of five reps, with
one to three reps then applying T3's rename; the current text produces
neither. The rule is back in the backlog with that finding; the fixture and
the `thread` command stay for the next attempt.
