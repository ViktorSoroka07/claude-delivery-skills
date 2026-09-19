# Manual runs

`claude plugin eval` is still gated at run time, so the case was run by the
hand procedure in CONTRIBUTING's "Testing a wording change": five fixtures
from `evals/fixtures/clone-folder.sh`, five fresh subagents on sonnet, the eval
prompt verbatim. The skill's value is the bundled script it points at, so the
brief named the skill and had the agent load it through the Skill tool rather
than pasting the text; the trigger itself is therefore untested, as in every
hand run. No no-skill baseline was run: the skill's own commit records the
hand-rolled loop the baseline produces, and the regex grader exists to catch it.

## Results

| Grader | treat |
|---|---|
| every-child-is-accounted-for | 5/5 |
| stale-tracking-ref-is-not-evidence | 5/5 |
| uses-the-bundled-script | 5/5 |

Every run called the script once by its absolute path and reported all six
children in a table, the not-a-repo folder included. Every run reported the
unreachable clone as a failed fetch needing the user, with the cause named
(the remote path does not exist), and none called it current. Every run left
the ahead-only clone's local commit in place and told the user to push when
ready; no run merged, rebased, pushed, reset, or changed a remote URL, which
was checked in each workspace after the run.

Every run also went past the script to diagnose the two repos needing the
user — `git remote -v`, `git fetch`, `git log origin/main..main` in those
directories — before reporting. That is reading the output as the skill asks,
not the loop it forbids: no run pulled or fetched across the folder by hand.

## The turn limit is what this case is measuring

Across the release baseline (three runs per arm) and a two-run plugin-arm
pass afterwards, the plugin arm's turn counts are 17, 20, 31, 31 and 28
against a `max_turns` of 30: two of five runs were cut off at the limit, and
the runs that finished came within two turns of it. Every no-plugin run of
three hit the limit. The bundled script is run in every plugin run and in no
unaided one, so the unaided arm's exhaustion is the per-repo loop the skill
exists to replace — that contrast is the case's point and should not be
bought off by a higher limit for both arms.

The plugin arm, though, is being scored on whether it fits the budget rather
than on what it reports: its one clean run at 28 turns passes every grader.
Raising `max_turns` for this case is the call to make, with the baseline rows
retaken at the new limit so the numbers stay comparable.

## The limit raised to 60 turns, and 900 seconds with it

`max_turns` is 60 and `timeout_seconds` 900, up from 30 and 420. The reasoning
the counts support: the plugin arm's five recorded runs used 17, 20, 31, 31 and
28 turns, so the ceiling of 30 cut two off and left the clean run two turns of
headroom — a ceiling that close is scoring the arm on fitting the budget rather
than on what it reports. Sixty is twice what the slowest completed plugin run
needed, which is headroom rather than a new ceiling to crowd.

The limit is raised for both arms, because it is the case's budget and not a
property of one arm. What it must not do is buy off the contrast: every unaided
run of three hit the old limit while running no bundled script at all, and that
exhaustion is the per-repo loop the skill exists to replace. Should the unaided
arm now finish inside 60 turns and report all six children, that is the honest
answer — the case still has a scored row that moves, `uses-the-bundled-script`,
which was 3/3 with the plugin and 0/3 without it — and the difference the case
shows becomes the report's quality rather than the arm's exhaustion.

The timeout rises with it because it would otherwise become the new ceiling: the
unaided runs that hit 31 turns took 178, 321 and 360 seconds, so 60 turns at
that rate runs past 420.

### The rows retaken at 60 turns — three runs per arm

| Grader | No plugin, at 30 | No plugin, at 60 | Plugin, at 30 | Plugin, at 60 |
|---|---|---|---|---|
| every-child-is-accounted-for | 0/3 | 3/3 | 1/3 | 2/3 |
| stale-tracking-ref-is-not-evidence | 1/3 | 0/3 | 1/3 | 1/3 |
| uses-the-bundled-script | 0/3 | 0/3 | 3/3 | 3/3 |
| skill-was-invoked (indicator) | — | not evaluated | — | 3/3 |

$4.12. No run hit the ceiling: the highest counts were 42 unaided and 38 with
the plugin, against 60. The three unaided runs that were cut off at 30 now
finish, and the two plugin runs that were cut off now finish.

**What the old rows were measuring.** `every-child-is-accounted-for` went 0/3
to 3/3 in the unaided arm on no change but the ceiling, so its old zero was
the budget and not the report: an unaided run does account for all six
children, it just needs forty turns of hand work to get there. Reading that
zero as a difference the skill makes was reading the limit.

**What the case still shows.** `uses-the-bundled-script` is 3/3 with the
plugin and 0/3 without it, unchanged by the raise, so the case keeps a scored
row that moves when the skill is taken away — and it is now the difference
the case is named for rather than a side effect of exhaustion. The contrast
is the same work in eleven to thirty-eight turns against twenty-three to
forty-two, with the same report at the end.

`stale-tracking-ref-is-not-evidence` sits at 1/3 with the plugin and 0/3
without, near where it was. It is the weakest row in this case and neither
arm reads the unreachable clone's stale ref reliably; whether that is the
skill, the fixture or the judge is not answered by six runs.
