#!/bin/bash
# Gemeinsame Hilfsfunktionen für alle Check-Skripte mit detailliertem Feedback

PASS=0
FAIL=0

DAY_MARKER_FILE=".github/classroom/day"
CLASSROOM50_CONFIG=".classroom50.yaml"

# Liest die Tagesnummer aus einem String wie "day04", "tag4",
# "day_4_solution" oder "itcne-25-project-day04-mmuster".
# Der Praefix tag|day ist zwingend — sonst wuerde "itcne-25-project"
# als Tag 25 gelesen. Gibt die Nummer aus (Rueckgabewert 0) oder 1.
day_from_string() {
  local normalized
  normalized="$(echo "$1" | tr '[:upper:]' '[:lower:]')"

  if [[ "$normalized" =~ (tag|day)[_-]?0*([1-9][0-9]?)($|[^0-9]) ]]; then
    echo "${BASH_REMATCH[2]}"
    return 0
  fi

  return 1
}

resolve_day() {
  local day

  # 1. Expliziter Override (z. B. lokales Testen: CLASSROOM_DAY=4 bash ...)
  if [ -n "${CLASSROOM_DAY:-}" ]; then
    echo "${CLASSROOM_DAY}"
    return 0
  fi

  # 2. Classroom-50-Konfiguration — in bereitgestellten Studierenden-Repos
  #    die verbindliche Quelle (assignment: "day04").
  if [ -f "$CLASSROOM50_CONFIG" ]; then
    local assignment
    assignment="$(sed -n 's/^[[:space:]]*assignment:[[:space:]]*//p' "$CLASSROOM50_CONFIG" | head -1)"
    if day="$(day_from_string "$assignment")"; then
      echo "$day"
      return 0
    fi
  fi

  # 3. Branch-Name (day_4_solution, tag04, tag13-ai-integration, ...)
  local ref="${GITHUB_REF_NAME:-${GITHUB_HEAD_REF:-${GITHUB_REF:-}}}"
  if [ -n "$ref" ] && day="$(day_from_string "$ref")"; then
    echo "$day"
    return 0
  fi

  # 4. Repository-Name — greift in Classroom-Repos, in denen die
  #    Studierenden direkt auf 'main' arbeiten und der Branch-Name
  #    keine Tag-Nummer enthaelt.
  if [ -n "${GITHUB_REPOSITORY:-}" ] && day="$(day_from_string "${GITHUB_REPOSITORY##*/}")"; then
    echo "$day"
    return 0
  fi

  # 5. Marker-Datei — manueller Override durch die Lehrperson.
  if [ -f "$DAY_MARKER_FILE" ]; then
    local marker
    marker="$(tr -cd '0-9' < "$DAY_MARKER_FILE")"
    if [ -n "$marker" ]; then
      echo "$((10#$marker))"
      return 0
    fi
  fi

  return 0
}

run_day_checks() {
  local day
  day="$(resolve_day)"

  if [ -z "$day" ]; then
    echo "⚠️ Keine Tag-Nummer erkannt (weder CLASSROOM_DAY, $CLASSROOM50_CONFIG, Branch-Name, Repository-Name noch $DAY_MARKER_FILE)."
    echo "::warning title=Keine Auswertung::Tag-Nummer nicht erkannt — es wurden KEINE Abnahmekriterien geprüft."
    return 0
  fi

  local check_file=".github/classroom/checks/day-${day}.sh"

  if [ ! -f "$check_file" ]; then
    echo "::notice title=Keine Checks::Für Tag $day sind keine Checks definiert"
    return 0
  fi

  # Die Ueberschrift kommt aus dem jeweiligen Check-Skript (mit Tagesthema).
  chmod +x "$check_file"
  bash "$check_file"
}

solution_for_id() {
  local id="$1"
  case "$id" in
    aws-setup)
      echo "Stelle sicher, dass .env mit AWS-Credentials vorhanden ist"
      ;;
    readme)
      echo "Erstelle README.md mit Dokumentation zur App"
      ;;
    git-ignore)
      echo "Erstelle .gitignore mit Python-Einträgen (__pycache__, .venv, .env)"
      ;;
    version)
      echo "Erstelle setup.py, setup.cfg oder pyproject.toml"
      ;;
    ci-workflow)
      echo "Erstelle .github/workflows/ci.yml mit Push-Trigger"
      ;;
    ci-trigger)
      echo "Konfiguriere im CI-Workflow einen Trigger: on: push (und pull_request)"
      ;;
    ci-branches)
      echo "Trigger auf die Branching-Strategie ausrichten: branches: [main, 'day_*']"
      ;;
    ci-dependencies)
      echo "Ergänze einen Schritt 'pip install -r requirements.txt' im CI-Workflow"
      ;;
    test-deps)
      echo "Ergänze pytest und pytest-mock in requirements.txt"
      ;;
    conftest)
      echo "Erstelle conftest.py im Projektstamm (fügt das Projektverzeichnis zum sys.path hinzu)"
      ;;
    test-files)
      echo "Erstelle tests/test_app.py und tests/integration/test_workflow.py (siehe Vorbereitung)"
      ;;
    linting)
      echo "Füge Linting-Schritt (flake8, pylint) im CI-Workflow hinzu"
      ;;
    lint-config)
      echo "Konfiguriere den Linter, z. B. flake8 tests/ conftest.py --max-line-length=100 --ignore=E302,W503"
      ;;
    lint-strict)
      echo "Entferne --exit-zero bzw. '|| true' — der Linter muss die Pipeline rot machen"
      ;;
    testing)
      echo "Füge Test-Schritt (pytest) im CI-Workflow hinzu"
      ;;
    pipeline-strict)
      echo "Entferne continue-on-error: true — die Pipeline muss bei Fehlern fehlschlagen"
      ;;
    cd-workflow)
      echo "Erstelle .github/workflows/deploy.yml für Deployment"
      ;;
    dockerfile)
      echo "Erstelle Dockerfile mit FROM, RUN, CMD Anweisungen"
      ;;
    security-scan)
      echo "Integriere Security-Scan (Snyk, Trivy) im Workflow"
      ;;
    k8s-manifests)
      echo "Erstelle k8s/deployment.yaml mit Kubernetes-Manifesten"
      ;;
    ai-integration)
      echo "Erstelle AI_INTEGRATION.md mit Reflexion (mind. 100 Wörter)"
      ;;
    helm-chart)
      echo "Erstelle helm/Chart.yaml mit Helm-Konfiguration"
      ;;
    security-workflow)
      echo "Erstelle .github/workflows/security-pipeline.yml mit einem jobs:-Block"
      ;;
    security-trigger)
      echo "Trigger ergänzen: on: push (main) und pull_request"
      ;;
    snyk-token)
      echo "Snyk-Token als GitHub Secret SNYK_TOKEN hinterlegen und als \${{ secrets.SNYK_TOKEN }} referenzieren"
      ;;
    snyk-sca)
      echo "Dependency-Scanning ergänzen: 'snyk test' bzw. die snyk/actions-Action"
      ;;
    snyk-sast)
      echo "Statische Code-Analyse ergänzen: 'snyk code test'"
      ;;
    severity-threshold)
      echo "Severity-Threshold setzen, z. B. --severity-threshold=high"
      ;;
    sarif-upload)
      echo "SARIF-Datei von Snyk erzeugen und mit github/codeql-action/upload-sarif hochladen"
      ;;
    security-doc)
      echo "Erstelle SECURITY.md mit den gefundenen Schwachstellen, Massnahmen und Behebungsplan (mind. 100 Wörter)"
      ;;
    deploy-workflow)
      echo "Erstelle einen Deployment-Workflow, z. B. .github/workflows/deployment.yml"
      ;;
    container-build)
      echo "Container-Build ergänzen: 'docker build' oder docker/build-push-action"
      ;;
    registry-push)
      echo "Image in die Registry pushen (AWS ECR), z. B. mit aws-actions/amazon-ecr-login"
      ;;
    aws-credentials)
      echo "AWS-Credentials als GitHub Secrets hinterlegen und aws-actions/configure-aws-credentials nutzen"
      ;;
    deploy-stage)
      echo "Deployment-Schritt auf die EC2-Instanz ergänzen (SSH + docker compose up)"
      ;;
    compose-file)
      echo "Erstelle docker-compose.yml für App- und Datenbank-Container"
      ;;
    deploy-doc)
      echo "Erstelle DEPLOYMENT.md mit Pipeline-Architektur und Bedienungsanleitung (mind. 100 Wörter)"
      ;;
    *)
      echo "Überprüfe die Anforderungen in der Dokumentation"
      ;;
  esac
}

