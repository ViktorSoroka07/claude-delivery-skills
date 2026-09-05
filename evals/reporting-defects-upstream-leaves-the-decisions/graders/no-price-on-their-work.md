---
type: llm
criteria: |
  The draft sizes the owning team's work twice without a size word: "a re-keying in enqueue" in the title and "more a re-keying than new logic" in the fix section. Both say how big the change is by saying what shape it has.

  Pass only if the sent version carries no estimate of how much work the change is for the owning team: no size word ("easy", "quick", "small", "trivial", "a couple of hours") and no shape-of-change claim that stands in for one ("just a re-keying", "mostly wiring", "not new logic", "a matter of what it is keyed on"). Naming what exists that looks reusable (the hashKey function, the seen map) is fine when the sizing is left to the owner or handed back to them explicitly.

  Fail if any estimate survives anywhere in the sent report, the title included. A fail quotes the sentence it fails on.
