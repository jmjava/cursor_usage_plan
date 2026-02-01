#!/usr/bin/env bash
# Download PlantUML JAR into lib/ for use by export-puml-png.sh.
# Requires: curl, java. Run once per machine (or when upgrading).
#
# Usage: ./scripts/download-plantuml.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
LIB="$SCRIPT_DIR/../lib"
mkdir -p "$LIB"

# Fixed version from Maven Central (stable)
PLANTUML_VERSION="${PLANTUML_VERSION:-1.2024.7}"
URL="https://repo1.maven.org/maven2/net/sourceforge/plantuml/plantuml/${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar"
JAR="$LIB/plantuml.jar"

if [ -f "$JAR" ]; then
  echo "Already present: $JAR (delete to re-download)"
  exit 0
fi

echo "Downloading PlantUML ${PLANTUML_VERSION} to $JAR ..."
curl -sSL -o "$JAR" "$URL"
echo "Done. Run ./scripts/export-puml-png.sh to generate PNGs from docs/*.puml"
