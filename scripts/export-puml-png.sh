#!/usr/bin/env bash
# Export PNG from PlantUML diagrams in docs/.
# Uses project JAR (lib/plantuml.jar) if present — run ./scripts/download-plantuml.sh once.
# Otherwise uses plantuml CLI or PLANTUML_JAR.
#
# Usage: ./scripts/export-puml-png.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
PLAN_DIR="$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)"
DOCS="$PLAN_DIR/docs"
LIB="$PLAN_DIR/lib"
JAR="$LIB/plantuml.jar"

cd "$DOCS"

run_plantuml() {
    if command -v java &>/dev/null; then
        java -jar "$1" -tpng *.puml 2>/dev/null && echo "Exported PNG from PUML." || true
    else
        echo "Java not found. Install Java or use the plantuml CLI." >&2
        return 1
    fi
}

if [ -f "$JAR" ]; then
    run_plantuml "$JAR"
elif command -v plantuml &>/dev/null; then
    plantuml -tpng *.puml 2>/dev/null && echo "Exported PNG from PUML (plantuml)." || true
elif [ -n "${PLANTUML_JAR:-}" ] && [ -f "$PLANTUML_JAR" ] && command -v java &>/dev/null; then
    run_plantuml "$PLANTUML_JAR"
else
    echo "No PlantUML found. Run once: ./scripts/download-plantuml.sh" >&2
    echo "  (downloads plantuml.jar to lib/; requires curl and java)" >&2
    echo "  Or install plantuml (apt install plantuml) or set PLANTUML_JAR." >&2
    exit 1
fi
