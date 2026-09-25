#!/usr/bin/env python3
"""Writes this case's `history.jsonl`: the replay case's seeded exchange,
built by that case's generator, with one more row on the seeded closing
table - a fourth question that is the requester's, like the second.

Once the requester answers item 1 and the third (the other team's question)
leaves, two of the requester's items stay open, so the list closing the next
message is a table by the skill's own rule, and both items sit below a gap.
The brief and the skill are read by the shared generator at build time, so a
change to either stales both cases at once.

    python3 evals/tracking-open-asks-keeps-the-item-numbers/make-history.py
"""
import importlib.util
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
GENERATOR = os.path.join(os.path.dirname(HERE),
                         "tracking-open-asks-rederives-the-closing-list",
                         "make-history.py")

ROW_4 = """
| 4 | Should `--dry` stay accepted as a hidden alias for one release, for \
scripts that still pass it? | Nothing - the rename is done either way | \
`--dry` is gone as of this change |"""

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("replay_history", GENERATOR)
gen = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gen)
gen.ASSISTANT = gen.ASSISTANT + ROW_4

sys.argv = [GENERATOR,
            sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "history.jsonl")]
gen.main()
