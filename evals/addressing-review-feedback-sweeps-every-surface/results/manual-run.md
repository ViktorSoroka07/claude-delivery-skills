# Manual runs

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

## Fixture note

The forge's data lives in `forge/` inside the fixture tree, gitignored but
readable, and one run read it directly instead of through the script. The
read-every-surface grader then fails a run that did read every surface. The run
that did so also read the resolved thread's body from disk, which no grader
reading the log can see. A real forge is not a directory; the next fixture
revision should put the data where a repository search does not find it
(recorded in the review findings as B3).
