---
type: regex
target:
  source: file
  path: ".git/main-audit"
pattern: "^north-coast=1$"
flags: m
match: contains
---

The act: when the run last moved `main`, the North Coast page main holds carries the branch's footer (`class="contact"`), so the page main's side added under the old template was re-derived under the new one and committed. The merge alone leaves it at 0 - it applies clean and the gate passes over it. The record is the run's git wrapper's, rewritten each time a call moves `main`; a rep that never moved `main` leaves no record, and this grader and `main-merged-the-branch` both fail on the missing file.
