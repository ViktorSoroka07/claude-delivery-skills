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
