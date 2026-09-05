# Maintaining git-sync

    bash test.sh      # a fixture per status, plus exotic names, scale, interrupt
    bash mutate.sh    # breaks each check in turn, confirms the suite catches it
    bash matrix.sh    # runs the whole suite under several global git configs

Run them from this directory. `mutate.sh` and `matrix.sh` both require a green
`test.sh` first. Never run `mutate.sh` and `matrix.sh` at the same time:
`mutate.sh` edits the script in place, so a concurrent `matrix.sh` would be
testing whichever mutation happened to be applied.

`matrix.sh` exists because the script inherits the user's git configuration, and
a setting that is harmless in isolation can change what a plumbing command does.
When adding a profile, check it does not disable something a test depends on: a
`core.hooksPath` override pointing away from the repo silently defeats the
interrupt test, whose fixture installs a `post-merge` hook, and the resulting
failure looks like a defect in the script.

## The suite derives its own population

`test.sh` builds a throwaway origin and clone for every status the script can
emit, runs the script against them, and asserts the working trees afterwards,
not just the printed rows. It compares `git-sync.sh --print-status-vocab`
against its own expected list and against the statuses its assertions cover,
so **a status added without a fixture fails the suite** rather than passing
untested.

Adding a status means adding its fixture in `build_workspace`.

## Changing a check means mutating it

A first green run proves nothing. `mutate.sh` applies one breakage at a time,
asserts the edit actually landed (a target string that appears zero times, or
more than once, is reported as not-applied rather than as a result), requires
the suite to fail **on the specific assertion that mutation targets**, then
restores and verifies the file is byte-identical.

A mutation that survives, or that kills some other assertion, is reported as
such. Both mean the check is not doing what its name claims.

**Mutate toward the outcome the check uniquely controls.** Neutering the
overlap detection so it never finds overlap changes no status, because the
`merge --ff-only` fallback still refuses and still reports `BLOCKED`; the check
would look tested while being dead code. Forcing it to always find overlap is
what exposes it, because that flips a repo's fate from `UPDATED` to `BLOCKED`.
A mutation whose effect a fallback also produces cannot kill anything.

**A behaviour that lives in the detail column needs a detail assertion.** Every
row reports on the default branch, which is not always the branch checked out,
so each status carries a note naming where the user is standing. Removing that
note leaves every status identical and every status assertion green. Only an
assertion reading the row's text catches it, and its negative twin matters as
much: a repo on its default branch must carry no such note, or the assertion
passes on a script that annotates everything unconditionally.

## Portability constraints

The script targets the oldest interpreters likely to be present, which rules
out three things that work everywhere else:

- **No `wait -n`.** Job throttling polls `jobs -pr` instead.
- **One assignment per `local`.** `local a="$1" b="$WS/$a"` fails under
  `set -u`, because `local` is a builtin whose arguments all expand before any
  assignment happens, so `$a` is still unbound when `$b` is built.
- **No newline after `:` in an awk ternary.** The original awk rejects it; the
  table's colour selection uses `if`/`else` for that reason.

Two data-shape constraints are just as easy to reintroduce:

- **The record delimiter is the unit separator, not a tab.** A whitespace
  character in `IFS` makes bash collapse runs of it into one delimiter, so a
  record with an empty middle field shifts every later field left.
- **`$$` is the parent's PID inside a subshell.** Temporary files created by
  the parallel workers must come from `mktemp`, or every worker writes to the
  same name and they read each other's data.

## Two traps in testing the script itself

**A harness cannot send SIGINT to the script.** A shell sets `SIGINT` to ignored
in background jobs when job control is off, and a signal ignored on entry cannot
be trapped, so the handler never runs however the harness sends it. `SIGTERM` is
not ignored and reaches the same handler, which is what the interrupt test uses.
A test written around `kill -INT` reports the guard as broken when it is fine.

**Measure alignment in characters, never in bytes.** `awk`'s `index()` and
`length()` both count bytes, so an assertion built on them fails on exactly the
non-ASCII rows the padding exists to fix, and passes on a script that pads
wrongly. Count characters by stripping UTF-8 continuation bytes:
`LC_ALL=C tr -d '\200-\277' | wc -c`. Wide glyphs still occupy two terminal
columns while counting as one character, so CJK names remain visually a little
wide; character alignment is the guarantee, not display width.

