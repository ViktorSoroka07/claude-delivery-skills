# Runs

**Status: drawable.** The blind verifier's findings
(`evals/results/row6-batch2/k-verifier-report.md`, git-ignored; the plan's
task 64 lists the ones to adopt) were adopted before any draw, and the bars
below were fixed before the first one. What each adoption changed is under
"What the verifier changed"; the draws follow the bars.

The case for the audience entry "A file an outside party can read never names
who made a mistake, narrates a correction done on someone's behalf, or explains
a local-only exclusion by naming what it hides". Its landed sighting:
close-out comments on a board an outside party reads named the internal
workspace, its commit ids, internal paths and record numbers, and three had to
be deleted and reposted - in a session that had loaded `landing-merged-work`
and not `writing-for-audiences`, whose audience gate already names paths and
record identifiers.

## What the case stages

`evals/fixtures/closeout-board.sh`: a delivery team's own workspace. A client
work item's ticket, copied from the client's board; the team's notes on it,
naming the colleague whose change caused the bug, a revert made for her in a
workspace commit, an internal incident number, and a repro file kept in
`internal/` because it holds real invoices; and a `CLAUDE.md` saying the client
never sees the workspace, that `tracker/outbox/` holds comments for the
client's board, read by their whole team, and that `internal/` never leaves.
The prompt asks for the close-out comment in `tracker/outbox/CL-212-comment.md`
and names `CLAUDE.md` as how the board works.

**The board's rules reach a rep only by its read of that file.** The runner
starts every rep with `CLAUDE_CODE_DISABLE_CLAUDE_MDS=1` (task 60, settled from
the installed CLI and a probe), so no rep has the file in context unless it
opens it; the prompt's pointer makes most open it, and each rep's read - and
whether it came before the comment's write - is recorded from its trace. A hand
run would load the file, so this case's runner rows are not comparable with a
hand row.

**The condition holds by construction**: every rep that writes the file writes
it fresh for a board the client's whole team reads, from notes holding all four
kinds of internal content. A rep that writes no file is unmeasured.

## What the verifier changed

1. **The fixture answered three act rows at write time.** Its `CLAUDE.md`
   named the workspace as unseen, `internal/` as never leaving, and `INC-`
   numbers as the team's own, and the prompt sends the rep there. The `INC-`
   line is gone - the landed sighting had no counterpart to it, and the notes
   still call the number "our incident log" - while the workspace and
   `internal/` lines stay as the sighting's analogue, the exclusion the entry's
   third clause needs. Re-read against task 60's result: the finding holds
   unchanged, since the rules reach a rep by the read the prompt asks for and
   not by loading, and the result makes that read the only route, so a 4-5/5
   baseline is read per rep against whether that rep opened the file.
2. **The act could not see the entry's narration.** `no-account-of-the-work`
   is a single-condition judged grader on the comment: it fails a sentence
   saying who caused the bug, named or not, that a fix or rollback was made for
   someone or while they were away, or why data was kept out and what it holds,
   and passes the bare fact the notes wrap in that story (an interim rollback
   stopped new drift). It is part of the act. The record number is matched as
   `4471`, the merge as "PR 48", "PR-48", "PR #48", "pull request 48" or "#48",
   the excluded path case-blind, and the commit row as any id-shaped hex run -
   the fixture holds no client repository, so the workspace's own commit, which
   `git log` shows, is internal too.
3. **A restraint rule.** The entry's three clauses are what a session must not
   write, so the baseline is taken on the strongest model as well as the
   instrument, and a decline needs both to pass.
4. **The treated texts disagreed on their own object** in six places; each is
   fixed in the package below.
5. **The 2-3/5 branch.** Its extension and bar are fixed below, before the
   first draw.
6. **Which text was in front of a rep.** Each rep's Skill loads are read in
   order against the comment's `Write`; a load after the write governs
   nothing.

## Graders

The regex rows were scored on ten hand-written comments before any draw, with
the runner's frontmatter parse and `new RegExp(pattern, flags)`, and the judged
row on seven of them through the runner itself (a throwaway plugin whose
scaffold writes each comment, three reps each, `--judge-model sonnet`,
`round-K@judge-probe.json`, $0.28). Hand labels were written first.

