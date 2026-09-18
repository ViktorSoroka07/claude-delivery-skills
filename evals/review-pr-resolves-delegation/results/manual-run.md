# Runs

No hand run has been made on this prompt as committed.

## Through the runner

One run of `claude plugin eval` on this case, three runs per arm, the
runner's own arms (no plugin, the plugin) and its default judge.

| Grader | No plugin | Plugin |
|---|---|---|
| findings-file-written | 1/3 | 3/3 |
| held-the-mount-back | 0/3 | 0/3 |
| opened-the-tracker | 2/3 | 2/3 |

**The 0/3 on both arms reads as no difference and is no reading at all.** One
of the six runs reached the judge. Three threw, because this grader's
`focus.path` is a single literal file name and the run either wrote no
findings file or named it something else — in one of those runs
`findings-file-written`, whose glob is `review-findings-*.md`, passed on a
file the judge could not open. Two more were skipped because the run had
crossed the invocation's cost ceiling, and a skipped paid grader is scored a
fail like any other. Nothing in the JSON distinguishes those five
non-verdicts from a behaviour that failed; only the per-run `explanation`
does.

The one judged run passes all four rubric conditions by hand: one finding
about the detail-page mount, naming the owning work item; the swallowed
fetch error and the 50-row page cap as two numbered symptoms inside that
finding's Problem; a Suggestion that is the single action of holding the
mount back until the owning task lands; and no suggestion anywhere of an
error state, an error banner or a total-count display. The judge voted fail
three times.

The explanation is the rubric's own opening clause. It says to judge only the
final or merged list where the file separates that from drafts and verdicts,
and the file under judgement ends with a final list that *indexes* by
severity — one title line per finding — with each finding's Problem and
Suggestion standing earlier, under the draft heading the clause excludes.
Read as instructed, the final list contains no Problem and no Suggestion, so
conditions 2 and 3 cannot be satisfied by any file of that shape, whatever
the review did. A file that restates its findings in full under the final
heading is gradable; one that indexes them is not.

Two instrument fixes fall out, both for the case rather than the skill: the
rubric needs to say that where the final list indexes findings stated
earlier, those findings' bodies are what it points at; and a grader that
names one literal file cannot be the grader for a behaviour whose file name
the run chooses.

What this run does say about the plugin: the findings file was written in
three plugin runs of three and one no-plugin run of three, and the two
runs that called no tracker script are one in each arm.
