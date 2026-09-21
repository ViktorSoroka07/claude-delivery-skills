#!/usr/bin/env python3
"""Fold the kept eval runs into one row per case, grader and release.

`evals/results/*.json` is read one release at a time and then forgotten, so a
grader that has been sliding for three releases looks exactly like one that
broke yesterday. This prints them apart.

Four rules decide what a row may contain, and they are the reason the numbers
here differ from the runner's own aggregates:

* **Only runs the settled judge graded.** `--judge-model` is an
  invocation-level choice, and a row judged by the default judge is not
  comparable with one judged by the model CONTRIBUTING names: on a
  multi-condition rubric the default judge fails conditions a hand read and the
  stronger judge both pass. Files judged by anything else are listed as
  excluded rather than dropped in silence. `--judge any` overrides it and says
  so in the header.
* **Only runs of this plugin's own suite.** A judge-calibration probe runs a
  throwaway plugin over a throwaway case; its rows belong to
  `evals/judge-calibration.md`, not to a trend of the suite. The plugin name in
  `.claude-plugin/plugin.json` is what decides, so nothing here is hard-coded.
* **A check that could not have passed is unmeasured, not failed.** A run the
  runner curtailed still carries a verdict for every grader, and a grader
  skipped at a cost ceiling carries `passed: false`; counted as fails, both
  read as a regression the work never caused. They are lifted out and counted
  separately.
* **A round's arms are named in the file name, never inferred.** The two arms
  of a wording round are two runs of one case at one release with different
  skill text, so they share this fold's whole key and would land in one cell as
  though the declined wording were the shipped text. The ablation mode cannot
  separate them - both arms run with `--ablation none` - so the name of the
  file the maintainer copies in is where the arm is said out loud: a file named
  `<round>@<arm>.json` is kept out of the release trend and reported under
  `Named arms`, where the arms of one round are compared with each other. A
  name that means to say an arm and does not - more than one `@` - is excluded
  with its reason rather than folded into a release. What a name cannot fix is
  reported instead: a release cell fed by more than one plugin checkout is
  flagged, because two checkouts at one version are two bodies of text this
  fold cannot tell apart.

Usage: python3 scripts/eval-trend.py [--dir DIR] [--judge MODEL|any]
                                     [--case SUBSTRING] [--grader SUBSTRING]
       A round's arms are copied in as `<round>@baseline.json` and
       `<round>@<wording>.json`.
"""

import argparse
import glob
import json
import os
import re
import sys

SETTLED_JUDGE = "sonnet"  # CONTRIBUTING, "Testing a wording change"
SKIPPED = re.compile(r"^\s*skipped\b", re.I)
ARM_IN_NAME = re.compile(r"^(?P<round>[^@]+)@(?P<arm>[^@]+)\.json$")


def arm_of(name):
    """A round and its arm, from `<round>@<arm>.json`; (None, None) otherwise.

    Nothing in a run's own JSON distinguishes a wording round's two arms - the
    version is equal, the ablation mode is `none` in both - so the arm is what
    the maintainer says in the file name or it is not known at all.
    """
    match = ARM_IN_NAME.match(name)
    return (match.group("round"), match.group("arm")) if match else (None, None)


def version_key(v):
    parts = []
    for piece in str(v).split("."):
        parts.append(int(piece) if piece.isdigit() else 0)
    return tuple(parts + [0, 0, 0])[:3]


def load(path):
    try:
        with open(path) as fh:
            return json.load(fh)
    except (OSError, ValueError) as exc:
        return {"_unreadable": "%s" % exc}


def suite_plugin_name(root):
    """The plugin whose runs belong in the trend, read from the manifest."""
    try:
        with open(os.path.join(root, ".claude-plugin", "plugin.json")) as fh:
            return json.load(fh).get("name")
    except (OSError, ValueError):
        return None


