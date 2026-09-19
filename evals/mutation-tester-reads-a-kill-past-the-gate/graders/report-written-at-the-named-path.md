---
type: file_exists
path: "mutation-report.md"
---

The prompt names the path the agent's complete report has to reach, and says
the orchestrator saves the report itself where the agent replies with one
instead of a path. Every other grader here reads that file, and a file-targeted
grader whose target is absent throws and is scored a fail — so without this row
a run that never reported and a run that reported the wrong thing are the same
four zeros. This row is what tells them apart: where it fails, the four below
it say nothing at all about the run.
