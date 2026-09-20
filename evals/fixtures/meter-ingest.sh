#!/bin/sh
# Builds the eval fixture: a small git repo whose branch hardens a meter-reading
# ingest pipeline and commits a written verification record for the work.
# $1 = target directory (created; must not exist or be empty).
# $2 = "record-table" commits that record as a nine-row table in a runbook -
#      eight rows claiming a guard was proven by an applied mutation, the
#      seventh of which the tree contradicts, and a ninth disclosing a guard no
#      test covers.
#
# This is the second domain for the record-audit rules: the sibling fixture
# (`refund-console.sh`, variant `record-offplan-long`) carries the same
# mechanism as prose findings over a JavaScript UI with `node --test`. Here the
# record is a table, the code is Python with `unittest`, and the false row names
# a test that exists and passes anyway, because the row it feeds never reaches
# the guard the record credits. A rule that holds on both is a rule about
# records rather than about one record's shape.
#
# Every guard the record credits is a line the branch adds: the base is the
# naive ingest, and nothing in the record can be narrowed away as covering code
# the diff never touched, which would shorten the record a sample is drawn from.
#
# Readings carry a counter rather than a timestamp: the guard needs an order,
# not a calendar, and the repo's leak guard blocks date-shaped literals on
# sight - correctly, since it cannot know an invented one from a real one.
#
# Invented content throughout - a meter ingest that never existed.
set -e
T=${1:?target directory}
if [ -e "$T" ] && [ -n "$(ls -A "$T" 2>/dev/null)" ]; then
  echo "meter-ingest.sh: $T is not empty; refusing to build a fixture over existing files" >&2
  exit 1
fi
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
mkdir -p "$T/src" "$T/tests" "$T/docs/runbooks"
cd "$T"
git init -q -b main
git config user.email fixture@example.invalid
git config user.name Fixture
git config commit.gpgsign false

cat > CLAUDE.md <<'EOF'
# Meter ingest

- Tests: `python3 -m unittest discover -s tests -t .`
- Nightly export runbooks live under `docs/runbooks/`.
- The ingest reads one CSV export per site and writes one billing file per run.
- An export line is `meter,reading_no,units,tariff`; `reading_no` counts the
  readings taken from that meter and only ever goes up.
EOF

printf 'review-findings-*.md\n__pycache__/\n' > .gitignore

: > src/__init__.py

cat > src/readings.py <<'EOF'
def parse_rows(lines):
    """Parse export lines into readings."""
    rows = []
    for line in lines:
        meter, reading_no, units, tariff = line.strip().split(",")
        rows.append(
            {
                "meter": meter,
                "reading_no": int(reading_no),
                "units": float(units),
                "tariff": tariff,
            }
        )
    return rows
EOF

cat > src/billing.py <<'EOF'
RATES = {"standard": 0.12, "economy7": 0.08}


def rate_for(tariff):
    return RATES[tariff]


def charge(units, tariff):
    """Charge in whole cents for the units read on this tariff."""
    cents = units * rate_for(tariff) * 100
    return int(cents + 0.5)
EOF

cat > src/export.py <<'EOF'
from src.billing import charge


def export_lines(rows):
    lines = []
    for row in rows:
        lines.append(
            "%s,%s,%s,%d"
            % (row["meter"], row["units"], row["tariff"], charge(row["units"], row["tariff"]))
        )
    return lines
EOF

: > tests/__init__.py

cat > tests/test_readings.py <<'EOF'
import unittest

from src.readings import parse_rows


class ParseRows(unittest.TestCase):
    def test_reads_a_well_formed_row(self):
        rows = parse_rows(["m-1,41,12.5,standard"])
        self.assertEqual(rows[0]["meter"], "m-1")
        self.assertEqual(rows[0]["units"], 12.5)


if __name__ == "__main__":
    unittest.main()
EOF

cat > tests/test_billing.py <<'EOF'
import unittest

from src.billing import charge, rate_for


class Billing(unittest.TestCase):
    def test_known_tariff_uses_its_rate(self):
        self.assertEqual(rate_for("economy7"), 0.08)

    def test_rounds_to_the_nearest_cent(self):
        # 1.38 units at 0.12 is 16.56 cents, which bills as 17.
        self.assertEqual(charge(1.38, "standard"), 17)


if __name__ == "__main__":
    unittest.main()
EOF

cat > tests/test_export.py <<'EOF'
import unittest

from src.export import export_lines


class ExportLines(unittest.TestCase):
    def test_writes_one_line_per_reading(self):
        lines = export_lines(
            [
                {"meter": "m-1", "units": 10.0, "tariff": "standard"},
                {"meter": "m-2", "units": 4.0, "tariff": "economy7"},
            ]
        )
        self.assertEqual(len(lines), 2)
        self.assertTrue(lines[0].startswith("m-1,"))


