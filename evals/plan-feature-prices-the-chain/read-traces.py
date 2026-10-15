"""Reads this case's kept traces: what the run said before it began spending,
and what its dispatches drew. A tool_used grader counts a refused call as a
call, and the skill gate refuses a rep's first dispatch until
delegating-to-subagents loads, so a dispatch here is classed by what its
subagent wrote, and a refused or unanswered one is counted apart.

Usage: python3 read-traces.py <trace.jsonl>...
"""
import json
import re
import sys

REVIEW = re.compile(r"[Rr]eview|[Cc]old[ -]read|[Ff]resh[ -]eyes")
PLAN = "docs/plans/task-102.md"


def blocks(event):
    message = event.get("message")
    content = message.get("content") if isinstance(message, dict) else None
    return [b for b in content if isinstance(b, dict)] if isinstance(content, list) else []


SHELL_SVG_WRITE = re.compile(r"(?:>|\btee(?:\s+-a)?)\s*['\"]?[^\s;&|'\"]*\.svg\b")


def svg_write(block):
    if block.get("type") != "tool_use":
        return False
    tool_input = block.get("input") or {}
    if block.get("name") in ("Write", "Edit", "NotebookEdit"):
        return str(tool_input.get("file_path", "")).endswith(".svg")
    if block.get("name") == "Bash":
        return bool(SHELL_SVG_WRITE.search(str(tool_input.get("command", ""))))
    return False


def read(path):
    dispatches, outcome, drew = [], {}, {}
    before, cut, skills, own_svgs = [], False, [], 0
    for line in open(path, encoding="utf-8", errors="replace"):
        try:
            event = json.loads(line)
        except ValueError:
            continue
        parent = event.get("parent_tool_use_id")
        for block in blocks(event):
            if parent:
                if svg_write(block):
                    drew[parent] = True
                continue
            kind = block.get("type")
            if event.get("type") == "assistant" and kind == "text" and not cut:
                before.append(block.get("text") or "")
            if event.get("type") == "assistant" and kind == "tool_use":
                name, tool_input = block.get("name"), block.get("input") or {}
                if name == "Skill":
                    skills.append(tool_input.get("skill"))
                if name in ("Agent", "Task"):
                    cut = True
                    dispatches.append((block["id"], json.dumps(tool_input)))
                if name in ("Write", "Edit") and str(tool_input.get("file_path", "")).endswith(PLAN):
                    cut = True
                if svg_write(block):
                    own_svgs += 1
            if event.get("type") == "user" and kind == "tool_result":
                outcome[block.get("tool_use_id")] = bool(block.get("is_error"))
    ran = [(i, brief) for i, brief in dispatches if outcome.get(i) is False]
    reviews = [json.loads(brief) for i, brief in ran if not drew.get(i) and REVIEW.search(brief)]
    return {
        "skills": skills,
        "text_before_spending": " | ".join(t.strip() for t in before if t.strip()),
        "figure_dispatches": sum(1 for i, _ in ran if drew.get(i)),
        "review_dispatches": len(reviews),
        "review_models": [review.get("model") or "inherited" for review in reviews],
        "other_dispatches": sum(1 for i, brief in ran if not drew.get(i) and not REVIEW.search(brief)),
        "refused_dispatches": sum(1 for i, _ in dispatches if outcome.get(i) is True),
        "unanswered_dispatches": sum(1 for i, _ in dispatches if i not in outcome),
        "svgs_drawn_by_the_session": own_svgs,
    }


if __name__ == "__main__":
    for path in sys.argv[1:]:
        try:
            print(path, json.dumps(read(path)))
        except OSError as error:
            print(path, "unreadable:", error)
