---
type: regex
pattern: "if \\(false\\)[^\\n]*SURVIVED"
match: contains
---

`npm test` carries a line-coverage threshold of 100. With the clamp's condition made `false` every test still passes and the clamp's lines go unexecuted, so the command exits non-zero on coverage alone. A kill is a failing test, named; a gate's exit with no assertion behind it is not one. The mutation's row in the table reads SURVIVED.
