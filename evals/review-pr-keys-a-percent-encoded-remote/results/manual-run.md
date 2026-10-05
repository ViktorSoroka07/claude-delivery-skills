# review-pr-keys-a-percent-encoded-remote


The case's project was renamed after the draws below (the fixture now spells `Night%20Shift`); those draws used another two-word name, and their folder names are given here in the current spelling. The draw after the rename is the last section.

The storage case's fixture under an Azure DevOps remote whose project name carries a space, which every remote form spells `%20`: `git@ssh.dev.azure.com:v3/acme/Night%20Shift/Ticket-Gateway`. review-pr's §5 keys the folder by the remote's host and path, lowercased, with an Azure DevOps remote as `dev.azure.com/<org>/<project>/<repo>`, and says nothing about the encoding. The migrated review tree keys such a project decoded (`night shift`), so a session that keeps the `%20` starts a second folder at round 1 and never reaches the earlier reviews. This is a baseline-first check of the landed text (plan task 71, item 1).

## Bars, fixed before the first draw

One arm: review-pr on `main` at the commit that adds these bars, the plugin loaded (`--ablation none`), five reps, `--model sonnet`, `--keep-temp`, and the full grant `--allow-tools Bash Write Edit Agent 'Write(~/.local/state/**)' 'Edit(~/.local/state/**)'` (without `Bash` every rep is unusable). Kept as `evals/results/round-71a@baseline.json`; every trace and every kept home's state folder are copied under `evals/results/` the moment the run ends, since the run roots sit where the system clears files by age.

