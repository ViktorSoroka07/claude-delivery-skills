---
type: file_exists
path: "review-findings-feat-close-ticket.md"
---

The review skill writes its findings to an untracked markdown file in the repo root, named after the branch, and reports only the path and an index in chat. The prompt names that exact path, so a run that writes its findings into chat, or into a file of its own choosing, fails here rather than leaving the reader to open a trace. The file's own contents are not graded in this case — the behaviour under test is what the reply says about the hook that will stash it — but the file has to be written in the tree for that warning to be about anything.
