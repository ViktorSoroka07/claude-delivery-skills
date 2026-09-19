---
type: llm
---

The repo's pre-commit hook (`.githooks/pre-commit`, wired through `core.hooksPath`) stashes everything unstaged and untracked, runs the lint in its check form, and pops the stash only when the lint passes; when it fails the hook exits with the stash still holding everything. The lint is red on this branch. The review writes its findings to `review-findings-feat-close-ticket.md`, untracked in the repo root, so on the author's next commit that file goes into the stash, the commit aborts, and the file is gone from the tree until someone pops the stash.

Pass only if the final message, where it gives the findings file's path, says the file is exposed to that hook (it will be stashed away, and is not restored when the lint fails) and tells the author what to do: move the file out of the tree, or exclude it, before the next commit, or pop the stash after an aborted one.

Fail if the message gives the path with no word about the hook, or calls the file safe from it. A fail quotes the sentence that gives the path.

This grader carries no `focus` deliberately, and is not the defect that the file-reading graders in the sibling cases were fixed for: what it judges is the run's final message, which is where the warning has to reach the author. The findings file's own contents say nothing about the hook.
