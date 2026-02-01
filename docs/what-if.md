# What-if scenarios and cost estimates

Use **what-if** to try a new target % for a repo and see estimated cost ($), remaining buffer, and how many features/sessions fit. Then schedule features per repo in your monthly plan.

## 1. Set your budget (one-time)

Edit **config/budget.env**:

- **MONTHLY_BUDGET_DOLLARS** — Your Cursor Ultra (or Pro) period cap. Get it from the Cursor dashboard or use a placeholder (e.g. `400`). Leave blank to use % only.
- **DOLLARS_PER_FEATURE** — Rough $ per "feature" (e.g. `20`) so you can see how many features fit per repo.
- **DOLLARS_PER_SESSION** — Rough $ per Cursor session (e.g. `10`) for session-based planning.

## 2. Suggest a new target for a repo

Run:

```bash
./scripts/what-if-target.sh <project> <new_target_%>
```

**Example:**

```bash
./scripts/what-if-target.sh course-builder 25
```

You get:

- Current vs new target %
- Other repos' total % (unchanged)
- Total assigned % and remaining buffer
- **Estimated cost ($)** for that repo at the new % (if MONTHLY_BUDGET_DOLLARS is set)
- **~N features** at your DOLLARS_PER_FEATURE
- **~N sessions** at your DOLLARS_PER_SESSION
- A warning if total > 100% or buffer < 10%

Then you can update **projects.md** with the new target % (and optionally paste Est. $ from `./scripts/estimate-budget.sh`).

## 3. See estimated cost for all repos

Run:

```bash
./scripts/estimate-budget.sh
```

This reads **projects.md** and **config/budget.env** and prints a table with **Est. $** per project (and ~features, ~sessions). Use it to fill the "Est. $" column in projects.md or to plan the month.

## 4. Schedule features per repo (monthly plan)

In your monthly plan (e.g. **plans/2026-02.md**):

1. Set **target %** per project (from projects.md or from a what-if you liked).
2. In **Planned features per repo**, list features (and optional $ estimate) for each project.
3. Compare: **Est. $ for repo** (from what-if or estimate-budget) vs **sum of feature estimates**. If sum < est., you're within budget; if not, drop a feature or move % from another repo.

**Example:**

| Project         | Target % | Est. $ | Planned features (est. each)     | Sum  | Fits? |
|-----------------|----------|--------|----------------------------------|------|-------|
| course-builder  | 25%      | $100   | Auth ($40), Export ($35), UI ($30) | $105 | ✓     |
| datadog-drilldown | 15%   | $60    | Filters ($25), Save view ($30)   | $55  | ✓     |

## 5. Formulas (for reference)

- **Est. $ for repo** = `MONTHLY_BUDGET_DOLLARS × (target % / 100)`
- **~Features** = `Est. $ for repo / DOLLARS_PER_FEATURE`
- **~Sessions** = `Est. $ for repo / DOLLARS_PER_SESSION`
- **Remaining buffer** = `100 − (new % + sum of other repos' %)`

## 6. Tips

- Run what-if **before** changing projects.md to see impact.
- Use **estimate-budget.sh** after setting target % for all repos to get a full table and catch total > 100%.
- Adjust **DOLLARS_PER_FEATURE** over time from real usage (e.g. "that feature took ~2 sessions ≈ $20").
