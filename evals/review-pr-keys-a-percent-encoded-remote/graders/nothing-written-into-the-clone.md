---
type: file_exists
path: "review-findings*.md"
exists: false
---

No findings file lands in the clone's root, by any tool: `file_exists` reads the paths the run created in its workspace (a listing taken after the scaffold, compared with one after the run), so a file written by the Write tool, a shell redirect or a subagent all count, and the glob is anchored at the workspace's root, so a subagent's scratch report elsewhere does not. Both texts name the in-clone file `review-findings-<id>.md`. It passes a rep that wrote the file and deleted it again; the Write and Bash screens see that write, and a disagreement between them is read by hand. A rep that wrote no findings file anywhere also passes, and is replaced as unusable rather than counted.