def collect(paths, judge, plugin_name):
    """-> (cells, arms, excluded, notes).

    A trend cell keys (case, grader, release); a named arm's cell keys (round,
    case, grader, arm) and is kept out of the trend entirely.
    """
    cells, arms, excluded, notes, provenance = {}, {}, [], [], {}
    for path in sorted(paths):
        name = os.path.basename(path)
        run = load(path)
        if "_unreadable" in run:
            excluded.append((name, "unreadable: %s" % run["_unreadable"]))
            continue
        suite = run.get("suite") or {}
        used = suite.get("judgeModel")
        if judge != "any" and used != judge:
            excluded.append((name, "judged by %s" % (used or "the default judge")))
            continue
        plugins = suite.get("plugins") or [{}]
        ran = plugins[0].get("name")
        if plugin_name and ran != plugin_name:
            excluded.append((name, "a run of %s, not this suite" % (ran or "no plugin")))
            continue
        release = plugins[0].get("version") or "unknown"
        checkout = plugins[0].get("path") or ""
        provenance[name] = checkout
        round_name, arm_name = arm_of(name)
        if not arm_name and "@" in name:
            excluded.append((name, "an arm this fold cannot read - a named arm "
                                   "is <round>@<arm>.json, one @ and no more"))
            continue
        target = arms if arm_name else cells
        for case in run.get("cases") or []:
            for arm, runs in (case.get("arms") or {}).items():
                for rep in runs:
                    curtailed = bool(rep.get("error"))
                    flagged = bool(rep.get("skippedPaidGraders"))
                    saw_skip = False
                    for grader in rep.get("graders") or []:
                        if not grader.get("scored", True):
                            continue  # an arm-only indicator scores in neither arm
                        key = ((round_name, case.get("name"),
                                grader.get("name"), arm_name) if arm_name else
                               (case.get("name"), grader.get("name"), release))
                        cell = target.setdefault(
                            key,
                            {"with": [0, 0], "without": [0, 0], "unmeasured": 0,
                             "files": set(), "judge": used, "checkouts": set(),
                             "release": release},
                        )
                        cell["files"].add(name)
                        cell["checkouts"].add(checkout)
                        skipped = bool(SKIPPED.match(grader.get("explanation") or ""))
                        saw_skip = saw_skip or skipped
                        if curtailed or skipped:
                            cell["unmeasured"] += 1
                            continue
                        tally = cell.get(arm)
                        if tally is None:
                            continue
                        tally[1] += 1
                        if grader.get("passed"):
                            tally[0] += 1
                    if flagged and not saw_skip:
                        notes.append(
                            "%s: %s/%s reports skipped paid graders, but no grader "
                            "carries the skip marker - those verdicts are counted as "
                            "real and may not be" % (name, case.get("name"), arm))
    notes.extend(mixed_checkout_notes(cells, provenance))
    return cells, arms, excluded, notes


def mixed_checkout_notes(cells, provenance):
    """One version is not one body of text once two checkouts ran it.

    Reported once per release and set of checkouts, with the files named under
    the checkout each came from: the affected rows are marked in the table, and
    a line per row would bury the reading under the repetition.
    """
    groups = {}
    for key in sorted(cells, key=lambda k: tuple(str(part) for part in k)):
        checkouts = frozenset(c for c in cells[key]["checkouts"] if c)
        if len(checkouts) < 2:
            continue
        group = groups.setdefault((key[2], checkouts), {"rows": 0, "files": set()})
        group["rows"] += 1
        group["files"] |= cells[key]["files"]
    out = []
    for (release, checkouts), group in sorted(
            groups.items(), key=lambda item: str(item[0][0])):
        lines = ["%d row(s) at %s, marked ! above, fold runs from %d plugin "
                 "checkouts - one version is not one body of text, so this fold "
                 "cannot say whether they held the same skill text. If they are "
                 "a round's arms, copy each in as <round>@<arm>.json and it is "
                 "reported apart instead of folded."
                 % (group["rows"], release, len(checkouts))]
        for checkout in sorted(checkouts):
            lines.append("    %s" % checkout)
            lines.append("        %s" % ", ".join(
                sorted(f for f in group["files"]
                       if provenance.get(f) == checkout)))
        out.append("\n".join(lines))
    return out


def rate(tally):
    passed, total = tally
    if not total:
        return None
    return passed / total


def fmt(tally):
    passed, total = tally
    if not total:
        return "-"
    return "%d/%d" % (passed, total)


def points(now, before):
    if now is None or before is None:
        return "-"
    return "%+d" % round((now - before) * 100)


def print_arms(arms, case_filter, grader_filter):
    """The rounds, one row per named arm, beside each other and apart."""
    keys = [k for k in arms
            if case_filter in (k[1] or "") and grader_filter in (k[2] or "")]
    if not keys:
        return
    keys.sort(key=lambda k: (k[0] or "", k[1] or "", k[2] or "",
                             0 if (k[3] or "").lower() == "baseline" else 1,
                             k[3] or ""))
    header = ("round", "case", "grader", "arm", "rel", "plugin", "none", "vs 1st")
    widths = [max([len(header[i])] + [len(k[i] or "") for k in keys])
              for i in range(4)]
    line = "%-*s  %-*s  %-*s  %-*s  %-7s %-7s %-7s %s"
    print()
    print("Named arms - %d row(s) over %d round(s), kept out of the trend above: "
          "a round's arms compare with each other, never with a release."
          % (len(keys), len({k[0] for k in keys})))
    print(line % (widths[0], header[0], widths[1], header[1], widths[2], header[2],
                  widths[3], header[3], header[4], header[5], header[6], header[7]))
    first_key, first_rate = None, None
    for key in keys:
        cell = arms[key]
        here_rate = rate(cell["with"])
        if key[:3] != first_key:
            first_key, first_rate, against = key[:3], here_rate, "-"
        else:
            against = points(here_rate, first_rate)
        print(line % (widths[0], key[0], widths[1], key[1], widths[2], key[2],
                      widths[3], key[3], cell["release"],
                      fmt(cell["with"]), fmt(cell["without"]), against))
    print("'vs 1st' is percentage points of the plugin arm against the round's "
          "first row; arms sort with `baseline` first.")


