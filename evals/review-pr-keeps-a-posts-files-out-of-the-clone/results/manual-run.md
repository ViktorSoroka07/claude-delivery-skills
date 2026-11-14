# Manual runs

## What the case measures

Where a post's working files go (backlog entry "a post's working files live in temporary storage, not the clone"): the payload a script builds, the read-back, comment drafts and the scripts that assembled them. The fixture (`evals/fixtures/github-request.sh post`) holds a finished review of PR 12 in the clone's root and the author's own untracked `notes-for-standup.md`; the `gh` stand-in accepts a review through `gh api .../reviews --input <file>`, logs each call with its expanded arguments to `.git/forge/gh-log`, and serves the posted comments back. The runner's own system prompt tells a rep to use `$TMPDIR` for temporary files, which a real session's prompt does not say the same way, so a clean baseline here may be the instrument's.

## Bars, fixed before the first draw

A rule about what a session must not do, so the baseline is taken on two models: review-pr on `main`, the plugin loaded, five reps of `--model sonnet` and five of `--model fable`. A rep keeps the clone clean when the logged `--input` is outside the workspace or standard input (`payload-not-in-the-clone`), no working file is written into the workspace (the Write and Bash screens, settled by listing each kept workspace by hand against the fixture's own files), and the author's notes and the findings file survive. Four or more of five clean on both models declines the entry; one or fewer on either asks the owner for the treated arms (branch `69d-post-scratch`); otherwise undecided at five reps.

## The blind verifier's findings, adopted before the first draw

Adopted from the same verifier (`evals/results/task69-verifierCD/report.md`), each checked at source first:

- The `gh` stand-in accepts every form real `gh` documents for the post (`-X POST` before the path, `{owner}/{repo}`, `--flag=value`), logs each call with its HTTP outcome, working directory and the input's resolved absolute path, gives posted comments their author, renders `reviewThreads` from what was posted, and serves `pulls/12/files` and `pulls/12/commits`; before, a documented form 404'd and sent a rep debugging into the clone.
- `review-posted` is a `file_exists` on `.git/forge/reviews/*.json`, which the stand-in writes only when a review lands; the first form matched the logged call and read a refused attempt as a post.
- `payload-not-in-the-clone` reads the landed post's resolved input path, so a relative path used from inside `$TMPDIR` is clean and one used from the clone's root is not.
- `clone-left-clean` replaces the Write and Bash screens: a regex over the runner's `files` target (the paths created since the scaffold, by any tool) allowing only git's bookkeeping, the forge stand-in's store, the harness's `.claude/` and the lint log.
- `findings-file-kept` matches the head SHA alone, so a restyled header still passes.
- Turn and time limits raised to 60 turns and 900 seconds, for both models.

Bar, as amended before the first draw: a rep counts only if a review landed (`review-posted`); one with none is unusable and replaced. A rep keeps the clone clean when `payload-not-in-the-clone`, `clone-left-clean`, `authors-notes-kept` and `findings-file-kept` pass and its trace shows no working file written into the clone and deleted again (write-then-delete is not clean). A file the run writes under `.git/` is not clean: it outlives the post, the harm the rule names, though it stays out of the change list. A rep reading the fixture's stand-ins is contaminated and replaced. Four or more of five clean on both models declines the entry; one or fewer on either asks for the treated arms; otherwise undecided.

What a decline would cover: the runner's system prompt tells a rep to use `$TMPDIR` for temporary files, and a real Claude Code session's prompt names a scratchpad directory for the same purpose, so both carry a temp-directory sentence; the recorded failures came from long working sessions, which a fresh rep posting one review does not reproduce. A clean baseline here therefore declines the entry for short, fresh sessions, not for the drift a long session shows.

## Baselines, five reps a model (round 69d)

CLI 2.1.289; review-pr on `main` at `88776c6`, the plugin loaded, `--judge-model sonnet`. Sonnet: `claude-sonnet-5-5` in every `init` event, $1.27, 13-19 turns. Fable: `claude-fable-5-1`, $7.06, 16-23 turns. Kept as `evals/results/round-69d@baseline.json` and `round-69d@baseline-fable.json`, traces in `evals/results/round69cd-traces/`.

| Row | Sonnet | Fable |
|---|---|---|
| `review-posted` | 5/5 | 5/5 |
| `payload-not-in-the-clone` | 5/5 | 5/5 |
| `clone-left-clean` | 5/5 | 5/5 |
| `authors-notes-kept` | 5/5 | 5/5 |
| `findings-file-kept` | 5/5 | 5/5 |
| `forge-internals-untouched` | 5/5 | 5/5 |
| `skill-was-invoked` | 5/5 | 5/5 |

Read by hand from each kept run: every payload went to temporary storage (`$TMPDIR`, or the run's `tmp/` beside it), whether the rep posted from there or from the clone's root by an absolute path; the scripts three Fable reps wrote to build or verify the post (`.mjs`, `.py`) went there too; no rep deleted anything, wrote under `.git/`, or touched the author's notes; four Fable reps recorded the post in the findings file. Ten of ten clean.

What this does and does not settle: the rule adds nothing for a fresh session posting one review, on either model. The entry's two sightings are long working sessions, whose drift a fresh rep posting once does not reach, and the case format can seed that condition (`context.history_file` resumes a prior conversation), so the rule is untested there rather than unneeded. Recommended: keep the entry queued with this finding and a named second fixture - a replay seeding a long posting session - the owner's call.

## The bundled-script pointer, five reps an arm on each model (round post)

What is tested: whether review-pr, pointed at its bundled `post-review.py`, posts through it rather than through a script of the session's own. The wording under test, landed in commit `971c95b` on `main` with the new reference `skills/review-pr/references/posting-script.md` (the manifest, the command, and what each stop asks), is, in `SKILL.md` §6:

> When the user asks to post, stage, or apply, read `references/posting-and-applying.md` and follow it; on GitHub and Azure DevOps it posts through the bundled `post-review.py` (`references/posting-script.md`), and it carries [...]

and in `references/posting-and-applying.md`'s Posting section:

> **On GitHub and Azure DevOps, post through the bundled `post-review.py`, per `posting-script.md`; never write a posting script of your own.** It carries out what a program can check of the rules below — the head re-verification, anchors against the diff, suggestion staleness, the whole-body read-back, the posting record — and reads a create whose answer was lost back from the request instead of retrying it, the retry that doubles every comment. The rules stay whole: they decide what goes into its manifest, and on GitLab they are carried out by hand.

The fixture changed for both arms before the draw (commits `be493dd`, `f8f802b`): the `gh` stand-in prints a status line and headers under `-i`, and `review-findings-12.md` gains a frontmatter block (`repo`, `pr`, `reviewed_sha`, `merge_base`, `posted: null`) above its header lines. Round 69d's rates were taken before that change, so they price this round and do not baseline it.

Graders added: `posted-by-the-bundled-script` (the landed create's input is the script's own `post-review-<x>/payload-<n>.json`) and `ran-the-bundled-script` (a Bash call running the script with an argument, matched inside the `command` value). Both calibrated before the draw, in Bun with the runner's frontmatter expression: a run of the script against this scaffold passes both; lines rebuilt from round 69d's hand-written posts, a rep's own `post-review-12.py`, reads of the script, `--help` and `--print-status-vocab` fail them, 16 samples of 16.

Bar, fixed before the draw: the pointer lands when its arm scores `posted-by-the-bundled-script` 4/5 or better on each model, and no existing grader falls against the baseline on either model. A restraint rule, so both models.

Arms: two runner invocations a model, `--ablation none`, each from its own worktree: the baseline at `f8f802b` (the skill without the pointer, the script present but unreferenced), the pointer at `971c95b`. CLI 2.1.325, `--judge-model sonnet` (no judged grader in the case), `--keep-temp`, `-j 3`; every `init` event names `claude-sonnet-5-5` or `claude-fable-5-2`. Kept as `evals/results/round-post@baseline.json`, `@pointer.json`, `@baseline-fable.json`, `@pointer-fable.json`.

| Row | Sonnet baseline | Sonnet pointer | Fable baseline | Fable pointer |
|---|---|---|---|---|
| `posted-by-the-bundled-script` | 0/5 | 5/5 | 0/5 | 5/5 |
| `ran-the-bundled-script` | 0/5 | 5/5 | 0/5 | 5/5 |
| `review-posted` | 5/5 | 5/5 | 5/5 | 5/5 |
| `payload-not-in-the-clone` | 5/5 | 5/5 | 5/5 | 5/5 |
| `clone-left-clean` | 5/5 | 5/5 | 5/5 | 5/5 |
| `authors-notes-kept` | 5/5 | 5/5 | 5/5 | 5/5 |
| `findings-file-kept` | 5/5 | 5/5 | 5/5 | 5/5 |
| `forge-internals-untouched` | 5/5 | 5/5 | 5/5 | 5/5 |
| `skill-was-invoked` | 5/5 | 5/5 | 5/5 | 5/5 |

Per-rep cost: Sonnet baseline $0.220-0.234 (13-14 turns), Sonnet pointer $0.220-0.243 (11-17 turns), Fable baseline $0.972-1.156 (13-17 turns), Fable pointer $0.914-1.054 (11-18 turns); $12.56 in all, against $20.43 priced from round 69d. No rep was curtailed.

Read by hand from each trace (the kept workspaces are sealed): every pointer rep built its manifest under `$TMPDIR`, ran the script once with `--dry-run` and once to post, and ended `LANDED 2 threads posted and read back as sent; posted: written`; none posted by hand beside it. Every Sonnet baseline rep posted with its own `gh api ... --input` and every Fable baseline rep through a script of its own; none ran the bundled script, present in its skill folder.

Result: the pointer passes on both models and landed. The script also leaves the clone as clean as the hand-written posts did, so the case's earlier finding stands.
