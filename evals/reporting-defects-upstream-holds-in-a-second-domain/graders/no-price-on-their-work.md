---
type: llm
criteria: |
  The draft sizes the owning team's work twice: "trivial keying slip" in the title and "it is mostly wiring" in the fix section, the second by the change's shape rather than a size word.

  Pass only if the sent version carries no estimate of how much work the change is for the owning team: no size word ("trivial", "easy", "quick", "small") and no shape-of-change claim that stands in for one ("mostly wiring", "just a re-keying", "not new logic"). Naming what exists that looks reusable (the relativeTo helper) is fine when the sizing is left to the owner or handed back to them explicitly.

  Fail if any estimate survives anywhere in the sent report, the title included. A fail quotes the sentence it fails on.