def main(argv=None):
    here = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--dir", default=os.path.join(here, "evals", "results"))
    ap.add_argument("--judge", default=SETTLED_JUDGE,
                    help="judge model a run must have used, or 'any'")
    ap.add_argument("--case", default="", help="substring filter on the case name")
    ap.add_argument("--grader", default="", help="substring filter on the grader name")
    args = ap.parse_args(argv)

    paths = glob.glob(os.path.join(args.dir, "*.json"))
    if not paths:
        print("no run JSON under %s" % args.dir)
        return 1
    plugin_name = suite_plugin_name(here)
    cells, arms, excluded, notes = collect(paths, args.judge, plugin_name)

    rows = [k for k in cells
            if args.case in (k[0] or "") and args.grader in (k[1] or "")]
    rows.sort(key=lambda k: (k[0] or "", k[1] or "", version_key(k[2]), k[2]))

    print("Eval trend - %d file(s) read, %d kept%s"
          % (len(paths), len(paths) - len(excluded),
             ", %d of them a named arm" % len({f for cell in arms.values()
                                               for f in cell["files"]})
             if arms else ""))
    if not plugin_name:
        print("NOTE: no plugin manifest at %s - runs of other plugins are not "
              "filtered out." % here)
    if args.judge == "any":
        print("JUDGE FILTER OFF: rows judged by different models are not comparable.")
    else:
        print("Rows are runs judged by %s alone; the rest are listed below." % args.judge)
    print()

    if not rows:
        print("nothing to fold: no run matched the filters.")
    header = ("case", "grader", "rel", "plugin", "none", "delta", "vs prev")
    widths = [max([len(header[0])] + [len(r[0] or "") for r in rows] or [4]),
              max([len(header[1])] + [len(r[1] or "") for r in rows] or [6]),
              max([len(header[2])] + [len(r[2]) + 2 for r in rows] or [3])]
    line = "%-*s  %-*s  %-*s  %-7s %-7s %-6s %s"
    print(line % (widths[0], header[0], widths[1], header[1], widths[2], header[2],
                  header[3], header[4], header[5], header[6]))
    prev_key, prev_rate = None, None
    unmeasured_total = 0
    for key in rows:
        case, grader, release = key
        cell = cells[key]
        unmeasured_total += cell["unmeasured"]
        here_rate = rate(cell["with"])
        if (case, grader) != prev_key:
            prev_key, prev_rate = (case, grader), None
        delta = "-"
        if here_rate is not None and rate(cell["without"]) is not None:
            delta = "%+d" % round((here_rate - rate(cell["without"])) * 100)
        tail = ""
        if cell["unmeasured"]:
            tail += "  [%d unmeasured]" % cell["unmeasured"]
        if len(cell["files"]) > 1:
            tail += "  [%d runs folded]" % len(cell["files"])
        mixed = len({c for c in cell["checkouts"] if c}) > 1
        if mixed:
            tail += "  [%d checkouts - see WARNING]" % len(cell["checkouts"])
        print(line % (widths[0], case, widths[1], grader,
                      widths[2], release + ("*" if len(cell["files"]) > 1 else "")
                      + ("!" if mixed else ""),
                      fmt(cell["with"]), fmt(cell["without"]), delta,
                      points(here_rate, prev_rate) + tail))
        prev_rate = here_rate

    print()
    print("plugin/none are pass counts per arm; delta and 'vs prev' are percentage "
          "points of the plugin arm.")
    if unmeasured_total:
        print("%d grader verdict(s) lifted out as unmeasured - a curtailed run or a "
              "grader skipped at a cost ceiling." % unmeasured_total)
    print_arms(arms, args.case, args.grader)
    if notes:
        print()
    for note in notes:
        print("WARNING: %s" % note)
    if excluded:
        print()
        print("Excluded (%d):" % len(excluded))
        for name, why in excluded:
            print("  %-52s %s" % (name, why))
    return 0


if __name__ == "__main__":
    sys.exit(main())
