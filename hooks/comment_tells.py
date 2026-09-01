"""Shared detection for the two comment-discipline hooks.

One definition, because the write-time and commit-time hooks must agree on what
counts as a tell; two copies drift and the drift is invisible until one fires and
the other does not.
"""
import re

# Comment markers across the common languages the skill's corpus covered.
COMMENT_LINE = re.compile(r"^\s*(//|#(?!!)|/\*|\*|<!--|--)\s?(.*)")

# Draft-grep tells. Each must appear inside a comment line. `would` is on the
# skill's draft-grep list for narrative framing: a comment states what is true
# now, so a hypothetical is usually narrating the change - each hit is a
# candidate, not a verdict.
TELLS = re.compile(
    r"(Regression:|Locks in\b|used to\b|previously\b|without this\b|"
    r"\bwould\b|no longer\b|which is immaterial|harmless because|"
    r"acceptable since|does not matter here)",
    re.IGNORECASE,
)

# Files where prose is the content, not commentary - including patch files,
# whose lines are quoted text from someone else's change.
SKIP_SUFFIXES = (".md", ".markdown", ".txt", ".rst", ".adoc", ".json", ".lock", ".patch", ".diff")


def tells_in(lines):
    """Comment lines carrying a tell, trimmed for reporting. Each line carries
    exactly one diff marker; a greedier strip turns a patch file's quoted
    '+' lines into apparent comments."""
    return [ln[1:].strip()[:120] for ln in lines if COMMENT_LINE.match(ln[1:]) and TELLS.search(ln)]
