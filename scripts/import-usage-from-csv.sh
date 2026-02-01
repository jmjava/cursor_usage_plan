#!/usr/bin/env bash
# Import Cursor usage from dashboard CSV export into config/usage.env.
#
# 1. Cursor Dashboard → Usage → pick date range → Export CSV
# 2. Save as config/usage-export.csv (or pass path)
# 3. Run: ./scripts/import-usage-from-csv.sh [path/to/export.csv]
#
# The script sums cost and sets USED_DOLLARS in config/usage.env.
# Then run ./scripts/usage-remaining.sh to see remaining.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
PLAN_DIR="$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)"
CSV="${1:-$PLAN_DIR/config/usage-export.csv}"

if [ ! -f "$CSV" ]; then
    echo "Usage: $0 [path/to/usage-export.csv]" >&2
    echo "" >&2
    echo "Cursor Dashboard → Usage → date range → Export CSV" >&2
    echo "Save as: $PLAN_DIR/config/usage-export.csv" >&2
    exit 1
fi

exec python3 "$SCRIPT_DIR/import_usage_from_csv.py" "$CSV"
