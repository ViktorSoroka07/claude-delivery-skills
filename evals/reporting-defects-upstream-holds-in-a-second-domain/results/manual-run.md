# Manual runs

Run by the hand procedure in CONTRIBUTING's "Testing a wording change":
ten fixtures from `evals/fixtures/build-cache-report.sh`, verified
identical by hash, fresh subagents on sonnet, the eval prompt verbatim.
The baseline arm was told not to use the Skill tool; the other arm was
told nothing about skills. Graded on the files under `docs/reports/` as
written to disk; the trigger grader read from each transcript by script.

A first round ran before the observations note carried the four-minute
cost per miss. Every baseline in it deleted the draft's whole priority
argument as an unsupported number, so the ranking grader was never facing
the decision it tests. That round is discarded; the note now carries the
figure and the results below are from the corrected fixture.

## Results

| Grader | base | skill unnamed |
|---|---|---|
| states-the-true-proportion | 5/5 | 5/5 |
| no-price-on-their-work | 5/5 | 5/5 |
| no-ranking-of-their-priorities | 5/5 | 5/5 |
| suggestion-is-an-option | 4/5 | 5/5 |
| no-safety-assertion | 3/5 | 5/5 |
| title-carries-no-verdict | 5/5 | 5/5 |
| split-moves-the-evidence | 0/5 | 5/5 |
| no-disposal-imagery | 5/5 | 5/5 |
| skill-was-invoked | 0/5 (forbidden) | 5/5 |

Every unnamed run loaded the skill before its first edit, between
transcript lines 10 and 12 against a first write between 25 and 33.

The baseline here is strong, and that is the finding. Without the skill,
every run removed "trivial" from the title, the line about somebody
knowing better, "the stats endpoint is lying", "mostly wiring" and "jump
the queue", most of them saying in their own words that ordering another
team's backlog is not theirs to do. The draft's violations are blunt
enough that Sonnet reads them as overreach unaided, which is what the
first case's first round showed for its blunt estimate and safety claim.
What the baseline never does is split the report: all five kept the
counter defect as an "Also" section under the asset-bundle title. Two
kept a prediction that the change leaves the other artifact types as
they are, and one kept the fix as an instruction.

So on this fixture the skill's measurable contribution is the split, the
option phrasing, and the safety hand-back; the other rules are Sonnet's
defaults against blunt violations. A future round of this fixture should
soften the violations the way the first case's second round did: size the
fix by its shape rather than "mostly wiring", argue the ranking from the
cost figure rather than "jump the queue", and drop "lying" and "somebody
knew better" for images that merely rate the work.

## Not tested

The rules whose baseline passes five of five above, against a subtler
draft. The trigger against a prompt that does not describe the report as
bound for another team.
