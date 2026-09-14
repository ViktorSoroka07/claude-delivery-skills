# Azure DevOps — work item fields

Loaded when the tracker item being closed, commented on, or created lives in Azure DevOps. PR-thread comments are a different API surface and default to Markdown; work-item fields do not.

## Rich-text fields carry a per-field format

A work item's multiline fields (Description, a comment, acceptance criteria) each carry a format, `"html"` or `"markdown"`. `GET` the item and read `multilineFieldsFormat` in the response — a map of field name to format — before writing into any of them. Where this was learned, every newly created item defaulted every multiline field to `"html"`; read the map rather than assume it, since the default is the organisation's to change.

Markdown sent into an HTML-formatted field is stored and read back byte-for-byte unchanged (no error), and renders in the UI as literal text — asterisks and brackets visible, not a list. A post-write read-back therefore passes clean over it; only reading the format back catches it.

Switch a field to Markdown with one PATCH that sets the format and a value together — a format-only op errors ("the type changed without a value"):

```json
[
  {"op": "add", "path": "/multilineFieldsFormat/System.Description", "value": "Markdown"},
  {"op": "add", "path": "/fields/System.Description", "value": "<markdown text>"}
]
```

After that PATCH, plain CommonMark in later updates renders correctly without repeating the format op. Confirm which format actually landed by reading `multilineFieldsFormat` back — a mismatch between what was sent and what the field claims to be otherwise stays silent.

**In both formats, a raw `<` in the field is read as an unclosed HTML tag and silently truncates everything after it** — no error on write; the field just reads back shorter than what was sent. Escape it (`&lt;`) or keep it inside a code span. (learned from a real work-item update)
