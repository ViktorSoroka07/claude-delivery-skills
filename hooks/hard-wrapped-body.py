#!/usr/bin/env python3
"""PreToolUse hook (Bash): warn when a body about to be sent to a forge is hard-wrapped or carries a token the forge deletes.

A forge renders every newline inside a paragraph as a line break, so a body
wrapped at a column arrives as chopped lines that never reflow. The skill says
so; this reads the body at the moment the command sends it - a pull request or
issue created or edited, or a comment on either, a pull request review's body,
or the closing comment of either, through gh; a pull request created or updated
through az - from wherever the command takes it - a body file, a command
substitution over one, a heredoc, a quoted literal - because that is the last
point before the text is public, and the one a session steered toward the shell
always passes. az's work-item description and discussion are not read for
wrapping: the CLI stores them in HTML fields, where a newline is whitespace and
a wrapped paragraph reflows.

The second check reads the same bodies, and those two work-item fields, for a
tag-shaped token: `<Name>` or `</Name>`, with or without attributes, whose name
is not an HTML element the forge keeps (`KEPT`). The forge's sanitizer takes it
for an unknown tag and deletes it, the send reports success, and readers see an
empty gap mid-sentence, as `Task<Result>` or a `<Id>` placeholder gives. Through
gh, text inside a code span or a fenced block is kept, so neither is read;
through az the token is read anywhere: a work-item field is stored as HTML,
and a pull request description, which renders Markdown, is read the same
way. An autolink and an HTML comment are not tokens. Both rules rest on what
a forge documents or a body was seen to lose, not on a send made from here.

Warn-only: a deliberate line break reads the same as a wrapped one, a token may
be meant as markup, and the skill owns the judgment. Fails open on any error -
a broken backstop must not block the send.
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from shell_text import CD_ANCHOR, HEREDOC, argument_at, blank  # noqa: E402

BODY_SEND = re.compile(
    r"\bgh\b[^|;&\n]*\b(?:(?:pr|issue)\s+(?:create|edit|comment)|pr\s+review"
    r"|(?P<close>(?:pr|issue)\s+close))(?![-\w])"
    r"|\baz\b[^|;&\n]*\brepos\s+pr\s+(?:create|update)(?![-\w])"
    r"|\baz\b[^|;&\n]*\bboards\s+work-item\s+(?:create|update)(?![-\w])"
)
WORK_ITEM = re.compile(r"\baz\b[^|;&\n]*\bboards\b")
FLAGS = {
    "gh": {"file": ("--body-file", "-F"), "text": (("--body", "-b"),)},
    "az": {"file": (), "text": (("--description", "-d"),)},
    "az item": {"file": (), "text": (("--description", "-d"), ("--discussion",))},
    "gh close": {"file": (), "text": (("--comment", "-c"),)},
}
CAT = re.compile(r"""^\s*\$\(\s*cat\s+(?:"([^"]*)"|'([^']*)'|(\S+))\s*\)\s*$""")

FENCE = re.compile(r"\s*(?:```|~~~)")
STRUCTURAL = re.compile(r"\s*(?:#|\||>|<|!\[|\[[^\]]*\]:)")
LIST_ITEM = re.compile(r"\s*(?:[-*+]|\d+[.)])\s")
ENDS_OPEN = re.compile(r"[A-Za-z0-9,;)`]$")
STARTS_LOWER = re.compile(r"\s*[a-z]")
SHOWN_TOKENS = 5

KEPT = frozenset(
    "a abbr b bdo blockquote br caption cite code dd del details dfn div dl dt em "
    "figcaption figure h1 h2 h3 h4 h5 h6 h7 h8 hr i img ins kbd li mark ol p picture "
    "pre q rp rt ruby s samp small source span strike strong sub summary sup table "
    "tbody td tfoot th thead time tr tt ul var wbr".split()
)
TAG = re.compile(r"<(/?)([A-Za-z][A-Za-z0-9-]*)(?=[\s/>])[^<>]*>")
HTML_COMMENT = re.compile(r"<!--.*?-->", re.DOTALL)
CODE_SPAN = re.compile(r"(?<!`)(`+)(?!`).*?(?<!`)\1(?!`)", re.DOTALL)


def flag_value(command, blanked, names):
    """The argument after the first of `names` found outside quotes, read
    from the original at the same offset, which the length-preserving
    blanking guarantees is the right place; None when no flag is present."""
    pattern = re.compile(r"(?<!\S)(?:%s)(?:=|\s)" % "|".join(re.escape(n) for n in names))
    m = pattern.search(blanked)
    if not m:
        return None
    return argument_at(command, m.end())


def read_file(path, blanked, cwd):
    """The file's text, or None where the path cannot be settled here: a
    variable in it, stdin, or a relative path behind a cd the command makes."""
    if not path or path == "-" or "$" in path:
        return None
    path = os.path.expanduser(path)
    if not os.path.isabs(path):
        if CD_ANCHOR.search(blanked):
            return None
        path = os.path.join(cwd or os.getcwd(), path)
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            return fh.read()
    except OSError:
        return None


