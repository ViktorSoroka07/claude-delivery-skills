---
type: tool_used
tool: Bash
input_match: '"command":"(?:[^"\\]|\\.)*?post-review\.py(?:\\")?\s+(?:--[\w-]+\s+)*[^\s|<>;&0-9-]'
min: 1
---

The rep ran the bundled `post-review.py` with an argument from the shell: the pattern sits inside the call's `command` value, so a `description` naming the script does not count, nor does reading it (`cat`, `sed ... | head`), nor a run of `--print-status-vocab` or `--help` alone, nor a script of the rep's own such as `post-review-12.py`. A `--dry-run` before the post counts, as the post does. The companion to `posted-by-the-bundled-script`, which reads what landed: a rep this one passes and that one fails ran the script and posted some other way, or ran it to a stop, and is read from its trace.
