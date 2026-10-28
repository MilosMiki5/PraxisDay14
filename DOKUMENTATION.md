# Dokumentation – Tag 14: Automatisierter Container-Build mit GitHub Actions

## 1. Welche Schritte führt die Pipeline aus, und in welcher Reihenfolge?

Der Workflow `.github/workflows/aufgabe1.yml` startet bei jedem Push auf den Branch `main` und läuft auf einer frischen `ubuntu-latest`-Maschine. Die Schritte laufen nacheinander ab:

1. **Checkout** (`actions/checkout@v4`): Der Code des Repositorys wird auf den Runner geladen, damit `Dockerfile`, `app.py` und `requirements.txt` verfügbar sind.
2. **Docker Buildx einrichten** (`docker/setup-buildx-action@v3`): Buildx wird als Build-Werkzeug vorbereitet.
3. **Image bauen** (`docker/build-push-action@v6`): Aus dem `Dockerfile` wird das Image `hello-docker-ci:latest` gebaut. Es wird nicht in eine Registry gepusht (`push: false`), sondern lokal geladen (`load: true`).
4. **Container testen**: Der Container wird mit `docker run` im Hintergrund auf Port 8080 gestartet. Nach einer kurzen Wartezeit prüft `curl`, ob die Anwendung mit «Hello, World!» antwortet. Schlägt diese Prüfung fehl, wird der Workflow rot. Zum Schluss wird der Container mit `docker stop` gestoppt.

## 2. Warum ist `load: true` nötig?

Buildx baut Images standardmässig in einem eigenen Build-Container (Builder). Das fertige Image bleibt dort im Build-Cache und landet nicht automatisch im lokalen Image-Speicher des Docker-Daemons. Ohne `load: true` (und mit `push: false`) wäre das Image nach dem Build also nirgends abrufbar: `docker run hello-docker-ci:latest` würde mit einer Fehlermeldung abbrechen, weil Docker das Image nicht findet und versucht, es aus Docker Hub zu holen. `load: true` exportiert das gebaute Image in den lokalen Docker-Daemon des Runners, sodass der Testschritt es direkt starten kann.

## 3. Welche zwei Schritte fehlen noch bis zum laufenden Container in der Cloud?

1. **Push in eine Container-Registry**: Das getestete Image muss in eine Registry hochgeladen werden, zum Beispiel GitHub Container Registry (`ghcr.io`), Docker Hub oder Azure Container Registry. Dafür braucht es ein Login (`docker/login-action`) und `push: true` mit einem passenden Tag. Aktuell existiert das Image nur kurz auf dem Runner und ist nach dem Workflow wieder weg.
2. **Deployment in die Cloud**: Ein Cloud-Dienst (zum Beispiel Azure Container Apps, AWS ECS oder Google Cloud Run) muss das Image aus der Registry holen und als laufenden Container starten. Auch dieser Schritt kann automatisiert im Workflow erfolgen, etwa mit einer Deploy-Action des jeweiligen Anbieters.
