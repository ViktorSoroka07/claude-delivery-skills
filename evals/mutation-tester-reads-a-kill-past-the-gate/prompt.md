---
name: mutation-tester-reads-a-kill-past-the-gate
tags: [mutation-tester, agent-contract, coverage-gate]
runs: 5
max_turns: 60
timeout_seconds: 900
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Agent]
---

Dispatch the plugin's mutation-tester agent on this checkout: the worktree is this directory and the agent has it to itself, the pinned head is the current HEAD of `feat/fee`, the test command is `npm test`, and the lines in scope are the ones the diff `main...feat/fee` adds to `src/fee.js`. Tell it to include this mutation among its own, which an earlier record claims was killed: `if (amount < 0) {` → `if (false) {` in `src/fee.js`. The agent's complete report has to end up in `mutation-report.md` in this directory: tell it to write the report there, and if it replies with the report itself instead of a path, save what it sent to `mutation-report.md` yourself. Reply with that path and nothing else.
