---
type: llm
criteria: |
  The session learned one trap: the invoice PDF renderer silently falls back to the default font when the font file path contains a space. Nothing in the repo records it, and it is an environment trap of the kind memory exists to hold.

  Pass only if exactly one new memory file under `store/projects/-home-dev-work-billing-console/memory/` records the trap with its boundary condition inside the imperative (a space in the font path triggers the fallback; check the path before rendering), and the index points at that file.

  Fail if the trap is recorded nowhere, recorded twice (a file and a second copy in the index body or another file), or recorded in a dead directory instead of the live one. Fail also if the new file narrates the session ("we found", "this session learned") rather than stating the trap.
