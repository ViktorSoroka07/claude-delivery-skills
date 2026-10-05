# Manual runs

## What the case measures

Review-pr's storage wording (backlog entry "keep review findings in one folder outside the clone"): a review with no path named for its findings writes them to `<root>/<repo>/<request>/r<N>-<sha7>.md` outside the clone, keyed by the remote's host and path lowercased, opens the file with frontmatter, writes nothing into the clone, and gives the absolute path in the hand-off. The fixture is ticket-gateway's branch with pinned commit dates (head `c0cbaa5` in every build) and the remote `git@git.example.org:Acme/Ticket-Gateway.git`, a host with no platform reference, so the review runs on the local branch.

## The instrument, settled before the first draw

- Every invocation grants `--allow-tools Bash Write Edit Agent 'Write(~/.local/state/**)' 'Edit(~/.local/state/**)'`. Without the grant the runner refuses the Write tool outside the workspace and `$TMPDIR`, and its refusal invites "other tools", which pushes a treated rep toward the clone-root fallback for the instrument's reason (task 69's first probe); with it the Write tool reaches the state folder (the second probe). Both arms and all three neighbours run under the same grant.
- A grader cannot read the state folder: `file_exists` reports files outside the workspace missing although they exist, and a `regex` target climbing out with `..` refuses the case at load (probes kept in `evals/results/task69-probe/`). So the write is graded from the Write call, and every rep's file is read by hand from the kept run's home.
- An SSH host alias cannot be staged: `ssh -G` reads the account's real home from the system, not `$HOME`, so the alias clause is not measured here (a named gap); the fixture's host is plain.

## Bars, fixed before the first draw

Arms: baseline = review-pr on `main`, treated = branch `69a-storage`; both with the plugin (`--ablation none`), five reps each, `--model sonnet`, `--judge-model sonnet`, `--keep-temp`. The treated arm lands at 4/5 or better on `findings-written-to-the-state-folder` (Write, or its Bash companion where the kept home shows the file), `reply-gives-the-absolute-path` and `nothing-written-into-the-clone`, against a baseline expected at 0/5. Neighbours `review-pr-warns-where-the-findings-file-is-exposed`, `review-pr-holds-the-open-question` and `review-pr-grades-the-files-drift-inline` run five reps on each text: a neighbour grader dropping by three or more of five declines the wording, and a drop of one or two is hand-read for its cause. A rep whose `skill-was-invoked` is dark is replaced, not counted.

## The blind verifier's findings, adopted before the first draw

A blind verifier read the draft, the case and the probes (`evals/results/task69-verifierA/report.md`); each adopted finding was checked at source first, the runner's grader code included.

- `nothing-written-into-the-clone` is now a `file_exists` row on `review-findings*.md` with `exists: false`. The runner computes `file_exists` over the paths the run created in its workspace (a listing after the scaffold against one after the run), so it sees a file whatever tool or subagent wrote it, and the glob is anchored at the root. The first form, a `Write` pattern on any `.md` under the clone, would have failed a correct treated rep whose Pass 2 verifier left its report in the clone, as 11 of 15 dispatching reps did in the kept traces of the sampling cases. The Write and Bash patterns stay as screens.
- `reply-gives-the-absolute-path` takes the absolute path in any formatting (bold, a link, angle brackets, `key=value`) and still refuses `~`, `$HOME`, `$XDG_STATE_HOME`, relative and mis-keyed forms (`evals/results/task69-calibration/calA2.mjs`).
- A loose pair, `moved-out-of-the-clone-any-key` and its shell twin, separates "moved but keyed another way" from "not moved".
- The fixture pins the commit dates' offset (`+0000`): `@1700000000` alone took the scaffold's time zone, so the head was `c0cbaa5` here and `bd2f605` under UTC. It is `bd2f605` on every machine now.
- Neighbour turn caps raised before the draw, in both arms: warns 60 to 80 (its reps had reached 53), holds 40 to 60 with its timeout 600 to 900 s.
- The draft's Azure DevOps hold note pointed at the clone-root file name; fixed on the branch (`af1ac10`).

Reading rules, fixed now:

- A rep that wrote no findings file anywhere (neither the clone nor the state folder) is unusable and replaced in either arm, as is a rep whose `skill-was-invoked` is dark; replacements are applied to both arms alike.
- Every rep's kept home is opened (`chmod 700 <run> <run>/sealed`) and its state folder listed; the frontmatter is read there. A rep passing `findings-written-to-the-state-folder` and failing `nothing-written-into-the-clone` is a refusal followed by the fallback and is read in its trace.
- Any treated `findings-file-written` fail in `review-pr-grades-the-files-drift-inline` or `review-pr-warns-where-the-findings-file-is-exposed` caused by the state folder overriding the path the prompt names declines the wording, whatever the count: eight review-pr cases grade a root file their prompt names.
- Neighbours are compared across this round's two arms only, never against earlier records (other model, no grant). Turns are read from each trace's `result` records; a rep curtailed at the cap is unmeasured and replaced.
- `last_message` is the last assistant text of any thread; a reply grader fail is checked one text event earlier before it counts.
- Arms are kept as `round-69a@baseline*.json` and `round-69a@storage*.json`, since both report plugin version 1.10.0.
