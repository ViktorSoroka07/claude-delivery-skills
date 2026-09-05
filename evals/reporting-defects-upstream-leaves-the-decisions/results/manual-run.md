# Manual runs

`claude plugin eval` is still gated at run time, so the case was run by the
hand procedure in CONTRIBUTING's "Testing a wording change": ten fixtures
from `evals/fixtures/notify-report.sh`, verified identical by hash, fresh
subagents on sonnet, the eval prompt verbatim. The baseline arm was told not
to use the Skill tool, because the skill is installed and its description
matches the prompt; the treatment arm loaded the skill through the Skill
tool before starting. Graded on the files under `docs/reports/` as written
to disk, not on the reply.

## Results

| Grader | base | treat |
|---|---|---|
| states-the-true-proportion | 1/5 | 5/5 |
| no-price-on-their-work | 4/5 | 4/5 |
| no-ranking-of-their-priorities | 0/5 | 5/5 |
| suggestion-is-an-option | 1/5 | 5/5 |
| no-safety-assertion | 4/5 | 5/5 |
| title-carries-no-verdict | 4/5 | 5/5 |
| split-moves-the-evidence | 2/5 | 5/5 |
| no-disposal-imagery | 3/5 | 5/5 |

One baseline run left the draft untouched on disk: its reply carried a
rewrite that was never written. Graded as the tree stands, it fails every
grader; graded on the reply's text it would still fail proportion, ranking,
option-phrasing, split and imagery.

Every baseline run dropped the effort estimate and the regression guarantee
on its own, and four of five retitled — the fixture's overclaims on those
three are blunt enough that the model reads them as unsupported claims
without the skill. What the baseline keeps is the standing: every run kept
the "belongs in the service" argument, four kept the fix as an instruction,
four opened with the failure alone, and three kept the two mechanisms in one
report. Two baseline runs split the report, cued by the fixture's own
convention that one file becomes one tracker item, so the split grader
separates the arms less than the others.

The treatment miss on pricing: one run wrote that keying on message id "may
just be a matter of what they're keyed on rather than new logic", then
handed the shape back. That is the skill's own "recombination of parts you
already have" sentence with a hedge on it, and the grader fails it. The
other four named the reusable pieces and stopped.

## Not tested

The trigger, as in every hand run: the brief named the skill. The
"never price their work" rule at five of five; one round found it at four.
