#!/usr/bin/env bash
# Fetch open issues with low-effort labels from Embabel (and related) repos.
# Output: markdown table rows for embabel-low-effort-issues.md.
#
# Optional: use embabel-learning config and repo list:
#   export EMBABEL_LEARNING_DIR=/path/to/embabel-learning
#   export USE_EMBABEL_LEARNING_REPOS=1   # use gh repo list UPSTREAM_ORG instead of embabel-issue-repos.txt
#
# Requires: gh (GitHub CLI), jq

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
REPOS_FILE="$SCRIPT_DIR/embabel-issue-repos.txt"

# Labels we consider "low effort" (issues with any of these)
LOW_EFFORT_LABELS=("good first issue" "help wanted" "documentation")

# Optional: load embabel-learning config so we can use UPSTREAM_ORG and repo list
if [ -n "${EMBABEL_LEARNING_DIR:-}" ] && [ -d "$EMBABEL_LEARNING_DIR" ]; then
    CONFIG_LOADER="$EMBABEL_LEARNING_DIR/scripts/config-loader.sh"
    if [ -f "$CONFIG_LOADER" ]; then
        LEARNING_DIR="$EMBABEL_LEARNING_DIR" source "$CONFIG_LOADER" 2>/dev/null || true
    fi
fi

# Build list of repos to scan
REPOS=()
if [ -n "${USE_EMBABEL_LEARNING_REPOS:-}" ] && [ -n "${UPSTREAM_ORG:-}" ]; then
    while IFS= read -r name; do
        [ -n "$name" ] && REPOS+=("$UPSTREAM_ORG/$name")
    done < <(gh repo list "$UPSTREAM_ORG" --limit 100 --json name --jq '.[].name' 2>/dev/null || true)
fi
if [ ${#REPOS[@]} -eq 0 ] && [ -f "$REPOS_FILE" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        line="${line%%#*}"
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -n "$line" ] && REPOS+=("$line")
    done < "$REPOS_FILE"
fi
if [ ${#REPOS[@]} -eq 0 ]; then
    echo "No repos to scan. Set USE_EMBABEL_LEARNING_REPOS=1 and EMBABEL_LEARNING_DIR, or edit scripts/embabel-issue-repos.txt" >&2
    exit 1
fi

TMP_ISSUES=$(mktemp)
trap 'rm -f "$TMP_ISSUES"' EXIT

TODAY=$(date +%Y-%m-%d)

for repo in "${REPOS[@]}"; do
    for label in "${LOW_EFFORT_LABELS[@]}"; do
        gh issue list --repo "$repo" --state open --label "$label" --limit 50 \
            --json number,title,url,labels,createdAt 2>/dev/null | \
        jq -r --arg repo "$repo" --arg today "$TODAY" '
            .[] |
            "\(.url)\t\($repo)\t\(.number)\t\(.title)\t—\t\(.labels | map(.name) | join(", "))\t\($today)"
        ' 2>/dev/null >> "$TMP_ISSUES"
    done
done

# Dedupe by URL (first column), then output markdown rows
sort -u -t$'\t' -k1,1 "$TMP_ISSUES" 2>/dev/null | while IFS=$'\t' read -r url repo num title _ labels added; do
    [ -z "$num" ] && continue
    title=$(echo "$title" | sed 's/|/\\|/g')
    echo "| $repo | [#$num]($url) | $title | — | $labels | $added |"
done
