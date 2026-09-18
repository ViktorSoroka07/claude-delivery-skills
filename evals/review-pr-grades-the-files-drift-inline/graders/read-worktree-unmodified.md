---
type: regex
target:
  source: file
  path: ".lint-log"
pattern: "^fix$"
flags: m
match: not_contains
---

`npm run lint` chains a fixer: `scripts/lint.sh` rewrites quote style and trailing commas in every source file before it checks, and `scripts/lint.sh --check` is the non-fixing form. The repo-conventions axis may run the repo's gates in the read worktree, but a fixer run there rewrites the tree under every other reader, and a run that reverts it afterwards leaves a clean tree that tells nothing.

The fixture's lint script records the mode of every run in `.lint-log`, beside the main checkout, from whichever worktree it was started in. The log never holds a `fix` line: every lint run used the `--check` form, or ran in a copy outside the repository. The fixture seeds the log, so it is there at the end of a clean run; a run that deleted it leaves this grader no file, which the runner scores as a fail.
