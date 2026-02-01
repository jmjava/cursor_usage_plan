# Cursor usage: CSV import

Usage (used $) comes from **Cursor’s usage CSV**. There is no API or local file for personal plans; use the CSV export.

## How to get usage into this repo

1. **Export CSV** from [Cursor Dashboard → Usage](https://cursor.com/dashboard?tab=usage) for the current period (or paste raw CSV).
2. **Run the importer:**
   - With a file: `./scripts/import-usage-from-csv.sh path/to/export.csv`
   - With stdin: `cat export.csv | ./scripts/import-usage-from-csv.sh` or paste CSV and run with `-`
3. The script sums the cost column and writes **USED_DOLLARS** to **config/usage.env**.
4. Run **`./scripts/usage-remaining.sh`** to see used, remaining, and % remaining.

## What uses config/usage.env

| Script | What it does |
|--------|----------------|
| **usage-remaining.sh** | Reads USED_DOLLARS or REMAINING_DOLLARS; prints used, limit, remaining, % remaining, ~features left. |
| **estimate-budget.sh** | If usage is set, shows "Remaining this period" and reminds you to run usage-remaining.sh. |
| **what-if-target.sh** | If usage is set, shows "Remaining this period → at X%, ~$Y for this repo". |

## Quick workflow

```bash
# 1. Export CSV from dashboard (or paste raw CSV), then:
./scripts/import-usage-from-csv.sh path/to/export.csv
# or: cat export.csv | ./scripts/import-usage-from-csv.sh

# 2. See used / remaining / % remaining
./scripts/usage-remaining.sh

# 3. Per-repo estimates and remaining this period
./scripts/estimate-budget.sh

# 4. What-if: "If I give course-builder 25%, how much of my remaining $?"
./scripts/what-if-target.sh course-builder 25
```

Refresh whenever you want updated numbers: export CSV again and re-run the importer.
