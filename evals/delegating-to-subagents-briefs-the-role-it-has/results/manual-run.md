# Runs

The case for the dispatch-brief entry "An instruction in a dispatch brief that
the agent's own tool set cannot carry out": a brief tells a role holding no
write tool to put its report in a file; the role cannot, finishes the work,
and hands it back in the reply - the route the file instruction existed to
avoid.

## What the case stages

The fixture (`evals/fixtures/log-digest.sh`) is a small ops repository: three
nightly batch logs, each with one failed job, and a `CLAUDE.md` saying logs
are summarised by the `log-summariser` agent, one log per dispatch, into
`summaries/<log>.md`. The role is defined with `Read`, `Grep` and `Glob` and
nothing that writes. The prompt asks for one summary file per log "the way
`CLAUDE.md` says" and for which job failed on which night.

**The runner never loads a fixture's `CLAUDE.md`.** It starts each rep with
`CLAUDE_CODE_DISABLE_CLAUDE_MDS=1` and `--setting-sources user` (read from the
CLI by this case's verifier), so the convention reaches a rep only by reading
the file, which the prompt names, and through the role's own description in
the agent listing ("Use for every log under logs/"). Each rep's read of
`CLAUDE.md` is recorded from its trace.

**The skill's own text creates the condition**: "End every spawn prompt by
naming the path the agent writes its full report to" sends a path to every
role, read-only ones included, and the skill gate stops the first dispatch
until `delegating-to-subagents` is loaded. **In a batch of sibling dispatches
the gate stops only the first**: the siblings, written in the same message
before the skill loaded, run - five of five such batches in this machine's
real sessions - so their briefs carry no text either arm could differ on.

**Where the role lives, settled by a probe for $0.15.** A scaffold-written role
in the run's own config directory (`../../config/agents/`) is offered to the
rep: the trace's `init` event lists `probe-reader`, and neither a copy in the
project's `.claude/agents/` nor one under `config/.claude/agents/`; the role
answered "PONG, Read, Grep, Glob". The probe also met the entry's condition
once, unplanned: after the gate loaded `delegating-to-subagents`, the rep
rewrote a fixed brief to add "Write your full reply to
`$TMPDIR/probe-reader-report.txt`, then reply with the path to that file
alone" and sent it to that read-only role, which answered in the reply. Its
case and trace are under `evals/results/row6-probes/`.

## Reading a rep, in both arms alike, before any verdict

1. **Curtailment** first, from each trace's `result` records - a rep that
   dispatches in the background writes more than one.
2. **The condition**: the rep tried a dispatch for the logs at all, the call
   the gate stopped included (`attempts-a-dispatch`). A rep that summarised
   every log itself is unmeasured on the act and replaced, at most two.
3. **The act**, read by hand from the dispatch briefs issued after
   `delegating-to-subagents`' Skill call returned: a rep fails where any of
   them asks `log-summariser` to write, save or create its report in a file.
   A brief asking that role for its summary in the reply passes, and so does
   giving the files to a role that holds a write tool. A rep that dispatched
   nothing after the load is unmeasured, and replaced.
4. **Beside it, by hand**: whether the rep read `CLAUDE.md`, and whether it
   used the role `CLAUDE.md` names - leaving it is the wording's own second
   route and a cost to the repository's convention, reported, not scored.

## Graders

| Grader | Type | Reads | Role |
|---|---|---|---|
| `no-file-asked-of-the-readonly-role` | `tool_used` Agent, `min: 0`, `max: 0` | any dispatch to `log-summariser` asking for a file | screen for the act |
| `attempts-a-dispatch` | `tool_used` Agent, `min: 1` | any dispatch | the condition |
| `dispatches-the-readonly-role` | `tool_used` Agent, `min: 1` | a dispatch to `log-summariser` | which role, read beside the act |
| `names-each-failure` | `regex`, final message | all three failed jobs named | neighbour: the asked answer |
| `summary-0N-names-its-failure` (three) | `regex`, file | each summary file exists and names that night's failure | neighbour: the asked files, whoever wrote them |
| `skill-was-invoked` | `tool_used`, with-only | `delegating-to-subagents` loaded | indicator of the gate firing |

The screen was scored as the runner scores it - its match count against `min`
and `max` - on stringified dispatch inputs from both sides: it fails six file
instructions (bare, a quoted path, "should be written to", "writes", "create",
upper case) and passes a short-reply brief, a brief mentioning `CLAUDE.md`'s
format, "do not overwrite anything", and a file instruction to a writing role.
Its first version declared `max: 1` with no `min`, which the runner reads as
exactly one match - so it would have failed every clean rep - and matched a
leading `\b` that never fires after a JSON line break; a blind verifier caught
both before any draw.

## The treated text, revised before any draw and not yet bought

`delegating-to-subagents`, "Before dispatch":

- **A paragraph before "Name the file the report goes to"**: "**Check the
  brief against what the role can do.** A brief is written from what the
  coordinator holds, and an instruction resting on a tool the role lacks does
  not fail: the role finishes the work and falls back to the one route it has,
  which is often the failure the instruction was there to prevent - a report
  told to go to a file comes back in the reply, cut, from a role holding no
  write tool. Before dispatching, read each instruction against the role's
  tool list: a file for the report goes to a role that holds a write tool."
- **"Name the file" bounded, bold lead and imperative alike**, to a role that
  can write a file; "a read-only role's reply is its only channel, so a lone
  dispatch of one asks for a report short enough to arrive whole, and
  read-only roles dispatched together return their work one at a time or give
  it to a role that can write" - since the paragraph's own reason, the budget
  sibling reports share, loses a short reply exactly where this case
  dispatches three. The red-flags row "This dispatch is short; no file
  needed" is bounded the same way.

The draft's clause about premises a role cannot reach (a pipeline log, a
decision the requester made) is cut: nothing here measures it, and its entry
is measured by the review round the plan names for it. The coordinator-side
sentence (read delivery from what arrived) stays out: nothing here reads it.

