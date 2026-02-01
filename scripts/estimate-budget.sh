#!/usr/bin/env bash
# Print a table of all projects with Target % and Est. $ (and ~features, ~sessions).
# Reads: config/budget.env, projects.md.
#
# Usage: ./scripts/estimate-budget.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
PLAN_DIR="$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)"
PROJECTS_MD="$PLAN_DIR/projects.md"
BUDGET_ENV="$PLAN_DIR/config/budget.env"
USAGE_ENV="$PLAN_DIR/config/usage.env"

# Load budget
if [ -f "$BUDGET_ENV" ]; then
    set -a
    while IFS= read -r line || [ -n "$line" ]; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ "$line" =~ ^[[:space:]]*$ ]] && continue
        if [[ "$line" == *=* ]]; then
            key="${line%%=*}"; key="${key// /}"
            value="${line#*=}"; value="${value// /}"
            export "$key=$value" 2>/dev/null || true
        fi
    done < "$BUDGET_ENV"
    set +a
fi

# Load usage (optional: set by CSV import)
if [ -f "$USAGE_ENV" ]; then
    set -a
    while IFS= read -r line || [ -n "$line" ]; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ "$line" =~ ^[[:space:]]*$ ]] && continue
        if [[ "$line" == *=* ]]; then
            key="${line%%=*}"; key="${key// /}"
            value="${line#*=}"; value="${value// /}"
            export "$key=$value" 2>/dev/null || true
        fi
    done < "$USAGE_ENV"
    set +a
fi

# Compute remaining this period (if usage set). Allow decimals for dollars.
EFFECTIVE_BUDGET="${MONTHLY_BUDGET_DOLLARS:-}"
if [ -n "${USED_DOLLARS:-}" ] && [[ "${USED_DOLLARS}" =~ ^[0-9]+(\.[0-9]+)?$ ]] && [ -n "$EFFECTIVE_BUDGET" ] && [[ "$EFFECTIVE_BUDGET" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    REMAINING_THIS_PERIOD=$(awk "BEGIN{printf \"%.2f\", $EFFECTIVE_BUDGET - $USED_DOLLARS}" 2>/dev/null)
elif [ -n "${REMAINING_DOLLARS:-}" ] && [[ "${REMAINING_DOLLARS}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    REMAINING_THIS_PERIOD="$REMAINING_DOLLARS"
fi

echo "=========================================="
echo "Cost estimates by project (from projects.md)"
echo "=========================================="
echo ""

if [ -z "${MONTHLY_BUDGET_DOLLARS:-}" ] || ! [[ "${MONTHLY_BUDGET_DOLLARS}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Set MONTHLY_BUDGET_DOLLARS in config/budget.env for cost estimates."
    echo ""
    echo "Current target % per project:"
    awk -F'|' '/^\| [0-9]+ \| [a-zA-Z0-9_-]+ \|/{gsub(/^ | $/,"",$3); gsub(/^ | $/,"",$6); printf "  %-30s %s%%\n", $3, $6}' "$PROJECTS_MD" 2>/dev/null
    exit 0
fi

if [ -n "${REMAINING_THIS_PERIOD:-}" ] && awk "BEGIN{exit(!($REMAINING_THIS_PERIOD >= 0))}" 2>/dev/null; then
    echo "  Remaining this period (from config/usage.env): \$${REMAINING_THIS_PERIOD}"
    echo "  (Refresh: https://cursor.com/dashboard?tab=usage → update config/usage.env)"
    echo ""
fi

printf "  %-30s %8s %12s %10s %10s\n" "Project" "Target %" "Est. $" "~Features" "~Sessions"
echo "  -------------------------------------------------------------------------"

TOTAL_PCT=0
while IFS= read -r line; do
    [[ "$line" != \|* ]] && continue
    [[ "$line" == "| # |"* ]] && continue
    [[ "$line" == "|---"* ]] && continue
    pslug=$(echo "$line" | awk -F'|' '{gsub(/^ | $/,"",$3); print $3}')
    pct=$(echo "$line" | awk -F'|' '{gsub(/^ | $/,"",$6); print $6}')
    [[ "$pct" =~ ^[0-9]+(\.[0-9]+)?$ ]] || continue
    TOTAL_PCT=$(awk "BEGIN{printf \"%.1f\", $TOTAL_PCT + $pct}" 2>/dev/null)
    est=$(awk "BEGIN{printf \"%.2f\", $MONTHLY_BUDGET_DOLLARS * $pct / 100}" 2>/dev/null)
    features="—"
    sessions="—"
    if [ -n "${DOLLARS_PER_FEATURE:-}" ] && [[ "${DOLLARS_PER_FEATURE}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        features=$(awk "BEGIN{printf \"%.0f\", $est / $DOLLARS_PER_FEATURE}" 2>/dev/null)
    fi
    if [ -n "${DOLLARS_PER_SESSION:-}" ] && [[ "${DOLLARS_PER_SESSION}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        sessions=$(awk "BEGIN{printf \"%.0f\", $est / $DOLLARS_PER_SESSION}" 2>/dev/null)
    fi
    printf "  %-30s %7s%% %11s\$ %10s %10s\n" "$pslug" "$pct" "$est" "$features" "$sessions"
done < <(awk '/^\| [0-9]+ \| [a-zA-Z0-9_-]+ \|/{print}' "$PROJECTS_MD" 2>/dev/null)

echo "  -------------------------------------------------------------------------"
REMAINING_PCT=$(awk "BEGIN{printf \"%.1f\", 100 - $TOTAL_PCT}" 2>/dev/null)
echo ""
echo "  Total assigned: ${TOTAL_PCT}%  |  Remaining buffer: ${REMAINING_PCT}%"
if [ -n "${DOLLARS_PER_FEATURE:-}" ]; then
    echo "  (\$ per feature: \$${DOLLARS_PER_FEATURE}; per session: \$${DOLLARS_PER_SESSION:-—})"
fi
if [ -n "${REMAINING_THIS_PERIOD:-}" ] && awk "BEGIN{exit(!($REMAINING_THIS_PERIOD >= 0))}" 2>/dev/null; then
    echo ""
    echo "  Run ./scripts/usage-remaining.sh for used/remaining this period."
fi
echo ""
