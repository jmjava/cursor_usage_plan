#!/usr/bin/env python3
"""
Parse Cursor dashboard usage CSV export and write USED_DOLLARS to config/usage.env.
Looks for a cost column (Cost, API_COST, Spend, etc.) and sums it.

Usage:
  python3 import_usage_from_csv.py [path/to/usage-export.csv]
  python3 import_usage_from_csv.py -                    # read CSV from stdin
  cat export.csv | python3 import_usage_from_csv.py      # pipe CSV from stdin

  Default (no args, no stdin): config/usage-export.csv

Workflow:
  1. Cursor Dashboard → Usage → date range → Export CSV
  2. Save as file and pass path, or paste/pipe CSV as raw input
  3. Run this script; it sums the cost column and updates config/usage.env
"""

import csv
import os
import re
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
DEFAULT_CSV = REPO_ROOT / "config" / "usage-export.csv"
USAGE_ENV = REPO_ROOT / "config" / "usage.env"

# Cost column names to try (case-insensitive)
COST_COLUMN_NAMES = ("cost", "api_cost", "spend", "usage cost", "total cost", "amount", "price")


def find_cost_column(headers):
    for h in headers:
        h_lower = h.strip().lower()
        if h_lower in COST_COLUMN_NAMES or "cost" in h_lower or "spend" in h_lower:
            return h
    return None


def safe_float(val):
    if val is None or (isinstance(val, str) and not val.strip()):
        return 0.0
    s = str(val).strip().replace(",", "").replace("$", "")
    try:
        return float(s)
    except (ValueError, TypeError):
        return 0.0


def sum_cost_from_file(f, column_hint=None):
    """Read CSV from file-like object f; return (total, None) or (None, error)."""
    total = 0.0
    reader = csv.DictReader(f)
    headers = reader.fieldnames or []
    if column_hint:
        col = next((c for c in headers if c.strip().lower() == column_hint.strip().lower()), None)
        if not col:
            return None, f"Column '{column_hint}' not found. Headers: {headers}"
    else:
        col = find_cost_column(headers)
        if not col:
            return None, f"No cost column found. Headers: {headers}"

    for row in reader:
        total += safe_float(row.get(col))
    return round(total, 2), None


def sum_cost_from_csv(csv_path, column_hint=None):
    with open(csv_path, newline="", encoding="utf-8", errors="replace") as f:
        return sum_cost_from_file(f, column_hint=column_hint)


def update_usage_env(used_dollars):
    from datetime import date
    today = date.today().isoformat()

    if not USAGE_ENV.exists():
        USAGE_ENV.write_text(
            f"# Cursor usage (from CSV import)\nUSED_DOLLARS={used_dollars}\nUSAGE_UPDATED={today}\n",
            encoding="utf-8",
        )
        return

    lines = []
    for line in USAGE_ENV.read_text(encoding="utf-8").splitlines():
        if re.match(r"^\s*USED_DOLLARS\s*=", line):
            lines.append(f"USED_DOLLARS={used_dollars}")
        elif re.match(r"^\s*USAGE_UPDATED\s*=", line):
            lines.append(f"USAGE_UPDATED={today}")
        else:
            lines.append(line)
    if not any(re.match(r"^\s*USED_DOLLARS\s*=", l) for l in lines):
        lines.append(f"USED_DOLLARS={used_dollars}")
    if not any(re.match(r"^\s*USAGE_UPDATED\s*=", l) for l in lines):
        lines.append(f"USAGE_UPDATED={today}")
    USAGE_ENV.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main():
    column_hint = os.environ.get("CURSOR_USAGE_CSV_COLUMN")
    read_from_stdin = False

    if len(sys.argv) > 1 and sys.argv[1] == "-":
        read_from_stdin = True
    elif len(sys.argv) == 1 and not sys.stdin.isatty():
        read_from_stdin = True

    if read_from_stdin:
        total, err = sum_cost_from_file(sys.stdin, column_hint=column_hint)
    else:
        csv_path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_CSV
        if not csv_path.is_absolute():
            csv_path = REPO_ROOT / csv_path
        if not csv_path.exists():
            print("Usage: python3 import_usage_from_csv.py [path/to/usage-export.csv]", file=sys.stderr)
            print("       python3 import_usage_from_csv.py -   # read CSV from stdin", file=sys.stderr)
            print("       cat export.csv | python3 import_usage_from_csv.py", file=sys.stderr)
            print("Cursor Dashboard → Usage → Export CSV → save file or paste/pipe CSV", file=sys.stderr)
            sys.exit(1)
        total, err = sum_cost_from_csv(csv_path, column_hint=column_hint)

    if err:
        print(err, file=sys.stderr)
        sys.exit(2)

    update_usage_env(total)
    print(f"Summed cost from CSV: ${total}")
    print(f"Updated {USAGE_ENV} (USED_DOLLARS={total})")
    print("Run ./scripts/usage-remaining.sh to see remaining.")


if __name__ == "__main__":
    main()