## The bars, fixed before any draw

- **The act row's tier is set on the baseline's first five measured reps.**
  - **4-5/5**: no treated arm; the skill's path sentence does not send a file
    to a read-only role on the suite's model, and the entry is declined on
    this case's evidence.
  - **0/5**: the treated arm's first five measured reps decide; it clears at
    4/5 or better.
  - **1/5**: it clears only at 5/5.
  - **2-3/5**: no treated arm; the ten-rep extension and its bar (9/10 or
    better, five above the baseline's ten) are fixed at the stop before any
    draw.
  - **A treated arm below its bar** is declined for this wording, the entry
    saying whether the gap fell below the floor.
- **No row lands from this case alone.** The entry is Strong-tier, and this is
  its one domain; a clear is recorded as tested on one domain, the landing
  waiting on a second fixture where the instruction a role cannot carry out is
  not a report path - a test command to a role without a shell, a fix to a
  role without an editor.
- **Neighbours**: a fall from 5/5 to 1/5 or lower, or from 4/5 to 0/5, is a
  cost; smaller, watched.
- **The invocation**: `--ablation none --model sonnet --judge-model sonnet
  --allow-tools Bash Write Edit Agent -j 3 --keep-temp`, the runs copied in as
  `round-E@baseline.json` and `round-E@<wording>.json`. Ceiling: each arm
  about $2.50, set above that.

## The baseline: two of four measured reps keep the file off the read-only role

Five reps from a detached worktree at `eb25595`, the invocation above, CLI
2.1.281: $1.44, kept as `round-E@baseline.json` with each trace under
`evals/results/rowE-traces/`. Nothing curtailed: 11-17 turns and 25-78
seconds in each first `result` record, two reps writing further records after
background agents reported. Every rep read `CLAUDE.md`, and every rep sent all
three logs to `log-summariser` in one message: the gate stopped the first and
the two siblings ran on briefs written before `delegating-to-subagents`
loaded - the batch the verifier predicted, in five reps of five.

| Rep | Briefs before the load (siblings ran) | Brief after the load | Act |
|---|---|---|---|
| 1 | "Write the summary to `summaries/nightly-01.md`" | none - it dispatched nothing after the load | unmeasured |
| 2 | "Return the summary as text ... (do not write any file)" | "You do not have a Write tool, so return the complete summary as plain text in your final reply (not a file) - keep it concise (under 200 words) since it must fit whole" | pass |
| 3 | "Write the summary to `.../summaries/nightly-01.md`" | the same, plus "That file is the deliverable. Reply with just the path you wrote" | fail |
| 4 | "do not write any file yourself - you don't have write access" | "You have no Write tool, so return the full summary as plain text ... keep it concise ... since it will arrive alongside two sibling reports" | pass |
| 5 | "Write the summary to `summaries/nightly-01.md`" | the same, plus "Report back by writing the full summary content ... to `summaries/.nightly-01.report.txt`, then reply with just that file path" | fail |

**The act: 2/4 measured**, the fifth measured rep unable to move the tier
(2/5 or 3/5), so no replacement was bought. The screen failed reps 1, 3 and
5 - rep 1 on its pre-load briefs alone, the false fail the record names - and
passed 2 and 4. `names-each-failure` and the three summary-file rows read 5/5:
the coordinator wrote every file itself from the replies, which is the
fallback the entry describes and not a cost to the asked work.

**What the reps show about the skill's own text.** Once loaded, it moved
briefs both ways: reps 2 and 4 read the role's tool list and kept the file off
it, rep 4 adding the sibling budget the skill's paragraph gives as its reason;
reps 3 and 5 applied "name the path the agent writes its full report to, and
ask for a reply of that path alone" to a role with no write tool, rep 5
adding a second file for the report on top of the summary file. Before the
load, the unaided briefs split the same way, two of five keeping the file off.

**By the bars fixed before the draw: 2-3/5 buys no treated arm inside batch
1.** Its extension - both arms to ten measured reps, the row clearing at 9/10
or better and five above the baseline's ten - is priced at the stop: five
more baseline reps and ten treated, about $4.50 with replacements, on the
revised treated text above. A clear there would still be tested on one
domain.

**Spent on this round**: the probe $0.15 and the baseline $1.44 - **$1.59**.
