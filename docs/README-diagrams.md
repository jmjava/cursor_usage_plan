# Flow diagrams (PlantUML)

Diagrams in this folder describe the Cursor usage plan flow.

| File | Description |
|------|--------------|
| **flow-overview.puml** | Activity: input (CSV) → usage remaining → allocation (projects.md) → period plan (plans/YYYY-MM.md) → optional Embabel. |
| **flow-commands.puml** | Sequence: RUNBOOK command flow (import → usage-remaining → estimate-plan → estimate-budget / what-if). |
| **flow-two-docs.puml** | Components: how **projects.md** (allocation) and **plans/YYYY-MM.md** (period plan) work together and which scripts use them. |

## Export PNG (project JAR — no system install)

From the repo root, use the JAR in the project (recommended):

```bash
# One-time: download PlantUML JAR into lib/ (requires curl and java)
./scripts/download-plantuml.sh

# Generate PNGs from docs/*.puml
./scripts/export-puml-png.sh
```

The JAR is stored in **lib/plantuml.jar** (ignored by git). No system PlantUML install needed.

**Alternatives:** Install `plantuml` (e.g. `apt install plantuml`) or set `PLANTUML_JAR`; or use VS Code PlantUML extension or plantuml.com to export PNG.

Or with a PlantUML JAR (if not using lib/):

```bash
export PLANTUML_JAR=/path/to/plantuml.jar
./scripts/export-puml-png.sh
```

Or open each `.puml` in VS Code with the [PlantUML extension](https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml) and export (Alt+D / “Export Current Diagram”).  
Or paste the contents into [plantuml.com/plantuml](https://www.plantuml.com/plantuml) and export PNG.

After export, PNGs appear next to the `.puml` files (e.g. `flow-overview.png`).
