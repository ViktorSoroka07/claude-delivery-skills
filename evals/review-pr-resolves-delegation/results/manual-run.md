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

## Both instrument fixes, applied

**The prompt names the findings file.** `held-the-mount-back` reads one literal
path, and `focus` takes no glob and no directory, so the grader could only ever
resolve on a run that happened to choose the same name. Three of the six
baseline runs threw on it. The prompt now says the findings go to
`review-findings-feature-mount-table.md` in the repo root — the name the skill's
own convention produces for this branch, so the plugin arm's behaviour is
unchanged and the unaided arm is simply pinned to the same place.

What that costs is `findings-file-written` as a signal that the skill fired:
with the path named, a run in either arm can write it. The signal moves to
`skill-was-invoked`, which reads the Skill call itself and is a better one —
it distinguishes the skill under test from the harness's own built-in review
skill, which answers to a review request too. `findings-file-written` is now
pinned to the same literal path rather than a glob, so it and the focus graders
agree: a run that writes its findings somewhere else fails the first and does
not silently throw the second.

**The rubric says which text it judges.** Its opening clause said to judge only
the final or merged list. The one baseline run that reached the judge ends with
a final list that *indexes* its findings by severity, one title line each, with
every Problem and Suggestion standing earlier under the draft heading the
clause excludes — so conditions 2 and 3 were unsatisfiable by construction, and
the judge failed three votes to none a file that passes all four by hand. The
clause now says that where the final list indexes findings stated earlier, the
bodies it points at are what the conditions are judged against.

### Runner pass at the named path — one run per arm

| Grader | No plugin | Plugin |
|---|---|---|
| findings-file-written | 1/1 | 1/1 |
| held-the-mount-back (single rubric) | fail | fail |
| opened-the-tracker | 1/1 | 1/1 |
| skill-was-invoked (indicator) | not evaluated | 1/1 |

$1.48. No grader threw in either arm: the naming defect is gone, and both runs
wrote the findings file at the path the prompt names. The unaided run reached
it in four turns against the plugin run's thirty-three.

The unaided run's fail is correct on inspection — it splits the mount into
three separate findings, suggests no hold-back, and says "Tracker item 102
calls for an error state here". The plugin run's fail is not: its file carries
one Major finding naming item 102, with the swallowed error and the 50-row cap
as numbered symptoms inside its Problem, and no finding asking for an error
state, a banner or a total count.

### The judge could not read the rubric, and that is the rest of the defect

Both findings files were then put through the rubric directly, as throwaway
cases whose scaffold writes the kept file, so the same text is judged
repeatedly without paying for a review run. Three reps each.

| Rubric, on the plugin-arm file | Default judge | Stronger judge |
|---|---|---|
| the single four-condition rubric | 0/3 | — |
| the same, with two conditions loosened | 0/3 | — |
| split: one grader per condition | 1 of 4 conditions | 3 of 4 conditions |

On the unaided file every condition fails under both judges, which is right.
On the plugin-arm file the default judge fails three conditions that a
stronger judge passes three votes to none — same file, same wordings, so the
difference is the judge and nothing else. Loosening the wording did not move
it; splitting the rubric moved it only under the stronger judge.

The one condition that fails under both is the Suggestion's. That is a real
fail, and the first hand grade of this file was too generous: the run's
Suggestion holds the fetch call and its error and paging handling out of the
branch and keeps the table mounted, which is repairing the wiring rather than
not shipping it. The grader now names that shape as the fail.

So the case carries four graders where it carried one. Each is a single
condition, which also says which condition a run missed instead of collapsing
four into one bit. What no case file can fix is the judge: the runner takes
`--judge-model` per invocation and a grader cannot name its own judge (`model`,
`judge_model`, `judge-model` and `judgeModel` are all rejected at load). A
verdict on this case is worth reading only from a run given a judge that can
hold a six-kilobyte findings file.