def resolve(text, blanked, cwd):
    """The body a flag's value stands for: the value itself, or the file or
    heredoc a substitution in it reads; None where that cannot be settled."""
    cat = CAT.match(text)
    if cat:
        return read_file(cat.group(1) or cat.group(2) or cat.group(3), blanked, cwd)
    if "$(" in text:
        doc = HEREDOC.search(text)
        return doc.group("body") if doc else None
    return text


def body_of(command, cwd):
    """(body, forge, reflows) for the send the command makes, None where it
    makes none or its body cannot be read; reflows is true where the forge's
    field turns a newline into whitespace."""
    unfenced, blanked = blank(command)
    m = BODY_SEND.search(blanked)
    if not m:
        return None
    forge = "az" if blanked[m.start():m.start() + 2] == "az" else "gh"
    item = forge == "az" and bool(WORK_ITEM.match(blanked, m.start()))
    if item:
        flags = FLAGS["az item"]
    elif forge == "az":
        flags = FLAGS["az"]
    else:
        flags = FLAGS["gh close" if m.group("close") else "gh"]
    path = flag_value(command, blanked, flags["file"]) if flags["file"] else None
    if path is not None:
        body = read_file(path, blanked, cwd)
    else:
        parts = []
        for names in flags["text"]:
            text = flag_value(command, blanked, names)
            part = None if text is None else resolve(text, blanked, cwd)
            if part:
                parts.append(part)
        body = "\n\n".join(parts) if parts else None
    return None if body is None else (body, forge, item)


def dropped_tokens(text, forge):
    """The distinct tag-shaped tokens of the body whose element name the forge
    does not keep, as written without attributes, in order of appearance;
    through gh code spans and fenced blocks are not read, since they are kept."""
    text = HTML_COMMENT.sub("", text)
    if forge == "gh":
        lines = []
        fenced = False
        for line in text.splitlines():
            if FENCE.match(line):
                fenced = not fenced
            elif not fenced:
                lines.append(line)
        text = CODE_SPAN.sub("", "\n".join(lines))
    found = []
    for m in TAG.finditer(text):
        if m.group(2).lower() not in KEPT:
            token = "<%s%s>" % (m.group(1), m.group(2))
            if token not in found:
                found.append(token)
    return found


def wrapped_joins(text):
    """Line numbers of each line that continues the sentence the line above
    left open: the one above ends on a word or a comma, this one starts
    lowercase and starts no list item. Fenced code, headings, tables, quotes
    and HTML are not paragraphs, and neither is a blank line's neighbour."""
    joins = []
    fenced = False
    prev = None
    for n, line in enumerate(text.splitlines(), 1):
        if FENCE.match(line):
            fenced = not fenced
            prev = None
            continue
        if fenced or not line.strip() or STRUCTURAL.match(line):
            prev = None
            continue
        if (prev is not None and ENDS_OPEN.search(prev.rstrip())
                and STARTS_LOWER.match(line) and not LIST_ITEM.match(line)):
            joins.append(n)
        prev = line
    return joins


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0
    if payload.get("tool_name") != "Bash":
        return 0
    command = (payload.get("tool_input", {}) or {}).get("command", "") or ""
    try:
        send = body_of(command, payload.get("cwd"))
        if not send or not send[0]:
            return 0
        body, forge, reflows = send
        joins = [] if reflows else wrapped_joins(body)
        tokens = dropped_tokens(body, forge)
    except Exception:
        return 0
    if not joins and not tokens:
        return 0

    shown = ", ".join("`%s`" % t for t in tokens[:SHOWN_TOKENS]) + (
        ", and %d more" % (len(tokens) - SHOWN_TOKENS) if len(tokens) > SHOWN_TOKENS else "")
    system, context = [], []
    if joins:
        system.append("the body carries %d hard-wrapped line(s), first at line %d." % (len(joins), joins[0]))
        context.append(
            "%d line(s) of the body (first at line %d) continue a sentence the line above left "
            "open. The forge renders every newline inside a paragraph as a line break, so "
            "the paragraph arrives as chopped lines that never reflow. Join each wrapped "
            "paragraph or list item into one line before sending; each list item still "
            "starts its own line, and a table row or a code block keeps its lines."
            % (len(joins), joins[0])
        )
    if tokens:
        system.append("the body carries %s, a tag-shaped token the forge may delete." % shown)
        context.append(
            "The body carries %s. The forge's sanitizer takes a tag-shaped token for an HTML "
            "element it does not keep and deletes it, and the send still reports success, so "
            "readers meet an empty gap mid-sentence. Write each one without the angle brackets, "
            "or as &lt;Name&gt;, then read the stored body back to see what the forge kept."
            % shown
        )
    sys.stdout.write(json.dumps({
        "systemMessage": "writing-pr-descriptions backstop: " + " ".join(system) + " Not blocked.",
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "additionalContext": "\n\n".join(context),
        },
    }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
