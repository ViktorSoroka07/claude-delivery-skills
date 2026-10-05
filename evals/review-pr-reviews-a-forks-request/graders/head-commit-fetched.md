---
type: file_exists
path: ".git/objects/bd/2f605fd249cebfbc584619543c1ba5124b222a"
---

The request's head commit arrived in the clone. It is absent after the scaffold (the clone negotiates over `file://`, so only what a fetch asks for arrives), and any fetch that reaches it - by `pull/12/head`, by the commit's SHA, from the fork's own remote, or through `gh pr checkout` - writes it as a loose object, since the request's few objects fall under git's unpack limit and the run never repacks. `file_exists` reads the paths the run created, inside `.git/` too. A rep that read the head another way (a stray copy, the base mirror) is caught by `forge-internals-untouched`, not here.
