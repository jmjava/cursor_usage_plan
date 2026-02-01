#!/usr/bin/env bash
# What-if: suggest a new target % for a repo and see estimated cost ($) + impact.
#
# Usage: ./scripts/what-if-target.sh <project> <new_target_%>
# Example: ./scripts/what-if-target.sh course-builder 25
#
# Reads: config/budget.env, config/usage.env (optional), projects.md.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
PLAN_DIR="$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)"
PROJECTS_MD="$PLAN_DIR/projects.md"
BUDGET_ENV="$PLAN_DIR/config/budget.env"
USAGE_ENV="$PLAN_DIR/config/usage.env"

# Load budget (skip comments and empty)
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

PROJECT="${1:-}"
NEW_PCT="${2:-}"

if [ -z "$PROJECT" ] || [ -z "$NEW_PCT" ]; then
    echo "Usage: $0 <project> <new_target_%>" >&2
    echo "Example: $0 course-builder 25" >&2
    echo "" >&2
    echo "Projects (from projects.md):" >&2
    awk -F'|' '/^\| [0-9]+ \| [a-z]/{gsub(/^ | $/,"",$3); print "  - " $3}' "$PROJECTS_MD" 2>/dev/null | head -20
    exit 1
fi

# Validate new_pct is a number
if ! [[ "$NEW_PCT" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Error: new_target_% must be a number (e.g. 25 or 15.5)" >&2
    exit 1
fi

# Parse projects table: | # | Project | Repo | Priority | Target % | Est. $ | Notes |
# Pipe-separated; trim spaces. Column 3 = project, column 6 = target %.
CURRENT_PCT="0"
OTHERS_SUM=0

while IFS= read -r line; do
    [[ "$line" != \|* ]] && continue
    # Skip header and separator
    [[ "$line" == "| # |"*"Project"* ]] && continue
    [[ "$line" == "|---"* ]] && continue
    # Data row: split by |
    pslug=$(echo "$line" | awk -F'|' '{gsub(/^ | $/,"",$3); print $3}')
    pct=$(echo "$line" | awk -F'|' '{gsub(/^ | $/,"",$6); print $6}')
    [[ "$pct" =~ ^[0-9]+(\.[0-9]+)?$ ]] || continue
    if [ "$pslug" = "$PROJECT" ]; then
        CURRENT_PCT="$pct"
    else
        OTHERS_SUM=$(awk "BEGIN{printf \"%.1f\", $OTHERS_SUM + $pct}" 2>/dev/null || echo "$OTHERS_SUM")
    fi
done < <(awk '/^\| [0-9]+ \| [a-zA-Z0-9_-]+ \|/{print}' "$PROJECTS_MD" 2>/dev/null)

# Ensure OTHERS_SUM is numeric (in case bc wasn't used)
[[ "$OTHERS_SUM" =~ ^[0-9]+(\.[0-9]+)?$ ]] || OTHERS_SUM=0

TOTAL_AFTER=$(awk "BEGIN{printf \"%.1f\", $NEW_PCT + $OTHERS_SUM}" 2>/dev/null || echo "$NEW_PCT")
REMAINING=$(awk "BEGIN{printf \"%.1f\", 100 - $TOTAL_AFTER}" 2>/dev/null || echo "?")

echo "=========================================="
echo "What-if: set $PROJECT to $NEW_PCT%"
echo "=========================================="
echo ""
echo "  Current target %:  ${CURRENT_PCT:-0}%"
echo "  New target %:     ${NEW_PCT}%"
echo "  Other repos sum:   ${OTHERS_SUM}%"
echo "  Total assigned:   ${TOTAL_AFTER}%"
echo "  Remaining buffer: ${REMAINING}%"
echo ""

if [ -n "${MONTHLY_BUDGET_DOLLARS:-}" ] && [[ "${MONTHLY_BUDGET_DOLLARS}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    EST_DOLLARS=$(awk "BEGIN{printf \"%.2f\", $MONTHLY_BUDGET_DOLLARS * $NEW_PCT / 100}" 2>/dev/null || echo "?")
    echo "  Estimated cost for $PROJECT at $NEW_PCT%: \$$EST_DOLLARS"
    if [ -n "${DOLLARS_PER_FEATURE:-}" ] && [[ "${DOLLARS_PER_FEATURE}" =~ ^[0-9]+(\.[0-9]+)?$ ]] && [ "$EST_DOLLARS" != "?" ]; then
        FEATURES=$(awk "BEGIN{printf \"%.0f\", $EST_DOLLARS / $DOLLARS_PER_FEATURE}" 2>/dev/null || echo "?")
        echo "  At ~\$${DOLLARS_PER_FEATURE}/feature: ~${FEATURES} features"
    fi
    if [ -n "${DOLLARS_PER_SESSION:-}" ] && [[ "${DOLLARS_PER_SESSION}" =~ ^[0-9]+(\.[0-9]+)?$ ]] && [ "$EST_DOLLARS" != "?" ]; then
        SESSIONS=$(awk "BEGIN{printf \"%.0f\", $EST_DOLLARS / $DOLLARS_PER_SESSION}" 2>/dev/null || echo "?")
        echo "  At ~\$${DOLLARS_PER_SESSION}/session: ~${SESSIONS} sessions"
    fi
    if [ -n "${USED_DOLLARS:-}" ] && [[ "${USED_DOLLARS}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        REM=$(awk "BEGIN{printf \"%.2f\", $MONTHLY_BUDGET_DOLLARS - $USED_DOLLARS}" 2>/dev/null)
        REM_FOR_REPO=$(awk "BEGIN{printf \"%.2f\", $REM * $NEW_PCT / 100}" 2>/dev/null)
        echo "  Remaining this period (usage.env): \$$REM → at $NEW_PCT%, ~\$$REM_FOR_REPO for this repo"
    elif [ -n "${REMAINING_DOLLARS:-}" ] && [[ "${REMAINING_DOLLARS}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        REM_FOR_REPO=$(awk "BEGIN{printf \"%.2f\", $REMAINING_DOLLARS * $NEW_PCT / 100}" 2>/dev/null)
        echo "  Remaining this period (usage.env): \$$REMAINING_DOLLARS → at $NEW_PCT%, ~\$$REM_FOR_REPO for this repo"
    fi
    echo ""
else
    echo "  (Set MONTHLY_BUDGET_DOLLARS in config/budget.env for cost estimates.)"
    echo ""
fi

if [ -n "$REMAINING" ] && [ "$REMAINING" != "?" ]; then
    if awk "BEGIN{exit(!($REMAINING < 0))}" 2>/dev/null; then
        echo "  ⚠ Total > 100%. Reduce other repos or lower this target."
    elif awk "BEGIN{exit(!($REMAINING < 10))}" 2>/dev/null; then
        echo "  ⚠ Buffer < 10%. Consider leaving 10–15% unassigned."
    fi
fi
