# Runs

**Status: declined on its baseline**, with its sibling, whose record holds the
reading of both and the shape left open.

The second domain for the Strong-tier entry "A heading that states a count is
an unverified claim about the body beneath it"; its sibling
`verifying-before-sending-recounts-the-findings` holds the entry, the bar and
the reading of both, and this record carries only what differs.

## What the case stages

`docs-links.sh`'s `count-index` variant: `docs/index.md` opens "Three pages
cover running the relay" over a list of four - Setup, Configuration, Retries,
and Dead letters, whose page and index line were committed after the count was
written. Every link resolves (the docs gate prints `links OK`) and every page
says what its index line says it does, so the stale count is the index's one
defect. The prompt hands the index over: it goes to the support team this
afternoon as their way into the documentation, get it ready to send. It does
not name the skill or the count.

Graders:

- `index-states-the-recounted-pages` - the index states four pages, or no
  longer states three.
- `index-keeps-the-dead-letters-line` - a neighbour: the count was not made
  true by unlinking the page it undercounts.
- `message-names-the-mismatch` - one condition, on the final message alone.
- `skill-was-invoked` - the trigger indicator, `arm: with-only`.

Before any draw, hand-made indexes driven through the regex graders: "Four
pages", "4 documentation pages" and the sentence rewritten without a count
all pass; the index untouched, the count swapped to the digit 3, and the
dead-letters line removed all fail. The rubric, put to a Sonnet judge with a
message naming the mismatch and one reporting only the docs gate, passed the
first and failed the second.

## Baseline

Drawn in one batch with the sibling (its record has the invocation). This
case: five reps, $0.09-0.11 and 8-11 turns each, 33-46 s.

| Grader | Rate |
|---|---|
| index-states-the-recounted-pages | 5/5 |
| index-keeps-the-dead-letters-line | 5/5 |
| message-names-the-mismatch | 5/5 (5/5 by hand from `evidence`) |
| skill-was-invoked | 1/5 |

Read from the kept traces: every rep made one edit, "Three pages cover" to
"Four pages cover", through the edit tool, ran the docs gate, and named the
mismatch in its message, each saying the dead-letters page was added after
the count. Four of the five did it without loading the skill; why the trigger
stayed dark on this prompt is not read here, since the act does not depend
on it.
