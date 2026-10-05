---
type: tool_used
tool: Write
input_match: "\"file_path\"\\s*:\\s*\"/[^\"]*/\\.local/state/delivery-skills/review-pr/[^\"]*\\.md\""
min: 1
---

A screen beside `findings-written-to-the-state-folder` that ignores the folder key: the findings went to the state folder at all. A rep passing this and failing the exact grader moved the file but keyed it another way (a rep that read "the remote cannot be reached" as "no remote" keys it `local/<directory>`), which is a different reading from a rule that did not bind.
