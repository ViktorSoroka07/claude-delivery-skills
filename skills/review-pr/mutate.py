#!/usr/bin/env python3
"""Mutation harness for post-review.py.

    python3 mutate.py            # every mutation
    python3 mutate.py NAME ...   # the named ones

Each mutation must find its text exactly once and change the file, the test
holding the mutation's target assertion must then fail on it, and the script is
restored byte-identical before the next one. Only that test runs per mutation;
which test holds each assertion is read off the baseline run of the whole suite.
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
     "a findings file without frontmatter: the run stops NO-FRONTMATTER"),
    ("findings-request-unchecked",
     '    expected = [("pr", str(manifest.request)),\n',
     "    expected = [\n",
     "a findings file of another request" + NO_CREATE),
    ("findings-head-unchecked",
     '                ("reviewed_sha", manifest.reviewed_sha)]',
     "                ]",
     "a findings file of another head" + NO_CREATE),
    ("findings-key-missing-passes",
     "        if got != want:",
     "        if got is not None and got != want:",
     "a findings file without reviewed_sha" + NO_CREATE),
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
     '        record.event("rejected", key, reply.status)\n        return True\n',
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
     "a sanitizer dropping <Id> again after the PATCH: the run stops MISMATCH"),
    ("body-only-compared",
     "    if place_stored != place_sent:",
     "    if False:",
     "an ADO read-back reporting another line: the run stops MISPLACED"),
    ("plain-run-ignores-an-unfinished-record",
     "    if record is not None and record.unfinished():",
     "    if False:",
     "a plain re-run after the ADO 400: no further create reached the stand-in"),

    # Task 4: lost answers, resume and the settle window.
    ("retried-once-after-a-lost-answer",
     "    reply = create()\n    outcome = classify_create(reply)\n",
     "    reply = create()\n    if classify_create(reply) == \"uncertain\":\n        reply = create()\n"
     "    outcome = classify_create(reply)\n",
     "a 502 whose create landed at once: the stand-in holds one copy of each thread"),
    ("lost-answer-not-read-back",
     "        absent = reconcile(forge, head, record, sent)",
     "        absent = [key]",
     "a 502 whose create landed at once: the run reads back clean"),
    ("resume-ignores-the-settle-window",
     "    if left > 0:",
     "    if False:",
     "a resume inside the settle window: the run stops SETTLING"),
    ("resume-skips-the-read-back",
     "        todo = reconcile(forge, head, record, keys)",
     "        todo = [k for k in keys if k not in record.landed_ids()]",
     "a create that hangs past the timeout and lands later: the resume after the window posts nothing"),
    ("paired-on-exact-body-only",
     "              lambda w, i: i.anchor == w.anchor)",
     "              lambda w, i: False)",
     "a 502 whose create landed with a sanitized body: the record pairs it with the forge's id"),
    ("unpaired-item-let-pass",
     "    if free:",
     "    if False:",
     "the lost original landing after the resume's post: the run stops UNCERTAIN"),
    ("sending-line-dropped",
     '    record.event("sending", key, time.time())\n',
     "",
     "a run killed after its create landed: a plain re-run sends no further create"),
    ("failed-read-back-treated-as-empty",
     '        raise Stop("UNVERIFIED", "%s could not be read: %s" % (what, reply.describe()))',
     "        return [], reply",
     "a read-back failing four times: the run stops UNVERIFIED"),
    ("window-counts-every-call",
     '        times = [e[2] for e in self.last_events().values() if e[0] in ("sending", "uncertain")]',
     '        times = [self.data["started"]]',
     "a resume at once after the ADO 400, with no call in doubt: the run reads back clean"),
    ("by-id-read-skipped",
     "            item = by_id(created)",
     "            item = None",
     "a thread missing from the list but readable by id: the run reads back clean"),
    ("latest-reviews-unchecked",
     '        if not record.ever("uncertain", "review"):',
     "        if True:",
     "a GitHub 502 whose review is absent from latestReviews: the run reports it absent from "
     "latestReviews"),

    # Task 5: correction and write-back.
    ("body-compared-by-prefix",
     "    if body_stored != body_sent:",
     "    if body_stored[:-1] != body_sent[:-1]:",
     "a body differing only in its final character: the run corrects it in place"),
    ("body-compared-after-whitespace-normalisation",
     "    if body_stored != body_sent:",
     "    if body_stored.split() != body_sent.split():",
     "a body that lost its trailing newline: the run corrects it in place"),
    ("correction-skipped",
     "            if forge.correct(item, wanted.body) is not None:",
     "            if False:",
     "a sanitizer dropping <Id> on ADO once: the run corrects it in place"),
    ("pending-comment-patched",
     "        if self.m.pending:\n            return None\n",
     "        if False:\n            return None\n",
     "a staged review with a sanitized body: no PATCH reached the stand-in"),
    ("posted-written-before-the-read-back",
     "    verify(forge, head, record, outcome)\n",
     '    write_posted(manifest.findings_file, "{ }")\n    verify(forge, head, record, outcome)\n',
     "a read-back failing four times: posted: stays unwritten"),
    ("posted-written-on-a-mismatch",
     "    status = outcome.finish()\n",
     "    write_posted(manifest.findings_file, posted_record(manifest, forge, head))\n"
     "    status = outcome.finish()\n",
     "a sanitizer dropping <Id> again after the PATCH: posted: stays unwritten"),
    ("continuation-lines-left",
     '    while stop < end and lines[stop][:1] in (" ", "\\t"):',
     "    while False:",
     "--repost over a value running over several lines: the file reads as the literal"),
    ("frontmatter-reserialised",
     '        f.write("".join(lines))',
     '        f.write("".join(line.split(" #")[0].rstrip() + "\\n" for line in lines))',
     "the write-back: every byte outside posted: is unchanged"),
    ("continuation-read-past-the-next-key",
     "            value += [more.strip() for more in itertools.takewhile(",
     "            value += [more.strip() for more in filter(",
     "a findings file whose posted: is not its last key: the run reads back clean"),

    # Task 6: working files and the credential.
    ("payload-written-in-the-working-directory",
     '        return os.path.join(self.workdir, "%s-%03d.json" % (stem, self.files))',
     '        return "%s-%03d.json" % (stem, self.files)',
     "an ADO run from inside a clone: git status is unchanged"),
    ("token-passed-as-an-argument",
     '        argv = ["curl", "-K", "-", "-sS", "-X", method,',
     '        argv = ["curl", "-u", ":" + self.token, "-sS", "-X", method,',
     "the sentinel token: in no argument list"),
    ("curl-run-verbose",
     '        argv = ["curl", "-K", "-", "-sS", "-X", method,',
     '        argv = ["curl", "-K", "-", "-sS", "-v", "-X", method,',
     "no call passes curl a verbose or trace flag"),
]


def digest(data):
    return hashlib.sha256(data).hexdigest()


def run_suite(*names):
    proc = subprocess.run([sys.executable, SUITE, *names], capture_output=True, timeout=1800)
    return proc.returncode, proc.stdout.decode("utf-8", "replace")


def owners(out):
    """{assertion label: the test that holds it}, read off the suite's output, where each
    test's name stands unindented above its PASS and FAIL lines."""
    owner = {}
    test = None
    for line in out.splitlines():
        if line and not line.startswith(" "):
            test = line
        elif line.startswith(("  PASS ", "  FAIL ")):
            owner[line[len("  PASS "):]] = test
    return owner