# Schreibt ein Ergebnis nach $CLASSROOM_RESULTS (TSV: STATUS<TAB>Beschreibung),
# falls die Variable gesetzt ist. update_readme.py hakt damit die
# Abnahmekriterien im README ab. Die Datei wird beim ersten Check geleert,
# damit ein erneuter Lauf nicht anhaengt.
record_result() {
  [ -n "${CLASSROOM_RESULTS:-}" ] || return 0

  if [ -z "${_C50_RESULTS_INIT:-}" ]; then
    : > "$CLASSROOM_RESULTS"
    _C50_RESULTS_INIT=1
  fi

  printf '%s\t%s\n' "$1" "$2" >> "$CLASSROOM_RESULTS"
}

check() {
  local id="$1"
  local description="$2"
  local condition="$3"

  if eval "$condition" &>/dev/null; then
    echo "✅ $description"
    echo "::notice title=✅ $description::Check erfolgreich bestanden"
    record_result PASS "$description"
    PASS=$((PASS + 1))
  else
    echo "❌ $description"
    local solution
    solution="$(solution_for_id "$id")"
    echo "::error title=❌ $description::$solution"
    record_result FAIL "$description"
    FAIL=$((FAIL + 1))
  fi
}

check_file_exists() {
  local id="$1"
  local description="$2"
  local filepath="$3"
  check "$id" "$description" "[ -f '$filepath' ]"
}

