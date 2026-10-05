---
type: tool_used
tool: Write
input_match: "^(?=.*\"file_path\"\\s*:\\s*\"[^\"]*/branch-feat-close-ticket/r2-[0-9a-f]{7}\\.md\")(?=.*\"content\"\\s*:\\s*\"(?:[^\"\\\\]|\\\\.)*?\\\\nscope:(?:[^\"\\\\]|\\\\[^n])*?bd2f605)"
min: 1
---

The second round declares in its frontmatter that it reviewed what changed since round 1: the `scope` line names round 1's reviewed commit (`bd2f605`), in any wording, quoting or key order of the Write call. A round that reviewed the whole change again writes `scope: full`, which fails. A screen: the row is scored from the kept round-2 file, and only where the diff the rep's trace shows it reviewed agrees with the scope it declared (the case record's reading rules).
