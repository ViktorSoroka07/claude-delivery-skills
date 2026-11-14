# Maintaining post-review.py

    python3 test_post_review.py     # a fixture per status, against the forge stand-in
    python3 mutate.py               # breaks each check in turn, confirms the suite catches it
    /usr/bin/python3 test_post_review.py   # the same suite on macOS's stock 3.9

Run them from this directory or by path; each finds its siblings itself.
`mutate.py` requires a green suite first. Never run it beside another suite
run, and never edit `post-review.py` while it runs: it writes each mutation
into the script in place, so a concurrent run tests whichever mutation happens
to be applied. After an interrupted sweep, check `git status --short` before
trusting the script's bytes. A full sweep takes the better part of an hour.

## The stand-in interprets; it never echoes

`fake_forge.py` is installed first on `PATH` as `gh` and `curl` shims and
serves both forges from one model of a request, kept in
`$FAKE_FORGE_DIR/model.json`, which every call loads and saves. It parses the
argument forms the real tools take and refuses ones they refuse. It computes
changed lines, pending positions and the 422 from its own parse of `git diff`,
never from the script's helpers: a stand-in that shared the script's arithmetic
would agree with it on the same wrong number. For the same reason, every
expected value in a fixture is a literal written into the fixture: a UTF-16
end offset, a pending position, a stored path.

Each call is logged to `calls.jsonl` before it is handled, so a call that
crashes the stand-in, or that kills its caller, still counts. The log holds
argument lists and payload files, never standard input, which carries the
credential.

Faults are chosen per fixture in the model's `faults` map, each read where
the forge would misbehave: a create answered with a malformed echo, a lost
answer that lands now, later or never, a read that fails, a thread the list
hides, a body the forge stores altered, a placement reported off by one.
Counting is across runs (`creates` persists in the
model), so a fixture can stop a run and resume it against the same forge
state; `Fixture.run()` reloads the model after every run.

## The suite derives its own population

The suite compares `post-review.py --print-status-vocab` with its own expected
list and with the statuses its assertions cover, so a status added without a
fixture fails the suite. A refusal is asserted by "no create reached the
stand-in", counting refused attempts, never by the printed status alone: for
several checks the forge's own refusal would end the run anyway.

Every fixture runs the script under a hostile global git config (colour
forced, no prefixes, eight lines of context, an external diff command that
fails, copy detection, quoted paths), with `XDG_STATE_HOME` and `TMPDIR` of its own, and
an Azure DevOps token that is a sentinel.

## Changing a check means mutating it

`mutate.py` applies one named mutation at a time, requires its text to appear
exactly once and the edit to change the file, requires the suite to fail **on
that mutation's own assertion**, then restores the script and checks it is
byte-identical. A mutation that survives, or that fails some other assertion,
means the check is not doing what its name claims.

Assertion labels are the mutations' targets, matched exactly: renaming a label
means editing its mutation. Mutate toward the outcome only that check
controls. Three cases met here:

- A strict reply parse changes no exit code, because pairing falls back to
  body and anchor; what only the lenient parse controls is the forge's id in
  the run's record, so that is the assertion.
- Dropping the `sending` line changes nothing in a run that completes; it
  shows only when the run dies between the create and its record, and a plain
  re-run then posts a second copy.
- The correction and the final judgement go through one comparison,
  `verdict()`. A second comparison deciding whether to correct would let a
  mutation of the judgement survive, since the correction would still fix the
  body the judgement no longer checks.

## Time in the suite

The settle window is tested by moving the times in the run's record into the
past (`Fixture.age`), never by a clock hook in the script. Two pauses are
real. A read is retried three times two seconds apart, so a fixture whose
reads fail costs two seconds a failure, and only four failures exhaust it.
A hung curl call is played by the stand-in as curl's own `--max-time`
expiring, after the fault's `seconds`. No fixture shortens the script's
`--timeout`: it bounds every call of the run, and under a loaded sweep an
ordinary call outlived a one-second one, was killed before the stand-in saved
its model, and shifted the count every fault keys on.

## Portability

The script runs on Python 3.9, macOS's stock interpreter: no `match`, no
runtime `X | Y` unions. Ruff's default target does not enforce that, so the
suite is run under `/usr/bin/python3` as well. Windows is out of scope: the
stand-in's shims are shell scripts the script's `subprocess` calls cannot
start there.
