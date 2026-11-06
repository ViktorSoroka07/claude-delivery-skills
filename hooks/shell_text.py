"""Shared reading of a shell command for the hooks that look for an act in one.

One definition, because heredoc bodies and quoted spans carry message text that
names acts without running them, and two copies of the blanking drift until one
hook reads as an act what its neighbour reads as a message.
"""
import os
import re

QUOTED = re.compile(r"\"[^\"]*\"|'[^']*'")
HEREDOC = re.compile(
    r"<<-?\s*(?P<q>[\"']?)(?P<tag>\w+)(?P=q)[^\n]*\n(?P<body>.*?)\n[ \t]*(?P=tag)[ \t]*(?=\n|$)",
    re.DOTALL,
)
ARG = re.compile(r"""\s*(?:"((?:[^"\\]|\\.)*)"|'([^']*)'|(\S+))""")
CD_ANCHOR = re.compile(r"(?:^|&&|;|\||\n)\s*cd(?=\s|$)")
C_ANCHOR = re.compile(r"\s-C(?=\s|$)")
PR_CREATE = re.compile(
    r"\bgh\b.*\bpr\s+create(?![-\w])"
    r"|\baz\b.*\brepos\s+pr\s+create(?![-\w])"
)


def git_verb(verb):
    """`git <verb>` behind any global options, and not a longer subcommand that
    starts with the verb (merge-base, commit-tree)."""
    return re.compile(r"\bgit(?:\s+-[\w-]+(?:=\S*)?|\s+-[Cc]\s+\S+)*\s+%s(?![-\w])" % verb)


def blank_body(m):
    start = m.start("body") - 1 - m.start()
    return m.group(0)[:start] + " " * (len(m.group(0)) - start)


def blank(command):
    """Heredoc bodies and quoted spans carry message text, which names acts
    without running them, while the rest of a heredoc's opening line is a
    command. Blanking keeps offsets, so a span found in the blanked text reads
    the same span of the original. Returns the command with its heredoc bodies
    blanked, then with its quoted spans blanked as well."""
    unfenced = HEREDOC.sub(blank_body, command)
    return unfenced, QUOTED.sub(lambda m: " " * len(m.group(0)), unfenced)


def argument_at(command, pos):
    """The shell word starting at `pos` with its quotes removed, '' for an
    empty quoted one, None where nothing follows."""
    a = ARG.match(command, pos)
    if not a:
        return None
    return next((g for g in a.groups() if g is not None), None)


def target_dir(command, stripped, match):
    """The directory the matched act runs in, None for the CWD, or '' where a
    directory the command names cannot be resolved here, which means nothing
    may be read on the act's behalf. Anchors are found in the stripped string
    so quoted text cannot fake structure; the argument is then read from the
    original at the same offset, which the length-preserving blanking
    guarantees is the right place."""
    cwd = None
    cds = [c for c in CD_ANCHOR.finditer(stripped) if c.start() < match.start()]
    if cds:
        d = argument_at(command, cds[-1].end())
        if not d:
            return ""
        cwd = os.path.expanduser(d)
    c = C_ANCHOR.search(stripped, match.start(), match.end())
    if c:
        d = argument_at(command, c.end())
        if not d:
            return ""
        d = os.path.expanduser(d)
        cwd = os.path.join(cwd, d) if cwd else d
    if cwd is not None and not os.path.isdir(cwd):
        return ""
    return cwd
