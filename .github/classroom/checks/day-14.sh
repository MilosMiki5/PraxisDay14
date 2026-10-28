#!/bin/bash
# PRAXIS Tag 14 — Container Teil 2: automatisierter Container-Build (CI).
# Registry-Push und Deployment gehören seit der Kürzung zum Projekt.
# Geprüft wird das Wurzel-Verzeichnis: die Workflows liegen in
# .github/workflows/ — genau dort, wo GitHub Actions sie ausführt.
source .github/classroom/grade.sh

solution_for_id() {
  case "$1" in
    app) echo "Lege app.py und requirements.txt im Wurzel-Verzeichnis an" ;;
    dockerfile) echo "Lege das Dockerfile im Wurzel-Verzeichnis an" ;;
    ci-workflow) echo "Lege .github/workflows/aufgabe1.yml an" ;;
    ci-trigger) echo "Starte den Workflow bei jedem Push (on: push)" ;;
    ci-build) echo "Baue das Image mit docker/build-push-action oder 'docker build'" ;;
    ci-load) echo "Setze 'load: true' in docker/build-push-action, sonst findet 'docker run' das Image nicht" ;;
    ci-test) echo "Starte den Container mit 'docker run' und prüfe die Antwort mit 'curl'" ;;
    praxis-doku) echo "Lege DOKUMENTATION.md im Wurzel-Verzeichnis an und beantworte die drei Fragen (mind. 80 Wörter)" ;;
    *) echo "Überprüfe die Aufgabenstellung im README" ;;
  esac
}

echo "🔍 Prüfe Abnahmekriterien für Tag 14 Praxis — Automatisierter Container-Build mit GitHub Actions"
echo ""

WF=.github/workflows
DOKU=DOKUMENTATION.md

# classroom.yml gehört zur Bewertung und darf kein Kriterium erfüllen.
all_wf() { ls $WF/*.yml $WF/*.yaml 2>/dev/null | grep -v '/classroom\.yml$'; }
ALL="$(all_wf | tr '\n' ' ')/dev/null"

echo "── Anwendung ──"

check "app" \
  "Anwendung vorhanden (app.py und requirements.txt im Wurzel-Verzeichnis)" \
  "[ -f app.py ] && [ -f requirements.txt ]"

check_file_exists "dockerfile" \
  "Dockerfile vorhanden (Wurzel-Verzeichnis)" \
  "Dockerfile"

echo ""
echo "── CI-Workflow ──"

check "ci-workflow" \
  "Workflow vorhanden (.github/workflows/)" \
  "all_wf | grep -q ."

check "ci-trigger" \
  "Workflow startet bei jedem Push (on: push)" \
  "grep -qE '^[[:space:]]*push:|^on:[[:space:]]*\[?[[:space:]]*push' $ALL"

check "ci-build" \
  "Container-Image wird im Workflow gebaut" \
  "grep -qiE 'docker/build-push-action|docker build|buildx build' $ALL"

check "ci-load" \
  "Gebautes Image steht für den Test bereit (load: true oder docker build)" \
  "grep -qE 'load:[[:space:]]*true|docker build' $ALL"

check "ci-test" \
  "Container wird gestartet und per HTTP getestet (docker run + curl)" \
  "grep -q 'docker run' $ALL && grep -qE 'curl[[:space:]]' $ALL"

echo ""
echo "── Dokumentation ──"

check_file_exists "praxis-doku" \
  "Doku: DOKUMENTATION.md vorhanden" \
  "$DOKU"

check "praxis-doku" \
  "Doku: DOKUMENTATION.md hat ausreichend Inhalt (mind. 80 Wörter)" \
  "[ \$(wc -w < $DOKU 2>/dev/null) -ge 80 ]"

summary 14
