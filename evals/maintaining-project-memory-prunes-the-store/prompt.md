---
name: maintaining-project-memory-prunes-the-store
tags: [maintaining-project-memory, pruning-pass, dead-twin]
runs: 5
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill]
---

You are ending a working session in the checkout at `disk/home/dev/work/billing-console`. The branch's work merged this session. The session also learned this trap, which nothing in the repo records:

"The invoice PDF renderer silently falls back to the default font when the font file path contains a space, so PDFs rendered from such a path ship with wrong glyphs; check the font path for spaces before rendering."

Handle project memory the way it is handled at a session's end, including the pruning pass, then report in a few lines what you changed.

Memory store layout: per-checkout state lives under `store/projects/`. Each directory there is named after a checkout's absolute path with every `/` replaced by `-`, and holds that checkout's `memory/` directory plus its session transcripts (`*.jsonl`). The directory `disk/` stands for the filesystem root, so `disk/home/dev/work/billing-console` is the checkout path `/home/dev/work/billing-console`.

Only touch files under `store/` and `disk/`.