def apply(original, find, replace):
    text = original.decode("utf-8")
    count = text.count(find)
    if count != 1:
        return None, "the target text appears %d times, expected 1" % count
    mutated = text.replace(find, replace).encode("utf-8")
    if mutated == original:
        return None, "the edit did not change the file"
    return mutated, ""


def mutate(original, name, find, replace, target, owner):
    print("\n%s\n  target assertion: %s" % (name, target))
    if target not in owner:
        print("  NOT APPLIED no test of the suite holds the target assertion")
        return "misfired"
    mutated, problem = apply(original, find, replace)
    if mutated is None:
        print("  NOT APPLIED %s; the mutation proves nothing" % problem)
        return "misfired"
    try:
        with open(SCRIPT, "wb") as f:
            f.write(mutated)
        rc, out = run_suite(owner[target])
    finally:
        with open(SCRIPT, "wb") as f:
            f.write(original)
    failures = [line.strip()[len("FAIL "):] for line in out.splitlines() if line.strip().startswith("FAIL ")]
    if rc == 0:
        print("  SURVIVED %s still passes with the check broken" % owner[target])
        return "survived"
    if target in failures:
        print("  KILLED by: %s" % target)
        return "killed"
    print("  WRONG REASON %s failed, but not on the target assertion:" % owner[target])
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
    owner = owners(out)
    tally = {"killed": 0, "survived": 0, "misfired": 0}
    for name, find, replace, target in MUTATIONS:
        if names and name not in names:
            continue
        tally[mutate(original, name, find, replace, target, owner)] += 1
        with open(SCRIPT, "rb") as f:
            if digest(f.read()) != digest(original):
                print("  RESTORE FAILED the script is not byte-identical to the original")
                return 2
    print("\n%(killed)d killed, %(survived)d survived, %(misfired)d misfired" % tally)
    return 0 if tally["survived"] == tally["misfired"] == 0 else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
