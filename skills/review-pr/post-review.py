#!/usr/bin/env python3
"""Post a review-pr manifest to GitHub or Azure DevOps, and read it back.

Run from the clone the review was made in:

    post-review.py <manifest.json> [--resume] [--repost] [--settle N] [--timeout N] [--dry-run]
    post-review.py --print-status-vocab
"""

import argparse
import sys

STATUSES = (
    "MANIFEST-INVALID", "UNSUPPORTED-FORGE", "EMPTY", "NO-FRONTMATTER", "ALREADY-POSTED",
    "POSTED-UNKNOWN", "UNFINISHED-RUN",
    "NO-TOKEN", "AUTH-REFUSED",
    "STALE-HEAD", "MISSING-COMMIT",
    "OUT-OF-DIFF", "LINE-OUT-OF-FILE", "OFF-DIFF-LINE", "STALE-SUGGESTION", "SUGGESTION-IN-GROUP",
    "PARTITION", "PENDING-EXISTS",
    "LANDED", "REJECTED", "UNCERTAIN", "UNVERIFIED", "MISSING", "CORRECTED", "MISMATCH", "MISPLACED",
    "NO-STATE", "SETTLING",
)


def parse_args(argv):
    parser = argparse.ArgumentParser(prog="post-review.py")
    parser.add_argument("manifest", nargs="?")
    parser.add_argument("--resume", action="store_true")
    parser.add_argument("--repost", action="store_true")
    parser.add_argument("--settle", type=int, default=600)
    parser.add_argument("--timeout", type=int, default=60)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--print-status-vocab", action="store_true")
    args = parser.parse_args(argv)
    if not args.print_status_vocab and args.manifest is None:
        parser.error("a manifest path is required")
    return args


def main(argv):
    args = parse_args(argv)
    if args.print_status_vocab:
        print("\n".join(STATUSES))
        return 0
    print("posting is not built yet", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
