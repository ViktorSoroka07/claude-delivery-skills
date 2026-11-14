#!/usr/bin/env python3
"""Mutation harness for post-review.py.

    python3 mutate.py            # every mutation
    python3 mutate.py NAME ...   # the named ones

Each mutation must find its text exactly once and change the file, the suite
must then fail on the mutation's target assertion, and the script is restored
byte-identical before the next one.
"""

import hashlib
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SCRIPT = os.path.join(HERE, "post-review.py")
SUITE = os.path.join(HERE, "test_post_review.py")

# (name, text to find, replacement, target assertion)
NO_CREATE = ": no create reached the stand-in"

MUTATIONS = [
    ("vocab-entry-dropped",
     '"NO-STATE", "SETTLING",',
     '"NO-STATE",',
     "the status vocabulary matches the expected list"),

    # Task 2: every refusal dies on the assertion that no create was attempted,
    # since for several checks the forge's own refusal would end the run anyway.
    ("unknown-fields-ignored",
     "    unknown = sorted(set(obj) - allowed)\n",
     "    unknown = []\n",
     "a misspelled start_line" + NO_CREATE),
    ("duplicate-key-check-dropped",
     "        if thread.key in keys:",
     "        if False:",
     "a key given twice" + NO_CREATE),
    ("keys-compared-case-insensitively",
     "        if thread.key in keys:",
     "        if thread.key.lower() in {k.lower() for k in keys}:",
     "case-distinct keys: both threads land and read back as sent"),
    ("placeholder-read-as-null",
     "    if bare in NULL_VALUES or repost:",
     "    if bare in NULL_VALUES or repost or PLACEHOLDER in bare:",
     "a posted: line holding the placeholder" + NO_CREATE),
    ("missing-frontmatter-read-as-null",
     "    value = posted_value(text)\n",
     '    value = posted_value(text) or "null"\n',
     "a findings file without frontmatter" + NO_CREATE),
    ("head-read-from-the-clone",
     "    if head != manifest.reviewed_sha:",
     '    if git("rev-parse", "HEAD").decode().strip() != manifest.reviewed_sha:',
     "a forge head moved past the local clone" + NO_CREATE),
    ("file-set-skipped-on-ado",
     "        if t.path not in head.files:",
     '        if t.path not in head.files and manifest.forge != "ado":',
     "an ADO thread on a file outside the diff" + NO_CREATE),
    ("line-exists-skipped",
     "        if t.line > len(head_lines(head, t.path)):",
     "        if False:",
     "an ADO thread past the end of its file" + NO_CREATE),
    ("changed-line-check-skipped",
     "            off = [n for n in range(t.first_line, t.line + 1) if n not in changed]",
     "            off = []",
     "a GitHub thread on an unchanged line" + NO_CREATE),
    ("suggestion-compared-after-strip",
     "        if actual != wanted:",
     "        if [a.strip() for a in actual] != [w.strip() for w in wanted]:",
     "a suggestion whose lines differ only in leading whitespace" + NO_CREATE),
    ("suggestion-in-group-dropped",
     "        if t.suggestion is not None and len(t.members) > 1:",
     "        if False:",
     "a multi-member compact thread with a suggestion" + NO_CREATE),
    ("partition-dropped",
     "        if t.path is None and inside:",
     "        if False:",
     "a request-level compact thread with an in-diff member" + NO_CREATE),
    ("pending-check-skipped",
     "    if not manifest.pending:\n        return\n",
     "    if True:\n        return\n",
     "a pending review of the user's already on the request" + NO_CREATE),
    ("no-token-check-skipped",
     '    if manifest.forge == "ado" and not transport.token:',
     "    if False:",
     "an ADO run without the token variable makes no call"),

    # Task 3: post, classify and read back.
    ("reply-parsed-strictly",
     "            return json.loads(candidate, strict=False)",
     "            return json.loads(text)",
     "a malformed ADO create reply: the record holds the ids the forge gave"),
    ("success-keyed-off-the-parse",
     "    if 200 <= reply.status < 300:",
     "    if parse_reply(reply.body) is not None:",
     "a 400 on the third ADO thread: threads past it are never sent"),
    ("continued-after-a-4xx",
     '        record.event("rejected", key, reply.status)\n',
     '        record.event("rejected", key, reply.status)\n        return None\n',
     "a 400 on the third ADO thread: threads past it are never sent"),
    ("offset-in-code-points",
     '    return len(text.encode("utf-16-le")) // 2 + 1',
     "    return len(text) + 1",
     "an ADO suggestion over an astral character and CRLF: the stored payload spans the literal "
     "UTF-16 offset"),
    ("offset-in-bytes",
     '    return len(text.encode("utf-16-le")) // 2 + 1',
     '    return len(text.encode("utf-8")) + 1',
     "an ADO suggestion over an astral character and CRLF: the stored payload spans the literal "
     "UTF-16 offset"),
    ("cr-kept-in-span",
     '    text = raw_line.decode("utf-8").rstrip("\\r")',
     '    text = raw_line.decode("utf-8")',
     "an ADO suggestion over an astral character and CRLF: the stored payload spans the literal "
     "UTF-16 offset"),
    ("minimal-anchor-on-a-suggestion",
     "    end = ado_end_offset(head_lines(head, t.path)[t.line - 1]) if t.suggestion else 2",
     "    end = 2",
     "the ADO happy path: the stored payloads match the literals"),
    ("start-side-omitted",
     '                comment["start_side"] = "RIGHT"\n',
     "",
     "the GitHub happy path: the stored payload matches the literal"),
    ("leading-slash-dropped",
     '    return {"filePath": "/" + t.path,',
     '    return {"filePath": t.path,',
     "the ADO happy path: the stored payloads match the literals"),
    ("first-page-only",
     """            if 'rel="next"' not in reply.headers.get("link", ""):""",
     "            if True:",
     "a GitHub review whose comments run past one page: the run reads back clean"),
    ("placement-only-compared",
     "    if body_stored != body_sent:",
     "    if False:",
     "a sanitizer dropping <Id> on ADO: the run stops MISMATCH"),
    ("body-only-compared",
     "    if place_stored != place_sent:",
     "    if False:",
     "an ADO read-back reporting another line: the run stops MISPLACED"),
    ("plain-run-ignores-an-unfinished-record",
     "    if record is not None and record.unfinished():",
     "    if False:",
     "a plain re-run after the ADO 400: no further create reached the stand-in"),
]


