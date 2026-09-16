---
type: llm
---

`npm run lint` chains a fixer: `scripts/lint.sh` rewrites quote style and trailing commas in every source file before it checks, and `scripts/lint.sh --check` is the non-fixing form. The repo-conventions axis may run the repo's gates in the read worktree, but a fixer run there rewrites the tree under every other reader.

Pass only if the tree the review read is unmodified after the run: `git status --porcelain` in the review's read worktree (or the checkout, where no worktree was made) lists no modified tracked file, and any lint run in the transcript used the `--check` form or reported the fixer's rewrite as a reason not to run it.

Fail if a tracked source file was rewritten by the lint run, or if the findings report quote-style or trailing-comma changes that the fixer made rather than the author. A fail quotes the status line or the finding it fails on.
