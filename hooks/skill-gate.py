#!/usr/bin/env python3
"""PreToolUse hook (Bash, Write, Edit, Agent): stop an act once until the
skill that owns it is loaded.

A skill the user does not invoke by name loads only when the model decides to:
reliably only where the request names its work, and not always then. A commit,
a pull request, a memory write or a subagent dispatch the session chooses on
its own names no such work, and in the sessions behind this repo most of those
that committed or wrote memory did so with the owning skill unread, as did
five of the thirteen that opened a pull request. Context added here arrives
beside the call's result, one act too late for a commit whose message is
already in the command, so the gate stops the call instead: once per act per
conversation, with a reason naming the skill, so the session loads it and runs
the act again, rewritten where the skill changes it. A session that declines
the skill loses one turn.

A subagent's hook input carries its parent's session and transcript plus its
own agent_id. Its own transcript sits beside the parent's, and its state is
keyed apart, so a skill the parent loaded does not count for a subagent that
never read it, and the parent's one stop does not let the subagent's act
through. That transcript path is observed, not documented: where it is absent
the gate finds no load and stops once per act, and never blocks.

Fails open on any error, and wherever the stop cannot be recorded: a stop not
remembered repeats on every retry, which is a block.
"""
import json
import os
import re
import shlex
import sys
import tempfile

QUOTED = re.compile(r"\"[^\"]*\"|'[^']*'")
HEREDOC = re.compile(
    r"<<-?\s*(?P<q>[\"']?)(?P<tag>\w+)(?P=q)[^\n]*\n(?P<body>.*?)\n[ \t]*(?P=tag)[ \t]*(?=\n|$)",
    re.DOTALL,
)
SEPARATOR = re.compile(r"[|;&\n]")

GIT_COMMIT = re.compile(r"\bgit(?:\s+-[\w-]+(?:=\S*)?|\s+-[Cc]\s+\S+)*\s+commit(?![-\w])")
PR_CREATE = re.compile(
    r"\bgh\b.*\bpr\s+create(?![-\w])"
    r"|\baz\b.*\brepos\s+pr\s+create(?![-\w])"
)
INERT = re.compile(r"--help\b|\s-h\b|--dry-run\b")
MEMORY_PATH = re.compile(r"/\.claude/projects/[^/\s\"']+/memory(?:/|$)")
REDIRECT = re.compile(r">>?")
IN_PLACE = re.compile(r"\b(?:sed|perl)\b.*\s(?:-[a-zA-Z]*i\b|--in-place\b)")
COPY = re.compile(r"\b(?:mv|cp|tee)\b")

ACTS = {
    "commit": ("writing-commit-messages", "this commit"),
    "pr": ("writing-pr-descriptions", "this pull request"),
    "memory": ("maintaining-project-memory", "this memory write"),
    "dispatch": ("delegating-to-subagents", "this subagent dispatch"),
}


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


def writes_memory(raw, stripped):
    for m in REDIRECT.finditer(stripped):
        rest = raw[m.end():].split(None, 1)
        if rest and MEMORY_PATH.search(rest[0]):
            return True
    if IN_PLACE.search(stripped) and MEMORY_PATH.search(raw):
        return True
    copy = COPY.search(stripped)
    if copy:
        try:
            words = shlex.split(raw[copy.start():])
        except ValueError:
            return False
        args = [w for w in words[1:] if not w.startswith("-")]
        if words[0] == "tee":
            return any(MEMORY_PATH.search(a) for a in args)
        return len(args) >= 2 and bool(MEMORY_PATH.search(args[-1]))
    return False


def acts_of(payload):
    tool = payload.get("tool_name")
    tool_input = payload.get("tool_input")
    if not isinstance(tool_input, dict):
        return []
    if tool == "Agent":
        return ["dispatch"]
    if tool in ("Write", "Edit"):
        return ["memory"] if MEMORY_PATH.search(tool_input.get("file_path") or "") else []
    if tool != "Bash":
        return []
    command, stripped = blank(tool_input.get("command") or "")
    acts = []
    start = 0
    for end in [m.start() for m in SEPARATOR.finditer(stripped)] + [len(stripped)]:
        seg, raw = stripped[start:end], command[start:end]
        start = end + 1
        if INERT.search(seg):
            continue
        if GIT_COMMIT.search(seg):
            acts.append("commit")
        if PR_CREATE.search(seg):
            acts.append("pr")
        if writes_memory(raw, seg):
            acts.append("memory")
    return sorted(set(acts), key=list(ACTS).index)


def own_transcript(payload):
    path = payload.get("transcript_path") or ""
    agent = payload.get("agent_id")
    if path and agent:
        base = path[:-len(".jsonl")] if path.endswith(".jsonl") else path
        return os.path.join(base, "subagents", "agent-%s.jsonl" % agent)
    return path


def skill_loaded(transcript, skill):
    call = re.compile(r'"skill"\s*:\s*"(?:[\w-]+:)?%s"' % re.escape(skill))
    slash = re.compile(r"<command-name>/?(?:[\w-]+:)?%s</command-name>" % re.escape(skill))
    try:
        with open(transcript, encoding="utf-8", errors="replace") as fh:
            for line in fh:
                if skill in line and (call.search(line) or slash.search(line)):
                    return True
    except OSError:
        return False
    return False


def stand_aside_file(payload, act):
    key = "%s-%s-%s" % (payload.get("session_id"), payload.get("agent_id") or "main", act)
    return os.path.join(tempfile.gettempdir(), "delivery-skills-gate", re.sub(r"[^\w.-]", "_", key)[:160])


def record(path):
    try:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w") as fh:
            fh.write("done\n")
        return True
    except OSError:
        return False


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0
    if not isinstance(payload, dict) or not payload.get("session_id"):
        return 0
    transcript = own_transcript(payload)
    stops = []
    for act in acts_of(payload):
        flag = stand_aside_file(payload, act)
        if os.path.exists(flag):
            continue
        if skill_loaded(transcript, ACTS[act][0]):
            record(flag)
            continue
        if record(flag):
            stops.append(act)
    if not stops:
        return 0
    if len(stops) == 1:
        skill, what = ACTS[stops[0]]
        why = ("%s once, because `delivery-skills:%s` owns it and this conversation has not "
               "loaded it. Call the Skill tool with `delivery-skills:%s`, follow it, then run the "
               "act again - rewritten where the skill changes it." % (what, skill, skill))
    else:
        owners = " and ".join("`delivery-skills:%s` owns %s" % ACTS[a] for a in stops)
        why = ("this command once, because %s, and this conversation has loaded none of them. "
               "Call the Skill tool with each, follow them, then run the command again - "
               "rewritten where the skills change it." % owners)
    sys.stdout.write(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": (
                "Not an error: delivery-skills stops %s The gate stands aside for the rest of "
                "the conversation; where no Skill tool is available, run the act again as it "
                "was." % why
            ),
        }
    }))
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        sys.exit(0)
