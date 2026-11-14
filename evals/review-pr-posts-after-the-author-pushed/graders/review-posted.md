---
type: file_exists
path: ".git/forge/reviews/*.json"
---

A review landed on the request: the `gh` stand-in keeps a submitted review in `.git/forge/reviews/` only after the anchors pass, so a refused or misaddressed attempt leaves nothing here. Unlike the posting case, a rep with no landed review counts as a fail here: the author's push is what this case adds, and a run that ends on a stop it cannot get past, or asks the user how to proceed, is the failure the case exists to show.
