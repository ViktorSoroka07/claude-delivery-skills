"""Reads the kept traces of this case and of plan-feature-prices-the-verifiers:
what the run said before it began spending and at its end, and what its
dispatches drew. A tool_used grader counts a refused call as a call, and the
skill gate refuses a rep's first dispatch until delegating-to-subagents loads,
so a dispatch here is classed by what its subagent wrote, and a refused or
unanswered one is counted apart. A verifier writes nothing, so it is classed by
its brief naming the role, before the review words are tried; every dispatch
that ran is listed with its description for the hand read that settles both.

Usage: python3 read-traces.py [--plan docs/plans/<plan>.md] <trace.jsonl>...
"""
import json
import re
import sys

REVIEW = re.compile(r"[Rr]eview|[Cc]old[ -]read|[Ff]resh[ -]eyes")
VERIFIER = re.compile(r"[Vv]erifier")
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


def is_verifier(brief):
    tool_input = json.loads(brief)
    return bool(VERIFIER.search(f"{tool_input.get('description', '')} {tool_input.get('prompt', '')}"))


def read(path, plan=PLAN):
    dispatches, outcome, drew = [], {}, {}
    before, cut, skills, own_svgs, last_text = [], False, [], 0, ""
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
            if event.get("type") == "assistant" and kind == "text":
                last_text = block.get("text") or ""
                if not cut:
                    before.append(last_text)
            if event.get("type") == "assistant" and kind == "tool_use":
                name, tool_input = block.get("name"), block.get("input") or {}
                if name == "Skill":
                    skills.append(tool_input.get("skill"))
                if name in ("Agent", "Task"):
                    cut = True
                    dispatches.append((block["id"], json.dumps(tool_input)))
                if name in ("Write", "Edit") and str(tool_input.get("file_path", "")).endswith(plan):
                    cut = True
                if svg_write(block):
                    own_svgs += 1
            if event.get("type") == "user" and kind == "tool_result":
                outcome[block.get("tool_use_id")] = bool(block.get("is_error"))
    ran = [(i, brief) for i, brief in dispatches if outcome.get(i) is False]

    def kind_of(i, brief):
        if drew.get(i):
            return "figure"
        if is_verifier(brief):
            return "verifier"
        return "review" if REVIEW.search(brief) else "other"

    classed = [(kind_of(i, brief), json.loads(brief)) for i, brief in ran]
    reviews = [tool_input for kind, tool_input in classed if kind == "review"]
    return {
        "skills": skills,
        "text_before_spending": " | ".join(t.strip() for t in before if t.strip()),
        "figure_dispatches": sum(1 for kind, _ in classed if kind == "figure"),
        "verifier_dispatches": sum(1 for kind, _ in classed if kind == "verifier"),
        "review_dispatches": len(reviews),
        "review_models": [review.get("model") or "inherited" for review in reviews],
        "other_dispatches": sum(1 for kind, _ in classed if kind == "other"),
        "refused_dispatches": sum(1 for i, _ in dispatches if outcome.get(i) is True),
        "unanswered_dispatches": sum(1 for i, _ in dispatches if i not in outcome),
        "svgs_drawn_by_the_session": own_svgs,
        "dispatches_that_ran": [
            [kind, tool_input.get("model") or "inherited", tool_input.get("description", "")]
            for kind, tool_input in classed
        ],
        "final_text": last_text.strip(),
    }


if __name__ == "__main__":
    args, plan = sys.argv[1:], PLAN
    if args[:1] == ["--plan"]:
        plan, args = args[1], args[2:]
    for path in args:
        try:
            print(path, json.dumps(read(path, plan)))
        except OSError as error:
            print(path, "unreadable:", error)
