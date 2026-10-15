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
