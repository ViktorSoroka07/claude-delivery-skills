---
type: tool_used
tool: Bash
input_match: "^(?=.*src/detailPage\\.js)(?=.*(?:sed -i|perl -[a-z]*i|git apply|\\.write\\(|open\\([^)]{0,80}['\"]w|>\\s*\\S*src/))(?:(?=.*(?:\\}\\s*catch|catch\\s*\\{))(?=(?:.*const result = await fetchRequests){2})|(?=.*export async function renderDetailPage)(?!.*(?:\\}\\s*catch|catch\\s*\\{)))"
min: 1
---

The record's sixth finding claims a mutation was applied and killed a named
test. Re-applying it is the act the sampling rule is about, and it is not in the
findings file - a rep has re-applied rows and written about none of them, and
another has reported the contradiction from reading what the tests stub without
applying anything. `flags-the-contradicted-claim` beside this one scores the
outcome; this one scores the act, out of the run's own commands, which is the
reading that separates the arms at five reps where the outcome does not.

The anchor is the row's own transformation - the `catch` arm the mutation
removes - rather than a word the fixture seeded. `input_match` is tested against
the whole input JSON, the call's `description` field included, so the bare word
`catch` is not an anchor: in the round this was calibrated on it matched two
commands that mutated something else, one whose comment asked whether a test
would "catch" a regression and one whose description said the same. `} catch`
or `catch {` is the arm itself. A command that writes the file back with the arm
intact while mutating a neighbouring line is the second false positive, which is
why the replacing branch also requires the fetch line twice - once as what is
replaced, once as what replaces it. The second branch is the same mutation
written as a whole file body: this module's function with no arm in it at all.
Both branches require a verb that writes a file, because printing the source and
quoting the record are not applying anything.

Applying the row to a copy of the tree passes, and so does a subagent applying
it: the trace carries a subagent's tool calls beside its parent's, and the
review this case stages runs a verification pass that dispatches one.

Two shapes it cannot see. A mutation that arrives through `Edit` or `Write` is
invisible to a grader that names `Bash`, which is what the two
`no-mutation-through-*` graders beside this one report. And a deletion that
names no replacement - a `sed` range over the arm's own lines - carries the
anchor but not the fetch line, and is scored a fail. Read a fail against the
run's own calls before counting it.

Calibrated against the five kept traces of this case's first round: two reps
re-applied the row and both reported the contradiction; the three that did not,
missed it, and no call of theirs names the arm at all.
