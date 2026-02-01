#!/usr/bin/env bash
# Regenerate the "Auto-collected" table in embabel-low-effort-issues.md
# by running fetch-embabel-issues.sh and replacing the block between markers.
#
# Optional: use embabel-learning for repo list (same as fetch-embabel-issues.sh):
#   export EMBABEL_LEARNING_DIR=/path/to/embabel-learning
#   export USE_EMBABEL_LEARNING_REPOS=1

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
PLAN_DIR="$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)"
MD_FILE="$PLAN_DIR/embabel-low-effort-issues.md"

START_MARKER="<!-- AUTO-COLLECTED-START -->"
END_MARKER="<!-- AUTO-COLLECTED-END -->"

if [ ! -f "$MD_FILE" ]; then
    echo "Not found: $MD_FILE" >&2
    exit 1
fi

# Run fetch and capture markdown table rows
ROWS=$("$SCRIPT_DIR/fetch-embabel-issues.sh" 2>/dev/null) || true
TODAY=$(date +%Y-%m-%d)

# Build the replacement block in a temp file
TMP_BLOCK=$(mktemp)
trap 'rm -f "$TMP_BLOCK"' EXIT

{
    echo "$START_MARKER"
    echo "*Generated on ${TODAY} by \`scripts/update-embabel-low-effort-issues.sh\`.*"
    echo ""
    echo "| Repo | Issue | Title | Effort | Labels | Added |"
    echo "|------|-------|--------|--------|--------|-------|"
    echo "$ROWS"
    echo ""
    echo "$END_MARKER"
} > "$TMP_BLOCK"

# Replace content between (and including) the two markers
if grep -qF "$START_MARKER" "$MD_FILE" && grep -qF "$END_MARKER" "$MD_FILE"; then
    BEFORE=$(awk -v start="$START_MARKER" '$0==start{exit} {print}' "$MD_FILE")
    AFTER=$(awk -v end="$END_MARKER" '$0==end{skip=1;next} skip{print}' "$MD_FILE")
    {
        echo "$BEFORE"
        cat "$TMP_BLOCK"
        echo "$AFTER"
    } > "$MD_FILE.tmp" && mv "$MD_FILE.tmp" "$MD_FILE"
else
    echo "Markers not found in $MD_FILE; run once with markers (see embabel-low-effort-issues.md)." >&2
    exit 1
fi

echo "Updated $MD_FILE (Auto-collected table)."
