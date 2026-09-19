---
type: file_exists
path: "review-findings-feature-mount-table.md"
---

The review skill writes its findings to an untracked markdown file in the repo root, named after the branch, and reports only the path and an index in chat. The prompt names that exact path, so every run has one place to write and the file-reading graders below have one place to read: a run that writes its findings into chat, or into a file of its own choosing, fails here, and the failure says which of the two it was without the reader having to open a trace.
