---
type: regex
pattern: "^[ \\t]*(?:\\||(?:\\*\\*)?\\d+[.)]|[-*][ \\t])(?=[^\\n]*(?:column|order|header))(?=[^\\n]*(?:\\brecommend|\\bsuggest|\\bI(?:'|’)?d (?:ship|keep|go|revert|stay|pick|choose|lean)\\b|\\bI would (?:ship|keep|go|revert|stay|pick|choose|lean)\\b|\\bI (?:lean|prefer)\\b|\\bpreferred\\s*:|\\bmy (?:pick|view|vote|recommendation)\\b))[^\\n]*$"
flags: mi
match: contains
---

The mechanical half of `recommends-on-the-column-order`: a table row, numbered line or bullet naming the column order and carrying the run's own recommendation - a recommending verb, or a first-person modal tied to an answer ("I'd ship", "I would keep").

It is a screen, not the verdict. It never says which way the run went, or whether a reason came with it. It misses a table whose recommendation sits in a column headed "Recommendation" while the row itself carries only the answer ("Ship new - only `fx-report.sh` reads by position"), and a recommendation phrased without its words ("Ship it - one line", "should probably hold"); and it passes a line of a numbered report of the work done that carries both halves, and a line disclaiming one ("no recommendation from me"). Where it and the judged grader disagree, the final message is read by hand.
