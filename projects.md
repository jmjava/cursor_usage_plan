# Project Registry & Budget

Use this file to assign **priority** and **target % of monthly Cursor usage** per project. Adjust percentages so they sum to ~85–90% (leave 10–15% buffer for ad-hoc use).

## Budget parameters (for what-if & cost estimates)

Fill these to get **estimated cost ($) per repo** and to run [what-if scenarios](docs/what-if.md). Leave blank to use % only.

| Parameter | Value | Notes |
|-----------|-------|--------|
| **Monthly budget ($)** | _e.g. 400_ | Your Cursor Ultra (or Pro) monthly cap; check Cursor dashboard or use a placeholder. |
| **$ per feature** | _e.g. 20_ | Rough estimate per “feature” so you can schedule how many features fit per repo. |
| **$ per session** | _e.g. 10_ | Rough per Cursor session; optional, for session-based planning. |

- To **suggest a new target** for a repo and see estimated cost: run `./scripts/what-if-target.sh <project> <new_%>` (see [docs/what-if.md](docs/what-if.md)).
- Set numeric values in [config/budget.env](config/budget.env) for scripts; **Est. $** below are computed when **Monthly budget ($)** is set there.

## Projects

| # | Project | Repo | Priority | Target % | Est. $ | Notes |
|---|--------|------|----------|----------|-------------|--------|
| 1 | course-builder | [menkelabs/course-builder](https://github.com/menkelabs/course-builder) | _set_ | _%_ | — | Course creation / authoring |
| 2 | datadog-drilldown | [menkelabs/datadog-drilldown](https://github.com/menkelabs/datadog-drilldown) | _set_ | _%_ | — | Datadog exploration / drill-down |
| 3 | camera_recorder | [menkelabs/camera_recorder](https://github.com/menkelabs/camera_recorder) | _set_ | _%_ | — | Dual USB cameras, MediaPipe, golf swing |
| 4 | embabel-agent-rag-sample | [menkelabs/embabel-agent-rag-sample](https://github.com/menkelabs/embabel-agent-rag-sample) | _set_ | _%_ | — | RAG + Embabel demo (Java/React) |
| 5 | chatbot | [menkelabs/chatbot](https://github.com/menkelabs/chatbot) | _set_ | _%_ | — | Chatbot application |
| 6 | reference-architecture-poc | [menkelabs/reference-architecture-poc](https://github.com/menkelabs/reference-architecture-poc) | _set_ | _%_ | — | Reference architecture proof-of-concept |

**Buffer (unassigned):** 10–15% for debugging, spikes, and experiments.

---

## Priority scale (suggested)

- **P0** – Must progress every month (e.g. 1–2 projects).
- **P1** – Important; aim for steady progress (e.g. 2–3 projects).
- **P2** – When P0/P1 are covered; opportunistic.

## Example allocation (customize to your goals)

| Priority | Projects | Combined % |
|----------|----------|------------|
| P0 | course-builder, reference-architecture-poc | 35% |
| P1 | embabel-agent-rag-sample, datadog-drilldown | 30% |
| P2 | camera_recorder, chatbot | 25% |
| Buffer | — | 10% |

**Total:** 100%

---

## Clone / workspace paths (optional)

Fill these in so you can open the right workspace quickly:

| Project | Local path |
|---------|------------|
| course-builder | |
| datadog-drilldown | |
| camera_recorder | |
| embabel-agent-rag-sample | |
| chatbot | |
| reference-architecture-poc | |
