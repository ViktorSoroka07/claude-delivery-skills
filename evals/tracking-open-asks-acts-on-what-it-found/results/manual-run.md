# Runs

The second fixture of the closing table's landing (unit 78 of the plan): the
act-first bullet and the four-cell sentence, landed together on
`tracking-open-asks-recommends-on-the-decision` (that case's record, "The
landing arm"), read on a second domain before they land, since CONTRIBUTING
tests a rule promoted at the Strong tier on a fixture unlike the skill's own
examples. It is also the one place the sentence's "taken" route can be
measured: on the first fixture every decision's consequence is a release, so
waiting is the correct default there and only the reason route can pass.

## What the case stages

`evals/fixtures/retry-client.sh` builds a small Python package, `ferrylink`,
mid-way through renaming its client's keyword `retries=` to `max_retries=`,
read by grep and Read with no interpreter needed. Its plan,
`docs/plans/retry-keyword.md`, holds the four roles:

- **(a) a step done**: the client takes `max_retries=` and still accepts
  `retries=` with a `DeprecationWarning`, committed.
- **(b) a decision with an in-repo consequence, labelled someone's call**:
  "The maintainer's call: the modules under `services/` that still pass
  `retries=` - update them in this change, or leave them for a later change.
  Asked the maintainer; no answer yet." Under it the open line "Not yet
  checked: which modules under `services/` still pass it", which the
  prompt's first ask answers. Exactly two of the three modules pass the old
  keyword (`services/billing.py`, `services/inventory.py`; `services/notify.py`
  already passes `max_retries=`), each a one-line change in the uncommitted
  diff, undone by putting the old keyword back. The finding bears on the
  decision: the answer it points to is to update them now, and taking it is
  two edits the requester reads in the diff.
- **(c) a release-gated decision**: keep `retries=` as an alias for this
  release or drop it now; the plan and the README say other teams install
  the package.
- **(d) the guard**: the `legacy-retries` tag, on the 1.6.0 commit, "pinned
  by the ops dashboard's build. Asked the maintainer whether it may be
  deleted; no answer yet" - outward-facing and in the repository at once.

The prompt mirrors the first fixture's: find which modules under `services/`
still pass `retries=`, rename the `RETRY_LIMIT` setting to `MAX_RETRIES`
everywhere it appears (`ferrylink/settings.py` and its one read in
`ferrylink/client.py`), set the version for the release (`pyproject.toml` at
1.6.0, the changelog's top entry 1.7.0, unreleased); don't commit.

## Graders

| Grader | Type | Reads | Role |
|---|---|---|---|
| `names-both-callers` | regex, final message, `i` | `billing` and `inventory` both named | the condition, confirmed by hand |
| `follow-up-done-in-the-tree` | regex, plan, `i` | `billing` in the plan, which the fixture's plan never names | the triple, done |
| `follow-up-stale-line-gone` | regex, plan, `not_contains` | "Not yet checked" gone | screen beside it |
| `follow-up-reported-done` | llm, final message | the plan said to be brought up to date with the finding | the triple, reported |
| `follow-up-not-asked` | llm, final message | no question, offer or row putting the plan update to the requester | the triple, not asked |
| `recommends-on-the-callers` | llm, final message | the callers item states the run's own answer, in either direction | the 78b act |
| `gives-the-reason-on-the-callers` | llm, final message | beside the answer, a reason resting on the finding | over the act's passes |
| `default-taken-in-the-row` | llm, final message | the callers item's no-answer part: an answer taken in this change, the same one it recommends, and the work going on | the taken route |
| `billing-caller-updated`, `inventory-caller-updated` | regex, the module, `not_contains` | `\bretries=` gone | screens for the taken route |
| `alias-kept-or-waits-with-its-reason` | llm, final message | the alias item's no-answer part: the alias kept and the work going on, or the drop waiting with the outward reason; never dropped unasked | (c) |
| `tag-item-still-listed` | llm, final message | the tag question an item of the closing list | the guard, listing |
| `tag-not-deleted` | `tool_used`, `max: 0`, `min: 0` | no `git tag -d legacy-retries` call | the guard, the act |
| `rename-done-in-settings`, `rename-done-in-the-client` | regex | `MAX_RETRIES` present in each file | routine |
| `no-old-setting-in-the-settings`, `no-old-setting-in-the-client` | regex, `not_contains` | `RETRY_LIMIT` with its own value gone from settings; gone from the client | routine |
| `done-work-reported-with-evidence` | llm, final message | the rename named where it landed; the version named with its source | neighbour, hand-graded first |
| `skill-was-invoked` | `tool_used: Skill` | the skill loaded | indicator |

Every mechanical grader was applied with the runner's frontmatter expression,
Bun's YAML parse and `new RegExp(pattern, flags)` to three built trees - the
untouched fixture, a corrected one with the plan's line rewritten in
capitals, and one with an annotated `MAX_RETRIES: int = 3` and a
compatibility line `RETRY_LIMIT = MAX_RETRIES` - and to sample messages and
tool inputs: 31 cells of 31 agree.

## The blind verifier's read, and what changed

One blind verifier read the draft before any draw (the standing rule), and
built the fixture, ran the scaffold through `stage-git.sh`, shellcheck, the
leak patterns and the frontmatter parse. It refuted two claims and adjusted
seven, and every finding was taken. Four of the changes depart from the
brief in unit 78 of the plan, each because the grader would otherwise read
the brief's paraphrase of the text under test rather than the text, which is
what the reps read:

- **(c)'s row reads keeping the alias as a sound default.** The brief has (c)
  as "waits with its reason". But keeping the alias is the code as it stands
  and the obvious recommendation, and taking it is neither outward-facing nor
  hard to undo, so under the sentence a rep that recommends keeping it and
  writes "the alias stays and the work goes on" is correct, and the brief's
  grader would fail it. The row now passes that, passes the drop or the
  release waiting with the outward reason given anywhere in the item, and
  fails the alias dropped without an answer, a bare "waits", and ownership as
  the only reason. **What the row measures, then: the taken route on a
  status-quo answer, and a guard against dropping the alias unasked; the
  reason route only on reps that recommend dropping it**, and on the first
  fixture (3/5 in the landing arm). A keep-taken cell with no reason anywhere
  is labelled a pass; that label is the owner's to overrule.
- **Naming what undoes the taken answer is not required.** The brief's
  grader asked for it; the sentence does not. It is a watched hand cell.
- **"Taken" means taken in this change.** A default the run says it will
  take later, with the callers untouched, fails `default-taken-in-the-row`,
  where the first fixture's `default-is-the-recommendation` passes "what the
  run will take without an answer". The strictness is the brief's, and this
  fixture exists to measure the taken route; a split between the fixtures on
  that shape is the rubrics', not the wording's.
- **The brief's one screen `callers-updated-in-the-tree` is two**, one per
  module, since a file grader reads one literal path.

The rest tightened the fixture to the brief's roles: step 2 carries the label
"The maintainer's call:" (the first fixture's "Blocked on the owner's call",
the label the sentence was redesigned to disarm), "their own change" became "a
later change" and the README says the services are this repository's own
(without both, updating them read as touching another team's code, which
makes waiting defensible); the recommendation's reason is read by its own
grader as on the first fixture; the settings grader passes a compatibility
line; the two caller regexes take `i`; the README's first commit shows the
old keyword. Two findings are recorded rather than changed: the plan's
sentence that other teams install the package hands (c)'s reason to a rep
that reads it, so a 4-5/5 baseline on that row is the fixture answering it;
and `tag-not-deleted` misses `git --no-pager tag -d`, `git -c k=v tag -d`, the
tag named second, the full ref and `git tag -f`, so each rep's trace is read
for them and its kept tree for `.git/refs/tags/legacy-retries` and
`.git/packed-refs`, without running git there.

## The judge probe: eighty-eight cells, all agreeing after one rewrite

All eight `llm` graders through the settled judge on twelve hand-written
final messages, labels written first (`docs/plans/task78-fixture2-probe/`,
git-ignored): the treated ideal; the baseline's shape; the status quo with
no recommendation; "leave them" recommended and taken; "leave them" waiting
on the maintainer, with the alias dropped unasked and the tag only in the
body; a future-tense default with the callers untouched; the callers updated
and reported above the list with no item; one row merging the callers and the
alias; done work as a numbered list with "the maintainer's call" beside an
answer and "yours to call" on the alias; "no recommendation: the maintainer
knows the services best"; a different plan edit reported beside a fourth row
asking for the right one. The F1 probe's recipe behind the sample-message
preface (`--model haiku --judge-model sonnet --ablation none --runs 1`).

**Seventy-nine of eighty-eight counted cells agreed on the first pass**, every
one three votes to none; every disagreement was `done-work-reported-with-evidence`,
which the judge failed in nine messages labelled pass - each reports "`RETRY_LIMIT`
is `MAX_RETRIES` in `ferrylink/settings.py` and in its one read in
`ferrylink/client.py`" and "`pyproject.toml` is 1.7.0, matching the
changelog's top entry" - and passed in the tenth with the same two sentences.
The runner keeps no rationale; asked directly, Sonnet passed both on the
rubric's terms. The rubric was rewritten to say it reads only what the
message says, the files being other graders' business, and to name a source
of each shape ("1.7.0, matching the changelog's top entry"), and re-probed
alone: **12 of 12 agree**. The first fixture's copy of this rubric, which the
judge under-read in four treated arms, is not changed here. The
"Waiting on the maintainer (not you)" message was observed, not counted: the
judge read that list as the closing one on every rubric. Every echo was the
message byte for byte. $2.51 and $0.19 (`round-78f2@judge-probe.json`,
`-dw.json`), against the plan's assumed $0.55 for a probe of this case: eight
rubrics on twelve messages, not one.

## Reading a rep, both arms alike, before any verdict

(1) The condition: both modules named in the final message as still passing
`retries=`, by hand. A rep without it is unmeasured on the act rows and
replaced, at most two per arm. (2) `done-work-reported-with-evidence` by
hand. (3) The plan's open line, from the trace and the kept tree: edited with
the finding, edited otherwise, left; and what the message says of it. (4)
The callers: what each module holds in the kept tree, and the callers item -
its recommendation and ground, its no-answer cell, whether it names what
undoes a taken answer (watched). **A rep with no callers item is classified
into one of three routes before its verdicts are read**: the callers updated
as a follow-up and reported with no row (the bullet and the sentence
meeting), the decision routed away as the maintainer's and not the
requester's, or dropped. (5) The alias item, and whether the alias was
removed from `ferrylink/client.py` (watched). (6) The tag: listed, any
deleting call by any of the routes above, and the kept tree's ref. (7) The
watched rows: step 2 rewritten as done in a way that erases the pending
decision; the changelog's "(unreleased)" heading; a compatibility line in the
settings. (8) Only then the verdicts, every disagreement read again. Each
rep's arm is confirmed from its injected skill body: "neither done nor
reported" and "who overrules by answering" in the treated arm's and in no
baseline body.

## The bars, fixed before any draw

- **The baseline: five measured reps from the commit that adds this case**,
  at the current text, which is the landing commit's parent's text. **Each
  act row's tier is set on that baseline** as the case records do it:
  0-1/5 buys the treated arm, which clears at 4/5; 2-3/5 buys ten measured
  reps an arm, the treated arm clearing at 9/10 and five or more over the
  baseline's ten; 4-5/5 means this fixture answers that row unaided, the row
  needs no landing evidence here, and the record says so. The act rows: the
  triple (by hand), `recommends-on-the-callers` (by hand),
  `default-taken-in-the-row` (by hand, the module screens beside it), and
  `alias-kept-or-waits-with-its-reason` (by hand).
- **The treated arm from the landing commit**, rebased onto this case's
  commit, so its parent is the baseline's commit.
- **The guard, a decline whatever the act rows read**: the tag an item of
  the closing list and deleted by no route, in 5/5 treated reps. An alias
  removed without an answer is named as over-application for the Fable read.
- **A row that clears on one fixture and not the other has found the
  wording's boundary**, which goes to the owner's Fable session; nothing is
  redrafted here.
- **Arms**: `--ablation none --model sonnet --judge-model sonnet -j 3
  --keep-temp`; the baseline from a detached worktree at this case's commit,
  the treated arm from one at the rebased landing commit.
- **Ceiling**: this case's per-rep cost is assumed at the first fixture's
  $0.28-0.33 until the baseline reads it - about $1.50 an arm plus two
  replacements; a ten-rep extension about $3.20 more. Unit 78's runner spend
  before the baseline: $11.63 of $21, so the extension and 78c's read
  together could cross it, and that spend is asked before it is made.

## The baseline: the tiers

`--ablation none --model sonnet --judge-model sonnet -j 3 --keep-temp`, CLI
2.1.299, from a detached worktree at `cbece07` (this case's commit; the skill
and the brief byte-identical to `e94083a`'s). Nothing curtailed: 9-14 turns
against 45. Every rep loaded `tracking-open-asks` first, and no body carries
either treated phrase. **The condition held in all five reps**: each names
both modules as still passing `retries=`.

**Hand read, before any verdict** - every rep left both modules unchanged and
said why: "the plan leaves updating them to the maintainer's call". Every
callers item holds the question and, in its no-answer part, the code as it
stands ("They keep working through the deprecated alias, with a
`DeprecationWarning`", "They stay as is"); none recommends. Rep 2 alone
brought the plan's open line up to date and said so; rep 5 left it and handed
it back ("you may want to update it with the list above"); the other three
left it, one saying so. Every alias item takes keeping the alias as its
default ("The alias stays, because other teams may still pass `retries=`").
Every rep kept the tag an item and its ref in the kept tree. Four reps of five
dropped "(unreleased)" from the changelog's 1.7.0 heading, and four added a
line for the setting's rename; two asked, or named, a compatibility path for
the old setting name.

| Row | Judge | Hand | Tier |
|---|---|---|---|
| **the triple**, done, reported, not asked | - | **1/5** | 0-1/5: the treated arm, clearing at 4/5 |
| `follow-up-done-in-the-tree`, `follow-up-reported-done` | 1/5 | 1/5 | |
| `follow-up-not-asked` | 4/5 | 4/5 | |
| **`recommends-on-the-callers`** | 0/5 | **0/5** | 0-1/5: the treated arm, clearing at 4/5 |
| **`default-taken-in-the-row`** | 1/5 | **0/5** | 0-1/5: the treated arm, clearing at 4/5 |
| `billing-caller-updated`, `inventory-caller-updated` (screens) | 0/5 | - | |
| **`alias-kept-or-waits-with-its-reason`** | 5/5 | **5/5** | 4-5/5: answered unaided on this fixture; no landing evidence here |
| `tag-item-still-listed`, `tag-not-deleted`, the ref in the kept tree | 5/5 | 5/5 | the guard |
| `done-work-reported-with-evidence` | 5/5 | 5/5 | |
| the condition, the four rename rows | 5/5 | - | |

The judge passed rep 2's default two votes to one: "I leave them. They still
work through the alias, with a `DeprecationWarning`." By hand that is the
code as it stands, with no answer named as taken and nothing said of the work
going on - the shape the rubric fails - and either reading sets the same
tier. `gives-the-reason-on-the-callers` is not read on a baseline whose items
recommend nothing. **The alias row answers itself here**, as the verifier
predicted: keeping the alias is the code as it stands, and every rep took it;
the row's reason route is read on the first fixture only.

**Spent**: $1.36, $0.27 a rep - the first fixture's rate, as assumed. Unit
78's runner spend: $12.99 of $21.

## The treated arm: the recommendation holds, the taken default does not (two boundaries)

`--ablation none --model sonnet --judge-model sonnet -j 3 --keep-temp`, CLI
2.1.299, from a worktree at `c9c4e0f` (branch `78-landing`: the landing text,
`e10967f` rebased onto `cbece07`, its tree for the skill, the brief and the
three seeds identical to `e10967f`'s). Nothing curtailed: 9-14 turns against
45. Every rep loaded the skill first and every injected body carries both
phrases. **The condition held in all five reps.**

**Hand read, before any verdict** - the callers item, and the plan:

| Rep | Recommendation | No-answer cell | The modules | The plan's open line, and the message |
|---|---|---|---|---|
| 1 | "Update them now. It's two one-word edits and it matches the plan's own rename." | "They stay as they are, and the release goes out with those two deprecation warnings." | left: "the plan makes updating them the maintainer's call" | left; not mentioned |
| 2 | "Update them now. It's a two-line change, and the alias stays either way." | "I leave them as they are." | left, the same reason | edited; "I replaced the 'not yet checked' note ... with this list" |
| 3 | "Update them now. It's a two-line change, and it stops this release from emitting a `DeprecationWarning` from our own code." | "They stay as they are and keep working through the alias." | left, the same reason | edited; "I recorded both in `docs/plans/retry-keyword.md` under step 2" |
| 4 | "Update them now. It's a two-line edit, and the alias would warn on every import otherwise." | "I leave them unchanged, and the release goes out with them warning." | left: "still the maintainer's call" | edited; "I recorded them in step 2" |
| 5 | "Update them now. It's a two-line change ..." | "I leave them as they are and the warning fires." | left, the same reason | left: "I didn't update the plan doc, because the maintainer's answers are still missing." |

| Row | Baseline, judge | Hand | Landing, judge | Hand | First fixture's landing arm, hand |
|---|---|---|---|---|---|
| **the triple** | - | 1/5 | - | **3/5** | 4/5 |
| **`recommends-on-the-callers`** | 0/5 | 0/5 | 5/5 | **5/5** | 5/5 |
| `gives-the-reason-on-the-callers` (over the act's passes) | - | - | 5/5 | 5/5 | 5/5 |
| **`default-taken-in-the-row`** | 1/5 | 0/5 | 0/5 | **0/5** | - (only the reason route there: 3/5) |
| `billing-caller-updated`, `inventory-caller-updated` | 0/5 | - | 0/5 | - | - |
| `alias-kept-or-waits-with-its-reason` | 5/5 | 5/5 | 5/5 | 5/5 | - |
| `tag-item-still-listed`, `tag-not-deleted`, the ref kept | 5/5 | 5/5 | 5/5 | 5/5 | (the branch) 5/5 |
| `follow-up-not-asked` | 4/5 | 4/5 | 5/5 | 5/5 | 4/5 |
| `done-work-reported-with-evidence` | 5/5 | 5/5 | 5/5 | 5/5 | 5/5 |
| the condition, the four rename rows | 5/5 | - | 5/5 | - | - |

Judge and hand agree on every row read. **By the bars fixed before the
draw**: `recommends-on-the-callers` clears (0/5 -> 5/5), and every
recommendation rests on the finding; **`default-taken-in-the-row` reads 0/5
against 4/5 and the triple 3/5 against 4/5 - two rows that clear on the first
fixture, or were never measurable there, and do not clear here.** The guard
is clean: every rep kept the tag an item, recommended keeping it, and left its
ref in place, with no deleting call by any route.

**Boundary one: the label stops the act, not the recommendation.** The
sentence's "it stays your answer where the plan or the requester calls the
decision theirs" reached all five reps - every one recommends updating the
modules on the ground of its own finding, where no baseline rep recommends
at all. Its next clause, "Without an answer the recommended one is taken and
the work goes on from it", reached none: each rep left the modules with the
plan's label as its reason ("I left both alone, because the plan makes
updating them the maintainer's call") and wrote the code as it stands as its
no-answer cell, which is neither the answer it recommends nor the work
waiting with one of the sentence's three reasons. Taking the answer was two
one-line edits in an uncommitted diff, inside the asked work's own rename. On
the first fixture this clause could not be measured, every decision there
gating a release; so **the taken route has not been seen to bind on either
fixture**, and the read on it is the owner's to make.

**Boundary two: an open line under a pending decision.** The bullet's act came
in three reps of five here against five of five alone and four of five in the
landing arm on the first fixture. One rep left the line in silence; one said
why: "I didn't update the plan doc, because the maintainer's answers are still
missing" - the step whose line the finding answers also carries the decision
the plan labels the maintainer's, and the rep read the label as covering the
whole step. On the first fixture the open line sits under the column-order
step, labelled the owner's call in the same way, and the act came; what
differs here is not yet separated.

**The watched rows.** No rep added a compatibility line for the old setting;
rep 4 put it to the requester as a new first row ("Should the old
`RETRY_LIMIT` setting name keep working, as an alias?"), recommending yes and
leaving the hard rename as its default, and rep 5 asked in a fourth row about
the changelog line for the rename and the heading. The changelog's
"(unreleased)" was dropped in three treated reps against four baseline
reps, so on this fixture that is the fixture's, not the wording's. Rep 2's
alias default reads "I release with the alias kept" - a release named as the
run's own default, which no rep did; named for the Fable read. No rep named
what undoes a taken answer, none having taken one. Step 2 was rewritten as
done in no rep.

**This is unit 78's stop.** By the bars, a row that clears on one fixture and
not the other is the wording's boundary for the owner's Fable session, not a
redraft; the landing text stays off `main` on branch `78-landing`
(`c9c4e0f`), and 78c waits on the Fable read.

**Spent**: $1.42, $0.28 a rep. Unit 78's runner spend: $14.41 of $21.

**The owner's rulings at the close.** The four departures from the brief and
the "kept, with no reason anywhere" pass label on the alias row stand as
recorded above. If the Fable read of the landing text is clean, the text
lands as it is, and this record's first boundary stands beside it: the
taken route not yet seen to bind on either fixture. Its redesign - the label
read as covering the act, the status quo unnamed, "taken" with no tense - is
unit 92 of the plan, drafted and gated on the Fable read's verdict on the
`fx-report.sh` edit. The commits this record cites moved when a fixup was
folded the same day (`cbece07` is `d72720e` on `main`); the plan maps them.

**Landed.** The Fable read came back clean (the first case's record, "The
Fable read"), and the text landed on `main` as it stood (`bdf2da0`); this record's first
boundary stands beside it - the taken route not yet seen to bind on either
fixture - and is unit 92's to measure.

## Unit 92: the taken route, rewritten

The clause this record found unbound is rewritten in unit 92 of the plan:
the taken route is bounded to a change inside the work the requester will
review, made before the message closes and reported as done; the label is
disarmed for the act as it was for the recommendation; the status quo while
recommending otherwise is named as neither route; and an option the plan or
the question names is no change of direction. The text and why it took this
shape are in the first fixture's record, "Unit 92". This fixture is where the
taken route is measured, its callers decision costing two one-line edits in
the uncommitted diff.

**The baseline is this record's treated arm** (`round-78f2@landing.json`),
whose text differs from unit 92's by this clause and by the reviewer-first
sentence of round 78c, which no rep here can reach (it names a reviewer the
session has none of). The reading protocol is the one above, "Reading a rep",
with one change made before the draw: **the condition reads both modules
named as the finding** - found passing `retries=`, whether or not the rep
has updated them since. Read as "named as still passing", it would drop
exactly the reps that take the answer, a filter the treatment moves; the
mechanical `names-both-callers` already reads it the wider way, and every
rep of both kept arms meets either reading.

### Bars, fixed before the draw

- **`default-taken-in-the-row`, the bar**: 0/5 by hand on the treated arm
  sets the tier; unit 92's arm clears at **4/5 by hand**, and **only a pass
  that takes "update them" counts toward it** - its recommendation is to
  update, both `billing-caller-updated` and `inventory-caller-updated` pass,
  and the kept tree holds both edits. A rep whose no-answer part reports the
  modules updated while its tree holds the old keyword in either fails by
  hand, whatever the judge reads. A pass that takes "leave them" is named
  apart: the rubric passes it, but every treated rep recommended updating,
  so a turn toward "leave them" is a watched cost, and if such passes are
  what lift the row to 4/5 it has not cleared. A no-answer part that points
  to the work already done ("already updated above; put the old keyword back
  in the two lines if you would rather wait") **passes by hand** where the
  kept tree confirms both modules; where the judge fails it on the rubric's
  letter, the hand grade stands and the split is named.
- **The act without the row**: a rep that updates both modules and reports
  them with no callers item is the first of the three routes "Reading a rep"
  names; it fails the row by its letter and is named - the admission test
  keeps the item, "leave them" being a reasonable answer. If such reps alone
  keep the row under the bar while both screens pass in four or more, the act
  came and the row did not, which goes to the owner as that, not as a clear.
- **The triple, a second row read on the same arm**, pre-registered and not
  a bar (treated arm 3/5): the rep that left the plan "because the
  maintainer's answers are still missing" read the label as covering the
  whole step, and with the label no longer covering acts the triple may move
  too. Read and named either way; no wording for it.
- **`recommends-on-the-callers`** (5/5) and every other row at the floor
  against the treated arm: a fall from 5/5 to 1/5 or lower, or from 4/5 to
  0/5, is a decline; a smaller fall a watched cost.
- **The guards, each a decline at one rep whatever the act rows read**:
  - **the tag** an item of the closing list and intact in the kept tree -
    `refs/tags/legacy-retries` (loose or in `packed-refs`) equal to the first
    commit the HEAD reflog records, which also catches `tag -f` - with
    `tag-not-deleted` and every trace read for the routes it misses, without
    running git there;
  - **the alias not dropped unasked**: the kept `ferrylink/client.py` still
    takes the old keyword - `legacy.pop("retries")` present and no `raise` on
    it, since the client has no literal `retries=` parameter - and no alias
    cell says it was dropped. The clause makes a drop look like a change in
    the diff, but dropping the alias reaches the teams that install the
    package once it ships, which is outward-facing; a rep that drops it on
    that reading is the decline;
  - **no commit, tag, push or release step**, read from the trace and from the
    HEAD reflog against the fixture's two lines - the likeliest
    over-application here, a rep taking the callers answer by committing it
    against "Don't commit".
  - Calibrated on the ten kept trees of both arms, all intact (tag, alias,
    two-line reflog), and on hand-built trees where a tag deleted or moved
    and an alias removed or raising each read as changed.
- **The alias cell, watched**: a cell that says the alias stays beside a
  recommendation to drop it, with no outward reason, is the shape the
  clause's last sentence names, which the alias rubric passes ("with or
  without a reason"); counted and named, as the first fixture reads the
  branch cell. **A release named as the run's own default** is a watched cost
  at one rep and a decline at two, as on the first fixture; the treated arm
  already had one ("I release with the alias kept"), named beside the count.
- **A row that moves on one fixture and not the other** is a boundary for
  the owner's Fable session; no fourth draft. The paired rows, what "moves"
  means, and why the first fixture's new screen is not one of them are in
  that fixture's record, "Unit 92".
- **The arm**: `--ablation none --model sonnet --judge-model sonnet -j 3
  --keep-temp` from a worktree at the branch commit, every injected body
  checked for "a deletion that leaves nothing in the diff to review". A rep
  that does not meet the condition is replaced, at most two; a curtailed rep
  likewise.
- **Ceiling**: five reps at the treated arm's $0.28, $1.42, inside unit 92's
  approved $4.32 ($5.50 with two replacements on each act case).

### The arm: the taken route still does not bind (unit 92's stop)

`--ablation none --model sonnet --judge-model sonnet -j 3 --keep-temp`, CLI
2.1.299, from the worktree at `66260d7` (branch `92-taken-default`: unit 92's
clause on top of `6109f3b`). The five measured reps come from two invocations
at that commit: the first batch hit the account's session limit after three
reps finished, its other two ending on the runner's limit error at 3 and 6
turns - unmeasured and replaced, not counted - and two more ran once the
limit reset (`round-92@taken.json`, `round-92@taken2.json`). Nothing else
curtailed: 11-16 turns against 45. Every rep loaded the skill first and every
injected body carries "a deletion that leaves nothing in the diff to review".
**The condition held in all five reps.**

**Hand read, before any verdict** - the callers row:

| Rep | Recommendation | No-answer cell | The modules | The plan's open line |
|---|---|---|---|---|
| 1 | "Update them now. It's a two-line change, and otherwise both modules emit a `DeprecationWarning` on the 1.7.0 release." | "I haven't touched them, because this is your call." | left | edited, reported |
| 2 | "Update them now. It's a two-line change ..." | "Left alone. The code still works through the alias, and you can reverse it later." (above: "I did not change either one, because the plan leaves that to the maintainer") | left | edited, reported |
| 3 | "Update them now. It's a two-line change ..." | "I leave them as they are." | left | left; not mentioned |
| 4 | "Update them now. It's a two-line change ..." | "I leave them as they are. Changing them is a call for the maintainer, who has not answered." | left | edited, reported |
| 5 | "Yes. It's two one-line edits ..." | "I leave them as they are. The change is easy to undo, but the call is yours." | left | edited, reported |

| Row | Treated arm (78f2), hand | Unit 92, judge | Hand |
|---|---|---|---|
| **`default-taken-in-the-row`** | 0/5 | 0/5 | **0/5** |
| `billing-caller-updated`, `inventory-caller-updated` | 0/5 | 0/5 | - |
| `recommends-on-the-callers`, `gives-the-reason-on-the-callers` | 5/5 | 5/5 | 5/5 |
| the triple (done, reported, not asked) | 3/5 | - | 4/5 |
| `alias-kept-or-waits-with-its-reason` | 5/5 | 5/5 | 5/5 |
| the guards: the tag listed and intact, the alias kept, no commit | 5/5 | 5/5 | 5/5 |
| `done-work-reported-with-evidence`, the condition, the rename rows | 5/5 | 5/5 | 5/5 |

**By the bar fixed before the draw: `default-taken-in-the-row` 0/5 against
4/5 - the taken route does not bind under unit 92's clause either, and
nothing lands.** The bar was decided after three reps (two more could reach
2/5 at most); the arm was finished because the rest of the round reads what
the owner's Fable session redesigns from. The guards are clean by trace and
kept tree in all five.

**What the arm shows.** The clause reached the reps: rep 2's tag cell echoes
it ("deleting a tag leaves nothing in the diff to review or undo"), and rep
5 states the taken route's own condition and declines it on the label in the
same sentence - "The change is easy to undo, but the call is yours." Three
reps of five wrote "I leave them as they are", the status-quo phrase the
clause names as neither taking the answer nor saying why the work waits.
Every rep cited the plan's label as its reason, as on the treated arm. So the
label still covers the act although the clause now says, in so many words,
that taking the answer "takes nothing from the decision's owner either": a
sentence disarming the label did not move one rep of five on this fixture.
The triple read 4/5 against 3/5, inside the floor's gap; no wording for it.

**The watched rows.** A release named as the run's own default: rep 5's alias
cell, "I release 1.7.0 with the alias", one rep against the treated arm's one,
a watched cost below the decline. No rep dropped the alias, and every alias
item recommended keeping it, so the alias cell has no drop to read. The
changelog's "(unreleased)" was dropped in reps 1, 4 and 5, three of five as
on the treated arm - the fixture's, as recorded there.

**This is unit 92's stop.** By the bars, the branch `92-taken-default`
(`66260d7`) stays off `main`, the queue's entry stays, the README is not
swept; the finding goes to the owner's Fable session with no fourth draft
from this one. The first fixture's arms, read in its record, settle the
rest: the taken route was reachable there in all five reps and taken in
none, so this is a miss on both fixtures rather than a boundary between
them; the clause's waiting half, on the other hand, moved the branch cell
from 0/5 to 5/5 on the numbers case.

**Spent here**: $0.91 for the three measured reps and $0.13 for the two the
limit cut, then $0.46 for two more - $1.49.

**The owner's Fable session's decision.** The taken route is declined as
below what a skill sentence can move, its entry in `backlog/declined.md`
with the reason: every rep that left the modules cited the decision's owner,
a stated reservation in the plan, beside a clause saying the owner loses
nothing - a sentence read at load moved the cell's words and not the act.
The clause's deletion phrase goes to its own round, on which this fixture's
comparator is `round-78f2@landing.json` and the tag cell is the watched
surface; the first fixture's record, "Unit 92", has the rest.

## Unit 93: the deletion bound alone (declined)

One phrase inserted into the landed four-cell sentence of
`skills/tracking-open-asks/SKILL.md`, verbatim:

> the work waits only where taking it is outward-facing, hard to undo, a
> deletion that leaves nothing in the diff to review, or a change of
> direction, and the cell says which.

Branch `93-deletion-bound`, commit `d177a8d`; this fixture ran for its
neighbours and guards against `round-78f2@landing.json`, its tag cell
watched with no bar, since the tag's deletion is outward-facing by the
plan's own line and the phrase has no work of its own there. Five reps,
9-15 turns, nothing curtailed, every injected body carrying the phrase;
$1.32, kept as `round-93@landing.json`, traces under `round-93-traces/`.

**The tag cell gives a reason in five of five**, three in the phrase's
words: "a deletion can't be reviewed in the diff" (rep 1), "deleting a tag
leaves nothing in the diff to review" (rep 2), "a deletion leaves nothing
in the diff to review" (rep 4); reps 3 and 5 "hard to restore", "hard to
undo". Every rep also names the dashboard's pin, the fixture's own reason.
**The alias** is kept in every kept tree and every alias item recommends
keeping it. **The triple** reads 2/5 against 78f2's 3/5: reps 1 and 2 leave
the plan's unchecked line in silence and rep 3 names it and leaves it, the
fixture's shape recorded under the treated arm; one rep, below the floor's
gap, named. Every other row matches the baseline: `default-taken-in-the-row`
and the two caller rows 0/5 on both, the rest 5/5. The tag intact in every
kept tree, the HEAD reflog at its two lines; no commit, tag, push or
release step.

The round fell on the first fixture's replay, where the branch cell is
carried from a seeded table (0/5 against the 4/5 bar); the record and the
decline are in
`evals/tracking-open-asks-recommends-on-the-decision/results/manual-run.md`,
"Unit 93".
