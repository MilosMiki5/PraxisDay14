# Tag 14 Praxis — Automatisierter Container-Build mit GitHub Actions

> **Praxisauftrag.** Dieses Repository ist dein Arbeitsplatz für die
> Praxis-Übung von Tag 14. Es enthält bewusst nur das Gerüst, jede Datei
> schreibst du selbst.

## Ausgangslage

Du baust eine CI-Pipeline für ein Container-Image: Bei jedem Push baut GitHub
Actions das Image, startet den Container und prüft per HTTP, ob die Anwendung
antwortet. Registry-Push (AWS ECR) und Deployment (AWS EC2) folgen danach im
Projekt am TechStyle-Shop.

## Ordnerstruktur

Alle Dateien gehören ins **Wurzel-Verzeichnis** dieses Repos bzw. in
`.github/workflows/`. Nur dort führt GitHub Actions Workflows aus. Lege keine
Unterordner an, die automatische Prüfung sucht die Dateien genau hier.

```
app.py                          # Flask-Anwendung, Port 8080
requirements.txt                # flask
Dockerfile
.github/workflows/aufgabe1.yml  # CI-Build mit Container-Test
DOKUMENTATION.md                # Antworten auf die drei Fragen
```

## Aufgabe

Die vollständige Schritt-für-Schritt-Anleitung mit allen Dateiinhalten steht
in der Tagesplanung von Tag 14.

1. Lege `app.py`, `requirements.txt` und das `Dockerfile` an.
2. Lege `.github/workflows/aufgabe1.yml` an. Der Workflow startet bei jedem
   Push auf `main`, baut das Image mit `docker/build-push-action` (mit
   `load: true`), startet den Container mit `docker run` und prüft die Antwort
   mit `curl`.
3. Pushe und beobachte den Lauf im Tab **Actions**, bis er grün ist.
4. Ändere den Antworttext in `app.py`, pushe und prüfe, dass der Lauf rot wird.
   Stelle den Text danach wieder her.
5. Beantworte in `DOKUMENTATION.md` (mind. 80 Wörter):
   - Welche Schritte führt die Pipeline aus, und in welcher Reihenfolge?
   - Warum ist `load: true` nötig?
   - Welche zwei Schritte fehlen noch bis zum laufenden Container in der Cloud?

## Abnahmekriterien

Diese Kriterien prüft die Pipeline bei jedem Push automatisch. **Die Haken
setzt die Pipeline selbst:** Ein erfülltes Kriterium wird abgehakt, und
sobald eine Änderung es wieder bricht, verschwindet der Haken. Du musst hier
nichts von Hand pflegen, beim nächsten Push wird die Liste überschrieben.

<!-- c50:progress -->
**Fortschritt: 0 / 9 Kriterien erfüllt** ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜ — Stand: 2026-10-25 22:53 UTC.
<!-- /c50:progress -->

- [ ] ⬜ Anwendung vorhanden (app.py und requirements.txt im Wurzel-Verzeichnis)
- [ ] ⬜ Dockerfile vorhanden (Wurzel-Verzeichnis)
- [ ] ⬜ Workflow vorhanden (.github/workflows/)
- [ ] ⬜ Workflow startet bei jedem Push (on: push)
- [ ] ⬜ Container-Image wird im Workflow gebaut
- [ ] ⬜ Gebautes Image steht für den Test bereit (load: true oder docker build)
- [ ] ⬜ Container wird gestartet und per HTTP getestet (docker run + curl)
- [ ] ⬜ Doku: DOKUMENTATION.md vorhanden
- [ ] ⬜ Doku: DOKUMENTATION.md hat ausreichend Inhalt (mind. 80 Wörter)

Zusätzlich manuell abgenommen (nicht automatisch geprüft):

- Ein Lauf «CI Build» ist grün
- Ein absichtlich kaputter Commit hat den Lauf rot gemacht

## Abnahmekriterien selber prüfen

**Lokal**, jederzeit und ohne Push:

```bash
bash .github/classroom/grade.sh
```

Das Skript liest die Tagesnummer aus `.classroom50.yaml`. Du kannst sie
auch erzwingen:

```bash
CLASSROOM_DAY=14 bash .github/classroom/grade.sh
```

Die Ausgabe listet jedes Kriterium mit ✅ oder ❌ und nennt bei jedem ❌
den konkreten Lösungshinweis. Sobald ein Kriterium fehlt, endet das
Skript mit Exit-Code 1.

**In GitHub**, bei jedem Push:

Der Workflow **🎓 Classroom Autograding** läuft automatisch und hakt die
erfüllten Kriterien oben im README ab. Ergebnis im Tab **Actions** →
letzter Run → Job *Abnahmekriterien prüfen*.

Die Punktzahl ist **anteilig**: Jedes erfüllte Abnahmekriterium zählt einen
Punkt (z. B. `Points 5/9`). Grün wird der Lauf erst, wenn alle Kriterien
erfüllt sind, Teilpunkte gibt es aber ab dem ersten.

## Musterlösung

Nach dem Unterricht findest du die Musterlösung im Repository
[`tbzdevops/musterloesungen-praxisauftraege`](https://github.com/tbzdevops/musterloesungen-praxisauftraege/tree/day_14_solution)
auf dem Branch `day_14_solution`.
