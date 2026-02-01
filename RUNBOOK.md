# Runbook — commands only

Budget resets on a **fixed day** each month (set `BUDGET_ROLLOVER_DAY` in config/budget.env, e.g. 17). Usage comes from **CSV** (dashboard → export).

---

## How the two flows work together

| | **projects.md** | **plans/YYYY-MM.md** (monthly plan) |
|---|------------------|-------------------------------------|
| **What** | Allocation: target % per project (e.g. course-builder 25%, datadog 15%). | This period’s plan: wishlist (tasks A, B, C) + planned features per repo. |
| **When** | Set once or when rebalancing. | One file per period; copy from template when starting a new period. |
| **Scripts** | `estimate-budget.sh` (Est. $ per project), `what-if-target.sh` (try a new %). | `estimate-plan.sh` (does wishlist total fit in remaining $?). |
| **Link** | Est. $ per project from here feed into the monthly plan’s “Planned features per repo” table — each repo’s features should sum to ≤ that repo’s Est. $. | Wishlist is a flat list of tasks; “Planned features per repo” splits by project using Est. $ from projects.md / estimate-budget.sh. |

**In practice:** Set target % in **projects.md** → run **estimate-budget.sh** to get Est. $ per project → in **plans/YYYY-MM.md** fill the wishlist (run **estimate-plan.sh** to check total fits remaining) and fill “Planned features per repo” (keep each repo’s sum ≤ its Est. $ from the table).

---

## 1. Load current usage (do this first)

Export CSV from [dashboard](https://cursor.com/dashboard?tab=usage), then:

```bash
./scripts/import-usage-from-csv.sh path/to/export.csv
```

Or pipe/paste raw CSV:

```bash
cat export.csv | ./scripts/import-usage-from-csv.sh
```

---

## 2. See used / remaining $

```bash
./scripts/usage-remaining.sh
```

---

## 3. Plan the period (wishlist → fits?)

**Where the template fits:** Your working plan is **plans/YYYY-MM.md** (e.g. `plans/2026-02.md`). If you don’t have one yet, create it by copying [templates/monthly-plan-template.md](templates/monthly-plan-template.md) into `plans/YYYY-MM.md`. That file is what you edit and what `estimate-plan.sh` reads.

Edit the **wishlist** table in **plans/YYYY-MM.md**, then:

```bash
./scripts/estimate-plan.sh
# or: ./scripts/estimate-plan.sh plans/2026-02.md
```

Adjust wishlist until total fits remaining; copy into week-by-week.

---

## 4. Per-project estimates (from projects.md target %)

Table of Est. $ per project:

```bash
./scripts/estimate-budget.sh
```

What-if for one repo (e.g. give course-builder 25%):

```bash
./scripts/what-if-target.sh course-builder 25
```

---

## 5. Optional — refresh Embabel low-effort list

```bash
./scripts/update-embabel-low-effort-issues.sh
```

Pick from [embabel-low-effort-issues.md](embabel-low-effort-issues.md) when you have remaining $.

---

## Config (one-time or rare)

- **config/budget.env** — `MONTHLY_BUDGET_DOLLARS=400`, `BUDGET_ROLLOVER_DAY` (e.g. 17 = resets on the 17th), `DOLLARS_PER_FEATURE=20`, `DOLLARS_PER_SESSION=10`
- **config/usage.env** — set by import script (USED_DOLLARS)
- **projects.md** — target % per project
- **plans/YYYY-MM.md** — your plan for the period; copy from [templates/monthly-plan-template.md](templates/monthly-plan-template.md) when starting a new period
