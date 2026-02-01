# Planning Sessions — Use Your $400 Effectively

Planning sessions help you **batch thinking** and **batch doing** so your Cursor Ultra budget ($400) goes to high-value work instead of scattered context switches — and you use the full amount each month.

---

## Why planning sessions help

1. **Use your $400 on high-value work** – One 30–60 min “planning” session in Cursor can produce a clear task list; then you execute in focused sessions that consume budget deliberately.
2. **Fewer context switches** – Opening one project, planning the week, then executing reduces thrashing between repos and makes it easier to spend the budget where it matters.
3. **Easier to use the full $400** – If you reserve “planning” time each week, you naturally create sessions (design, refactors, architecture) that use budget instead of leaving it unused.

---

## Two types of sessions

### 1. Planning session (budget-heavy)

**Goal:** Decide *what* to do and *in what order* for a project or week.

**Good for:**
- Breaking a feature into concrete tasks
- Reviewing codebase and listing tech-debt items
- Designing an approach (APIs, data model, tests)
- Writing specs or ADRs in the repo

**How to run:**
1. Open the target project in Cursor.
2. Prompt with context: “I’m planning work for [project] this week. Here are my goals: [list]. Review [relevant files/areas] and give me a prioritized task list with rough effort (S/M/L).”
3. Refine the list with follow-ups (dependencies, order, risks).
4. Copy the final list into your monthly plan (e.g. `plans/YYYY-MM.md`) under the right week.

**Typical length:** 20–45 min. Use Composer/Agent so your budget goes to analysis and planning.

---

### 2. Execution session (focused)

**Goal:** Do the work from the plan with minimal context switching.

**Good for:**
- Implementing a single task or small batch of tasks from the plan
- Fixing a specific bug or refactoring one area
- Writing tests for a defined scope

**How to run:**
1. Open the project and the exact file/area from your plan.
2. Reference the task: “Implement [task from plan]. Context: [link or short summary].”
3. Complete the task (or a clear chunk); if you discover new work, add it to the plan instead of branching in Cursor.
4. Log the session in your monthly plan if you track execution.

**Typical length:** 15–45 min per task. Keeps usage focused and measurable.

---

## Weekly rhythm (example)

| Day | Session type | Project | Purpose |
|-----|--------------|--------|--------|
| Monday | Planning | P0 project A | Plan week’s tasks for A |
| Tue–Thu | Execution | P0 project A | Do tasks from Monday’s plan |
| Wednesday | Planning | P1 project B | Plan next week or current sprint for B |
| Friday | Execution | P1 project B | Do 1–2 tasks from B’s plan |
| Weekend/buffer | Execution | Embabel low-effort issues | Pick from [Embabel low-effort list](../embabel-low-effort-issues.md) to use remaining $ |

Adjust to your calendar; the idea is: **plan once per project per week**, then **execute in batches**. Use **buffer** for Embabel low-effort issues when you have remaining budget so you use your full $400.

---

## Prompts that use budget well (planning)

- “List all call sites of [X] and suggest a refactor plan with steps and risks.”
- “I want to add [feature]. Break it into tasks: backend, frontend, tests, docs. Mark dependencies.”
- “Review [module] and give me a prioritized tech-debt list with S/M/L effort.”
- “Draft a one-page design for [change]. Include API changes and migration steps.”

---

## Prompts that use budget well (execution)

- “Implement [task N] from this plan: [paste task]. Constraints: [e.g. don’t change X].”
- “Add unit tests for [file/class] covering [scenarios from plan].”
- “Refactor [function/class] to [goal]. Keep behavior; add a short comment at the top.”

---

## Making sure you use your full budget

1. **Reserve planning slots** – Put 2–4 “planning” sessions per week in your calendar so budget-heavy work is guaranteed.
2. **Assign projects to weeks** – In your monthly plan, assign 1–2 primary projects per week so you know where to spend.
3. **Mid-month check** – Run `./scripts/usage-remaining.sh`. If you’re under pace (e.g. lots of $ left), add an extra planning session, a “deep dive,” or 1–2 items from the [Embabel low-effort issues](../embabel-low-effort-issues.md) list.
4. **Buffer** – Keep 10–15% unassigned for bugs and experiments; use it in the last week if you still have remaining $.
5. **Embabel low-effort issues** – When you have remaining budget, pick S/M issues from [embabel-low-effort-issues.md](../embabel-low-effort-issues.md). One short Cursor session per issue = predictable spend and helps you use the full $400.

---

## Buffer usage: Embabel low-effort issues

When you have remaining $ (buffer or end-of-week), use it on **low-effort Embabel project issues**:

- **List:** [../embabel-low-effort-issues.md](../embabel-low-effort-issues.md) — add issues from [embabel/embabel-agent](https://github.com/embabel/embabel-agent/issues), [embabel-agent-examples](https://github.com/embabel/embabel-agent-examples/issues), [coding-agent](https://github.com/embabel/coding-agent/issues), [menkelabs/embabel-agent-rag-sample](https://github.com/menkelabs/embabel-agent-rag-sample/issues), etc.
- **Session:** Open issue → clone repo if needed → in Cursor: “Implement/fix [issue title]. Context: [issue URL].” → Close issue.
- **Effort:** Only add S (15–30 min) or M (30–60 min) so they’re realistic buffer work and help you use the full $400.

---

## Link back

- **Project list and %:** [../projects.md](../projects.md)  
- **This month’s plan:** [../plans/](../plans/) (e.g. `2026-02.md`)  
- **Embabel low-effort issues:** [../embabel-low-effort-issues.md](../embabel-low-effort-issues.md)
