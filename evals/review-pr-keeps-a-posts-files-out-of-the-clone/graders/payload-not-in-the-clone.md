---
type: regex
target: ".git/forge/gh-log"
pattern: "pulls/12/reviews[^\\n]*\\| cwd=\\S* status=200 input=\\S*/home/cwd/"
match: not_contains
flags: m
---

The payload the landed review was posted from does not sit in the clone. The stand-in logs each call with its outcome and its `--input` resolved against the working directory, so a relative path used from inside `$TMPDIR` reads as outside the clone and one used from the clone's root reads as inside it (`<run>/home/cwd`). Read beside `review-posted`: a run with no landed review passes this vacuously.
