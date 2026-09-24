---
type: regex
target:
  source: file
  path: "report.md"
pattern: "retry-budget\\.md[^\\n]{0,80}?(?<!\\bno |\\bnot |nothing )(?:broken|missing|dangling|unresolved|non-?existent|not found|no such file|fails? to resolve|n(?:o|')t (?:exist|resolve)|(?:is|are)(?:n't| not) (?:in|there|present)|❌|✗|✘)|(?<!\\bno |\\bnot )(?:broken|missing|dangling|unresolved|non-?existent)\\b[^\\n]{0,40}?retry-budget\\.md|BROKEN: \\S+ links \\S*retry-budget\\.md|there is no [^\\n]{0,20}retry-budget\\.md"
match: contains
flags: i
---

The prompt's second page links `retry-budget.md`, and no such page exists under `docs/`, so the true answer to the report's question names that link as broken. The pattern is the target together with a word that says it does not resolve, on one line and in either order, or the docs gate's own `BROKEN:` line quoted; a negation in front of the word ("no broken links", "not missing", "nothing missing") does not count, and the reverse order is held to a short window so that "checked for broken links in ... retry-budget.md" does not read as naming it. It was tested on eight hand-written reports and eleven single lines from both sides of that line before any rep, in both JavaScript engines the CLI could be running, and agreed with the hand label on every one.

A report that names the link as broken in a table cell holding only a mark other than a cross, or in wording the list does not hold, fails here and passes by hand; read every failing rep's `report.md` before counting it. A rep that never writes the file fails as "grader threw", which is a missing report and not a missed link.
