# Automation scripts

Scripts to **automate data collection** for Embabel low-effort issues and **cost/budget** planning. Optional integration with [jmjava/embabel-learning](https://github.com/jmjava/embabel-learning).

## Requirements

- **gh** (GitHub CLI), authenticated: `gh auth status`
- **jq** (JSON processor)

## Scripts

| Script | Purpose |
|--------|--------|
| **fetch-embabel-issues.sh** | Fetch open issues with labels `good first issue`, `help wanted`, `documentation` from configured repos. Output: markdown table rows to stdout. |
| **update-embabel-low-effort-issues.sh** | Run fetch, then replace the "Auto-collected" block in `embabel-low-effort-issues.md` with the new table. |
| **what-if-target.sh** | What-if: suggest a new target % for a repo; shows estimated cost ($), ~features, ~sessions, remaining buffer. See [../docs/what-if.md](../docs/what-if.md). |
| **estimate-budget.sh** | Print table of all projects with Target % and Est. $ (~features, ~sessions). Reads budget.env and optional usage.env. |
| **usage-remaining.sh** | Show used, limit, remaining, % used, % remaining. Reads [../config/usage.env](../config/usage.env) (set by CSV import). See [../docs/usage-integration.md](../docs/usage-integration.md). |
| **import-usage-from-csv.sh** | Import usage CSV (file or stdin) → USED_DOLLARS in usage.env. |
| **embabel-issue-repos.txt** | List of `owner/repo` to scan (one per line). Edit to add/remove repos. |

## Quick run

```bash
# From repo root
./scripts/fetch-embabel-issues.sh          # Print table rows to stdout
./scripts/update-embabel-low-effort-issues.sh   # Update embabel-low-effort-issues.md
```

## Optional: use embabel-learning config and repo list

If you use [embabel-learning](https://github.com/jmjava/embabel-learning) (scripts to stay up to date on Embabel and support contributions), you can reuse its config and org repo list:

1. Set **EMBABEL_LEARNING_DIR** to your embabel-learning clone.
2. Set **USE_EMBABEL_LEARNING_REPOS=1** to scan all repos from `gh repo list $UPSTREAM_ORG` instead of `embabel-issue-repos.txt`.

```bash
export EMBABEL_LEARNING_DIR="$HOME/github/jmjava/embabel-learning"
export USE_EMBABEL_LEARNING_REPOS=1
./scripts/update-embabel-low-effort-issues.sh
```

- **Config:** Scripts source `$EMBABEL_LEARNING_DIR/scripts/config-loader.sh`, which loads `.env` or `config.sh` (same as embabel-learning’s `elist`, `eactions`, etc.).
- **Repo list:** With `USE_EMBABEL_LEARNING_REPOS=1`, repos come from `gh repo list $UPSTREAM_ORG` (embabel org by default). Without it, repos are read from `scripts/embabel-issue-repos.txt`.

## Cron / scheduled run

To refresh the list weekly:

```bash
# crontab -e
0 9 * * 1 cd /path/to/cursor_usage_plan && ./scripts/update-embabel-low-effort-issues.sh
```

## Labels scanned

- `good first issue`
- `help wanted`
- `documentation`

To change labels, edit `LOW_EFFORT_LABELS` in `fetch-embabel-issues.sh`.
