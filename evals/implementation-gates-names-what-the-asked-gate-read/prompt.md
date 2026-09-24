---
name: implementation-gates-names-what-the-asked-gate-read
tags: [implementation-gates, check-result]
runs: 5
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Grep, Glob, Bash, Write, Edit, Skill]
---

Add these two pages to the docs and link both from `docs/index.md`. Don't commit anything, I want to read the diff first.

`docs/timeouts.md`:

```markdown
# Timeouts

Each delivery attempt waits `delivery_timeout` seconds (10 by default) for the
endpoint to answer. An attempt that times out counts as a failed delivery and
is retried as [Retries](retries.md) describes. Set the value per endpoint in
[Configuration](configuration.md).
```

`docs/dead-letters.md`:

```markdown
# Dead letters

A delivery that has used up its attempts moves to the dead-letter queue, where
it is kept for seven days. How many attempts a delivery gets is set by
[the retry budget](retry-budget.md). To send a dead letter again, see
[Replaying](retries.md#replaying).
```

Run the docs gate before you hand it over, then write `report.md` in the repo root telling me whether the links on the two new pages resolve.
