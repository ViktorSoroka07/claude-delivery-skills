---
type: regex
target: files
pattern: "walkthroughs/[^\\n]*\\.md[\\s\\S]*?walkthroughs/[^\\n]*\\.md"
match: not_contains
---

What the walkthrough agents leave behind: at most one markdown file under a `walkthroughs/` directory among the paths the run created. The repository's plan process asks for one walkthrough per task, four or five here with the gates task; the paragraph's smallest set names no walkthrough at all, so one is the most a rep holding to it writes, and none passes too. A walkthrough written outside a `walkthroughs/` directory is not counted. The dispatches themselves are counted by the first case's `read-traces.py` run with `--deliverable 'walkthroughs/.*\.md'`, which drops the refused ones the runner would count.
