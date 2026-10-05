---
type: tool_used
tool: Write
input_match: "\"file_path\"\\s*:\\s*\"[^\"]*/\\.local/state/delivery-skills/review-pr/[^\"]*\\.md\"\\s*,\\s*\"content\"\\s*:\\s*\"-{3}\\\\n(?:[^\"\\\\]|\\\\.)*?repo:\\s*(?:\\\\\")?git\\.example\\.org/acme/ticket-gateway(?:[^\"\\\\]|\\\\.)*?reviewed_sha:\\s*(?:\\\\\")?[0-9a-f]{40}"
min: 1
---

The file opens with frontmatter naming the repository by its folder key and the reviewed head in full, which a later round and a later pass over many reviews read. Anchored on the written body: the Write into the state folder whose content starts with the frontmatter fence and carries both keys. A file written by the shell is read by hand from the kept home.
