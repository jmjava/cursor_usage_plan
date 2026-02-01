# Cursor Usage Plan — YYYY-MM

**Month:** YYYY-MM  
**Goal:** Use your $400 this period (resets on your rollover day—set `BUDGET_ROLLOVER_DAY` in [config/budget.env](../config/budget.env), e.g. 17). See [projects.md](../projects.md) for target % and Est. $ per project.

---

## What I want to do this month (wishlist)

List **A, B, C** (and more) with **priorities**. Add **Est. $** per item (or leave blank to use default from config). Then run **`./scripts/estimate-plan.sh`** to sum cost and check fit vs $400 — use that to schedule.

| Item | Priority | Description | Est. $ |
|------|----------|-------------|--------|
| A | P0 | _e.g. Auth for course-builder_ | |
| B | P0 | _e.g. Export PDF_ | |
| C | P1 | _e.g. Datadog filter UI_ | |
| _add rows…_ | | | |

**Workflow:** Fill table above → run `./scripts/estimate-plan.sh` → see total and “Fits?” → schedule in week-by-week below. See [docs/plan-and-estimate-workflow.md](../docs/plan-and-estimate-workflow.md).

---

## Monthly goals (one line per project)

_(Project rows come from [projects.md](../projects.md), generated from [config/projects.list](../config/projects.list). Run `./scripts/refresh-projects-md.sh` after changing the config, then copy the project rows here.)_

| Project | Goal this month | Target % |
|---------|-----------------|----------|
| _copy from projects.md_ | | % |

---

## Planned features per repo (schedule to use your $400)

Use [what-if](../docs/what-if.md) and `./scripts/estimate-budget.sh` to get **Est. $** per repo. List planned features (and rough $ each); check sum ≤ Est. $ so you use the full budget. _(Project list from [projects.md](../projects.md).)_

| Project | Est. $ (from budget) | Planned features (est. $ each) | Sum | Fits? |
|---------|----------------------|-------------------------------|-----|-------|
| _copy from projects.md_ | | _e.g. Auth ($20), Export ($15)_ | | |

---

## Week-by-week focus

### Week 1 (dates)
- **Primary:** _project_
- **Tasks:** _bullet list_
- **Session slots:** _e.g. 2–3 focused sessions_

### Week 2 (dates)
- **Primary:** _project_
- **Tasks:** _bullet list_
- **Session slots:** _e.g. 2–3 focused sessions_

### Week 3 (dates)
- **Primary:** _project_
- **Tasks:** _bullet list_
- **Session slots:** _e.g. 2–3 focused sessions_

### Week 4 (dates)
- **Primary:** _project_
- **Tasks:** _bullet list_
- **Session slots:** _e.g. 2–3 focused sessions_

---

## Buffer: use remaining $ (so you hit $400)

- **Embabel low-effort issues:** [embabel-low-effort-issues.md](../embabel-low-effort-issues.md) — if you have remaining budget, pick 1–2 S/M issues so you use the full $400.
- _Optional:_ Target _N_ Embabel issues this month: _number_

---

## Planning sessions (use budget on planning)

| Date | Type | Project(s) | Outcome |
|------|------|------------|---------|
| | Planning | | |
| | Planning | | |
| | Planning | | |

---

## Execution sessions (optional log)

| Date | Project | What you did | Notes |
|------|---------|--------------|-------|
| | | | |
| | | | |

---

## End-of-period check (before next rollover)

- [ ] Did I use most of my $400? (Run `./scripts/usage-remaining.sh`.)
- [ ] Did I hit target % for P0 projects?
- [ ] Any remaining $ left? If yes, note it and plan to use it next period (or Embabel issues).
- [ ] Adjust next period’s [projects.md](../projects.md) priorities if needed.
