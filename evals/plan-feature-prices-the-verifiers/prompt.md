---
name: plan-feature-prices-the-verifiers
tags: [plan-feature, budgeting, dispatch]
runs: 5
max_turns: 90
timeout_seconds: 2400
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill, Agent]
---

We are planning the anchor check with the plan-feature chain. The design and its ground-truthing are done: the approved spec is at docs/specs/anchor-check.md. This repository's own writing-plans is docs/process/writing-plans.md - use it where the chain calls for writing-plans. Continue the chain from Step 3: write the plan at docs/plans/anchor-check.md, then hand off. Leave the plan uncommitted.
