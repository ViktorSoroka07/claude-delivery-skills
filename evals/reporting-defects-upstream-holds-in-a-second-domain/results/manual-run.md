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

## The graders moved onto the report, and the retake that followed

Every rubric here is about the report that gets filed, and until `7b59f4d` all
eight `llm` graders carried no `focus`, so each was shown the run's closing
message and nothing else. The verdicts in the release baseline are votes on a
summary of the rewrite; none of them reads this case's behaviour.

The prompt now says the version to send goes into
`docs/reports/draft-cache-asset-miss.md` itself, and seven graders focus that
file. `split-moves-the-evidence` reads the parent instead — the counter
evidence gone from it, and the pointer to wherever the run filed that defect —
because the child's path is the run's own choice and no grader resolves one.

One runner pass at the head that carries those edits, three runs per arm,
`--judge-model sonnet`:

| Grader | No plugin | Plugin |
|---|---|---|
| no-disposal-imagery | 2/3 | 3/3 |
| no-price-on-their-work | 0/3 | 3/3 |
| no-ranking-of-their-priorities | 0/3 | 3/3 |
| no-safety-assertion | 0/3 | 3/3 |
| split-moves-the-evidence | 0/3 | 2/3 |
| states-the-true-proportion | 0/3 | 3/3 |
| suggestion-is-an-option | 0/3 | 1/3 |
| title-carries-no-verdict | 0/3 | 2/3 |
| skill-was-invoked | — | 3/3 (indicator, scored in neither arm) |

No grader threw and no run was curtailed. Six of the eight rows are 3/3 against
0/3, which is what this case was built to show in a second domain.

Two rows read further, from the kept `evidence`:

- **`split-moves-the-evidence`, judge 2/3, hand 2/3 — the fail is real.** The run
  it failed keeps both mechanisms in the report it files, under "Issue 2:
  eviction counter reported 0 while entries disappeared", carrying the 312
  disappearances and the `reason === 'manual'` reading in full. That is the
  behaviour the rubric exists for, and the reply-graded version of this grader
  could not have seen it.
- **`suggestion-is-an-option`, judge 1/3, hand at least 2/3.** The run judged
  first fails under a heading "## Possible fix" whose body reads "One option
  would be applying it (or equivalent logic) to `artifact.path`… we'll leave the
  sizing and sequencing to you". The rubric fails "a 'Fix:' line, or a heading
  that presents the change as decided", and a hedged heading over an option is
  neither.

So this case's rows carry the same caution as its sibling's. The rubrics are tone
judgements over a whole document, which is the shape the judge reads most
strictly; the next section settles what that means for reading a row, and it is
stricter than "hand-grade a plugin-arm fail" — the unaided arm is over-failed
here too.

## How this family is graded

Settled from the twelve reports both cases kept: **judged for screening,
hand-graded for deciding.** The full statement, the thirty hand-graded cells and
the regex trial that was tried and declined are in the sibling case's record,
`evals/reporting-defects-upstream-leaves-the-decisions/results/manual-run.md`;
CONTRIBUTING's "Testing a wording change" carries the general rule. What this
case contributes to it:

| Grader | judge, plugin | hand, plugin | judge, no plugin | hand, no plugin |
|---|---|---|---|---|
| title-carries-no-verdict | 2/3 | 3/3 | 0/3 | 0/3 |
| suggestion-is-an-option | 1/3 | 3/3 | 0/3 | 0/3 |

Every miss is the judge failing a report the rubric passes: a title reading
"Build cache: asset-bundle lookups never hit; eviction counter may undercount",
which carries neither a verdict word nor a size; and two framed options,
"## Possible fix" over "One option would be applying it…" and "**Option.** …
one option would be to count every reason". The three unaided reports fail both
rubrics for real, all of them keeping "trivial keying slip" in the title and a
literal "## Fix" heading over an imperative.

Note which way that moves this case: the hand read **widens** the gap here,
where in the sibling case it narrows two of the same rows. The judged delta is
not the hand delta in either direction, which is why a row is hand-graded before
a decision rests on it rather than adjusted by a rule of thumb.

The first table in this file was graded by hand throughout, on five reps an arm
and an earlier fixture; the retake's table is judged, on three. Their rates are
not comparable, and the difference between the arms is what each one carries.
