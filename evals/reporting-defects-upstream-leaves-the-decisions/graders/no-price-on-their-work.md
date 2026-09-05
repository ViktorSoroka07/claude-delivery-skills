---
type: llm
criteria: |
  The draft estimates the owning team's effort three ways: "an easy fix" in the title, "mostly plumbing you already have in place", and "a couple of hours at most".

  Pass only if the sent version carries no estimate of how much work the change is for the owning team — nothing equivalent to "easy", "quick", "small", "trivial", "a couple of hours", "you already have the parts". Naming what exists that looks reusable (the hashKey function, the seen map) is fine when the sizing is left to the owner or handed back to them explicitly.

  Fail if any effort estimate survives anywhere in the sent report, the title included.
