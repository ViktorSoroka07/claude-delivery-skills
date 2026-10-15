"""Shared reading of a shell command for the hooks that look for an act in one.

One definition, because heredoc bodies and quoted spans carry message text that
names acts without running them, and two copies of the blanking drift until one
hook reads as an act what its neighbour reads as a message.
"""
import re

QUOTED = re.compile(r"\"[^\"]*\"|'[^']*'")
HEREDOC = re.compile(
    r"<<-?\s*(?P<q>[\"']?)(?P<tag>\w+)(?P=q)[^\n]*\n(?P<body>.*?)\n[ \t]*(?P=tag)[ \t]*(?=\n|$)",
    re.DOTALL,
)
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
