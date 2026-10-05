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