def digest(data):
    return hashlib.sha256(data).hexdigest()


def run_suite():
    proc = subprocess.run([sys.executable, SUITE], capture_output=True, timeout=1800)
    return proc.returncode, proc.stdout.decode("utf-8", "replace")


def apply(original, find, replace):
    text = original.decode("utf-8")
    count = text.count(find)
    if count != 1:
        return None, "the target text appears %d times, expected 1" % count
    mutated = text.replace(find, replace).encode("utf-8")
    if mutated == original:
        return None, "the edit did not change the file"
    return mutated, ""


def mutate(original, name, find, replace, target):
    print("\n%s\n  target assertion: %s" % (name, target))
    mutated, problem = apply(original, find, replace)
    if mutated is None:
        print("  NOT APPLIED %s; the mutation proves nothing" % problem)
        return "misfired"
    try:
        with open(SCRIPT, "wb") as f:
            f.write(mutated)
        rc, out = run_suite()
    finally:
        with open(SCRIPT, "wb") as f:
            f.write(original)
    failures = [line.strip()[len("FAIL "):] for line in out.splitlines() if line.strip().startswith("FAIL ")]
    if rc == 0:
        print("  SURVIVED the suite still passes with the check broken")
        return "survived"
    if target in failures:
        print("  KILLED by: %s" % target)
        return "killed"
    print("  WRONG REASON the suite failed, but not on the target assertion:")
    for line in failures[:5]:
        print("    %s" % line)
    return "misfired"


def main(names):
    with open(SCRIPT, "rb") as f:
        original = f.read()
    known = {m[0] for m in MUTATIONS}
    unknown = [n for n in names if n not in known]
    if unknown:
        print("unknown mutation: %s" % ", ".join(unknown))
        return 2
    rc, out = run_suite()
    if rc != 0:
        print("baseline: red - fix the suite before mutating")
        return 2
    print("baseline: green")
    tally = {"killed": 0, "survived": 0, "misfired": 0}
    for name, find, replace, target in MUTATIONS:
        if names and name not in names:
            continue
        tally[mutate(original, name, find, replace, target)] += 1
        with open(SCRIPT, "rb") as f:
            if digest(f.read()) != digest(original):
                print("  RESTORE FAILED the script is not byte-identical to the original")
                return 2
    print("\n%(killed)d killed, %(survived)d survived, %(misfired)d misfired" % tally)
    return 0 if tally["survived"] == tally["misfired"] == 0 else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
