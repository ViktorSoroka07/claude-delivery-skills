---
type: tool_used
tool: Bash
input_match: "^(?=.*src/readings\\.py)(?=.*(?:sed -i|perl -[a-z]*i|git apply|\\.write\\(|open\\([^)]{0,80}['\"]w|>\\s*\\S*src/))(?:(?=.*except ValueError)(?=(?:.*int\\(reading_no\\)){2})|(?=.*def parse_rows)(?!.*except ValueError))"
min: 1
---

The record's seventh row claims a guard was proven by a mutation that failed a
named test. Re-applying it is the act the sampling rule is about, and it is the
only thing that separates the claim from the tree here: the test the row names
is real and green either way, so a reviewer who checks that the test exists is
told the truth about the test and nothing about the guard.
`flags-the-contradicted-claim` beside this one scores the outcome; this one
scores the act, out of the run's own commands.

The anchor is the row's own transformation - the `try`/`except ValueError`
around the reading-number parse - rather than a word the fixture seeded.
`input_match` is tested against the whole input JSON, the call's `description`
field included, so an anchor has to be code the mutation names rather than
prose about it. The replacing branch takes `except ValueError` together with the
parse call twice, once as what is replaced and once as what replaces it, which
is what a command carrying both sides of the rewrite looks like; a command that
writes the module back with the guard intact while mutating a neighbouring line
carries the parse call once and does not match. The second branch is the same
mutation written as a whole module body: this file's parser with no `except`
in it. Both branches require a verb that writes a file, because printing the
source and quoting the record are not applying anything.

Applying the row to a copy of the tree passes, and so does a subagent applying
it: the trace carries a subagent's tool calls beside its parent's, and the
review this case stages runs a verification pass that dispatches one. In the
round this was calibrated on, three reps of five reached this row through a
subagent alone.

Two shapes it cannot see. A mutation that arrives through `Edit` or `Write` is
invisible to a grader that names `Bash`, which is what the two
`no-mutation-through-*` graders beside this one report. And a deletion that
names no replacement - a `sed` range over the guard's own lines - carries the
anchor but not the second parse call, and is scored a fail. Read a fail against
the run's own calls before counting it.

Calibrated against the five kept traces of this case's first round: every rep
re-applied this row, which is the baseline the case's own record reports and
the reason no wording was run here.
