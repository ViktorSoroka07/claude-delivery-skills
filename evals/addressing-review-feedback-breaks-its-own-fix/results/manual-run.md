# addressing-review-feedback-breaks-its-own-fix

The backlog entry under test: a fix written to answer a review finding gets no review of its own, because the thread reads as settled once the fix is pushed and replied to, while the fix was written inside the frame the finding set - closing the one route it named - and so tends to leave that route's neighbours open. Built before any draw; nothing below is measured yet.

## The fixture

`evals/fixtures/tenant-export.sh`: a pull request makes each tenant's export run with that tenant's own token, keeping the shared account for two internal tenants. The repository's CLAUDE.md states the rule: a tenant that is not internal never exports with the shared account. One bot thread, correct, names a single route by which such a tenant still gets the shared account - a missing token file - and suggests no code, so the fix is the run's own rather than a suggestion step 2 already tells it to test. The same catch block holds two more routes: a token file that is empty, and one that cannot be read, the second logged and passed over. A fix that refuses only the missing file leaves both open: checked at the pushed head before any draw, `missing: refused`, `empty: shared`, `unreadable: shared`.

The fixture carries one defect, the one under test: the neighbours a fix written inside the finding's frame leaves open. The token path is built from the tenant name unchecked; no grader reads that, and a rep that spends a fix or a reply on it is read as it is.

## Graders

- `neighbours-closed`: the case's named behaviour. Both neighbouring routes refuse a tenant that is not internal. The verdict is `check-pushed.sh`'s, beside this record: it loads `src/credentials.js` at the head the fixture's remote holds for the pull request's branch and calls it on an own token, a missing file, an empty file, a directory in the file's place, and an internal tenant. The judged grader of the same name reads the working tree and is a cross-check; where the two disagree the rep is read by hand, since a refusal inside the `try` that the `catch` swallows reads as closed and is not.
- `named-route-closed`: the finding's own route refuses. A guard: a wording that sends the rep after neighbours must not lose the named fix.
- `internal-keeps-shared`: no regression on the design's exception. A guard against over-application.
- `skill-was-invoked` (`arm: with-only`): the trigger's indicator.
- Read by hand from each trace, not graded: whether the rep made an attempt to break its fix before the push call (a subagent dispatched on the fix, or a test or probe of an input the finding did not name), and whether a reply cited a commit before it was pushed.

## The baseline, fixed before its draw

Hand run (`docs/plans/task97-round/run-arm.sh`): fresh headless sessions, a fresh config directory each, so no operator instruction file, setting or installed plugin reaches a rep; the arm's plugin is exported from its commit; `git push` allowed, since the remote is the fixture's own bare repository. `claude-sonnet-5-5`, five reps, the plugin at `bf2dbc5`. Expected cost about $1.50 from the kept addressing-case figure ($1.35 for five reps with judging).

- `neighbours-closed` at the pushed head failing in 4 or 5 of 5: a failing baseline, live for the treated arm.
- Failing in 3 of 5: below the floor; a ten-rep re-take, read without this draw, is live at five or more fails of ten, and its treated arm is then ten reps too, landing on a gap of five.
- A rep that pushed nothing to the pull request's branch is unmeasured and replaced, in either arm; `neighbours-closed` would read the unchanged head and fail it for a reason not its condition.
- Failing in 2 or fewer: the current skill already carries it - most likely its verify step's "construct the input where the old rule and the new rule disagree", which names a stricter check falling through to a laxer branch - and the entry is declined on that ground. The fixture is not made harder to manufacture a failure.

The treated arm, if bought: the same five-rep draw on a commit carrying the wording alone; it lands on this fixture only on a gap of four reps on `neighbours-closed` with `named-route-closed` and `internal-keeps-shared` losing no more than one rep each, and then waits for a second fixture in an unlike domain, since the entry is Strong tier.
