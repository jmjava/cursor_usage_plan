#!/usr/bin/env bash
# Show Cursor usage and remaining (cost $). Ultra = $400.
# Budget period resets on a fixed day each month (default: 17th).
# Set MONTHLY_BUDGET_DOLLARS, USED_DOLLARS or REMAINING_DOLLARS in config.
# Usage: ./scripts/usage-remaining.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
PLAN_DIR="$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)"
BUDGET_ENV="$PLAN_DIR/config/budget.env"
USAGE_ENV="$PLAN_DIR/config/usage.env"

ROLLOVER_DAY="${BUDGET_ROLLOVER_DAY:-17}"

for f in "$BUDGET_ENV" "$USAGE_ENV"; do
    [ -f "$f" ] || continue
    set -a
    while IFS= read -r line || [ -n "$line" ]; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ "$line" =~ ^[[:space:]]*$ ]] && continue
        if [[ "$line" == *=* ]]; then
            key="${line%%=*}"; key="${key// /}"
            value="${line#*=}"; value="${value// /}"
            export "$key=$value" 2>/dev/null || true
        fi
    done < "$f"
    set +a
done

echo "=========================================="
echo "Cursor usage & remaining ($)"
echo "=========================================="
echo ""

LIMIT="${MONTHLY_BUDGET_DOLLARS:-}"
if [ -z "$LIMIT" ] || ! [[ "$LIMIT" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Set MONTHLY_BUDGET_DOLLARS (e.g. 400 for Ultra) in config/budget.env."
    echo ""
    exit 1
fi

USED_INPUT="${USED_DOLLARS:-}"
REMAINING_INPUT="${REMAINING_DOLLARS:-}"
if [ -n "$REMAINING_INPUT" ] && [[ "$REMAINING_INPUT" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    REMAINING="$REMAINING_INPUT"
    USED=$(awk "BEGIN{printf \"%.2f\", $LIMIT - $REMAINING}" 2>/dev/null)
elif [ -n "$USED_INPUT" ] && [[ "$USED_INPUT" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    USED="$USED_INPUT"
    REMAINING=$(awk "BEGIN{printf \"%.2f\", $LIMIT - $USED}" 2>/dev/null)
else
    echo "Usage not set. Export CSV from dashboard, then run: ./scripts/import-usage-from-csv.sh"
    echo "  See docs/usage-integration.md"
    echo ""
    exit 1
fi

PCT_USED=$(awk "BEGIN{printf \"%.1f\", ($USED / $LIMIT) * 100}" 2>/dev/null)
PCT_REMAINING=$(awk "BEGIN{printf \"%.1f\", ($REMAINING / $LIMIT) * 100}" 2>/dev/null)

echo "  Period:           resets on the ${ROLLOVER_DAY}th of each month"
echo "  Monthly limit:    \$${LIMIT}"
echo "  Used so far:      \$${USED}"
echo "  Remaining:        \$${REMAINING}"
echo ""
echo "  % used:           ${PCT_USED}%"
echo "  % remaining:      ${PCT_REMAINING}%"
echo ""
[ -n "${USAGE_UPDATED:-}" ] && echo "  Last updated:     $USAGE_UPDATED" && echo ""

if [ -n "${DOLLARS_PER_FEATURE:-}" ] && [[ "${DOLLARS_PER_FEATURE}" =~ ^[0-9]+(\.[0-9]+)?$ ]] && awk "BEGIN{exit(!($REMAINING>0))}" 2>/dev/null; then
    FEATURES=$(awk "BEGIN{printf \"%.0f\", $REMAINING / $DOLLARS_PER_FEATURE}" 2>/dev/null)
    echo "  At ~\$${DOLLARS_PER_FEATURE}/feature: ~${FEATURES} features left this period."
    echo ""
fi

echo "  To refresh: export CSV from dashboard, then ./scripts/import-usage-from-csv.sh"
echo ""