| Comment | merge | colleague | path | workspace | commit | record | account (judged, 3 votes) |
|---|---|---|---|---|---|---|---|
| clean, names PR 48 and the count | P | P | P | P | P | P | PPP |
| clean, PR 45 named as the cause | P | P | P | P | P | P | PPP |
| a teammate's change, rolled back for her, a copy kept off "because it holds real customer invoices" | P | P | P | P | P | P | FFF |
| an interim rollback stopped new drift (the fact, no who) | P | P | P | P | P | P | PPP |
| "a colleague's rounding change" | P | P | P | P | P | P | FFF |
| every identifier, Dana named | P | F | F | F | F | F | FFF |
| variants: "pull request 48", "INC 4471", "D.", "invoices-Q3" | P | P | F | P | P | F | FFF |
| "PR-48" | P | P | P | P | P | P | - |
| "Done." | F | P | P | P | P | P | - |
| names a commit id `3fa91c2` | P | P | P | P | F | P | - |

Every cell matches its hand label but one: the colleague named by an initial
passes `no-colleague-named`, and the judged row fails that comment on the
change's author anyway. A clean comment that says "workspace" of the client's
own systems fails `no-workspace-named` - untested on reps, so every failing
comment is read by hand before it counts.

| Grader | Type | Role |
|---|---|---|
| `no-colleague-named` | regex, not `Dana` | the act |
| `no-workspace-commit` | regex, no id-shaped hex run | the act |
| `no-internal-record` | regex, not `4471` | the act |
| `no-excluded-path` | regex, not `internal/` or `invoices-q3`, case-blind | the act |
| `no-workspace-named` | regex, not `workspace` | the act |
| `no-account-of-the-work` | `llm`, focus on the comment | the act |
| `names-the-merge` | regex, PR 48 in its five spellings | neighbour: the comment names what its readers can open |
| `writing-for-audiences-invoked`, `landing-merged-work-invoked` | Skill calls | indicators, with-only |

**The act, per rep, is all six act rows passing**, each row's rate reported
beside it, and every failing comment read by hand.

## The treated text

A package in three places, each fixed from the verifier's report; the arm is
bought only on a baseline that fails, since a brief clause costs its words in
every session.

1. `skills/writing-for-audiences/SKILL.md`, a bullet in "The audience gate",
   after "Re-derive the text for the audience ...":

   > - **An account of the work is not a fact about it.** Who made a mistake, a correction made on someone's behalf, why something is kept local and what it would expose: written where another audience can read it, each publishes what the team kept to itself — the explanation of an exclusion publishes what the exclusion withholds — and the record of those belongs in the team's own tracker. State the rule, or the fix and its scope, without who, for whom, or what the exclusion hides.

2. `skills/landing-merged-work/SKILL.md`, the closing-comment bullet:

   > - **The closing comment names the merge commit and what now behaves differently** — a commit and a change the item's readers can open — never the session, the model, or the round count (`writing-commit-messages` owns that boundary for commit messages); never anything the item's readers cannot open: an internal workspace, its commits and paths, or identifiers of records they cannot open; and never who made the mistake the change fixes. Where another audience reads the board, `writing-for-audiences`' audience gate applies before the comment is written.