- **The row:** the folder the findings file ends up in, read from the kept home - an empty folder left behind by a move is not a second key. Among reps that used the Azure DevOps form (the Azure DevOps host, then `acme/<project>/ticket-gateway/`), the project is either decoded (`night shift`) or kept encoded (`%20`).
- **Decision, read only when at least four reps used the Azure DevOps form:** 5/5 decoded - the clause is unneeded on this model, and task 71's item 1 is declined with this record; 4/5 - the one encoded rep is a direct sighting of the split (that session would start a second folder and never reach the earlier reviews), recorded and put to the owner, since a one-in-five effect is below what five reps measure; 3/5 or fewer - a decoding clause is drafted and its round priced for the owner. Nothing lands from this draw.
- **Other keys are their own finding**, not a count against decoding: the generic host-and-path form (the SSH host, then `v3/acme/...`) or a key decoded but not lowercased is recorded separately.
- **Screens:** `decoded-key-in-reply` and `encoded-key-not-in-reply` read the hand-off and can fail a correct rep - one that also mentions `Night%20Shift` in prose, a `file://` link (which encodes the space), a path quoting only the folder, or the folder and file name on separate lines - so every screen fail is read by hand against the kept home.
- **Replacements:** a rep whose `skill-was-invoked` is dark, or that keyed `local/<directory>` (reading "the remote cannot be reached" as "no remote"), never met the condition and is replaced. The sandbox has no Azure DevOps login (`az` is not on the run's PATH and the PAT variable is denied), so review-pr's platform check meets "no login" in every rep: a rep that stops there writes no findings file and is replaced, but if three of the first five stop, topping up stops, and that is recorded as a finding about the platform check - a branch with no request gets no review without a login - and the case is re-staged.
- Turns from each trace's `result` records; a rep curtailed at the cap is replaced.

## The baseline draw

Model `claude-sonnet-5-5`, CLI 2.1.289, `main` at `cd48d76`; $1.17, 11-16 turns, no rep stopped at the platform check and none was replaced. Kept as `evals/results/round-71a@baseline.json`, traces in `evals/results/round71a-traces/`, every kept home's state folder in `round71a-files/`.

| Rep | Folder the findings file ended up in (under the Azure DevOps host's folder) | Screens |
|---|---|---|
| 1 | `acme/night%20shift/ticket-gateway/branch-feat-close-ticket/` | both fail |
| 2 | `acme/night shift/ticket-gateway/branch-feat-close-ticket/` | both pass |
| 3 | `acme/night shift/ticket-gateway/branch-feat-close-ticket/` | both pass |
| 4 | `acme/night%20shift/ticket-gateway/branch-feat-close-ticket/` | both fail |
| 5 | `acme/night shift/ticket-gateway/branch-feat-close-ticket/` | both pass |

All five used the Azure DevOps form, so the decision reads: **3/5 decoded, 2/5 kept the encoding.** By the bar, a decoding clause is drafted and its round priced for the owner; nothing lands from this draw. No rep keyed the repository any other way, and the screens agreed with the kept homes on every rep.

## The decoding round's bars, fixed before its first draw

Bought by the owner. The draft is one clause in §5's `<repo>` bullet - the key is the remote's host and path "percent-decoded and then lowercased (a project the remote spells `Field%20Ops` keys as `field ops`)" - on branch `71-decode-repo-key` at `d3f27c3`. Its first version (`e95b41a`) used this case's own remote as the example, which would have let a rep copy the worked answer; a blind verifier caught it before any draw (`evals/results/task71-verifier/report.md`), and the example now names a project unlike the case's. The baseline arm is the draw above (`main` at `cd48d76`, whose `skills/`, `hooks/` and `agents/` match the draft's parent byte for byte); the treated arm is five reps at `d3f27c3`, kept as `evals/results/round-71a@decode.json`, same invocation, traces and homes copied out at once. Neighbour: `review-pr-keeps-the-findings-outside-the-clone`, five reps on each text, kept as `round-71a@baseline-storage.json` and `round-71a@decode-storage.json` - its remote carries no encoding, so the clause cannot change its key, and the draw checks for side effects only.

What the round can read, and what it cannot:

- **The clause binds** when every treated rep decodes the project segment of its key - 5/5, nothing less - whatever form the rep keyed in (the Azure DevOps form or the generic one, the form recorded separately), a rep decoded but not lowercased counting as decoded with that noted. Both baseline reps that kept `%20` had §5 loaded before they computed the key, so a treated rep keeping it read the clause and was not bound by it. At the baseline's point estimate a clause that did nothing would still score 5/5 about one time in twelve (0.6 to the fifth), and about one time in three if the true baseline rate is 0.8, so a 5/5 is weak evidence on its own.
- **It costs no neighbour** when no storage-case bar (`findings-written-to-the-state-folder` with its companion, read by the kept home; `nothing-written-into-the-clone`; `reply-gives-the-absolute-path`) drops three or more of five against its baseline, and no treated drop's hand-read cause is the wording.
- **What it cannot read** is a separated rate: five reps an arm separate only a four-in-five gap, and ten only a half, so 3/5 against 5/5 is below what any permitted spend separates. A landing rests on the baseline's measured failure - two reps in five would have started a second folder beside the one the earlier reviews sit in - together with a clause that bound in every treated rep on an example unlike its input, and the migrated tree already keyed the decoded way.
- **A failing draw** - any treated rep keeping `%20` - goes to the owner at the stop with that rep's trace read; a restatement is a new wording and a new round, never an edit landed on this draw.
- `encoded-key-not-in-reply` is expected to fail correct treated reps more often than baseline ones, since the clause invites a hand-off to say it decoded `Night%20Shift`; its rate is not compared across the arms, and the kept home decides.
- Decoding puts a space in the path: before replacing a treated rep for "no findings file in the state folder", its workspace is checked for a write split at the space.

The replacement rules above hold for both arms.

## The decoding round's draw

Model `claude-sonnet-5-5` in every `init` event of all three runs, CLI 2.1.289; treated at `d3f27c3`, the neighbour's baseline at `20bf8e1` (same `skills/` as `cd48d76`); $3.27 for the three runs, 9-14 turns, no rep replaced and no write split at the space. Kept as `evals/results/round-71a@decode.json`, `round-71a@baseline-storage.json`, `round-71a@decode-storage.json`, traces in `round71a-decode-traces/` and beside, every kept home's state folder in `round71a-decode-files/` and beside.

| Row | Baseline | Treated |
|---|---|---|
| project decoded in the folder the findings file ended up in (kept home) | 3/5 | 5/5 |
| `decoded-key-in-reply` (screen) | 3/5 | 5/5 |
| `encoded-key-not-in-reply` (screen) | 3/5 | 5/5 |
| storage neighbour: written to the state folder (kept home) | 5/5 | 5/5 |
| storage neighbour: `nothing-written-into-the-clone` | 5/5 | 5/5 |
| storage neighbour: `reply-gives-the-absolute-path` | 5/5 | 5/5 |

Every treated rep keyed the Azure DevOps form and filed under the Azure DevOps host's folder, then `acme/night shift/ticket-gateway/branch-feat-close-ticket/`, decoded and lowercased on an example naming another project; the screen expected to fail correct treated reps did not. The neighbour's Write screens read 2/5 in each arm, the other reps writing by shell, and the kept homes decided its rows. The `.claude` directory in every clone is the runner's own, present in every arm.

**Verdict, as the bars allow:** the clause binds (5/5) and moves no neighbour. A separated rate is not shown - a clause that did nothing would still score 5/5 about one time in twelve at the baseline's point estimate - so a landing rests on the baseline's measured failure (two reps in five would have started a second folder), the clause binding on an example unlike its input, and the migrated tree already keyed the decoded way. That reading, with this caveat, is the owner's to land; the first version of these bars said so and the re-pin dropped the sentence, which this verdict restores.

## After the rename: bars, fixed before the draw

The owner had the case's project renamed and paid for one redraw. One arm: review-pr on `main` with the decoding clause landed (`6187405`), the case at its renamed commit, five reps, `--model sonnet`, `--keep-temp`, the full grant `--allow-tools Bash Write Edit Agent 'Write(~/.local/state/**)' 'Edit(~/.local/state/**)'`; kept as `evals/results/round-71a@landed-renamed.json`, traces and homes copied out at once. It is the case's reading on the shipped text and on a third project name - unlike both the clause's example and the name the earlier draws used. Every rep decoding the project (5/5) is the shipped clause reading as it did in its round; any rep keeping `%20` is recorded with its trace read and goes to the owner. The replacement rules above hold.
