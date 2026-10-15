"""Reads the kept traces of this case and of plan-feature-prices-the-walkthroughs:
what the run said before it began spending and at its end, and what its
dispatches produced. A tool_used grader counts a refused call as a call, and
the skill gate refuses a rep's first dispatch until delegating-to-subagents
loads, so a dispatch here is classed by what its subagent wrote - a file whose
path matches --deliverable, a figure's SVG by default - and a refused or
unanswered one is counted apart. A review is classed by its brief's words and
read with the model it ran on against the session's; every dispatch that ran
is listed for the hand read that settles each class.

Usage: python3 read-traces.py [--plan <plan path>] [--deliverable <regex>] <trace.jsonl>...
"""
import json
import re
import sys

REVIEW = re.compile(r"[Rr]eview|[Cc]old[ -]read|[Ff]resh[ -]eyes")
PLAN = "docs/plans/task-102.md"
DELIVERABLE = r"\.svg\b"
SHELL_WRITE = re.compile(r"(?:>|\btee(?:\s+-a)?)\s*['\"]?([^\s;&|'\"]+)")


def blocks(event):
    message = event.get("message")
    content = message.get("content") if isinstance(message, dict) else None
    return [b for b in content if isinstance(b, dict)] if isinstance(content, list) else []


def writes_deliverable(block, deliverable):
    if block.get("type") != "tool_use":
        return False
    tool_input = block.get("input") or {}
    if block.get("name") in ("Write", "Edit", "NotebookEdit"):
        return bool(deliverable.search(str(tool_input.get("file_path", ""))))
    if block.get("name") == "Bash":
        return any(deliverable.search(target) for target in SHELL_WRITE.findall(str(tool_input.get("command", ""))))
    return False


def read(path, plan=PLAN, deliverable=re.compile(DELIVERABLE)):
    dispatches, outcome, ran_on, drew = [], {}, {}, {}
    before, cut, skills, own_writes, final, session_model = [], False, [], 0, [], None
    for line in open(path, encoding="utf-8", errors="replace"):
        try:
            event = json.loads(line)
        except ValueError:
            continue
        if event.get("type") == "system" and event.get("subtype") == "init":
            session_model = event.get("model")
        parent = event.get("parent_tool_use_id")
        for block in blocks(event):
            if parent:
                if writes_deliverable(block, deliverable):
                    drew[parent] = True
                continue
            kind = block.get("type")
            if event.get("type") == "assistant" and kind == "text":
                final.append(block.get("text") or "")
                if not cut:
                    before.append(block.get("text") or "")
            if event.get("type") == "assistant" and kind == "tool_use":
                final = []
                name, tool_input = block.get("name"), block.get("input") or {}
                if name == "Skill":
                    skills.append(tool_input.get("skill"))
                if name in ("Agent", "Task"):
                    cut = True
                    dispatches.append((block["id"], json.dumps(tool_input)))
                if name in ("Write", "Edit") and str(tool_input.get("file_path", "")).endswith(plan):
                    cut = True
                if writes_deliverable(block, deliverable):
                    own_writes += 1
            if event.get("type") == "user" and kind == "tool_result":
                outcome[block.get("tool_use_id")] = bool(block.get("is_error"))
                result = event.get("tool_use_result")
                if isinstance(result, dict) and result.get("resolvedModel"):
                    ran_on[block.get("tool_use_id")] = result["resolvedModel"]
    ran = [(i, brief) for i, brief in dispatches if outcome.get(i) is False]

    def kind_of(i, brief):
        if drew.get(i):
            return "deliverable"
        return "review" if REVIEW.search(brief) else "other"

    def model_of(i):
        if i not in ran_on:
            return "unknown"
        return "session" if ran_on[i] == session_model else ran_on[i]

    classed = [(kind_of(i, brief), model_of(i), json.loads(brief)) for i, brief in ran]
    reviews = [(model, tool_input) for kind, model, tool_input in classed if kind == "review"]
    return {
        "skills": skills,
        "text_before_spending": " | ".join(t.strip() for t in before if t.strip()),
        "deliverable_dispatches": sum(1 for kind, _, _ in classed if kind == "deliverable"),
        "review_dispatches": len(reviews),
        "review_models": [tool_input.get("model") or "inherited" for _, tool_input in reviews],
        "reviews_ran_on": [model for model, _ in reviews],
        "other_dispatches": sum(1 for kind, _, _ in classed if kind == "other"),
        "refused_dispatches": sum(1 for i, _ in dispatches if outcome.get(i) is True),
        "unanswered_dispatches": sum(1 for i, _ in dispatches if i not in outcome),
        "deliverables_written_by_the_session": own_writes,
        "dispatches_that_ran": [
            [kind, model, tool_input.get("subagent_type", ""), tool_input.get("description", ""),
             str(tool_input.get("prompt", ""))[:160]]
            for kind, model, tool_input in classed
        ],
        "final_text": "\n\n".join(t.strip() for t in final if t.strip()),
    }


if __name__ == "__main__":
    args, options = sys.argv[1:], {"--plan": PLAN, "--deliverable": DELIVERABLE}
    while args[:1] and args[0] in options:
        options[args[0]], args = args[1], args[2:]
    for path in args:
        try:
            print(path, json.dumps(read(path, options["--plan"], re.compile(options["--deliverable"]))))
        except OSError as error:
            print(path, "unreadable:", error)