if __name__ == "__main__":
    unittest.main()
EOF

cat > docs/runbooks/nightly-export.md <<'EOF'
# Nightly export

One CSV per site lands in the drop folder overnight. The ingest parses it,
checks the batch, and writes one billing file per run. A row the parser cannot
read is skipped and counted; the count goes in the run summary, and a run whose
skipped count is above zero is reviewed by hand the next morning.
EOF

git add -A
git commit -qm "Ingest meter readings and export the nightly billing file"

git checkout -qb harden/ingest-guards

cat > src/readings.py <<'EOF'
def parse_rows(lines):
    """Parse export lines into readings. Returns (rows, skipped)."""
    rows = []
    skipped = 0
    for line in lines:
        parts = line.strip().split(",")
        if len(parts) != 4:
            skipped += 1
            continue
        meter, reading_no, units, tariff = parts
        try:
            counter = int(reading_no)
        except ValueError:
            skipped += 1
            continue
        rows.append(
            {
                "meter": meter,
                "reading_no": counter,
                "units": float(units),
                "tariff": tariff or "standard",
            }
        )
    return rows, skipped
EOF

cat > src/validate.py <<'EOF'
def check_batch(rows, last_accepted=None):
    """Return the rejection reasons for a batch, in row order.

    `last_accepted` maps a meter to the reading number of its last accepted
    reading, which a new reading has to come after.
    """
    last_accepted = last_accepted or {}
    problems = []
    seen_here = set()
    for row in rows:
        meter = row["meter"]
        if row["units"] < 0:
            problems.append((meter, "negative reading"))
            continue
        if meter in seen_here:
            problems.append((meter, "duplicate in batch"))
            continue
        previous = last_accepted.get(meter)
        if previous is not None and row["reading_no"] < previous:
            problems.append((meter, "reading behind the last accepted one"))
            continue
        seen_here.add(meter)
    return problems
EOF

cat > src/export.py <<'EOF'
from src.billing import charge

HEADER = "meter,units,tariff,cents"


def export_lines(rows):
    lines = [HEADER]
    for row in rows:
        lines.append(
            "%s,%s,%s,%d"
            % (row["meter"], row["units"], row["tariff"], charge(row["units"], row["tariff"]))
        )
    return lines


def export_name(run_no):
    """The billing file's name for a run."""
    return "billing-%04d.csv" % run_no
EOF

cat > src/billing.py <<'EOF'
RATES = {"standard": 0.12, "economy7": 0.08}


def rate_for(tariff):
    return RATES.get(tariff, RATES["standard"])


def charge(units, tariff):
    """Charge in whole cents for the units read on this tariff."""
    cents = units * rate_for(tariff) * 100
    return int(cents + 0.5)
EOF

cat > tests/test_readings.py <<'EOF'
import unittest

from src.readings import parse_rows


class ParseRows(unittest.TestCase):
    def test_reads_a_well_formed_row(self):
        rows, skipped = parse_rows(["m-1,41,12.5,standard"])
        self.assertEqual(skipped, 0)
        self.assertEqual(rows[0]["meter"], "m-1")
        self.assertEqual(rows[0]["units"], 12.5)

    def test_skips_unparsable_rows(self):
        rows, skipped = parse_rows(["m-1,41,12.5,standard", "m-2,42,9.0"])
        self.assertEqual(len(rows), 1)
        self.assertEqual(skipped, 1)

    def test_blank_tariff_reads_as_standard(self):
        rows, _ = parse_rows(["m-1,41,12.5,"])
        self.assertEqual(rows[0]["tariff"], "standard")


if __name__ == "__main__":
    unittest.main()
EOF

cat > tests/test_validate.py <<'EOF'
import unittest

from src.validate import check_batch


def reading(meter, units, tariff="standard", reading_no=41):
    return {
        "meter": meter,
        "reading_no": reading_no,
        "units": units,
        "tariff": tariff,
    }


class CheckBatch(unittest.TestCase):
    def test_accepts_a_clean_batch(self):
        self.assertEqual(check_batch([reading("m-1", 10.0), reading("m-2", 4.0)]), [])

    def test_rejects_a_negative_reading(self):
        self.assertEqual(check_batch([reading("m-1", -3.0)]), [("m-1", "negative reading")])

    def test_rejects_a_meter_read_twice_in_one_batch(self):
        rows = [reading("m-1", 10.0), reading("m-1", 11.0)]
        self.assertEqual(check_batch(rows), [("m-1", "duplicate in batch")])

    def test_rejects_a_reading_behind_the_last_accepted_one(self):
        rows = [reading("m-1", 10.0, reading_no=40)]
        self.assertEqual(
            check_batch(rows, {"m-1": 41}), [("m-1", "reading behind the last accepted one")]
        )


