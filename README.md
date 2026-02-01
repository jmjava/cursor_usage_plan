# Cursor Ultra Usage Planning

**This repo is an example/template.** Clone it and adapt to your own projects: set your repos in [config/projects.list](config/projects.list), run `./scripts/refresh-projects-md.sh`, and use the scripts as-is. The project list and links in the repo are only examples—replace them with your own.

**Goal: Effectively use your $400 each period.**  
Your Ultra budget resets on a **fixed day each month** (e.g. the 17th—set `BUDGET_ROLLOVER_DAY` in [config/budget.env](config/budget.env)). Plan and divide it across projects so you use the full amount on high-value work instead of leaving it on the table.

## Workflow at a glance

1. **Provide current usage** – Export usage CSV from the [Cursor dashboard](https://cursor.com/dashboard?tab=usage) (or paste raw CSV). Run **`./scripts/import-usage-from-csv.sh`** with the file path, or pipe/paste CSV so it updates **USED_DOLLARS** in [config/usage.env](config/usage.env). Then **`./scripts/usage-remaining.sh`** shows remaining $ for this period.
2. **Work in your monthly plan** – Your planning document is **[plans/YYYY-MM.md](plans/)** (e.g. `plans/2026-02.md`). Create it from [templates/monthly-plan-template.md](templates/monthly-plan-template.md) or keep an existing file that follows that structure (wishlist, week-by-week, end-of-period check). Fill the wishlist, run **`./scripts/estimate-plan.sh`** to see if it fits in remaining $, then schedule.

So: **start with current usage CSV → then plan in a document that conforms to the monthly plan template.**

**→ [RUNBOOK.md](RUNBOOK.md)** — commands-only run flow (import CSV → remaining → plan → estimate). RUNBOOK also explains how **projects.md** (allocation by target %) and **plans/YYYY-MM.md** (period plan from the monthly template) work together.  
**→ [docs/README-diagrams.md](docs/README-diagrams.md)** — PlantUML flow diagrams (overview, commands, two-docs). Export PNG: run `./scripts/download-plantuml.sh` once (downloads JAR to lib/), then `./scripts/export-puml-png.sh`.  
**→ [docs/security-and-config.md](docs/security-and-config.md)** — No secrets; planning repos are configurable via [config/projects.list](config/projects.list).

## How to use your $400 each period (resets on your rollover day)

1. **State what you want to do (A, B, C) with priorities** – In your monthly plan ([plans/YYYY-MM.md](plans/)), fill the **“What I want to do this month (wishlist)”** table: Item, Priority, Description, Est. $ (or leave Est. $ blank to use default).
2. **Run planning to estimate cost** – Run **`./scripts/estimate-plan.sh`**. It sums Est. $ per item (using [config/budget.env](config/budget.env) default for blank rows) and tells you **total** and **“Fits in $400?”** so you can schedule.
3. **Schedule** – If it fits, copy items into **week-by-week** in the same plan. If over, drop P2 items or lower Est. $ and re-run.
4. **Set budget** – [config/budget.env](config/budget.env): `MONTHLY_BUDGET_DOLLARS=400`, `BUDGET_ROLLOVER_DAY` (e.g. `17` = resets on the 17th; use your plan’s reset day), and optional `DOLLARS_PER_FEATURE` (default Est. $ when wishlist row is blank).
5. **Assign % per project** – [projects.md](projects.md): give each repo a target %; use **what-if** and **estimate-budget.sh** for Est. $ per repo.
6. **Track usage** – Export usage CSV from the dashboard (or paste raw CSV), run **`./scripts/import-usage-from-csv.sh`**, then **`./scripts/usage-remaining.sh`** to see **used / remaining $**. See [docs/usage-integration.md](docs/usage-integration.md).
7. **Buffer before next reset** – If you have remaining $, add work or pick from your own buffer list (or the optional [embabel-low-effort-issues.md](embabel-low-effort-issues.md) if you keep it) so you use the full $400 before the next rollover.

See **[docs/plan-and-estimate-workflow.md](docs/plan-and-estimate-workflow.md)** for the full “I want to do A, B, C — estimate cost and help me schedule” workflow.

## File layout

```
cursor_usage_plan/
├── README.md                      # This file
├── projects.md                    # Project registry + target % + Est. $
├── embabel-low-effort-issues.md   # Buffer: low-effort Embabel issues
├── config/
│   ├── budget.env                 # MONTHLY_BUDGET_DOLLARS=400, BUDGET_ROLLOVER_DAY (e.g. 17), etc.
│   └── usage.env                  # USED_DOLLARS (set by import-usage-from-csv.sh)
├── scripts/
│   ├── estimate-plan.sh           # Plan & estimate: wishlist → sum Est. $, Fits in $400?
│   ├── usage-remaining.sh         # Used / remaining $, % remaining, ~features left
│   ├── what-if-target.sh          # What-if: new target % → Est. $, ~features
│   ├── estimate-budget.sh         # Table: Est. $ per project (~features, ~sessions)
│   ├── import-usage-from-csv.sh   # Import dashboard CSV → USED_DOLLARS in usage.env
│   ├── fetch-embabel-issues.sh    # Fetch low-effort Embabel issues
│   ├── update-embabel-low-effort-issues.sh
│   └── embabel-issue-repos.txt
├── templates/
│   └── monthly-plan-template.md
├── plans/                         # One file per month, e.g. 2026-02.md
└── docs/
    ├── planning-sessions.md       # How to batch work to use your $400
    ├── what-if.md                 # What-if and Est. $ per repo
    └── usage-integration.md       # CSV import → usage.env
```

## Scripts (all cost-based, $400)

| Script | What it does |
|--------|----------------|
| **estimate-plan.sh** | **Plan and estimate cost:** reads “What I want to do (wishlist)” from your monthly plan, sums Est. $ per item (default for blank rows), and reports total and “Fits in $400?” so you can schedule. See [docs/plan-and-estimate-workflow.md](docs/plan-and-estimate-workflow.md). |
| **usage-remaining.sh** | Shows used $, remaining $, % remaining, ~features left. Run after [importing CSV](docs/usage-integration.md). |
| **what-if-target.sh** | e.g. `./scripts/what-if-target.sh <project> 25` → Est. $ for that repo at 25%, ~features, remaining $ for repo. |
| **estimate-budget.sh** | Table of Est. $ per project (and ~features, ~sessions) from target %. |
| **import-usage-from-csv.sh** | Provide current usage: pass CSV file, or pipe/paste raw CSV into the script → updates USED_DOLLARS in usage.env. |

## Tips for using the full $400

- **Plan in $** – In your monthly plan, list planned features with rough $ per feature (e.g. “Auth ~$20, Export ~$15”) so you add up to ~$400.
- **Check remaining often** – Run `./scripts/usage-remaining.sh` weekly; if remaining is high, schedule more work or buffer tasks.
- **Reserve buffer %** – Keep 10–15% unassigned for ad-hoc work; use it in the last week if you still have remaining $.
- **Fill with buffer work** – Use your own list of low-effort tasks (or the optional [embabel-low-effort-issues.md](embabel-low-effort-issues.md) if you keep it) when you have extra budget so nothing is left unused.
