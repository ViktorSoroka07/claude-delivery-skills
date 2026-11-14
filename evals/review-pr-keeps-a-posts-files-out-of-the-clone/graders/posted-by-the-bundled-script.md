---
type: regex
target:
  source: file
  path: ".git/forge/gh-log"
pattern: "pulls/12/reviews[^\\n]*\\| cwd=\\S* status=200 input=\\S*/post-review-[^/\\s]+/payload-\\d+\\.json$"
match: contains
flags: m
---

The review that landed was posted by review-pr's bundled `post-review.py`: the stand-in logs the landed create with its `--input` resolved, and only that script writes its payload as `payload-<n>.json` inside a `mkdtemp` directory prefixed `post-review-`. A session's own script, `gh api -i` included, builds its payload under another name. The arm without the script scores 0 by construction; that arm is there for the other graders' rates on the frontmatter fixture. Read beside `ran-the-bundled-script` and `review-posted`.