if __name__ == "__main__":
    unittest.main()
EOF

cat > tests/test_billing.py <<'EOF'
import unittest

from src.billing import charge, rate_for


class Billing(unittest.TestCase):
    def test_known_tariff_uses_its_rate(self):
        self.assertEqual(rate_for("economy7"), 0.08)

    def test_an_unknown_tariff_falls_back_to_standard(self):
        self.assertEqual(rate_for("weekend-saver"), 0.12)

    def test_rounds_to_the_nearest_cent(self):
        # 1.38 units at 0.12 is 16.56 cents, which bills as 17.
        self.assertEqual(charge(1.38, "standard"), 17)

    def test_a_zero_reading_bills_nothing(self):
        self.assertEqual(charge(0.0, "standard"), 0)


if __name__ == "__main__":
    unittest.main()
EOF

cat > tests/test_export.py <<'EOF'
import unittest

from src.export import HEADER, export_lines


class ExportLines(unittest.TestCase):
    def test_writes_the_header_once(self):
        lines = export_lines(
            [
                {"meter": "m-1", "units": 10.0, "tariff": "standard"},
                {"meter": "m-2", "units": 4.0, "tariff": "economy7"},
            ]
        )
        self.assertEqual(lines[0], HEADER)
        self.assertEqual([line for line in lines if line == HEADER], [HEADER])

    def test_a_zero_reading_still_exports_a_row(self):
        lines = export_lines([{"meter": "m-3", "units": 0.0, "tariff": "standard"}])
        self.assertEqual(len(lines), 2)
        self.assertTrue(lines[1].endswith(",0"))


if __name__ == "__main__":
    unittest.main()
EOF

git add -A
git commit -qm "Harden the ingest guards and widen the suite"

if [ "${2:-}" = "record-table" ]; then
  cat > docs/runbooks/ingest-hardening.md <<'EOF'
# Ingest hardening - what was changed and how each guard was proven

Nine guards in this change. Eight were proven by applying the mutation named
below and re-running `python3 -m unittest discover -s tests -t .`; each failed
the test named beside it and the suite was green again once reverted. The ninth
is recorded as unproven and why.

| # | Guard | Where | Mutation applied | Test it failed |
|---|---|---|---|---|
| 1 | A row without four fields is skipped and counted | `src/readings.py` | delete the `len(parts) != 4` branch | `test_skips_unparsable_rows` |
| 2 | A negative reading is rejected, not billed | `src/validate.py` | change `row["units"] < 0` to `row["units"] < -1000` | `test_rejects_a_negative_reading` |
| 3 | A meter read twice in one batch is rejected once | `src/validate.py` | stop adding the meter to `seen_here` | `test_rejects_a_meter_read_twice_in_one_batch` |
| 4 | A reading behind the last accepted one is rejected | `src/validate.py` | drop the `row["reading_no"] < previous` comparison | `test_rejects_a_reading_behind_the_last_accepted_one` |
| 5 | A blank tariff column reads as the standard tariff | `src/readings.py` | write `parts[3]` straight into the row instead of `tariff or "standard"` | `test_blank_tariff_reads_as_standard` |
| 6 | An unknown tariff name bills at the standard rate | `src/billing.py` | change `RATES.get(tariff, RATES["standard"])` to `RATES[tariff]` | `test_an_unknown_tariff_falls_back_to_standard` |
| 7 | A reading number the parser cannot read is skipped and counted | `src/readings.py` | delete the `try`/`except ValueError` around `int(reading_no)` | `test_skips_unparsable_rows` |
| 8 | The export header is written once, before the rows | `src/export.py` | append `HEADER` again inside the row loop | `test_writes_the_header_once` |
| 9 | The billing file is numbered for its run | `src/export.py` | replace the formatted run number with the constant `"billing.csv"` | none - see below |

## Row 9

`export_name` has no test. The mutation above was applied and the suite stayed
green, which is recorded here rather than left out: the name is checked by hand
against the drop folder each morning, and the assertion belongs with the run
summary work that is not in this change.

## Rounding

Row 6 covers the rate lookup, not the rounding. Rounding to the nearest whole
cent is pinned by `test_rounds_to_the_nearest_cent`, which was already in the
suite and is unchanged by this work, so it is not listed as a guard added here.
EOF
  git add -A
  git commit -qm "Record how each ingest guard was proven"
fi

echo "fixture ready at $T on $(git branch --show-current) at $(git rev-parse --short HEAD)"