check_file_contains() {
  local id="$1"
  local description="$2"
  local filepath="$3"
  local pattern="$4"
  check "$id" "$description" "grep -qiE '$pattern' '$filepath' 2>/dev/null"
}

check_workflow_exists() {
  local id="$1"
  local description="$2"
  local pattern="$3"
  # grep -q stellt sicher, dass ein leeres ls-Ergebnis auch wirklich fehlschlaegt
  check "$id" "$description" "ls -1 .github/workflows/$pattern 2>/dev/null | grep -q ."
}

check_directory_exists() {
  local id="$1"
  local description="$2"
  local dirpath="$3"
  check "$id" "$description" "[ -d '$dirpath' ]"
}

check_command_in_file() {
  local id="$1"
  local description="$2"
  local filepath="$3"
  local command="$4"
  check "$id" "$description" "grep -qE \"$command\" '$filepath' 2>/dev/null"
}

summary() {
  local day="$1"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📊 Tag $day — Zusammenfassung"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ Erfüllt:    $PASS Kriterien"
  echo "❌ Fehlen:     $FAIL Kriterien"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  if [ "$FAIL" -gt 0 ]; then
    echo ""
    echo "::error title=Tag $day nicht bestanden::$FAIL von $((PASS + FAIL)) Kriterien nicht erfüllt. Siehe Details oben."
    exit 1
  else
    echo ""
    echo "::notice title=✅ Tag $day bestanden::Gratuliere! Alle Kriterien erfüllt."
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run_day_checks "$@"
fi
