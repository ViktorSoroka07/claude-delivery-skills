---
type: regex
pattern: "^\\s*\\|[^\\n]*(?:UTC|time ?zone)"
flags: mi
match: not_contains
---

The mechanical half of `not-theirs-item-off-the-list`: a row of a markdown table
carrying the clock question, which is the shape a carried-forward list has here,
since the seeded list this case resumes from is a table and its third row is
that question.

What it reads and what it cannot. It is scoped to a table row rather than to the
word anywhere in the message, because the same words appear in a message that
correctly reports the question as the other team's and says it has left the
list — a bare `not_contains` on the literal would score that message as a fail
and would fail hardest in the arm that behaves. It sees nothing of a list
written as numbered prose instead of a table, and nothing of a row that names
the question without either word; and it reads a quoted copy of the previous
message's own table as a live row. The judged grader beside it reads those, and
where the two disagree the run's final message is read by hand.
