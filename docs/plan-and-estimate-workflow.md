# Workflow: “I want to do A, B, C with these priorities — estimate cost and help me schedule”

This workflow lets you **state what you want to do (A, B, C)** with **priorities**, then **run planning** to **estimate cost for each** and see if it **fits in $400** so you can schedule.

## 1. List what you want to do (wishlist)

In your monthly plan (e.g. **plans/2026-02.md**), fill the **“What I want to do this month (wishlist)”** table:

| Item | Priority | Description | Est. $ |
|------|----------|-------------|--------|
| A | P0 | Auth for course-builder | 50 |
| B | P0 | Export PDF | 30 |
| C | P1 | Datadog filter UI | 20 |
| D | P2 | Docs pass on RAG sample | 15 |

- **Item** — Short label (A, B, C or a name).
- **Priority** — P0 (must do), P1 (should do), P2 (nice to have).
- **Description** — One line of what you want to do.
- **Est. $** — Rough cost for that item. Leave **blank** to use the default from **config/budget.env** (`DOLLARS_PER_FEATURE`, e.g. $20).

## 2. Run planning to estimate cost

From the repo root:

```bash
./scripts/estimate-plan.sh
```

Or pass a specific plan file:

```bash
./scripts/estimate-plan.sh plans/2026-02.md
```

The script:

- Reads the wishlist table from that plan.
- Uses **Est. $** when you filled it; otherwise uses **DOLLARS_PER_FEATURE** from **config/budget.env**.
- Sums cost for all items.
- Compares the total to **MONTHLY_BUDGET_DOLLARS** (e.g. $400).
- Prints: **each item with Est. $**, **total**, and **“Fits in $400: Yes”** (with remaining $) or **“Fits: No — Over by $X”** (and suggests dropping P2 or lowering estimates).

## 3. Use the output to schedule

- If **Fits: Yes** — Schedule the items in **week-by-week** in the same plan; you’re within $400.
- If **Fits: No** — Drop or shrink P2 items, or lower **Est. $** for some rows, then re-run **estimate-plan.sh** until the total fits. Then schedule what’s left in week-by-week.

## 4. Optional: refine estimates

- Edit **Est. $** in the wishlist (e.g. after a first run you might set A=40, B=25).
- Re-run **`./scripts/estimate-plan.sh`** to see the new total and fit.

## Quick reference

| Step | Action |
|------|--------|
| 1 | In **plans/YYYY-MM.md**, fill **“What I want to do this month (wishlist)”**: Item, Priority, Description, Est. $ (or leave blank). |
| 2 | Run **`./scripts/estimate-plan.sh`** (or with path to plan file). |
| 3 | Read output: cost per item, total, “Fits in $400?” and remaining/over. |
| 4 | If over: drop P2 or lower Est. $ and re-run. If fits: copy items into **week-by-week** and schedule. |

Your monthly plan is the single place where you state **what you want to do (A, B, C)** with **priorities**; the script does the **planning and cost estimate** so you can **schedule within $400**.
