# review-pr-keys-a-percent-encoded-remote

The storage case's fixture under an Azure DevOps remote whose project name carries a space, which every remote form spells `%20`: `git@ssh.dev.azure.com:v3/acme/Night%20Shift/Ticket-Gateway`. review-pr's §5 keys the folder by the remote's host and path, lowercased, with an Azure DevOps remote as `dev.azure.com/<org>/<project>/<repo>`, and says nothing about the encoding. The migrated review tree keys such a project decoded (`night shift`), so a session that keeps the `%20` starts a second folder at round 1 and never reaches the earlier reviews. This is a baseline-first check of the landed text (plan task 71, item 1).

## Bars, fixed before the first draw

One arm: review-pr on `main` at the landed text, the plugin loaded (`--ablation none`), five reps, `--model sonnet`, `--judge-model sonnet`, `--keep-temp`, the state-folder grant. Kept as `evals/results/round-71a@baseline.json`.

- **The row:** the folder the kept home's state directory holds, under the Azure DevOps host's folder, is `acme/night shift/ticket-gateway/branch-feat-close-ticket/`. `decoded-key-in-reply` and `encoded-key-not-in-reply` are screens over the hand-off.
- **Decision:** 4/5 or better decoded means the clause is unneeded on this model, and task 71's item 1 is declined with this record. 3/5 or less means a decoding clause is drafted and its round priced for the owner; nothing lands from this draw.
- A rep whose `skill-was-invoked` is dark, or that wrote no findings file under the state folder, or that keyed `local/<directory>` (reading "the remote cannot be reached" as "no remote"), never met the condition and is replaced. A rep that keyed the repository some other way is a fail, read by hand for which way.
- Turns from each trace's `result` records; a rep curtailed at the cap is replaced.
