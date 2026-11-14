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
MUTATIONS = [
    ("vocab-entry-dropped",
     '"NO-STATE", "SETTLING",',
     '"NO-STATE",',
     "the status vocabulary matches the expected list"),
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
