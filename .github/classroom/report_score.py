#!/usr/bin/env python3
"""Rechnet die Check-Ergebnisse in Teilpunkte um und gibt sie an den Reporter.

Die offizielle Action `classroom-resources/autograding-command-grader` kennt
nur bestanden/durchgefallen: ein einziger Test, der bei Exit-Code 0 die volle
Punktzahl gibt und sonst null. Damit haette ein Repo mit 12 von 13 erfuellten
Kriterien exakt so viele Punkte wie ein leeres.

`classroom-resources/autograding-grading-reporter` kann dagegen sehr wohl
Teilpunkte — es braucht nur ein Ergebnis mit MEHREREN Tests. Dieses Skript
baut genau das: es liest die von grade.sh geschriebene TSV-Datei
($CLASSROOM_RESULTS, Format "PASS|FAIL<TAB>Beschreibung") und erzeugt daraus
ein Ergebnis mit einem Test pro Abnahmekriterium.

**Ein Kriterium = ein Punkt.** Die Gesamtpunktzahl ist damit die Anzahl der
Kriterien des jeweiligen Tages, und die erreichte Punktzahl ist exakt die
Anzahl der erfuellten Kriterien ("Points 8/13"). Das deckt sich mit dem
Fortschrittsbalken, den update_readme.py ins README schreibt.

Bewusst NICHT auf 100 Punkte normiert: 100 laesst sich nicht ganzzahlig auf
13 Kriterien verteilen, und der Reporter addiert die Einzelpunkte. Jede
Restverteilung macht einzelne Kriterien mehr wert als andere — zwei Abgaben
mit gleich vielen erfuellten Kriterien haetten dann unterschiedlich viele
Punkte.

Der Gesamtstatus bleibt "fail", solange ein Kriterium offen ist: die Punkte
sind anteilig, der Auftrag gilt aber erst als bestanden, wenn alles erfuellt
ist.

Schreibt `result=<base64-json>` nach $GITHUB_OUTPUT (falls gesetzt), sonst
nach stdout. Exit-Code ist immer 0 — rot wird der Job ueber den Reporter.
"""

import base64
import json
import os
import sys

POINTS_PER_CRITERION = 1


def load_results(path):
    """[(bestanden, Beschreibung)] in der Reihenfolge der Pruefung."""
    results = []
    with open(path, encoding="utf-8") as fh:
        for line in fh:
            line = line.rstrip("\n")
            if not line:
                continue
            status, _, description = line.partition("\t")
            description = description.strip()
            if description:
                results.append((status.strip().upper() == "PASS", description))
    return results


def build_result(results):
    tests = [
        {
            "name": description,
            "status": "pass" if passed else "fail",
            "score": POINTS_PER_CRITERION if passed else 0,
            "message": "" if passed else "Kriterium nicht erfüllt",
            "test_code": "",
            "filename": "",
            "line_no": 0,
            "duration": 0,
        }
        for passed, description in results
    ]
    return {
        "version": 1,
        "status": "pass" if all(t["status"] == "pass" for t in tests) else "fail",
        "max_score": len(tests) * POINTS_PER_CRITERION,
        "tests": tests,
    }


def emit(name, value):
    target = os.environ.get("GITHUB_OUTPUT")
    if not target:
        print(f"{name}={value}")
        return
    with open(target, "a", encoding="utf-8") as fh:
        fh.write(f"{name}={value}\n")


def main():
    path = os.environ.get("CLASSROOM_RESULTS")
    if not path or not os.path.isfile(path):
        print("report_score: keine Ergebnisdatei ($CLASSROOM_RESULTS) — uebersprungen")
        return 0

    results = load_results(path)
    if not results:
        print("report_score: Ergebnisdatei leer — uebersprungen")
        return 0

    result = build_result(results)
    scored = sum(t["score"] for t in result["tests"])
    print(
        f"report_score: {scored}/{result['max_score']} Punkte "
        f"({scored} von {len(results)} Kriterien erfuellt)"
    )

    emit("result", base64.b64encode(json.dumps(result).encode("utf-8")).decode("ascii"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