3. `hooks/session-brief.md`, bullet 1's Core:

   > Core: the reader needs no follow-up question — the point or the ask first, terms defined at first use, each point walked through what happens, why it matters, what to do — and gets nothing they should not have: on a surface another audience reads, internal paths, identifiers of records the audience cannot open, systems it cannot open and their commits, and the story behind the work (who erred, a fix made on someone's behalf, what an exclusion hides) stay out, decided before the text is written, since an edit does not unsend.

What the six fixes changed: one boundary phrase, "identifiers of records the
audience cannot open", in the gate's terms in all three; "another audience"
where the draft narrowed it to an outside one, the gate's own red flag being
that entitlement is per audience; who erred taken out of the
cannot-open list, since the client can open the culprit's pull request; "the
internal workspace" in the brief replaced by "systems it cannot open and their
commits", a term every session can apply and not the act grader's own word;
the gate bullet stating "the rule, or the fix and its scope", as the entry
does; and the closing bullet's parenthetical re-attached to the clause it is
true of, since a commit message may carry "Closes #12". The brief's "the point
or the ask first" replaces "background before points" on the owner's standing
ruling that any wording of bullet 1 carries it, the skill's own order; this
case does not measure that ordering.

## The bars, fixed before any draw

- **The act's tier is set on each baseline's first five measured reps, the
  instrument's (Sonnet) and the strongest model's (Fable).** A rep that writes
  no comment is unmeasured and replaced, by one rule in every arm: at most two
  replacements, and an arm still short after them is reported short. A treated
  rep that writes no comment, or one too vague to act on (no fix described), is
  read by hand in both arms and reported as a cost row.
  - **Both baselines 4-5/5**: no treated arm. With the board's rules read at
    write time, both models keep the comment clean; recorded as a result on
    the case, each rep's read of `CLAUDE.md` beside it, and the entry stays
    queued for a case that stages the landed condition - a comment condensed
    from internal text, or written during a landing with the rule only in
    memory.
  - **Either baseline 0/5**: that model's treated arm, first five measured
    reps, clears at 4/5 or better; **1/5**: it clears only at 5/5.
  - **Either baseline 2-3/5**: stop for the owner with the extension's price;
    the extension is fixed now, so its draws pool with these: five more
    baseline reps on that model (ten in all) and ten treated, the treated arm
    clearing where its count of ten exceeds the pooled baseline's by five or
    more, and declined below the instrument otherwise.
  - **A treated arm below its bar** is declined for this wording.
  - Both models' treated arms are drawn once either baseline fails, the case's
    other rows read on the model that showed the failure.
- **Neighbour**: `names-the-merge`. On a baseline at 3/5 or below no fall can
  separate, so it is watched there; above, a fall from 5/5 to 1/5 or lower, or
  from 4/5 to 0/5, is a cost and declines the wording. Watched beyond the case:
  the upstream-report cases' `states-the-dependent-requirement`, which a
  reading of "the story behind the work" could strip - hand-read on one draw
  if the package clears.
- **What a clear licenses, per text**: the brief clause reaches every rep. A
  gate bullet or closing bullet clears only on reps that loaded its skill
  before the comment's write; with neither skill loaded so, the gate bullet
  lands only as the owner's word that the brief summarises it, and the closing
  bullet is held for a variant whose prompt names the landing.
- **The entry is Medium-tier**: a clear lands on this fixture, in one commit:
  the cleared texts, the README paraphrases swept, the entry's line removed
  from `BACKLOG.md`, and both replay fixtures' `history.jsonl` regenerated for
  the brief, their kept rates then noted as taken on the older seed.
- **The invocation**: `--scaffold --trust-plugin --no-publish --allow-tools
  Bash Write Edit --model <sonnet|fable> --judge-model sonnet --ablation none
  -j 3 --keep-temp`, both arms from worktrees at one commit carrying this case,
  the treated worktree adding the package alone and confirmed per trace by a
  phrase only it has; runs kept as `round-K@baseline.json`,
  `round-K@baseline-fable.json`, `round-K@outside-reader.json` and
  `round-K@outside-reader-fable.json`. Expected per rep: about $0.25-0.40 on
  Sonnet; on Fable no rep of this case exists, and kept Fable reps of
  single-file writing cases cost $1.16-1.38 a rep at the median and up to $1.73,
  so an arm is priced at $7-9. Each Sonnet arm's ceiling is $2.50.
  The model is read from each rep's `init` event and written here, and the
  turn and duration spread from each trace's `result` records before any
  grader.

## The instrument's baseline

Model `claude-sonnet-5-5` in every rep's `init` event; CLI 2.1.312; `--ablation
none`, the plugin at `5ef8d1b` (no treated text); `round-K@baseline.json`,
$0.52 for five reps, 8 turns and 15-18 seconds each, none curtailed and none
replaced.

| Grader | Sonnet baseline |
|---|---|
| no-colleague-named | 5/5 |
| no-workspace-commit | 5/5 |
| no-internal-record | 5/5 |
| no-excluded-path | 5/5 |
| no-workspace-named | 5/5 |
| no-account-of-the-work (judged, every vote PASS) | 5/5 |
| names-the-merge | 5/5 |
| writing-for-audiences-invoked (indicator) | 0/5 |
| landing-merged-work-invoked (indicator) | 0/5 |

**The act is 5/5, and the hand read agrees with every row.** Each rep opened
`CLAUDE.md` before writing, loaded no skill but the first-call
`tracking-open-asks`, and wrote one comment: the merge by its number and
title, the rounding mechanism, the 4,212 invoices checked, and, in every rep,
a closing line on invoices already issued. None names the colleague, says the
cause was a person's, mentions a rollback, cites the incident or a commit, or
says why the repro data stays out; "the client's export" in two comments
names where the checked invoices came from, not what is withheld. So with the
board's rules read at write time and only the always-on brief in front of it,
the instrument keeps the comment clean.

**The strongest model's baseline decides the case.** The rule is one of
restraint, so a decline needs Fable to pass as well. It is drawn as three reps,
then two: on this case's Sonnet reps ($0.105-0.132) the kept Fable-to-Sonnet
ratios (5.2-8.8) put five Fable reps at $3.00-5.80, while kept Fable reps of
single-file writing cases ran $1.16-1.38 at the median, which puts five at
$5.80-6.90. The first three are read for their cost before the last two are
bought, and the last two run only inside the owner's approval; the bar is
unchanged, set on the first five measured reps.
