#!/usr/bin/env bash
# Read "What I want to do this month (wishlist)" from your monthly plan,
# sum Est. $ per item (use DOLLARS_PER_FEATURE for blank rows), and check fit vs
# **current remaining cost** (from config/usage.env). If usage not set, uses full monthly budget.
#
# Usage: ./scripts/estimate-plan.sh [plans/YYYY-MM.md]
# Default: plans/$(date +%Y-%m).md

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
PLAN_DIR="$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)"
BUDGET_ENV="$PLAN_DIR/config/budget.env"
USAGE_ENV="$PLAN_DIR/config/usage.env"
PLAN_FILE="${1:-$PLAN_DIR/plans/$(date +%Y-%m).md}"

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

# Load usage (so we use current remaining $ as budget for this plan, not always $400)
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

MONTHLY="${MONTHLY_BUDGET_DOLLARS:-400}"
# Budget for this plan = current remaining $ when usage is set; else full monthly
if [ -n "${USED_DOLLARS:-}" ] && [[ "${USED_DOLLARS}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    LIMIT=$(awk "BEGIN{printf \"%.2f\", $MONTHLY - $USED_DOLLARS}" 2>/dev/null)
    BUDGET_LABEL="remaining (of \$$MONTHLY)"
elif [ -n "${REMAINING_DOLLARS:-}" ] && [[ "${REMAINING_DOLLARS}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    LIMIT="$REMAINING_DOLLARS"
    BUDGET_LABEL="remaining (of \$$MONTHLY)"
else
    LIMIT="$MONTHLY"
    BUDGET_LABEL="full month (no usage set; run import-usage-from-csv.sh to set remaining)"
fi
DEFAULT_EST="${DOLLARS_PER_FEATURE:-20}"

if [ ! -f "$PLAN_FILE" ]; then
    echo "Usage: $0 [plans/YYYY-MM.md]" >&2
    echo "Plan file not found: $PLAN_FILE" >&2
    echo "Create it from templates/monthly-plan-template.md and fill the wishlist table." >&2
    exit 1
fi

# Find wishlist table: between "## What I want to do" and next "##" or end
IN_TABLE=0
printf "==========================================\n"
printf "Plan cost estimate (wishlist)\n"
printf "==========================================\n\n"
printf "  Plan: %s\n" "$PLAN_FILE"
printf "  Budget for this plan: \$%s %s\n\n" "$LIMIT" "$BUDGET_LABEL"
printf "  %-6s %-6s %-40s %8s\n" "Item" "Pri" "Description" "Est. \$"
printf "  ------------------------------------------------------------------------\n"

TOTAL=0
while IFS= read -r line; do
    if [[ "$line" == *"What I want to do this month"* ]]; then
        IN_TABLE=1
        continue
    fi
    if [ "${IN_TABLE:-0}" -eq 1 ] && [[ "$line" =~ ^## ]]; then
        break
    fi
    if [ "${IN_TABLE:-0}" -eq 1 ] && [[ "$line" == \|* ]]; then
        # Skip header and separator
        [[ "$line" == "| Item |"* ]] && continue
        [[ "$line" == "|------"* ]] && continue
        # Parse: | A | P0 | description | 50 | or | A | P0 | description | |
        item=$(echo "$line" | awk -F'|' '{gsub(/^ | $/,"",$2); print $2}')
        pri=$(echo "$line" | awk -F'|' '{gsub(/^ | $/,"",$3); print $3}')
        desc=$(echo "$line" | awk -F'|' '{gsub(/^ | $/,"",$4); print $4}')
        est=$(echo "$line" | awk -F'|' '{gsub(/^ | $/,"",$5); print $5}')
        # Trim description to 40 chars for display
        desc_short="${desc:0:40}"
        [ "${#desc}" -gt 40 ] && desc_short="${desc_short}..."
        if [[ "$est" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            e="$est"
        else
            e="$DEFAULT_EST"
        fi
        TOTAL=$(awk "BEGIN{printf \"%.2f\", $TOTAL + $e}" 2>/dev/null)
        printf "  %-6s %-6s %-40s %8s\n" "$item" "$pri" "$desc_short" "$e"
    fi
done < "$PLAN_FILE"

printf "  ------------------------------------------------------------------------\n"
printf "  %-54s %8s\n" "TOTAL" "$TOTAL"
echo ""

REMAINING=$(awk "BEGIN{printf \"%.2f\", $LIMIT - $TOTAL}" 2>/dev/null)
if awk "BEGIN{exit(!($TOTAL <= $LIMIT))}" 2>/dev/null; then
    printf "  Fits in remaining \$%s: Yes   Left after plan: \$%s\n" "$LIMIT" "$REMAINING"
else
    OVER=$(awk "BEGIN{printf \"%.2f\", $TOTAL - $LIMIT}" 2>/dev/null)
    printf "  Fits in remaining \$%s: No   Over by: \$%s\n" "$LIMIT" "$OVER"
    echo "  → Drop or reduce P2 items, or lower Est. \$ for some rows."
fi
echo ""
echo "  Run import-usage-from-csv.sh so budget = current remaining."
echo "  Adjust Est. \$ in the wishlist table and re-run to reschedule."
echo ""
